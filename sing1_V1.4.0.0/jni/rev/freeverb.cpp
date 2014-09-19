#include "freeverb.h"
#include "memory.h"

#include <android/log.h>
#define LOG_TAG "System.out"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

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
	m_roomSize = no_room;
}


freeverb::~freeverb()
{
	if(m_rs) delete m_rs;
	if(m_rev) delete m_rev;
}

//输入的numsamples是short型的个数

static const float divisor=1.0f/-32768;
void freeverb::process(int samp_freq, int sf, int nchannels, short *samples0, size_t numsamples)
{
	if (m_roomSize == no_room)
	{
		LOGI("process 0");
		return;
	}

	float * samples = new float[numsamples];
	short * pIn = (short *)samples0;
	for(int i =0; i < (int)numsamples; i ++)
		samples[i] = (float)pIn[i] * divisor;

	m_rev->processreplace(samples, samples + 1, (int)numsamples / nchannels, 2);
	for(int i =0; i < (int)numsamples; i ++)
		pIn[i] = samples[i] * 32767 > 32767 ? 32767 :
	((samples[i] * 32767) < -32768 ? -32768 : ((short)(samples[i] * 32767)));
	delete[] samples;

	//if (is(fmt,cfg))
	//{
	//	float *samples=(float*)(samples0=init(cfg,fmt,samples0,numsamples));
	//	rev->processreplace(samples,samples+1,(int)numsamples,2);
	//}

}

void freeverb::setRev( room_size rSize )
{
	m_roomSize = rSize;
	if(rSize == no_room) return;
	bool wasfirst;
	if (!m_rev)
	{
		if (!m_rev)
		{
			m_rev=new revmodel;
			wasfirst=true;
		}
		else wasfirst=false;
	}

	int n = (int)rSize;
	if(n>4 || n<1)
		return;
	m_rev->setwet(rs[n-1].wet/1000.0f);
	m_rev->setroomsize(rs[n-1].roomsize/1000.0f);
	m_rev->setdry(rs[n-1].dry/1000.0f);
	m_rev->setdamp(rs[n-1].damp/1000.0f);
	m_rev->setwidth(rs[n-1].width/1000.0f);
	m_rev->setmode(rs[n-1].mode/1000.0f);	
	if (wasfirst) m_rev->mute();
}
