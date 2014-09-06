#ifndef _DOLBYDECODER_H_
#define _DOLBYDECODER_H_

//#include "TaudioFilter.h"
//#include "TdolbyDecoderSettings.h"
#include "firfilter.h"
#include "alloc.h"
#include <iostream>
#include <vector>

#ifndef NULL
#define NULL 0
#endif

class Tbuffer
{
private:
	void *buf;size_t buflen;
public: 
	Tbuffer(void):buf(NULL),buflen(0),free(true) {}
	Tbuffer(size_t Ibuflen):buf(NULL),buflen(0),free(true) {alloc(Ibuflen);}
	~Tbuffer() {if (free) clear();}
	bool free;
	void clear(void)
	{
		if (buf) aligned_free(buf);
		buf=NULL;buflen=0;
	}
	size_t size(void) const {return buflen;} 
	void* alloc(size_t Ibuflen)
	{
		if (buflen<Ibuflen)
			buf=aligned_realloc(buf,buflen=Ibuflen);
		return buf; 
	}
	template<class T> operator T*() const {return (T*)buf;} 
};

class DolbyDecoder
{
private:
 int olddelay;unsigned int oldfreq;
// int nchannels;
 Tbuffer buf;
 unsigned int dlbuflen;
 int cyc_pos;
 float l_fwr,r_fwr,lpr_fwr,lmr_fwr;
 std::vector<float> fwrbuf_l,fwrbuf_r;
 float adapt_l_gain,adapt_r_gain,adapt_lpr_gain,adapt_lmr_gain;
 std::vector<float> lf,rf,lr,rr,cf,cr;
 float LFE_buf[256];unsigned int lfe_pos;
 TfirFilter::_ftype_t *filter_coefs_lfe;unsigned int len125;
 TfirFilter::_ftype_t* calc_coefficients_125Hz_lowpass(int rate);

 static float passive_lock(float x);
 void matrix_decode(const float *in, const int k, const int il,
		    const int ir, bool decode_rear,
		    const int dlbuflen,
		    float l_fwr, float r_fwr,
		    float lpr_fwr, float lmr_fwr,
		    float *adapt_l_gain, float *adapt_r_gain,
		    float *adapt_lpr_gain, float *adapt_lmr_gain,
		    float *lf, float *rf, float *lr,
		    float *rr, float *cf);
 float * init(void * samples, int num);
protected:
// virtual bool is(const TsampleFormat &fmt,const TfilterSettingsAudio *cfg);
// virtual int getSupportedFormats(const TfilterSettingsAudio *cfg,bool *honourPreferred) const {return TsampleFormat::SF_FLOAT32;}
public:
 //DolbyDecoder(IffdshowBase *Ideci,Tfilters *Iparent);
 DolbyDecoder();
 virtual void done(void);
// virtual bool getOutputFmt(TsampleFormat &fmt,const TfilterSettingsAudio *cfg);
// virtual HRESULT process(TfilterQueue::iterator it,TsampleFormat &fmt,void *samples,size_t numsamples,const TfilterSettingsAudio *cfg0);
 void process(unsigned int freq, int nchannels, int delay, void *samples,size_t numsamples);
 virtual void onSeek(void);
};

#endif
