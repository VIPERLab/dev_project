//
//  KSAudioGraph.h
//  AudioGraphTest
//
//  Created by 单 永杰 on 13-4-26.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

@interface KSAudioGraph : NSObject{
    AudioStreamBasicDescription     m_StereoStreamFormat;
    AudioStreamBasicDescription     m_OutputStreamFormat;
    
    AUGraph                         m_AudioUnitGraph;
    
    AudioUnit                       m_IOUnit;
    AudioUnit                       m_MixerUnit;
    AudioUnit                       m_AcomPlayUnit;
    AudioUnit                       m_OrigionPlayUnit;
    
    AUNode      m_IONode;
    AUNode      m_MixerNode;
    AUNode      m_AcomPlayNode;
    AUNode      m_OrigionPlayNode;
    
//    AudioConverterRef m_BufConverter;
//    AudioBufferList m_RecordBufList;
//    SInt16* m_BufRecord;
    
    ExtAudioFileRef m_ExtAudioFile;
    
    BOOL m_bIsRecording;
    
    AudioFileID m_AcomFile;
    AudioFileID m_OrigionFile;
    
    freeverb* m_pEchoProcessor;
    RevSettings m_EchoPara;
    EAudioEchoEffect m_eEchoType;
    
    AudioStreamBasicDescription m_AcomFileDesc;
    AudioStreamBasicDescription m_OrigFileDesc;
    
    AudioTimeStamp m_CurrentTime;
    
    Float64 m_fDuration;
    
    bool m_bPaused;
}

- (void) setAcomVolume : (float) f_volume;
- (void) setSingVolume : (float) f_volume;
- (float) getSingVolume;

- (void) switchResource;

- (void) setEchoType : (EAudioEchoEffect) e_effect_type;

- (bool) initAudioGraph;

- (void) startAUGraph;
- (void) pauseAUGraph;
- (void) resumeAUGraph;
- (void) stopAUGraph;

- (int) getDuration;
- (unsigned int) currentTime;

@end
