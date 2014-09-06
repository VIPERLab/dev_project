//
//  WaveFileMerge.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-25.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CWaveFileMerge_h
#define KwSing_CWaveFileMerge_h

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

#include<string>

class CWaveFileMerge {
public:
    CWaveFileMerge(){};
    virtual ~CWaveFileMerge(){};
    
public:
    static int GetWaveDataLength(FILE* p_file);
    static int GetRawDataLength(FILE* p_file);
    
public:
    static bool MergeWaveFile(std::string str_accompany_file, std::string str_merge_file, float f_accompany_volume, float f_wav_volume);
};
#endif
