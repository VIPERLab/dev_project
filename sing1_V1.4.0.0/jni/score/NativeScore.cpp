#include <string.h>
#include <jni.h>
#include "Score.h"
#include <android/log.h>
#include "cn_kuwo_sing_logic_AudioLogic.h"

#define LOG_TAG "kwscore native"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

CScore* g_f = NULL;

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreInit(JNIEnv *, jobject, jint nRecWavSampleRate, jint nChannel, jdouble dbEnvRate) 
{
	if(g_f == NULL)
	{
		g_f = new CScore();
		g_f->Init(nRecWavSampleRate, nChannel, dbEnvRate);
		LOGI("init Rev");
	}
}
  
JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreOnWavNewDataComing
  (JNIEnv* env, jobject, jshortArray pWavData)
{

	if(pWavData == NULL)
	{
		LOGI("pWavData == NULL");
		return;
	}
	
	if(g_f != NULL)
	{
		jshort* pWav = env->GetShortArrayElements(pWavData, JNI_FALSE);
		int nLen = env->GetArrayLength(pWavData);
		g_f->OnWavNewDataComing(pWav, nLen);
		
		env->ReleaseShortArrayElements(pWavData, pWav, 0);
		LOGI("scoreOnWavNewDataComing");
	}
}

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreSentenceStart
  (JNIEnv* env, jobject, jdoubleArray pdbSpec,jdoubleArray pdbEnv)
{

	if(pdbSpec == NULL || pdbEnv == NULL)
	{
		LOGI("pdbSpec == NULL || pdbEnv == 0");
		return;
	}
	if(g_f != NULL)
	{
		jdouble* pSpec = env->GetDoubleArrayElements(pdbSpec, JNI_FALSE);
		jdouble* pEnv = env->GetDoubleArrayElements(pdbEnv, JNI_FALSE);
		int nSpecLen = env->GetArrayLength(pdbSpec);
		int nEnvLen = env->GetArrayLength(pdbEnv);
		g_f->SentenceStart(pSpec, nSpecLen, pEnv, nEnvLen);
		
		env->ReleaseDoubleArrayElements(pdbSpec, pSpec, 0);
		env->ReleaseDoubleArrayElements(pdbEnv, pEnv, 0);
		LOGI("scoreSentenceStart");
	}
}

JNIEXPORT jint JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreSentenceEnd
  (JNIEnv *, jobject)
{
	LOGI("SentenceEnd IN");
	if(g_f != NULL)
	{
		return g_f->SentenceEnd();
	}
}

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreRelease(JNIEnv * env, jobject job)
{

	if(g_f == NULL)
		return;
		
	delete g_f;
	g_f = NULL;
	LOGI("release Score");
}

