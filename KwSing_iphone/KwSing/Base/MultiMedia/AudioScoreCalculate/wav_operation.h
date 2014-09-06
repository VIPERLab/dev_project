#ifndef WAV_OPERATION_H
#define WAV_OPERATION_H
#include "pcm_wav_header.h"

//#include "afxtempl.h"

#define SAMPLING_RATE (16000)
#define PITCH_MAX_PERIOD (40)   //ms
#define PITCH_MIN_PERIOD (2)    //ms

#define ENV_FRAME_LEN (200)//(ms)
#define ENV_FRAME_STEP (100)//(ms)

#define SPEC_FRAME_LEN (20) //ms
#define SPEC_FRAME_STEP (10) //ms

//记录一句歌的信息的数据结构，不包含包络特征的信息
struct SINGING_SEGMENT
{
	SINGING_SEGMENT()
	{
		spec_fea = NULL;
		lyric = NULL;
	}
	int begin;			//开始时间（毫秒）
	int end;			//结束时间（毫秒）
	double * spec_fea;	//原唱频谱特征
	int spec_fea_len;	//原唱频谱特征的长度（一共有多少个double型的数据）
	int score;			//该句的得分
	char * lyric;		//该句的歌词
};

double ComputeScore(double * originalEnv, double * userEnv, int len);
double ComputeScore1(double * env1, double * env2, int len);
int SpectralFeature(double * & fea, short * pWav, int len, double & spr);
double ComputeTotalScore(double env_score, double spec_score, double spr);
double MPEG7_GetCentroid(double * pwr, int len);
#endif