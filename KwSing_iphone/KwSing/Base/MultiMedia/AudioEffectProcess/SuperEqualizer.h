#ifndef SUPER_EQUALIZER_H
#define SUPER_EQUALIZER_H
#include "memory.h"
#include "DolbyDecoder.h"
#include "equalizer.h"

class supereq;

class SuperEqualizer{
public:
	SuperEqualizer();
	SuperEqualizer(EqSettings * cfg);
	~SuperEqualizer();
private:
//	EqSettings old;
	EqSettings * m_cfg;
	unsigned int oldnchannels;
	supereq *eqs[6];
	float * init(void * samples, int num);
public:
	void process(int samp_freq, int sf, unsigned int nchannels, void *samples,size_t &numsamples, bool bCfgChanged);
	void onSeek(void);
	Tbuffer buf;
};
#endif