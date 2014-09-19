/*
 * interface.c
 *
 *  Created on: 2011-2-14
 *      Author: jwj
 */

#include <jni.h>
#include <stdio.h>
#include <android/log.h>
#include "NativeAACDecoder.h"

#ifndef LOGS8
#define LOGS8(s, args...) __android_log_print(ANDROID_LOG_DEBUG, __FUNCTION__, s, ##args)
#endif

#define EXPORT __attribute__((visibility("default")))


/*
 * JNI registration.
 */
static JNINativeMethod gAACDecoderMethods[] = {
		{"openFile", "(Ljava/lang/String;)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_openFile},
		{"getChannelNum", "(I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_getChannelNum},
		{"getBitrate", "(I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_getBitrate},
		{"getSamplerate", "(I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_getSamplerate},
		{"getDuration", "(I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_getDuration},
		{"getCurrentPosition", "(I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_getCurrentPosition},
		{"isReadFinished", "(I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_isReadFinished},
		{"seekTo", "(II)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_seekTo},
		{"getSamplePerFrame", "(I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_getSamplePerFrame},
		{"readSamples", "(ILjava/nio/FloatBuffer;I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_readSamples__ILjava_nio_FloatBuffer_2I},
		{"readSamples", "(ILjava/nio/ShortBuffer;I)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_readSamples__ILjava_nio_ShortBuffer_2I},
		{"readSamples", "(I[SI)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_readSamples__I_3SI},
		{"closeFile", "(I)V", (void*)Java_cn_kuwo_base_codec_NativeAACDecoder_closeFile},
		{"downsampling", "(ILjava/lang/String;)I", (jint*)Java_cn_kuwo_base_codec_NativeAACDecoder_downsampling},
};

int jniRegisterNativeMethods(JNIEnv* env, const char* className,
    const JNINativeMethod* gMethods, int numMethods)
{
    jclass clazz;

    LOGS8("Registering %s natives\n", className);
    clazz = env->FindClass(className);
    if (clazz == NULL) {
        LOGS8("Native registration unable to find class '%s'\n", className);
        return -1;
    }

    int result = 0;
    if (env->RegisterNatives(clazz, gMethods, numMethods) < 0) {
        LOGS8("RegisterNatives failed for '%s'\n", className);
        result = -1;
    }

    env->DeleteLocalRef(clazz);
    return result;
}
#ifndef NELEM
# define NELEM(x) ((int) (sizeof(x) / sizeof((x)[0])))
#endif

EXPORT jint JNI_OnLoad(JavaVM* jvm, void* reserved)
{
	JNIEnv* env = NULL;

	if (jvm->GetEnv((void**) &env, JNI_VERSION_1_4) != JNI_OK)
	{
		return -1;
	}

	jniRegisterNativeMethods(env, "cn/kuwo/base/codec/NativeAACDecoder",
			gAACDecoderMethods, NELEM(gAACDecoderMethods));

	return JNI_VERSION_1_4;
}
