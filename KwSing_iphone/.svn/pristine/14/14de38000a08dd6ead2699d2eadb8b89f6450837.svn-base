#include "SuperEqualizer.h"
#include "supereq.h"

#ifndef INT_MAX
#define INT_MAX (2147483647)
#endif

static inline float db2value(float db) {return powf(10.0f,db/20.0f);}
static inline float db2value(float db,int mul) {return powf(10.0f,db/(mul*20.0f));}

SuperEqualizer::SuperEqualizer()
{
//	old.eq0=INT_MAX;
	m_cfg = NULL;
	oldnchannels=0;
	memset(eqs,0,sizeof(eqs));
}

SuperEqualizer::SuperEqualizer(EqSettings * cfg)
{
	m_cfg = cfg;
	oldnchannels=0;
	memset(eqs,0,sizeof(eqs));
}

SuperEqualizer::~SuperEqualizer()
{
	for (int i=0;i<6;i++) if (eqs[i]) delete eqs[i];
}

float * SuperEqualizer::init(void * samples, int num)
{
	float * in_buf = new float[num];
	for(int i = 0; i < num; i ++)
		in_buf[i] = ((short *)samples)[i] / (float)32768.;
	return in_buf;
}

void SuperEqualizer::process(int samp_freq, int sf, unsigned int nchannels, void *samples,size_t &numsamples, bool bCfgChanged)
{
//	const TeqSettings *cfg=(const TeqSettings*)cfg0;
//	int tempsf = sf;
	if (!eqs[0] || oldnchannels!=/*fmt.*/nchannels || /*!cfg->equal(old)*/bCfgChanged)
	{
		//old=*cfg;
		oldnchannels=/*fmt.*/nchannels;
		float bands[supereq::NBANDS+1];
		for (unsigned int b=0;b<=supereq::NBANDS;b++)
		{
			float db=(m_cfg->highdb-m_cfg->lowdb)*(&m_cfg->eq0)[b]/200.0f+m_cfg->lowdb;
			bands[b]=db2value(db,100);// pow(10.0,db/(100*20.0));
		}
		for(unsigned int ch=0;ch</*fmt.*/nchannels;ch++)
		{
			if (eqs[ch]) delete eqs[ch];
			eqs[ch]=new supereq;
			eqs[ch]->equ_makeTable(bands,(float)samp_freq/*fmt.freq*/,&m_cfg->f0);
		}
	}

	float *in=(float*)init(samples, numsamples * nchannels)/*(cfg,fmt,samples,numsamples)*/,*out=NULL;
	int samples_out=0;
	for (unsigned int ch=0;ch</*fmt.*/nchannels;ch++)
	{
		eqs[ch]->write_samples(in+ch,(int)numsamples,/*fmt.*/nchannels);
		const float *eqout=eqs[ch]->get_output(&samples_out);
		if (!out) out=(float*)buf.alloc(samples_out * nchannels * sizeof(float));//alloc_buffer(fmt,samples_out,buf);
		for (int i=0;i<samples_out;i++)
			out[ch+i* /*fmt.*/nchannels]=eqout[i];
	}
	short * temp = (short *)samples;
	for(unsigned int i = 0; i < samples_out * nchannels; i ++)
	{
		int tmp = (int)(out[i] * 32767);
		if(tmp > 32767)
			temp[i] = 32767;
		else if(tmp < -32768)
			temp[i] = -32768;
		else
			temp[i] = (short)tmp;
	}
	delete[] in;
	numsamples = samples_out;
//	return parent->deliverSamples(++it,fmt,out,samples_out);
}

void SuperEqualizer::onSeek(void)
{
	for (int i=0;i<6;i++)
		if (eqs[i])
		{
			delete eqs[i];
			eqs[i]=NULL;
		}
}
