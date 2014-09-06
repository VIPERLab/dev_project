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

//��¼һ������Ϣ�����ݽṹ��������������������Ϣ
struct SINGING_SEGMENT
{
	SINGING_SEGMENT()
	{
		spec_fea = NULL;
		lyric = NULL;
	}
	int begin;			//��ʼʱ�䣨���룩
	int end;			//����ʱ�䣨���룩
	double * spec_fea;	//ԭ��Ƶ������
	int spec_fea_len;	//ԭ��Ƶ�������ĳ��ȣ�һ���ж��ٸ�double�͵����ݣ�
	int score;			//�þ�ĵ÷�
	char * lyric;		//�þ�ĸ��
};

double ComputeScore(double * originalEnv, double * userEnv, int len);
double ComputeScore1(double * env1, double * env2, int len);
int SpectralFeature(double * & fea, short * pWav, int len, double & spr);
double ComputeTotalScore(double env_score, double spec_score, double spr);
double MPEG7_GetCentroid(double * pwr, int len);
#endif