#include "equalizer.h"
#include "math.h"
#include "equalizer.h"

//#define M_PI       3.14159265358979323846

const double Equalizer::Q=1.2247449; // Q value for band-pass filters 1.2247=(3/2)^(1/2) gives 4dB suppression @ Fc*2 and Fc/2


static inline float db2value(float db) {return powf(10.0f,db/20.0f);}
static inline float db2value(float db,int mul) {return powf(10.0f,db/(mul*20.0f));}

Equalizer::Equalizer()
{
	m_cfg = 0;
}

Equalizer::Equalizer(EqSettings * cfg)
{
	m_cfg = cfg;
}

Equalizer::~Equalizer()
{
//	if(m_cfg)
//		delete m_cfg;
}

void Equalizer::bp2(float* a, float* b, double fc, double q)
{
	double th=2*M_PI*fc;
	double C=(1-tan(th*q/2))/(1+tan(th*q/2));
	static const double bp2mult=1;

	a[0]=float(bp2mult*(1+C)*cos(th));
	a[1]=float(bp2mult*-1*C);

	b[0]=float(bp2mult*(1.0-C)/2.0);
	b[1]=float(bp2mult*-1.0050);
}
void Equalizer::init(double freq)
{
	reset();
	static const double qmult=1;
	for(int i=0;i<AF_NCH;i++)
		for(int j=0;j<KM;j++)
		{
			float db=(m_cfg->highdb-m_cfg->lowdb)*(&m_cfg->eq0)[j]/200.0f+m_cfg->lowdb;
			g[i][j]=(float)(qmult*( db2value(db,100)/* pow(10.0,db/(100*20.0))*/ -1.0));
		}
		K=KM;
		while (((&m_cfg->f0)[K-1]/100.0)>freq/2.3)
			K--;
		for (int k=0;k<K;k++)
			bp2(a[k],b[k],((&m_cfg->f0)[k]/100.0)/freq,Q);
}
float Equalizer::equalize(const float *g,short in,unsigned int ci)
{
	float yt=(float)in;
	for (int k=0;k<K;k++)
	{
		float *wq = this->wq[ci][k];
		float w=yt*b[k][0] + wq[0]*a[k][0] + wq[1]*a[k][1];
		yt+=(w + wq[1]*b[k][1])*g[k];
		wq[1] = wq[0];
		wq[0] = w;
	}
	return yt; 
}  
void Equalizer::process(short *samples,size_t numsamples,unsigned int nchannels)
{
	unsigned int ci=nchannels;
	while (ci--)
	{
		const float *g=this->g[ci];
		short *inout=samples+ ci;
		short *end=inout+nchannels*numsamples;
		while (inout<end)
		{
			float yt=equalize(g,*inout,ci);
//			*inout=TsampleFormatInfo<sample_t>::limit(yt);
//			*inout = yt < -32768 ? -32768 : yt;
//			*inout = yt > 32767 ? 32767 : yt;
			if(yt < -32768)
				*inout = -32768;
			else if(yt > 32767)
				*inout = 32767;
			else
				*inout = (short)yt;
			inout+=nchannels;
		}
	}
}

void Equalizer::process(int samp_freq, int sf, int nchannels, void *samples,size_t numsamples,bool bCfgChanged)
{
//	const EqSettings *cfg=(const EqSettings*)cfg0;

//	samples=init(cfg,fmt,samples,numsamples);	//估计是得到format的信息
	//如果配置文件改变，则init
	//if (!cfg->equal(old))
	//{
	//	old=*cfg;
	//	eq.init(cfg,fmt.freq);
	//}
	if(m_cfg == 0 ||bCfgChanged)
	{
//		m_cfg = (EqSettings *)cfg;
		init(samp_freq);
	}
	if (oldsf!=sf)
	{
		oldsf=sf;
		reset();
	} 

	switch (sf)
	{
	case SF_PCM16:process((short int*)samples,numsamples,nchannels);break;
//	case SF_PCM32:process((int*)samples,numsamples,nchannels);break;
//	case SF_FLOAT32:process((float*)samples,numsamples,nchannels);break;
	}
	//往下一个filter传递数据
//	return parent->deliverSamples(++it,fmt,samples,numsamples);
}

void Equalizer::onSeek(void)
{
	reset();
}

