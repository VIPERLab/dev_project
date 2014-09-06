//
//  ImgEffectParaFactory.h
//  KwSing
//
//  Created by 单 永杰 on 13-3-8.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ImgEffectParaFactory_h
#define KwSing_ImgEffectParaFactory_h

#include "ImageEffectType.h"
#include "ImageEffectStruct.h"

class CImgEffectParaFactory {
    
public:
    static CImageEffectStruct* CreateImageEffect(EImageEffectType e_effect_type);
};

#endif
