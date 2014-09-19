LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
# Here we give our module name and source file(s)
LOCAL_MODULE    := kwscore
LOCAL_SRC_FILES := common/fft.cpp \
				   common/spectral_buf.cpp\
				   common/wav_buf.cpp\
				   common/wav_operation.cpp\
				   Resample/samplerate.cpp\
				   Resample/src_linear.cpp\
				   Resample/src_sinc.cpp\
				   Resample/src_zoh.cpp\
				   Score.cpp \
				   NativeScore.cpp
LOCAL_LDLIBS += -llog

include $(BUILD_SHARED_LIBRARY)