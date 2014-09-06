//
//  ImageProcess.h
//  KwSing
//
//  Created by 单 永杰 on 13-2-27.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ImageProcess_h
#define KwSing_ImageProcess_h

#include "ImageEffectType.h"

class CImageProcess {
public:
    static UIImage* Process(UIImage* p_image, EImageEffectType e_effect_type);
};

#endif
