/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class cn_kuwo_sing_logic_AudioLogic */

#ifndef _Included_cn_kuwo_sing_logic_AudioLogic
#define _Included_cn_kuwo_sing_logic_AudioLogic
#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreInit
  (JNIEnv *, jobject, jint, jint, jdouble);

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreOnWavNewDataComing
  (JNIEnv *, jobject, jshortArray);

JNIEXPORT void JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreSentenceStart
  (JNIEnv *, jobject, jdoubleArray ,jdoubleArray);

JNIEXPORT jint JNICALL Java_cn_kuwo_sing_logic_AudioLogic_scoreSentenceEnd
  (JNIEnv *, jobject);

#ifdef __cplusplus
}
#endif
#endif