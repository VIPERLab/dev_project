#include "freeverb.h"
#include "memory.h"

freeverb::freeverb()
{
	m_rs = new RevSettings;
	m_rs->damp = initialdamp;
	m_rs->dry = initialdry;
	m_rs->mode = initialmode;
	m_rs->roomsize = initialroom;
	m_rs->wet = initialwet;
	m_rs->width = initialwidth;
	m_rev = 0;
    m_bEcho = true;
}

freeverb::freeverb(RevSettings * rs)
{
	m_rs = rs;
	m_rev = 0;
    m_bEcho = true;
}

freeverb::~freeverb()
{
//	delete m_rs;
}

void freeverb::setParameter(RevSettings& para, bool b_echo){
    m_rs->damp = para.damp;
	m_rs->dry = para.dry;
	m_rs->mode = para.mode;
	m_rs->roomsize = para.roomsize;
	m_rs->wet = para.wet;
	m_rs->width = para.width;
    m_bEcho = b_echo;
}

//输入的numsamples是short型的个数
static const float divisor=1.0f/-32768;

void freeverb::process(int samp_freq, int sf, int nchannels, void *samples0,unsigned int numsamples, bool bCfgChanged)
{
    if (!m_bEcho) {
        return;
    }
	if (!m_rev || bCfgChanged)
	{
		bool wasfirst;
		if (!m_rev)
		{
			m_rev=new revmodel;
			wasfirst=true;
		}
		else wasfirst=false;
		m_rev->setwet(m_rs->wet/1000.0f);
		m_rev->setroomsize(m_rs->roomsize/1000.0f);
		m_rev->setdry(m_rs->dry/1000.0f);
		m_rev->setdamp(m_rs->damp/1000.0f);
		m_rev->setwidth(m_rs->width/1000.0f);
		m_rev->setmode(m_rs->mode/1000.0f);
		if (wasfirst) m_rev->mute();
	}else {
        m_rev->setwet(m_rs->wet/1000.0f);
		m_rev->setroomsize(m_rs->roomsize/1000.0f);
		m_rev->setdry(m_rs->dry/1000.0f);
		m_rev->setdamp(m_rs->damp/1000.0f);
		m_rev->setwidth(m_rs->width/1000.0f);
		m_rev->setmode(m_rs->mode/1000.0f);
    }
	float * samples = new float[numsamples];
	short * pIn = (short *)samples0;
	for(int i =0; i < (int)numsamples; i ++)
		samples[i] = (float)pIn[i] * divisor;
	m_rev->processreplace(samples, samples + 1, (int)numsamples / nchannels, 2);
	for(int i =0; i < (int)numsamples; i ++){
// temporary marked
		pIn[i] = samples[i] * 32767 > 32767 ? 32767 :
        ((samples[i] * 32767) < -32768 ? -32768 : ((short)(samples[i] * 32767)));
//        pIn[i] = samples[i] * 32767 / 2;
    }
	delete[] samples;
	//if (is(fmt,cfg))
	//{
	//	float *samples=(float*)(samples0=init(cfg,fmt,samples0,numsamples));
	//	rev->processreplace(samples,samples+1,(int)numsamples,2);
	//}

}