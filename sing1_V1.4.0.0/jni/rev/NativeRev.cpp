#include <string.h>
#include <jni.h>
#include "freeverb.h"
#include <android/log.h>
#include "cn_kuwo_sing_logic_AudioLogic.h"

#define LOG_TAG "kwrev native"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

freeverb* g_f = NULL;

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_revInit(JNIEnv * env, jobject job)
{	
	if(g_f == NULL)
	{
		g_f = new freeverb();
		LOGI("init Rev");
	}
}

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_revProcess(JNIEnv * env, jobject job, jint samp_freq, jint nchannels, jbyteArray jbArray)
{
	if (jbArray == NULL)
	{
		LOGI("jbArray == NULL");
		return;
	}
	
	jbyte* input= env->GetByteArrayElements(jbArray, JNI_FALSE);  
    jsize size = env->GetArrayLength(jbArray);  
	
	
    // ǿתΪshort  
    jshort *input_16 = (jshort*)input;  
    //jshort output_16[size >> 1];  
//  // �����������float����  
    //jint input_32[size>>1];  
    //jint output_32[size>>1];  
    // shortתint  
    //SInt16ToFixedPoint(input_16, input_32, size>>1); 
	
	
	if(g_f != NULL)
	{
//		void process(int samp_freq, int sf, int nchannels, short *samples0, size_t numsamples);
		g_f->process(samp_freq, 1, nchannels, (char*)input_16, size/2);
		// LOGI("process finish");
	}
	
	env->ReleaseByteArrayElements(jbArray, input, 0);
}

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_revSet(JNIEnv * env, jobject job, jint rs)
{

	if(rs < 0)
	{
		LOGI("roomsize < 0");
		return;
	}

	if(g_f != NULL)
	{
		g_f->setRev((room_size)rs);
		LOGI("setRev finish");
	}
}

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_revRelease(JNIEnv * env, jobject job)
{
	if(g_f == NULL)
		return;
		
	delete g_f;
	g_f = NULL;
	LOGI("release Rev");
}


