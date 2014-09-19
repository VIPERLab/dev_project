# Build both ARMv5TE and ARMv7-A machine code.  armeabi-v7a
APP_ABI := armeabi
APP_PLATFORM := android-7
APP_CPPFLAGS += -frtti -fexceptions
APP_STL := gnustl_static