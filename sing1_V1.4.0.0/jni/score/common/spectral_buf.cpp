//#include "stdafx.h"

#include "string.h"
#include "spectral_buf.h"
#include "fft.h"
#include "math.h"
//#include "log.h"

//spectral_buf���ʵ��
spectral_buf::spectral_buf(int nLen, int in_sr, int out_sr, int in_chan_num, int spec_fea_num)
: m_nTraceNum(0)
{
	//ASSERT(nLen > 0);
	//ASSERT(in_sr > 0);
	//ASSERT(out_sr > 0);
	m_nWavInTotalLen = nLen;
	m_nInSR = in_sr;
	m_nOutSR = out_sr;
	m_nInWavChanNum = in_chan_num;
	m_pWavIn = new short[m_nWavInTotalLen];
	m_nFeedLen = 0;
	m_nResampleDoneLen = 0;
	initialize_resample();
	m_nSpecDoneLen = 0;		//�ѽ��й�������ȡ��wav����
	m_nSpecFeaCount = spec_fea_num;	//Ҫ����������ĸ���
	m_nSpecFeaDoneNum = 0;
	m_pSpecFea = new double[m_nSpecFeaCount];	//Ϊ������������ڴ�ռ�
	m_pAcr = new double[m_nSpecFeaCount];	
	m_win = new double[m_FFT_N];			//����FFT��ʹ�õĴ�����
	sig_real = new double[m_FFT_N];		//ʱ���źŵ�ʵ��
	sig_imag = new double[m_FFT_N];		//ʱ���źŵ��鲿
	pwr_real = new double[m_FFT_N];		//Ƶ���źŵ�ʵ��
	pwr_imag = new double[m_FFT_N];		//Ƶ���źŵ��鲿
	pwr = new double[m_FFT_N];			//�ź���Ƶ�������
	HammingWin(m_win, m_FFT_N);			//������ʹ�ú�����
}

spectral_buf::~spectral_buf()
{
	if (m_pWavIn)
	{
		delete[] m_pWavIn;
		m_pWavIn = NULL;
	}

	if (m_pResampleData)
	{
		delete[] m_pResampleData;
		m_pResampleData = NULL;
	}

	if (m_srcInput)
	{
		delete[] m_srcInput;
		m_srcInput = NULL;
	}

	if (m_srcOutput)
	{
		delete[] m_srcOutput;
		m_pWavIn = NULL;
	}

	if (m_pWavOut)
	{
		delete[] m_pWavOut;
		m_pWavOut = NULL;
	}

	if (m_pMonoWav)
	{
		delete[] m_pMonoWav;
		m_pMonoWav = NULL;
	}

	if (m_pSpecFea)
	{
		delete[] m_pSpecFea;
		m_pSpecFea = NULL;
	}

	if (m_pAcr)
	{
		delete[] m_pAcr;
		m_pAcr = NULL;
	}

	if (m_win)
	{
		delete[] m_win;
		m_win = NULL;
	}

	if (sig_real)
	{
		delete[] sig_real;
		sig_real = NULL;
	}

	if (sig_imag)
	{
		delete[] sig_imag;
		sig_imag = NULL;
	}

	if (pwr_real)
	{
		delete[] pwr_real;
		pwr_real = NULL;
	}

	if (pwr_imag)
	{
		delete[] pwr_imag;
		pwr_imag = NULL;
	}

	if (pwr)
	{
		delete[] pwr;
		pwr = NULL;
	}
	
	src_delete(m_srcState);
}

void spectral_buf::feed_data(short * pWav, int len)
{
//	logtime("feed_data in");
	if(m_nFeedLen >= m_nWavInTotalLen)	//�Ѿ�feed���㹻�������
		return;
	int feed_len = (len < m_nWavInTotalLen - m_nFeedLen ? len : m_nWavInTotalLen - m_nFeedLen);
	memcpy(&m_pWavIn[m_nFeedLen], pWav, sizeof(short) * feed_len);
	m_nFeedLen += feed_len;
	resample();
//	logtime("feed_data out");
}

void spectral_buf::initialize_resample()
{
	try
	{
		m_fRatio = (double)m_nOutSR / m_nInSR;
		int nBufFrameCount = m_nResampleBufLen / sizeof(short) / m_nInWavChanNum;	//�ز���buf���ܴ�ŵĵ������Ĳ�������
		m_pMonoWav = new short[nBufFrameCount];	//m_pMonoWav��������ز���֮ǰ�ĵ�������wav
		m_pResampleData = new char[m_nResampleBufLen];	//Ϊresample buffer����ռ�
		int nError = 0;
		m_srcState = src_new(SRC_LINEAR, 1, &nError);
		m_srcInput = new float[nBufFrameCount];
		m_srcOutput = new float[(m_fRatio > 1 ? (long)(nBufFrameCount * m_fRatio  + 100): nBufFrameCount)];
		int nInputSampleCount = m_nWavInTotalLen / m_nInWavChanNum;
		m_nWavOutTotalLen = m_fRatio > 1 ? (long)(nInputSampleCount * m_fRatio) + 100 : nInputSampleCount;
		m_pWavOut = new short[m_nWavOutTotalLen];
		m_srcData.end_of_input = 0;
		m_srcData.input_frames = 0;
		m_srcData.src_ratio = m_fRatio;
		m_srcData.data_in = m_srcInput;
		m_srcData.data_out = m_srcOutput;
		m_srcData.output_frames = m_nResampleBufLen;
		m_nResampleOutNum = 0;
	}
	catch (...)
	{
	}
}

bool spectral_buf::resample()
{
	//logtime("resample in");
	int nBufFrameCount = m_nResampleBufLen / sizeof(short) / m_nInWavChanNum;	//�ز���buf���ܴ�ŵĵ������Ĳ�������
	while(m_nFeedLen - m_nResampleDoneLen >= m_nResampleBufLen / sizeof(short)	//��feed�������ִչ���һ��m_nResampleBufLen�ĳ���
		|| m_nFeedLen == m_nWavInTotalLen)	//�Ѿ���ĩβ�ˣ���ʣ�µ����ݴ��������
	{
		//m_pMonoWav: ��������δ����������Ƶ
		memset(m_pMonoWav, 0, sizeof(short) * nBufFrameCount);
		int n = 0;
		int len = (m_nFeedLen == m_nWavInTotalLen ? (m_nFeedLen - m_nResampleDoneLen) * sizeof(short) : m_nResampleBufLen);
		if(len > m_nResampleBufLen)
			len = m_nResampleBufLen;
		m_srcData.end_of_input = (m_nFeedLen == m_nWavInTotalLen ? 1 : 0);
		//pData: ԭʼ��Ƶ
		memcpy(m_pResampleData, &m_pWavIn[m_nResampleDoneLen], len);
		//pBuf: ԭʼ��Ƶ
		short * pBuf = (short *)m_pResampleData;
		if(m_nInWavChanNum > 1)
		{
			//�ϲ�Ϊ������
			for(int i = 0; i < len / (signed)sizeof(short); i += m_nInWavChanNum)
			{
				int nTemp = 0;
				for(int j = i; j < i + m_nInWavChanNum; j ++)
				{
					nTemp += pBuf[j];
				}
				m_pMonoWav[n++] = nTemp / m_nInWavChanNum;
			}
		}
		else
		{
			memcpy(m_pMonoWav, pBuf, len);
		}
		if(m_nInSR != DOWN_SAMPLERATE)
		{
			m_srcData.input_frames = n;
			src_short_to_float_array(m_pMonoWav, m_srcInput, m_srcData.input_frames);
			int error;
			if((error = src_process(m_srcState, &m_srcData)))
			{
				return false;
			}
			src_float_to_short_array(m_srcData.data_out, m_pWavOut + m_nResampleOutNum, m_srcData.output_frames_gen);
			m_nResampleOutNum += m_srcData.output_frames_gen;
			m_nResampleDoneLen += len / sizeof(short);
		}
		else
		{
			memcpy(m_pWavOut + m_nResampleOutNum, m_pMonoWav, len);
			m_nResampleOutNum += len / sizeof(short);
			m_nResampleDoneLen += len / sizeof(short);
		}
		if(m_nResampleDoneLen == m_nWavInTotalLen)
			break;
	}
	//FILE * fp_temp = fopen("spec1.wav", "r+b");
	//short * pWav = &m_pWavOut[m_nResampleOutNum - nNewOutputNum];
	//fseek(fp_temp, 0, SEEK_END);
	//fwrite(pWav, sizeof(short), nNewOutputNum, fp_temp);
	//fclose(fp_temp);
	get_spec_fea();
	//logtime("resample out");
	return true;
}

void spectral_buf::get_spec_fea()
{
	//logtime("get_spec_fea in");
	int nFrameLen = SPEC_FRAME_LEN * DOWN_SAMPLERATE / 1000;
	int nFrameStep = SPEC_FRAME_STEP * DOWN_SAMPLERATE / 1000;
	//	FILE * fp_temp = fopen("spec.wav", "r+b");
	while((m_nResampleOutNum - m_nSpecDoneLen >= nFrameLen) && m_nSpecFeaDoneNum < m_nSpecFeaCount)
	{
		//logtime("1");
		short * pWav = &m_pWavOut[m_nSpecDoneLen];
		//		fseek(fp_temp, 0, SEEK_END);
		//		fwrite(pWav, sizeof(short), nFrameStep, fp_temp);
		memset(sig_real, 0, sizeof(double) * m_FFT_N);
		for(int j = 0; j < nFrameLen; j ++)
		{
			sig_real[j] = pWav[j];
		}
		//logtime("2");
		///////////////////////////////////////////////////////////////////////////////////////////
		double avg_pwr = 0.;
		for(int j = 0; j < nFrameLen; j ++)
		{
			avg_pwr += fabs(sig_real[j]);
		}
		avg_pwr /= nFrameLen;
		if(avg_pwr < 300)
		{
			m_pSpecFea[m_nSpecFeaDoneNum] = 0.;
			m_pAcr[m_nSpecFeaDoneNum ++] = 1.;
			m_nSpecDoneLen += nFrameStep;
			m_nTraceNum ++;
			continue;
		}
		//logtime("3");
		
		///////////////////////////////////////////////////////////////////////////////////////////
		ApplyWindow(sig_real, m_win, m_FFT_N, sig_real);
		memset(sig_imag, 0, sizeof(double) * m_FFT_N);
		//logtime("4");
		fft_double(m_FFT_N, 0, sig_real, sig_imag, pwr_real, pwr_imag);
		//logtime("5");
		for(int j = 0; j < m_FFT_N / 2; j ++)
		{
			pwr[j] = pwr_real[j] * pwr_real[j] + pwr_imag[j] * pwr_imag[j];
			pwr[m_FFT_N - j - 1] = pwr[j];
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//��������غ�������ÿһ֡����غ��������ֵ���жϵ�ǰ��һ�����Ҫ�ɷ��Ƿ�������
		memcpy(pwr_real, pwr, sizeof(double) * m_FFT_N);
		memset(pwr_imag, 0, sizeof(double) * m_FFT_N);
		//logtime("6");
		fft_double(m_FFT_N, 1, pwr_real, pwr_imag, sig_real, sig_imag);
		//logtime("7");
		if(fabs(sig_real[0]) < 1e-6)
		{
			memset(sig_real, 0, sizeof(double) * m_FFT_N);
		}
		else
		{
			for(int j = 1; j < m_FFT_N; j ++)
			{
				sig_real[j] /= sig_real[0];
			}
			sig_real[0] = 1.;
		}
		double max = -99999999;
		//		int nPos = 1;
		int nMaxPos = SAMPLING_RATE * PITCH_MAX_PERIOD / 1000;
		int nMinPos = SAMPLING_RATE * PITCH_MIN_PERIOD / 1000;
		for(int j = nMinPos; j < nMaxPos; j ++)
		{
			if(sig_real[j] > sig_real[j - 1] && sig_real[j] >= sig_real[j+1])
			{
				if(sig_real[j] > max)
				{
					max = sig_real[j];
					//					nPos = j;
				}
			}
		}
		m_pAcr[m_nSpecFeaDoneNum] = max;
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		m_pSpecFea[m_nSpecFeaDoneNum ++] = MPEG7_GetCentroid(pwr, m_FFT_N / 2);
		m_nSpecDoneLen += nFrameStep;
		//logtime("8");
	}

	//logtime("get_spec_fea out");
	//	fclose(fp_temp);
}