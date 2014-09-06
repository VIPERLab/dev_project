//
//  ImageEffectStruct.h
//  KwSing
//
//  Created by 单 永杰 on 13-3-8.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ImageEffectStruct_h
#define KwSing_ImageEffectStruct_h

#include <iostream>

struct CPoint {
    float f_x;
    float f_y;
};

struct CImageEffectStruct {
    bool b_hue;
    float f_hue;
    
    bool b_saturation;
    float f_saturation;
    
    bool b_contrast;
    float f_contrast;
    
    bool b_brightness;
    float f_brightness;
    
    bool b_gaussion_blur;
    float f_gaussion_blur;
    
    bool b_color_curve;
    CPoint point_first;
    CPoint point_second;
    CPoint point_third;
    
    bool b_template;
    std::string str_image_name;
};

#endif
