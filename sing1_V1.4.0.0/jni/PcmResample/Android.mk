LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
# Here we give our module name and source file(s)
LOCAL_MODULE    := kwpcm
LOCAL_SRC_FILES := 	src/PcmResample.cpp \
					src/samplerate.cpp \
					src/src_linear.cpp \
					src/src_sinc.cpp \
					src/src_zoh.cpp \
					NativePcm.cpp
					
LOCAL_LDLIBS += -llog

include $(BUILD_SHARED_LIBRARY)

