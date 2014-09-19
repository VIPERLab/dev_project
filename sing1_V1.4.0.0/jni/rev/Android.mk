LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
# Here we give our module name and source file(s)
LOCAL_MODULE    := kwrev
LOCAL_SRC_FILES := revmodel/revmodel.cpp \
				   freeverb.cpp \
				   NativeRev.cpp
LOCAL_LDLIBS += -llog

include $(BUILD_SHARED_LIBRARY)