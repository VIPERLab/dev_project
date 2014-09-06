//
//  CoreImageProcess.h
//  KwSing
//
//  Created by 单 永杰 on 13-3-7.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CoreImageProcess_h
#define KwSing_CoreImageProcess_h

#import <UIKit/UIImage.h>
#import "ImageEffectType.h"

class CCoreImageProcess {
public:
    static UIImage* Process(UIImage* p_input_img, EImageEffectType e_img_type);
};

#endif
