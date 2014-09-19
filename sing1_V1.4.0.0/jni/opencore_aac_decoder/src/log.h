#ifndef LIBVLCJNI_LOG_H
#define LIBVLCJNI_LOG_H


#ifdef HAVE_LOG

#include <android/log.h>
#define AACD_MODULE "KWAAC"

#define AACD_TRACE(...) \
    __android_log_print(ANDROID_LOG_VERBOSE, AACD_MODULE, __VA_ARGS__)
#define AACD_DEBUG(...) \
    __android_log_print(ANDROID_LOG_DEBUG, AACD_MODULE, __VA_ARGS__)
#define AACD_INFO(...) \
    __android_log_print(ANDROID_LOG_INFO, AACD_MODULE, __VA_ARGS__)

#define AACD_WARN(...) \
    __android_log_print(ANDROID_LOG_WARN, AACD_MODULE, __VA_ARGS__)
#define AACD_ERROR(...) \
    __android_log_print(ANDROID_LOG_ERROR, AACD_MODULE, __VA_ARGS__)
#else 

#define AACD_TRACE(...) \
    //__android_log_print(ANDROID_LOG_VERBOSE, AACD_MODULE, __VA_ARGS__)
#define AACD_DEBUG(...) \
   // __android_log_print(ANDROID_LOG_DEBUG, AACD_MODULE, __VA_ARGS__)
#define AACD_INFO(...) \
   // __android_log_print(ANDROID_LOG_INFO, AACD_MODULE, __VA_ARGS__)

#define AACD_WARN(...) \
   // __android_log_print(ANDROID_LOG_WARN, AACD_MODULE, __VA_ARGS__)
#define AACD_ERROR(...) \
   // __android_log_print(ANDROID_LOG_ERROR, AACD_MODULE, __VA_ARGS__)	
    
#endif

#endif // LIBVLCJNI_LOG_H
