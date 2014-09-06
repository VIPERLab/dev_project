//
//  KSAudioGraph.m
//  AudioGraphTest
//
//  Created by 单 永杰 on 13-4-26.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import "KSAudioGraph.h"
#include "RecordTask.h"
#include "KwTools.h"
#include "KSRecordTempPath.h"
#include "Score.h"
#include "MessageManager.h"
#include "IAudioStateObserver.h"

#define GLOBAL_SAMPLE_RATE 44100.0
#define UN_FreeSing_File_Len 52923776 //44100 * 2 * 2 * 300

static UInt64 UN_Current_Length = 0;
static float s_f_volume = 0.0;
static dispatch_queue_t s_dispatchQueue;

@implementation KSAudioGraph

static void playingCompletationProc(void* userData, ScheduledAudioFileRegion *fileRegion, OSStatus result){
    KSAudioGraph* p_self = (KSAudioGraph*)userData;
    if (!p_self->m_bPaused) {
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
    }
}

/************************* 音频硬件改变的事件，已经由observer监控*******************
static void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
    
    // Ensure that this callback was invoked because of an audio route change
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange)
        return;

    KSAudioGraph *audioObject = (KSAudioGraph *) inUserData;
    if(nil == audioObject){
        return;
    }

    if (NO == audioObject->m_bIsRecording) {
        
        NSLog (@"Audio route change while application audio is stopped.");
        return;
        
    } else {
        
        // Determine the specific type of audio route change that occurred.
        CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
        
        CFNumberRef routeChangeReasonRef =
        (CFNumberRef)CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                              );
        
        SInt32 routeChangeReason;
        
        CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason
                          );

        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
            NSLog (@"Audio output device was removed; stopping audio playback.");
            NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
            [[NSNotificationCenter defaultCenter] postNotificationName: MixerHostAudioObjectPlaybackStateDidChangeNotification object: audioObject];
            
        } else {
            
            NSLog (@"A route change occurred that does not require stopping application audio.");
        }
    }
}
*/

static OSStatus micLineInCallback (void					*inRefCon,
                            AudioUnitRenderActionFlags 	*ioActionFlags,
                            const AudioTimeStamp			*inTimeStamp,
                            UInt32 						inBusNumber,
                            UInt32 						inNumberFrames,
                            AudioBufferList				*ioData)
{
    UN_Current_Length += ioData->mBuffers[0].mDataByteSize;
    
	KSAudioGraph *THIS = (KSAudioGraph *)inRefCon;
    
    AudioUnit rioUnit = THIS->m_IOUnit;    // io unit which has the input data from mic/lineIn
    
    AudioUnitRender(rioUnit, ioActionFlags,
                    inTimeStamp, 1, inNumberFrames, ioData);
    
    int n_data_len = ioData->mBuffers[0].mDataByteSize / 2;
    short* audio_data = (short*)ioData->mBuffers[0].mData;
    
    CScore::GetInstance()->OnWavNewDataComing(audio_data, n_data_len);
    
    dispatch_async(s_dispatchQueue,^{
        
        double f_volume = 0.;
        for (int n_itr = 0; n_itr < n_data_len; n_itr += 2) {
            double frame_amp = 0.;
            for (int j = n_itr; j < n_itr + 2; ++j) {
                frame_amp += audio_data[n_itr];
            }
            frame_amp /= 2;
            f_volume += frame_amp * frame_amp;
        }
        
        f_volume /= (n_data_len >> 1);
        f_volume = ((f_volume > 1) ? log10(f_volume) : 0.) / 9;
        
        s_f_volume = (f_volume < 0.5) ? 0.0 : ((f_volume - 0.5) * 2);
        
        s_f_volume = s_f_volume * s_f_volume;
    });
    
    if (NO_EFFECT != THIS->m_eEchoType) {
        THIS->m_pEchoProcessor->process(44100, 1, 2, audio_data, n_data_len, false);
    }
    
    ExtAudioFileWriteAsync(THIS->m_ExtAudioFile, inNumberFrames, ioData);
    
    if (UN_Current_Length >= UN_FreeSing_File_Len) {
        if (CRecordTask::GetInstance()->m_bIsFreeSing) {
            ASYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::FreeSingFinish, 0);
        }
    }
    
    return noErr;	// return with samples in iOdata
}

- (void) setupAudioSession{
    AVAudioSession* mySession = [AVAudioSession sharedInstance];
    [mySession setActive:YES error:nil];

    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord
                     error: &audioSessionError];
    
    /**********************ios 6.0 之后才支持该方法*****************/
//    [mySession setPreferredSampleRate: GLOBAL_SAMPLE_RATE
//                                error: &audioSessionError];
    
    Float32 currentBufferDuration =  (Float32) (2048.0 / GLOBAL_SAMPLE_RATE);
	AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, sizeof(currentBufferDuration), &currentBufferDuration);
    [mySession setActive: YES error: &audioSessionError];
    
    UInt32 size_buf_duration = sizeof(currentBufferDuration);
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &size_buf_duration, &currentBufferDuration);
//    AudioSessionAddPropertyListener (
//                                     kAudioSessionProperty_AudioRouteChange,
//                                     audioRouteChangeListenerCallback,
//                                     self
//                                     );
}
- (void) setupStereoStreamFormat{
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    //     NSLog (@"size of AudioUnitSampleType: %lu", bytesPerSample);
    
    // Fill the application audio format struct's fields to define a linear PCM,
    //        stereo, noninterleaved stream at the hardware sample rate.
    m_StereoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    m_StereoStreamFormat.mFormatFlags       = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    m_StereoStreamFormat.mBytesPerPacket    = bytesPerSample;
    m_StereoStreamFormat.mFramesPerPacket   = 1;
    m_StereoStreamFormat.mBytesPerFrame     = bytesPerSample;
    m_StereoStreamFormat.mChannelsPerFrame  = 2;                    // 2 indicates stereo
    m_StereoStreamFormat.mBitsPerChannel    = 16;
    m_StereoStreamFormat.mSampleRate        = GLOBAL_SAMPLE_RATE;
}

- (void) setupOutputStreamFormat{
    memset(&m_OutputStreamFormat, 0, sizeof(m_OutputStreamFormat));
    m_OutputStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    m_OutputStreamFormat.mFormatFlags       = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    m_OutputStreamFormat.mBytesPerPacket    = 4;
    m_OutputStreamFormat.mFramesPerPacket   = 1;
    m_OutputStreamFormat.mBytesPerFrame     = 4;
    m_OutputStreamFormat.mChannelsPerFrame  = 2;                    // 2 indicates stereo
    m_OutputStreamFormat.mBitsPerChannel    = 16;
    m_OutputStreamFormat.mSampleRate        = GLOBAL_SAMPLE_RATE;
}

- (void) initOutputFile{
    
    std::string record_file_path;
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        record_file_path = KwTools::Dir::GetFileName(CRecordTask::GetInstance()->m_strAccompanyPath);
        int n_index = record_file_path.rfind(".");
        record_file_path = [KSRecordTempPath getRecordTempPath] + "/" + record_file_path.substr(0, n_index) + "Record.wav";
    }else {
        record_file_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.wav";
    }
    NSString* str_output_file_path = [NSString stringWithFormat:@"%s", record_file_path.c_str()];
    CFURLRef file_url = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8*)[str_output_file_path UTF8String], [str_output_file_path length], NO);
    OSStatus ret_status = ExtAudioFileCreateWithURL(file_url, kAudioFileWAVEType, &m_OutputStreamFormat, NULL, kAudioFileFlags_EraseFile, &m_ExtAudioFile);
    CFRelease(file_url);
    if (noErr != ret_status) {
        return;
    }
    
    ExtAudioFileSetProperty(m_ExtAudioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(m_OutputStreamFormat), &m_OutputStreamFormat);
}

- (bool) configureAndInitializeAudioProcessingGraph{
    OSStatus result = noErr;
    
    [self setupAudioProcessingGraph];

    result = AUGraphOpen (m_AudioUnitGraph);
    if (noErr != result) {
        return false;
    }
    
    result =	AUGraphNodeInfo (
								 m_AudioUnitGraph,
								 m_IONode,
								 NULL,
								 &m_IOUnit
								 );
	
	if (result) {
        return false;
    }
    
    AudioUnitElement ioUnitInputBus = 1;
	
    // Enable input for the I/O unit, which is disabled by default. (Output is
    //	enabled by default, so there's no need to explicitly enable it.)
    UInt32 enableInput = 1;
	
    AudioUnitSetProperty (
						  m_IOUnit,
						  kAudioOutputUnitProperty_EnableIO,
						  kAudioUnitScope_Input,
						  ioUnitInputBus,
						  &enableInput,
						  sizeof (enableInput)
						  );
    
    result =	AudioUnitSetProperty (
                                      m_IOUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      ioUnitInputBus,
                                      &m_OutputStreamFormat,
                                      sizeof (m_OutputStreamFormat)
                                      );
    
    if (result) {
        return false;
    }
    
    result =	AudioUnitSetProperty (
                                      m_IOUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Input,
                                      0,
                                      &m_OutputStreamFormat,
                                      sizeof (m_OutputStreamFormat)
                                      );
    
    if (result) {
        return false;
    }
    
    result =    AUGraphNodeInfo (
                                 m_AudioUnitGraph,
                                 m_MixerNode,
                                 NULL,
                                 &m_MixerUnit
                                 );
    
    
    AudioUnitSetProperty (
						  m_MixerUnit,
						  kAudioOutputUnitProperty_EnableIO,
						  kAudioUnitScope_Output,
						  0,
						  &enableInput,
						  sizeof (enableInput)
						  );
    
    UInt32 n_mixer_bus_count = 3;
    UInt32 n_microphone_bus = 0;
    AudioUnitSetProperty (
                          m_MixerUnit,
                          kAudioUnitProperty_ElementCount,
                          kAudioUnitScope_Input,
                          0,
                          &n_mixer_bus_count,
                          sizeof (n_mixer_bus_count)
                          );
    
    UInt32 maximumFramesPerSlice = 4096;
    
    AudioUnitSetProperty (
                                   m_MixerUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (noErr != result) {
        return false;
    }
    
    AudioUnitSetProperty (
                                   m_MixerUnit,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   0,
                                   &m_OutputStreamFormat,
                                   sizeof (m_OutputStreamFormat)
                                   );
    AudioUnitSetProperty (
                          m_MixerUnit,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Input,
                          1,
                          &m_OutputStreamFormat,
                          sizeof (m_OutputStreamFormat)
                          );
    
    AudioUnitSetProperty (
                          m_MixerUnit,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Output,
                          0,
                          &m_OutputStreamFormat,
                          sizeof (m_OutputStreamFormat)
                          );
    
    AURenderCallbackStruct inputCallbackStruct;
	
    inputCallbackStruct.inputProc        = micLineInCallback;	// 8.24 version
    inputCallbackStruct.inputProcRefCon  = self;

    // Set a callback for the specified node's specified input
    result = AUGraphSetNodeInputCallback (m_AudioUnitGraph, m_MixerNode, n_microphone_bus, &inputCallbackStruct);
	
    if (noErr != result) {
        return false;
    }
    
    AudioUnitSetProperty(m_MixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &m_OutputStreamFormat, sizeof(m_OutputStreamFormat));
    
    result = AUGraphNodeInfo (
								 m_AudioUnitGraph,
								 m_AcomPlayNode,
								 NULL,
								 &m_AcomPlayUnit
								 );
	
	if (result) {
        return false;
    }
    
    AudioUnitSetProperty(m_AcomPlayUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &m_StereoStreamFormat, sizeof(m_StereoStreamFormat));
    
    result = AUGraphNodeInfo (
                              m_AudioUnitGraph,
                              m_OrigionPlayNode,
                              NULL,
                              &m_OrigionPlayUnit
                              );
	
	if (result) {
        return false;
    }
    
    AudioUnitSetProperty(m_OrigionPlayUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &m_StereoStreamFormat, sizeof(m_StereoStreamFormat));
    
    [self connectAudioProcessingGraph];
    
    AUGraphInitialize (m_AudioUnitGraph);
    
    return true;
}

- (bool) setupAudioProcessingGraph{
    OSStatus result = noErr;
    
    
    // Create a new audio processing graph.
    result = NewAUGraph (&m_AudioUnitGraph);
    
    if (noErr != result) {
        return false;
    }
    
    
    //............................................................................
    // Specify the audio unit component descriptions for the audio units to be
    //    added to the graph.
    
    // remote I/O unit connects both to mic/lineIn and to speaker
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    
    
    // Multichannel mixer unit
    AudioComponentDescription MixerUnitDescription;
    MixerUnitDescription.componentType          = kAudioUnitType_Mixer;
    MixerUnitDescription.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    MixerUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    MixerUnitDescription.componentFlags         = 0;
    MixerUnitDescription.componentFlagsMask     = 0;
    
    // Acompany player
    
    AudioComponentDescription auAcomPlayerUnitDescription;
    auAcomPlayerUnitDescription.componentType = kAudioUnitType_Generator;
    auAcomPlayerUnitDescription.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    auAcomPlayerUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    result =    AUGraphAddNode (
                                m_AudioUnitGraph,
                                &iOUnitDescription,
                                &m_IONode);
    
    if (noErr != result) {
        return false;
    }
    
	
    
    // mixer unit
    
    result =    AUGraphAddNode (
                                m_AudioUnitGraph,
                                &MixerUnitDescription,
                                &m_MixerNode
                                );
    
    if (noErr != result) {
        return false;
    }
    
    result = AUGraphAddNode(m_AudioUnitGraph, &auAcomPlayerUnitDescription, &m_AcomPlayNode);
    
    if (noErr != result) {
        return false;
    }
    
    result = AUGraphAddNode(m_AudioUnitGraph, &auAcomPlayerUnitDescription, &m_OrigionPlayNode);
    if (noErr != result) {
        return false;
    }
    
    return true;
}

- (void) setupAcomPlayerUnit{
    if (CRecordTask::GetInstance()->m_bIsFreeSing) {
        return;
    }
    
	CFURLRef acomAudioURL = ( CFURLRef) [NSURL fileURLWithPath:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strAccompanyPath.c_str()]];
	
	// open the input audio file
	AudioFileOpenURL(acomAudioURL, kAudioFileReadPermission, 0, &m_AcomFile);
    
    UInt32 un_duration_size = sizeof(Float64);
    AudioFileGetProperty(m_AcomFile, kAudioFilePropertyEstimatedDuration, &un_duration_size, &m_fDuration);
    
	// tell the file player unit to load the file we want to play
	AudioUnitSetProperty(m_AcomPlayUnit, kAudioUnitProperty_ScheduledFileIDs,
									kAudioUnitScope_Global, 0, &m_AcomFile, sizeof(m_AcomFile));
	
	UInt64 nPackets;
	UInt32 propsize = sizeof(nPackets);
	AudioFileGetProperty(m_AcomFile, kAudioFilePropertyAudioDataPacketCount,
									&propsize, &nPackets);
	
	// get file's asbd
	UInt32 fileASBDPropSize = sizeof(m_AcomFileDesc);
	AudioFileGetProperty(m_AcomFile, kAudioFilePropertyDataFormat,
									&fileASBDPropSize, &m_AcomFileDesc);
    
	// tell the file player AU to play the entire file
	ScheduledAudioFileRegion rgn;
	memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
	rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
	rgn.mTimeStamp.mSampleTime = 0;
	rgn.mCompletionProc = playingCompletationProc;
	rgn.mCompletionProcUserData = self;
	rgn.mAudioFile = m_AcomFile;
	rgn.mLoopCount = 0;
	rgn.mStartFrame = 0;
	rgn.mFramesToPlay = nPackets * m_AcomFileDesc.mFramesPerPacket;
	
	AudioUnitSetProperty(m_AcomPlayUnit, kAudioUnitProperty_ScheduledFileRegion,
									kAudioUnitScope_Global, 0,&rgn, sizeof(rgn));
	
	// prime the file player AU with default values
	UInt32 defaultVal = 0;
	AudioUnitSetProperty(m_AcomPlayUnit, kAudioUnitProperty_ScheduledFilePrime,
									kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal));
	
	// tell the file player AU when to start playing (-1 sample time means next render cycle)
	AudioTimeStamp startTime;
	memset (&startTime, 0, sizeof(startTime));
	startTime.mFlags = kAudioTimeStampSampleTimeValid;
	startTime.mSampleTime = -1;
	AudioUnitSetProperty(m_AcomPlayUnit, kAudioUnitProperty_ScheduleStartTimeStamp,
									kAudioUnitScope_Global, 0, &startTime, sizeof(startTime));
}

- (void) setupOrigionPlayerUnit{
    if (CRecordTask::GetInstance()->m_bIsFreeSing) {
        return;
    }
    
	CFURLRef origionAudioURL = ( CFURLRef) [NSURL fileURLWithPath:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strOrigionPath.c_str()]];
	
	// open the input audio file
	AudioFileOpenURL(origionAudioURL, kAudioFileReadPermission, 0, &m_OrigionFile);
    
	// tell the file player unit to load the file we want to play
	AudioUnitSetProperty(m_OrigionPlayUnit, kAudioUnitProperty_ScheduledFileIDs,
                         kAudioUnitScope_Global, 0, &m_OrigionFile, sizeof(m_OrigionFile));
	
	UInt64 nPackets;
	UInt32 propsize = sizeof(nPackets);
	AudioFileGetProperty(m_OrigionFile, kAudioFilePropertyAudioDataPacketCount,
                         &propsize, &nPackets);
	
	// get file's asbd
	UInt32 fileASBDPropSize = sizeof(m_OrigFileDesc);
	AudioFileGetProperty(m_OrigionFile, kAudioFilePropertyDataFormat,
                         &fileASBDPropSize, &m_OrigFileDesc);
    
	// tell the file player AU to play the entire file
	ScheduledAudioFileRegion rgn;
	memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
	rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
	rgn.mTimeStamp.mSampleTime = 0;
	rgn.mCompletionProc = NULL;
	rgn.mCompletionProcUserData = NULL;
	rgn.mAudioFile = m_OrigionFile;
	rgn.mLoopCount = 0;
	rgn.mStartFrame = 0;
	rgn.mFramesToPlay = nPackets * m_OrigFileDesc.mFramesPerPacket;
	
	AudioUnitSetProperty(m_OrigionPlayUnit, kAudioUnitProperty_ScheduledFileRegion,
                         kAudioUnitScope_Global, 0,&rgn, sizeof(rgn));
	
	// prime the file player AU with default values
	UInt32 defaultVal = 0;
	AudioUnitSetProperty(m_OrigionPlayUnit, kAudioUnitProperty_ScheduledFilePrime,
                         kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal));
	
	// tell the file player AU when to start playing (-1 sample time means next render cycle)
	AudioTimeStamp startTime;
	memset (&startTime, 0, sizeof(startTime));
	startTime.mFlags = kAudioTimeStampSampleTimeValid;
	startTime.mSampleTime = -1;
	AudioUnitSetProperty(m_OrigionPlayUnit, kAudioUnitProperty_ScheduleStartTimeStamp,
                         kAudioUnitScope_Global, 0, &startTime, sizeof(startTime));
}

- (void) connectAudioProcessingGraph{
    AUGraphConnectNodeInput(m_AudioUnitGraph, m_MixerNode, 0, m_IONode, 0);
    AUGraphConnectNodeInput(m_AudioUnitGraph, m_AcomPlayNode, 0, m_MixerNode, 1);
    AUGraphConnectNodeInput(m_AudioUnitGraph, m_OrigionPlayNode, 0, m_MixerNode, 2);
}

- (void) setAcomVolume : (float) f_volume{
    if (CRecordTask::GetInstance()->m_bIsAccompany) {
        AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 1, f_volume, 0);
        AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 2, 0.0, 0);
    }else {
        AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 1, 0.0, 0);
        AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 2, f_volume, 0);
    }
    
}

- (void) setSingVolume : (float) f_volume{
    AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, f_volume, 0);
}



- (bool) initAudioGraph{
    [self setupAudioSession];
    [self setupStereoStreamFormat];
    [self setupOutputStreamFormat];
    [self initOutputFile];
    [self configureAndInitializeAudioProcessingGraph];
    [self setupAcomPlayerUnit];
    [self setupOrigionPlayerUnit];
    
    UN_Current_Length = 0;
    m_bPaused = false;
    s_f_volume = 0.0;
    m_EchoPara = arry_echo_para[SMALL_ROOM_EFFECT];
    m_pEchoProcessor = new freeverb(&m_EchoPara);
    s_dispatchQueue = dispatch_queue_create("com.kwsing.onwavedatacomming", NULL);
    
    return true;
}

- (void) startAUGraph{
    AUGraphStart (m_AudioUnitGraph);
    
    m_bIsRecording = true;
}

- (void) pauseAUGraph{
    m_bPaused = true;
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        AudioTimeStamp temp_time;
        memset(&temp_time, 0, sizeof(AudioTimeStamp));
        UInt32 un_size = sizeof(AudioTimeStamp);
        AudioUnitGetProperty(m_AcomPlayUnit, kAudioUnitProperty_CurrentPlayTime, kAudioUnitScope_Global, 0, &temp_time, &un_size);
        m_CurrentTime.mSampleTime += temp_time.mSampleTime;
        AudioUnitReset(m_AcomPlayUnit, kAudioUnitScope_Global, 0);
        AudioUnitReset(m_OrigionPlayUnit, kAudioUnitScope_Global, 0);
    }
    
    AUGraphStop(m_AudioUnitGraph);
    
    m_bIsRecording = false;
}

- (void) resumeAUGraph{
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        ScheduledAudioFileRegion acom_region;
        acom_region.mTimeStamp.mSampleTime = 0;
        acom_region.mStartFrame = m_CurrentTime.mSampleTime;
        acom_region.mCompletionProc = playingCompletationProc;
        acom_region.mCompletionProcUserData = self;
        acom_region.mAudioFile = m_AcomFile;
        acom_region.mLoopCount = 0;
        
        UInt64 nPackets;
        UInt32 propsize = sizeof(nPackets);
        AudioFileGetProperty(m_AcomFile, kAudioFilePropertyAudioDataPacketCount,
                             &propsize, &nPackets);
        acom_region.mFramesToPlay = nPackets * m_AcomFileDesc.mFramesPerPacket - acom_region.mStartFrame;
        AudioUnitSetProperty(m_AcomPlayUnit, kAudioUnitProperty_ScheduledFileRegion,
                             kAudioUnitScope_Global, 0,&acom_region, sizeof(acom_region));
        UInt32 defaultVal = 0;
        AudioUnitSetProperty(m_AcomPlayUnit, kAudioUnitProperty_ScheduledFilePrime,
                             kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal));
        
        ScheduledAudioFileRegion orig_region;
        orig_region.mTimeStamp.mSampleTime = 0;
        orig_region.mStartFrame = m_CurrentTime.mSampleTime;
        orig_region.mCompletionProc = NULL;
        orig_region.mCompletionProcUserData = nil;
        orig_region.mAudioFile = m_OrigionFile;
        orig_region.mLoopCount = 0;

        AudioFileGetProperty(m_OrigionFile, kAudioFilePropertyAudioDataPacketCount,
                             &propsize, &nPackets);
        orig_region.mFramesToPlay = nPackets * m_OrigFileDesc.mFramesPerPacket - orig_region.mStartFrame;
        AudioUnitSetProperty(m_OrigionPlayUnit, kAudioUnitProperty_ScheduledFileRegion,
                             kAudioUnitScope_Global, 0,&orig_region, sizeof(orig_region));
        AudioUnitSetProperty(m_OrigionPlayUnit, kAudioUnitProperty_ScheduledFilePrime,
                             kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal));
        
        AudioTimeStamp startTime;
        memset (&startTime, 0, sizeof(startTime));
        startTime.mFlags = kAudioTimeStampSampleTimeValid;
        startTime.mSampleTime = -1;
        AudioUnitSetProperty(m_OrigionPlayUnit, kAudioUnitProperty_ScheduleStartTimeStamp,
                             kAudioUnitScope_Global, 0, &startTime, sizeof(startTime));
        
        AudioUnitSetProperty(m_AcomPlayUnit, kAudioUnitProperty_ScheduleStartTimeStamp,
                             kAudioUnitScope_Global, 0, &startTime, sizeof(startTime));
        AUGraphInitialize (m_AudioUnitGraph);
    }
    
    m_bPaused = false;
    
    AUGraphStart (m_AudioUnitGraph);
}

- (void) stopAUGraph{
    AUGraphStop(m_AudioUnitGraph);
    
    if (m_pEchoProcessor) {
        delete m_pEchoProcessor;
        m_pEchoProcessor = NULL;
    }
    
    ExtAudioFileDispose(m_ExtAudioFile);
    
    AudioFileClose(m_AcomFile);
    AudioFileClose(m_OrigionFile);
    
    m_bIsRecording = false;
}

- (int) getDuration{
    if (CRecordTask::GetInstance()->m_bIsFreeSing) {
        return 300000;
    }else {
        return m_fDuration * 1000;
    }
}

- (unsigned int) currentTime{
    return 1000 * UN_Current_Length / (44100 * 4);
}

- (float)getSingVolume{
    return (s_f_volume <= 0.1) ? 0 : (100 * s_f_volume);
}

- (void) switchResource{
    if (CRecordTask::GetInstance()->m_bIsAccompany) {
        CRecordTask::GetInstance()->m_bIsAccompany = false;
        AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 1, 0.0, 0);
        AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 2, CRecordTask::GetInstance()->GetAccompanyVolume(), 0);
    }else {
        CRecordTask::GetInstance()->m_bIsAccompany = true;
        AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 2, 0.0, 0);
        AudioUnitSetParameter(m_MixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 1, CRecordTask::GetInstance()->GetAccompanyVolume(), 0);
    }
}

- (void) setEchoType : (EAudioEchoEffect) e_effect_type{
    m_eEchoType = e_effect_type;
    m_EchoPara = arry_echo_para[e_effect_type];
    if (m_pEchoProcessor) {
        if (NO_EFFECT == e_effect_type) {
            m_pEchoProcessor->setParameter(m_EchoPara, false);
        }else {
            m_pEchoProcessor->setParameter(m_EchoPara, true);
        }
    }
}

- (void)dealloc{
    dispatch_release(s_dispatchQueue);
    
//    DisposeAUGraph(m_AudioUnitGraph);
    
    [super dealloc];
}

@end
