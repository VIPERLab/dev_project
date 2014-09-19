LOCAL_PATH := $(call my-dir)
MY_ORG_LOCAL_PATH := $(LOCAL_PATH)

PV_CFLAGS := -Wno-non-virtual-dtor -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -DUSE_CML2_CONFIG -DENABLE_SHAREDFD_PLAYBACK

include $(CLEAR_VARS)

include $(MY_ORG_LOCAL_PATH)/opencore/src/Android.mk

include $(CLEAR_VARS)

LOCAL_PATH := $(MY_ORG_LOCAL_PATH)

LOCAL_MODULE    := kwaac

LOCAL_ARM_MODE := arm

#LOCAL_C_INCLUDES :=  $(LOCAL_PATH)/../mp4ff/include  $(LOCAL_PATH)/src  $(LOCAL_PATH)/opencore/oscl $(LOCAL_PATH)/opencore/include $(LOCAL_PATH)/opencore/src
#
#LOCAL_SRC_FILES := \
#		    ../mp4ff/src/mp4ff.c \
#		    ../mp4ff/src/mp4atom.c \
#		    ../mp4ff/src/mp4meta.c \
#		    ../mp4ff/src/mp4sample.c \
#		    ../mp4ff/src/mp4util.c \
#		    ../mp4ff/src/mp4tagupdate.c \
#			 	opencore/src/analysis_sub_band.cpp \
#			 	opencore/src/apply_ms_synt.cpp \
#			 	opencore/src/apply_tns.cpp \
#			 	opencore/src/buf_getbits.cpp \
#			 	opencore/src/byte_align.cpp \
#			 	opencore/src/calc_auto_corr.cpp \
#			 	opencore/src/calc_gsfb_table.cpp \
#			 	opencore/src/calc_sbr_anafilterbank.cpp \
#			 	opencore/src/calc_sbr_envelope.cpp \
#			 	opencore/src/calc_sbr_synfilterbank.cpp \
#			 	opencore/src/check_crc.cpp \
#			 	opencore/src/dct16.cpp \
#			 	opencore/src/dct64.cpp \
#			 	opencore/src/decode_huff_cw_binary.cpp \
#			 	opencore/src/decode_noise_floorlevels.cpp \
#			 	opencore/src/deinterleave.cpp \
#			 	opencore/src/digit_reversal_tables.cpp \
#			 	opencore/src/dst16.cpp \
#			 	opencore/src/dst32.cpp \
#			 	opencore/src/dst8.cpp \
#			 	opencore/src/esc_iquant_scaling.cpp \
#			 	opencore/src/extractframeinfo.cpp \
#			 	opencore/src/fft_rx4_long.cpp \
#			 	opencore/src/fft_rx4_short.cpp \
#			 	opencore/src/fft_rx4_tables_fxp.cpp \
#			 	opencore/src/find_adts_syncword.cpp \
#			 	opencore/src/fwd_long_complex_rot.cpp \
#			 	opencore/src/fwd_short_complex_rot.cpp \
#			 	opencore/src/gen_rand_vector.cpp \
#			 	opencore/src/get_adif_header.cpp \
#			 	opencore/src/get_adts_header.cpp \
#			 	opencore/src/get_audio_specific_config.cpp \
#			 	opencore/src/get_dse.cpp \
#			 	opencore/src/get_ele_list.cpp \
#			 	opencore/src/get_ga_specific_config.cpp \
#			 	opencore/src/get_ics_info.cpp \
#			 	opencore/src/get_prog_config.cpp \
#			 	opencore/src/get_pulse_data.cpp \
#			 	opencore/src/get_sbr_bitstream.cpp \
#			 	opencore/src/get_sbr_startfreq.cpp \
#			 	opencore/src/get_sbr_stopfreq.cpp \
#			 	opencore/src/get_tns.cpp \
#			 	opencore/src/getfill.cpp \
#			 	opencore/src/getgroup.cpp \
#			 	opencore/src/getics.cpp \
#			 	opencore/src/getmask.cpp \
#			 	opencore/src/hcbtables_binary.cpp \
#			 	opencore/src/huffcb.cpp \
#			 	opencore/src/huffdecode.cpp \
#			 	opencore/src/hufffac.cpp \
#			 	opencore/src/huffspec_fxp.cpp \
#			 	opencore/src/idct16.cpp \
#			 	opencore/src/idct32.cpp \
#			 	opencore/src/idct8.cpp \
#			 	opencore/src/imdct_fxp.cpp \
#			 	opencore/src/infoinit.cpp \
#			 	opencore/src/init_sbr_dec.cpp \
#			 	opencore/src/intensity_right.cpp \
#			 	opencore/src/inv_long_complex_rot.cpp \
#			 	opencore/src/inv_short_complex_rot.cpp \
#			 	opencore/src/iquant_table.cpp \
#			 	opencore/src/long_term_prediction.cpp \
#			 	opencore/src/long_term_synthesis.cpp \
#			 	opencore/src/lt_decode.cpp \
#			 	opencore/src/mdct_fxp.cpp \
#			 	opencore/src/mdct_tables_fxp.cpp \
#			 	opencore/src/mdst.cpp \
#			 	opencore/src/mix_radix_fft.cpp \
#			 	opencore/src/ms_synt.cpp \
#			 	opencore/src/pns_corr.cpp \
#			 	opencore/src/pns_intensity_right.cpp \
#			 	opencore/src/pns_left.cpp \
#			 	opencore/src/ps_all_pass_filter_coeff.cpp \
#			 	opencore/src/ps_all_pass_fract_delay_filter.cpp \
#			 	opencore/src/ps_allocate_decoder.cpp \
#			 	opencore/src/ps_applied.cpp \
#			 	opencore/src/ps_bstr_decoding.cpp \
#			 	opencore/src/ps_channel_filtering.cpp \
#			 	opencore/src/ps_decode_bs_utils.cpp \
#			 	opencore/src/ps_decorrelate.cpp \
#			 	opencore/src/ps_fft_rx8.cpp \
#			 	opencore/src/ps_hybrid_analysis.cpp \
#			 	opencore/src/ps_hybrid_filter_bank_allocation.cpp \
#			 	opencore/src/ps_hybrid_synthesis.cpp \
#			 	opencore/src/ps_init_stereo_mixing.cpp \
#			 	opencore/src/ps_pwr_transient_detection.cpp \
#			 	opencore/src/ps_read_data.cpp \
#			 	opencore/src/ps_stereo_processing.cpp \
#			 	opencore/src/pulse_nc.cpp \
#			 	opencore/src/pv_div.cpp \
#			 	opencore/src/pv_log2.cpp \
#			 	opencore/src/pv_normalize.cpp \
#			 	opencore/src/pv_pow2.cpp \
#			 	opencore/src/pv_sine.cpp \
#			 	opencore/src/pv_sqrt.cpp \
#			 	opencore/src/pvmp4audiodecoderconfig.cpp \
#			 	opencore/src/pvmp4audiodecoderframe.cpp \
#			 	opencore/src/pvmp4audiodecodergetmemrequirements.cpp \
#			 	opencore/src/pvmp4audiodecoderinitlibrary.cpp \
#			 	opencore/src/pvmp4audiodecoderresetbuffer.cpp \
#			 	opencore/src/q_normalize.cpp \
#			 	opencore/src/qmf_filterbank_coeff.cpp \
#			 	opencore/src/sbr_aliasing_reduction.cpp \
#			 	opencore/src/sbr_applied.cpp \
#			 	opencore/src/sbr_code_book_envlevel.cpp \
#			 	opencore/src/sbr_crc_check.cpp \
#			 	opencore/src/sbr_create_limiter_bands.cpp \
#			 	opencore/src/sbr_dec.cpp \
#			 	opencore/src/sbr_decode_envelope.cpp \
#			 	opencore/src/sbr_decode_huff_cw.cpp \
#			 	opencore/src/sbr_downsample_lo_res.cpp \
#			 	opencore/src/sbr_envelope_calc_tbl.cpp \
#			 	opencore/src/sbr_envelope_unmapping.cpp \
#			 	opencore/src/sbr_extract_extended_data.cpp \
#			 	opencore/src/sbr_find_start_andstop_band.cpp \
#			 	opencore/src/sbr_generate_high_freq.cpp \
#			 	opencore/src/sbr_get_additional_data.cpp \
#			 	opencore/src/sbr_get_cpe.cpp \
#			 	opencore/src/sbr_get_dir_control_data.cpp \
#			 	opencore/src/sbr_get_envelope.cpp \
#			 	opencore/src/sbr_get_header_data.cpp \
#			 	opencore/src/sbr_get_noise_floor_data.cpp \
#			 	opencore/src/sbr_get_sce.cpp \
#			 	opencore/src/sbr_inv_filt_levelemphasis.cpp \
#			 	opencore/src/sbr_open.cpp \
#			 	opencore/src/sbr_read_data.cpp \
#			 	opencore/src/sbr_requantize_envelope_data.cpp \
#			 	opencore/src/sbr_reset_dec.cpp \
#			 	opencore/src/sbr_update_freq_scale.cpp \
#			 	opencore/src/set_mc_info.cpp \
#			 	opencore/src/sfb.cpp \
#			 	opencore/src/shellsort.cpp \
#			 	opencore/src/synthesis_sub_band.cpp \
#			 	opencore/src/tns_ar_filter.cpp \
#			 	opencore/src/tns_decode_coef.cpp \
#			 	opencore/src/tns_inv_filter.cpp \
#			 	opencore/src/trans4m_freq_2_time_fxp.cpp \
#			 	opencore/src/trans4m_time_2_freq_fxp.cpp \
#			 	opencore/src/unpack_idx.cpp \
#			 	opencore/src/window_tables_fxp.cpp \
#			 	opencore/src/pvmp4setaudioconfig.cpp \
#				src/NativeAACDecoder.cpp \
#				src/interface.cpp


LOCAL_C_INCLUDES :=  $(LOCAL_PATH)/../mp4ff/include  $(LOCAL_PATH)/src $(LOCAL_PATH)/opencore/include $(LOCAL_PATH)/opencore/src

LOCAL_SRC_FILES := \
		    ../mp4ff/src/mp4ff.c \
		    ../mp4ff/src/mp4atom.c \
		    ../mp4ff/src/mp4meta.c \
		    ../mp4ff/src/mp4sample.c \
		    ../mp4ff/src/mp4util.c \
		    ../mp4ff/src/mp4tagupdate.c \
		    	src/NativeAACDecoder.cpp \
				src/interface.cpp
				
#				src/NativeAACDecoder.cpp \
#LOCAL_CFLAGS := -DAAC_PLUS -DHQ_SBR -DPARAMETRICSTEREO -DFIXED_POINT -ffast-math -O3

LOCAL_CFLAGS := -DAAC_PLUS -DHQ_SBR -DPARAMETRICSTEREO $(PV_CFLAGS)
LOCAL_LDLIBS    := -llog

LOCAL_STATIC_LIBRARIES := libstagefright_aacdec 
#libpv_aac_dec
LOCAL_SHARED_LIBRARIES := 

include $(BUILD_SHARED_LIBRARY)
