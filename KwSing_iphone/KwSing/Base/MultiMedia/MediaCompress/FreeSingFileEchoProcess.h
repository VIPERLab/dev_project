//
//  FreeSingFileEchoProcess.h
//  KwSing
//
//  Created by 永杰 单 on 12-9-2.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_FreeSingFileEchoProcess_h
#define KwSing_FreeSingFileEchoProcess_h

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

#include <string>

class CFreeSingFileEchoProcess {
public:
    static void EchoProcess(std::string str_merge_file, EAudioEchoEffect echo_effect);
};

#endif
