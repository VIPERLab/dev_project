#ifndef EQUALIZER_H
#define EQUALIZER_H

#include "memory.h"

//SAMPLE_FORMATµÄ¶¨Òå
enum
{
	SF_NULL   =0,
	SF_PCM16  =1, 
	SF_PCM24  =2, 
	SF_PCM32  =4, 
	SF_FLOAT32=8,

	SF_ALL     =SF_PCM16|SF_PCM24|SF_PCM32|SF_FLOAT32,
	SF_ALLINT  =SF_PCM16|SF_PCM24|SF_PCM32,
	SF_ALL_24  =SF_PCM16|SF_PCM32|SF_FLOAT32,

	SF_AC3     =16,
	SF_PCM8    =32,
	SF_LPCM16  =64,
	SF_LPCM20  =128,
	SF_FLOAT64 =65536,

	SF_ALLFLOAT=SF_FLOAT32|SF_FLOAT64
};

//static const float F[10];
//static const float Fwinamp[10];
const float F[10] = {31.25,62.5,125,250,500,1000,2000,4000,8000,16000};
const float Fwinamp[10]={60,170,310,600,1000,3000,6000,12000,14000,16000};

struct EqSettings{
	int f0,f1,f2,f3,f4,f5,f6,f7,f8,f9;
	int eq0,eq1,eq2,eq3,eq4,eq5,eq6,eq7,eq8,eq9;
	int lowdb,highdb;
	int bSuper;
};



class Equalizer{
private:
	static const double Q;
	static const int AF_NCH=6;
	static const int KM=10;
	float wq[AF_NCH][KM][2];      // Circular buffer for W data
	float g[AF_NCH][KM];
	float a[KM][2];               // A weights
	float b[KM][2];               // B weights
	int K;
	int oldsf;
	static void bp2(float* a, float* b, double fc, double q);
	float equalize(const float *g, short in, unsigned int ci);
	EqSettings * m_cfg;
public:
	Equalizer();
	Equalizer(EqSettings * cfg);
	~Equalizer();
	void init(double freq);
	void reset(void)
	{
		memset(wq,0,sizeof(wq));
	}  
	void process(short *samples,size_t numsamples,unsigned int nchannels);
	void process(int samp_freq, int sf, int nchannels, void *samples,size_t numsamples, bool bCfgChanged);
	void onSeek(void);
};
#endif