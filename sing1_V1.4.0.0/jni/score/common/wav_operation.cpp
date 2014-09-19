//#include "stdafx.h"
#include "wav_operation.h"
#include "pcm_wav_header.h"
//#include "mmsystem.h"
#include "math.h"
#include "fft.h"
#include "string.h"

#ifndef WAVE_FORMAT_PCM
	#define WAVE_FORMAT_PCM (1)
#endif

#define MONO_CHANNEL (1)

double ComputeScore(double * originalEnv, double * userEnv, int len)
{
	int nDiff = 0;
	for(int i = 0; i < len - 1; i ++)
	{
		double temp1 = originalEnv[i + 1] - originalEnv[i];
		double temp2 = userEnv[i + 1] - userEnv[i];
		if(temp1 * temp2 < -1e-10)
			nDiff ++;
	}
	return 100 - (double)nDiff / len * 100;
}

double ComputeScore1(double * env1, double * env2, int len)
{
	double r1 = 0, r2 = 0;
	double cor = 0.;
	for(int i = 0; i < len; i ++)
	{
		r1 += env1[i] * env1[i];
		r2 += env2[i] * env2[i];
		cor += env1[i] * env2[i];
	}
	double temp = sqrt(r1 * r2);
	if(temp > 1e-6)
		return cor / temp;
	else
		return 0.;
}

double ComputeTotalScore(double env_score, double spec_score, double spr)
{
	return 0.2 * env_score + 0.8 * spec_score;
//	return 0.;
}

#define FREQ_RESOLUTION (15.625) //16000 / 1024
#define log2e (1.4426950408889634074)
double MPEG7_GetCentroid(double * pwr, int len)
{
	int nLow = 4;	//62.5 / FREQ_RESOLUTION;
	double dPwr = 0.;
	for(int i = 0; i <= nLow; i ++)
	{
		dPwr += pwr[i];
	}
	double temp = dPwr * 2/*log(31.25 / 1000) * log2e*/;
	for(int i = nLow + 1; i < len; i ++)
	{
		temp += pwr[i] * i/*log(i * FREQ_RESOLUTION / 1000.) * log2e*/;
		dPwr += pwr[i];
	}
	if(fabs(dPwr) > 1e-6)
		return temp / dPwr;
	else
		return 0.;
}

double MPEG7_GetSpread(double * pwr, int len, double cen)
{
	int nLow = (int)(62.5 / FREQ_RESOLUTION);
	double dPwr = 0.;
	for(int i = 0; i <= nLow; i ++)
	{
		dPwr += pwr[i];
	}
	double temp = dPwr * (2 - cen) * (2 - cen);
	for(int i = nLow + 1; i < len; i ++)
	{
		temp += pwr[i] * pow(i - cen, 2);
		dPwr += pwr[i];
	}
	return sqrt(temp / dPwr);
}

#define SUBBAND_NUM 7
int subband_edge[SUBBAND_NUM + 1]= {4, 8, 16, 32, 64, 128, 256, 512};
void GetFlatness(double * pwr, double * flat)
{
	for(int i = 0; i < SUBBAND_NUM; i ++)
	{
		double gm = 1., am = 0.;
		for(int j = subband_edge[i]; j < subband_edge[i + 1]; j ++)
		{
			if(pwr[j] > 1e-6)
			{
				gm += log(pwr[j]);
				am += pwr[j];
			}
		}
		if(am < 1e-6)
		{
			flat[i] = 1.;
			continue;
		}
		gm /= (subband_edge[i + 1] - subband_edge[i]);
		gm = exp(gm);
		am /= (subband_edge[i + 1] - subband_edge[i]);
		flat[i] = gm / am;
	//	if(flat[i] > 1e10 || flat[i] < 1e-10)
			//printf("Wrong");
	}
}

#define LOW_FQ (2000)	//0-2000HzÎªµÍÆµ¶Î
#define HI_FQ (4000)    //2000-4000HzÎª¸ßÆµ¶Î

double SPR(double * spec, int num)
{
	double total_pwr = 0.;
	double max_high = 0;
	double max_low = 0;
	for(int i = 0; i < num; i ++)
	{
		total_pwr += spec[i];
	}
	static int low_pos =  LOW_FQ * num * 2 / SAMPLING_RATE;
	static int hi_pos = HI_FQ * num * 2 / SAMPLING_RATE;
	for(int i = 4; i < low_pos; i ++)
	{
		if(spec[i] > max_low)
			max_low = spec[i];
	}
	for(int i = low_pos + 1; i < hi_pos; i ++)
	{
		if(spec[i] > max_high)
			max_high = spec[i];
	}
	return 10 * log10(max_low / max_high);
}

int SpectralFeature(double * & fea, short * pWav, int len, double & spr)
{
	int nFrameLen = SAMPLING_RATE * SPEC_FRAME_LEN / 1000;
	int nFrameStep = SAMPLING_RATE * SPEC_FRAME_STEP / 1000;
	int N = 1024;
	int nFrameCount = (len - nFrameLen) / nFrameStep + 1;
	double * pwr = new double[N];
	double * win = new double[N];
	HammingWin(win, N);
	double * sig_real = new double[N];
	double * sig_imag = new double[N];
	double * pwr_real = new double[N];
	double * pwr_imag = new double[N];
	fea = new double[N];
	double * frame_spr = new double[nFrameCount];
	double maxfea = 0.;
	for(int i = 0; i < nFrameCount; i ++)
	{
		memset(pwr, 0, sizeof(double) * N);
		for(int j = 0; j < nFrameLen; j ++)
		{
			pwr[j] = pWav[i * nFrameStep + j];
		}
		///////////////////////////////////////////////////////////////////////////////////////////
		double avg_pwr = 0.;
		for(int j = 0; j < nFrameLen; j ++)
		{
			avg_pwr += fabs(pwr[j]);
		}
		avg_pwr /= nFrameLen;
		if(avg_pwr < 300)
		{
			fea[i] = 0.;
			continue;
		}
		///////////////////////////////////////////////////////////////////////////////////////////
		ApplyWindow(pwr, win, N, pwr);
		for(int j = 0; j < N; j ++)
		{
			sig_real[j] = pwr[j];
			sig_imag[j] = 0;
		}
		fft_double(N, 0, sig_real, sig_imag, pwr_real, pwr_imag);
		for(int j = 0; j < N / 2; j ++)
		{
			pwr[j] = pwr_real[j] * pwr_real[j] + pwr_imag[j] * pwr_imag[j];
		}
		fea[i] = MPEG7_GetCentroid(pwr, N / 2);
		frame_spr[i] = SPR(pwr, N / 2) /** fea[i]*//*+ 20 * (log(fea[i]) / log(2.))*/;
		//double centroid = MPEG7_GetCentroid(pwr, N / 2);
		//fea[i] = MPEG7_GetSpread(pwr, N / 2, centroid);
		//GetFlatness(pwr, &fea[i]);
		if(fea[i] > maxfea)
			maxfea = fea[i];
	}
	spr = 0.;
	int nValidSPRNum = 0;
	for(int i = 0; i < nFrameCount; i ++)
	{
		fea[i] /= maxfea;
		if(fea[i] < 0.3 && fea[i] > 1e-6)
		{
			spr += frame_spr[i];
			nValidSPRNum ++;
		}
	}
	spr /= nValidSPRNum;
	delete[] sig_real; delete[] sig_imag;
	delete[] pwr_real; delete[] pwr_imag;
	delete[] pwr;	delete[] win;
	return nFrameCount;
}

/*
int ScoringFeature(double * & env_fea, double * & spec_fea, short * pWav, int len, double & spr)
{
	int fea_len = WavEnvelope(env_fea, pWav, len);
	fea_len = SpectralFeature(spec_fea, pWav, len, spr);
	return fea_len;
}
*/