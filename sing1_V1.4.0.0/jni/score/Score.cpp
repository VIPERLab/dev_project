#include "Score.h"
#include <math.h>
#include <android/log.h>
#include "stdio.h"

#define LOG_TAG "Score cpp"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)


#define RECORD_CHANEL_NUM (2)

#define POPULARITY_START_POINT (70)		//��ʼ������ֵ��������
#define MAX_LOG_SINGING_ENV (9)			//�Գ���������������ֵΪ 10 ^ 9
#define TOO_LOUD_TH1 (8.47)				//�û����������������ֵ:log10(3 * 10 ^8)
#define TOO_LOUD_TH2 (8.3)				//�û�����������Щ�죺log10(2 * 10^8)
#define TOO_SILENT_TH1 (5.78)			//�û������������ڰ�������ֵ1�� log10(6 * 10^5)
#define TOO_SILENT_TH2 (6)				//�û������������ڰ�������ֵ2�� log10(1 * 10^6)
#define CENTROID_LOW_TH1 (10)			//Ƶ����������͵���ֵ�����������ֵ����ʾ�質���п���û�г������ߺ��п����ںߺ�
#define CENTROID_LOW_TH2 (15)			//Ƶ���������ӵͣ����������ֵʱ�������ʵ��ĳͷ�
#define MAX_SCORE (100)					//������



CScore::CScore(void)
{
	m_nCurrentSingerEnvNum = 0;
	m_fArtistEnvNormRatio = 0;
	//m_sb = 0;
}

CScore::~CScore(void)
{
}

void CScore::OnWavNewDataComing( short * pWavData, int nLen )
{
	//LOGI("data comming in");

	if (pWavData == NULL) return;

	if(m_nCurrentSingerEnvNum > m_nEnvLen - 1){
		//LOGI("data comming out 1");
		return;
	}
	

	//�����µ�һ֡�İ���ֵ
	m_RecordWavBuf.add(pWavData, nLen);
	int nFrameLen = ENV_FRAME_LEN * m_nRecSampleRate / 1000 * RECORD_CHANEL_NUM;
	int nFrameStep = ENV_FRAME_STEP * m_nRecSampleRate / 1000 * RECORD_CHANEL_NUM;

	while(m_RecordWavBuf.get_data_len() > nFrameLen)
	{

		if(m_nCurrentSingerEnvNum > m_nEnvLen - 1){
			//LOGI("data comming out 2");
			return;
		}
			

		short * out = new short[nFrameLen];

		m_RecordWavBuf.get_from_head(out, nFrameLen);
		double temp_env = 0.;
		for (int i = 0; i < nFrameLen; i += RECORD_CHANEL_NUM)
		{
			double frame_amp = 0.;

			for(int j = i; j < i + RECORD_CHANEL_NUM; j ++)
			{
				frame_amp += out[i];
			}

			frame_amp /= RECORD_CHANEL_NUM;
			temp_env += frame_amp * frame_amp;
		}
		

		temp_env /= (nFrameLen / RECORD_CHANEL_NUM);


		m_pdbSingerEnvData[m_nCurrentSingerEnvNum] = (temp_env > 1 ? log10(temp_env) : 0.) / MAX_LOG_SINGING_ENV; 

		m_RecordWavBuf.remove_from_head(out, nFrameStep);
		delete[] out;
		m_nCurrentSingerEnvNum ++;
		
	}
	
	//LOGI("data comming out");

	//logtime("after while");
	
	//����wav���ݣ��û�������������Ƶ�׵ȹ���
	
	
	//if( m_sb )
	//	m_sb->feed_data(pWavData, nLen);
	
	//logtime("after feed_data");
}

void CScore::SentenceStart( double * pdbSpec, int nSpecLen, double * pdbEnv, int nEnvLen)
{

	LOGI("SentenceStart in");
	if(pdbSpec == NULL || pdbEnv == NULL) return;

	//copy the spec and env data
	m_pdbArtistSpecData = new double[nSpecLen];
	m_pdbArtistEnvData = new double[nEnvLen];
	m_pdbSingerEnvData = new double[nEnvLen];
	memcpy(m_pdbArtistEnvData, pdbEnv, nEnvLen * sizeof(double));
	memcpy(m_pdbArtistSpecData, pdbSpec, nSpecLen * sizeof(double));
	memset(m_pdbSingerEnvData, 0, nEnvLen * sizeof(double));
	m_nEnvLen = nEnvLen;
	m_nSpecLen = nSpecLen;

// 	char buffer[32];
// 	for(int i = 0; i<nEnvLen; i++){
// 		sprintf(buffer, "%f", pdbEnv[i]);
// 		LOGI(buffer);
// 	}


	//����һ���µļ���Ƶ��������buffer

	/*
	if (m_sb)
	{
		delete m_sb;
		m_sb = NULL;
	}

	m_sb = new spectral_buf(
		(int)( nEnvLen * 100 * (m_nRecSampleRate / 1000.) * RECORD_CHANEL_NUM ), //�þ�����ԭʼwav����
		m_nRecSampleRate,	//������
		DOWN_SAMPLERATE,	//����Ƶ�׵Ľ�����Ƶ��
		RECORD_CHANEL_NUM,  //����
		nSpecLen);			//�þ�Ƶ�׳���
	
	*/
	LOGI("SentenceStart out");
}

int CScore::SentenceEnd()
{
	LOGI("sentence end in");
	int nScore = GetSentenceScore();
	
	//if(m_sb)
	{
	//	nScore = GetSentenceScore();
		//delete m_sb;
		//m_sb = NULL;
	}
	
	//LOGI("sentence end in");
	
	//LOGI("sentence end in 1");
	if(m_pdbArtistEnvData){
		delete [] m_pdbArtistEnvData;
		m_pdbArtistEnvData = NULL;
	}
	//LOGI("sentence end in 2");
	if(m_pdbArtistSpecData){
		delete [] m_pdbArtistSpecData;
		m_pdbArtistSpecData = NULL;
	}
	//LOGI("sentence end in 3");
	if(m_pdbSingerEnvData){
		delete [] m_pdbSingerEnvData;
		m_pdbSingerEnvData = NULL;
	}
	//LOGI("sentence end out");
	m_nCurrentSingerEnvNum = 0;

	char scoreBuffer[32];
	sprintf(scoreBuffer, "final score is %d", nScore);
	LOGI(scoreBuffer);

	return nScore;
}

int CScore::GetSentenceScore()
{
	LOGI("getSentenceScore in");
	//�ҵ���һ�ΰ����������ֵ�����¹�һ��
	double fAvgSingerEnv = 0.;		//��һ���û��ݳ������ƽ��ֵ���������һ����ֵ������Ϊ̫���ˣ����ؼ���
	double fPunishCoef = 1.0;		//�������ز��õĵط��Ĵ�ֱ�׼
	double fEnvPunish = 1.0;
	double fSpecPunish = 1.0;


	for(int i = 0; i < m_nEnvLen; i ++)
	{
		m_pdbSingerEnvData[i] *= MAX_LOG_SINGING_ENV;
		fAvgSingerEnv += m_pdbSingerEnvData[i];
		m_pdbArtistEnvData[i] *= m_fArtistEnvNormRatio;
	}

	
	//LOGI("getSentenceScore 1");
	if(m_nEnvLen > 0)
		fAvgSingerEnv /= (m_nEnvLen);

	if(fAvgSingerEnv > TOO_LOUD_TH1 || fAvgSingerEnv < TOO_SILENT_TH1)	//̫���˻���̫������
	{
		//��һ����ֵĳͷ�ϵ��
		fPunishCoef = 0.3;
	}
	else if(fAvgSingerEnv > TOO_LOUD_TH2 || fAvgSingerEnv < TOO_SILENT_TH2)	//��Щ�������Щ����
	{
		fEnvPunish = 0.5;
	}

	//LOGI("getSentenceScore  2");
	for(int i = 0; i < m_nEnvLen; i ++)
	{
		m_pdbSingerEnvData[i] = pow(10., m_pdbSingerEnvData[i]);
		m_pdbArtistEnvData[i] = pow(10., m_pdbArtistEnvData[i]);
	}

	//����÷�

	double fEnvScore = ComputeScore1(m_pdbSingerEnvData, m_pdbArtistEnvData, m_nEnvLen);


	/*
	int nSpecFeaLen = m_sb->m_nSpecFeaDoneNum < m_nSpecLen ? m_sb->m_nSpecFeaDoneNum : m_nSpecLen;
	//double * pArtistSpec = m_pdbArtistSpecData;
	//double * pSingerSpec = m_sb->m_pSpecFea;
	double fAvgSingerSpecFea = 0., fAvgArtistSpecFea = 0.;
	for(int i = 0; i < nSpecFeaLen; i ++)
	{
		fAvgSingerSpecFea += m_sb->m_pSpecFea[i];
		fAvgArtistSpecFea += m_pdbArtistSpecData[i];
	}

	if(nSpecFeaLen > 0)
	{
		fAvgSingerSpecFea /= nSpecFeaLen;
		fAvgArtistSpecFea /= nSpecFeaLen;
	}

	if(fAvgSingerSpecFea < CENTROID_LOW_TH1)
	{
		//��һ����ֵĳͷ�ϵ��
		if(fabs(fPunishCoef - 1) < 1e-6)
			fPunishCoef = 0.3;
		else
			fPunishCoef = 0.1;
	}
	else if(fAvgSingerSpecFea < CENTROID_LOW_TH2)
	{
		fSpecPunish = 0.7;
	}


	double fSpecScore = ComputeScore1(m_pdbArtistSpecData, m_sb->m_pSpecFea, nSpecFeaLen);	//Ƶ�����ĵ÷�

	//��������غ��������ֵ�������ԣ����ж��Ƿ�������
	double * acr = m_sb->m_pAcr;
	int nTotalVoicedLen = 0;
	for(int i = 0; i < nSpecFeaLen; i ++)
	{
		if(acr[i] > 0.5)
			nTotalVoicedLen ++;
	}

	if((double)nTotalVoicedLen / nSpecFeaLen < 0.1)	//��Ϊ������Ƭ��
	{
		fPunishCoef = 0.1;
	}

	//Ƶ�׵÷ֵ����Ŷȣ�����ȥ���ߺߵ�����
	double fKeyScore = fAvgSingerSpecFea > 70 ? 100 : (sqrt(fAvgSingerSpecFea / 70 * 100) * 10);	//���ߵ÷�
	
	*/
	//int ret =  (int)((sqrt((0.25 * fEnvScore * fEnvPunish + 0.5 * fSpecScore * fSpecPunish) * MAX_SCORE + fKeyScore * 0.25) * 10.)* fPunishCoef);
	int ret = (int)((sqrt((fEnvScore * fEnvPunish ) * MAX_SCORE) * 10.)* fPunishCoef);

	return ret;
}

void CScore::Init( int nRecWavSampleRate, int nChannel, double dbEnvRate )
{
	m_fArtistEnvNormRatio = dbEnvRate;
	m_nRecSampleRate = nRecWavSampleRate;
}


