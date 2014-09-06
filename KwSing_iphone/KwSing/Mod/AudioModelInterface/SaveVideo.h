//
//  SaveVideo.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CSaveVideo_h
#define KwSing_CSaveVideo_h

#ifndef KwSing_CMediaSaveInterface_h
#include "MediaSaveInterface.h"
#endif

class CSaveVidio : public CMediaSaveInterface{
public:
    virtual ~CSaveVidio(){};
    virtual bool SaveFile();
};

#endif
