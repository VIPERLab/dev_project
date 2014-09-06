//
//  ImgEffectParaFactory.mm
//  KwSing
//
//  Created by 单 永杰 on 13-3-8.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#include "ImgEffectParaFactory.h"

static CImageEffectStruct S_Image_Effect;

CImageEffectStruct* CImgEffectParaFactory::CreateImageEffect(EImageEffectType e_effect_type){
    switch (e_effect_type) {
        case EImageOrigion:
        {
            return NULL;
        }
        case EImageOldFilm:
        {
            S_Image_Effect.b_hue = true;
            S_Image_Effect.f_hue = 0.55;
            
            S_Image_Effect.b_saturation = false;
            
            S_Image_Effect.b_contrast = true;
            S_Image_Effect.f_contrast = 0.85;
            
            S_Image_Effect.b_brightness = true;
            S_Image_Effect.f_brightness = -0.11;
            
            S_Image_Effect.b_gaussion_blur = false;
            
            S_Image_Effect.b_color_curve = true;
            S_Image_Effect.point_first.f_x = 0.251;
            S_Image_Effect.point_first.f_y = 0.196;
            S_Image_Effect.point_second.f_x = 0.5;
            S_Image_Effect.point_second.f_y = 0.5;
            S_Image_Effect.point_third.f_x = 0.686;
            S_Image_Effect.point_third.f_y = 0.765;
            
            S_Image_Effect.b_template = true;
            S_Image_Effect.str_image_name = "OldFilm.png";

            break;
        }
        case EImageSunny:
        {
            S_Image_Effect.b_hue = true;
            S_Image_Effect.f_hue = 0.6;//OK
            
            S_Image_Effect.b_saturation = true;
            S_Image_Effect.f_saturation = 1.5;//OK
            
            S_Image_Effect.b_contrast = true;
            S_Image_Effect.f_contrast = 1.2;
            
            S_Image_Effect.b_brightness = true;
            S_Image_Effect.f_brightness = 0.2;
            
            S_Image_Effect.b_gaussion_blur = false;
            
            S_Image_Effect.b_color_curve = false;
            
            S_Image_Effect.b_template = true;
            S_Image_Effect.str_image_name = "1m_sunny.png";

            break;
        }
        case EImageMemory:
        {
            S_Image_Effect.b_hue = true;
            S_Image_Effect.f_hue = -0.2;
            
            S_Image_Effect.b_saturation = true;
            S_Image_Effect.f_saturation = 0.4;
            
            S_Image_Effect.b_contrast = true;
            S_Image_Effect.f_contrast = 1.2;
            
            S_Image_Effect.b_brightness = false;
            
            S_Image_Effect.b_gaussion_blur = false;
            
            S_Image_Effect.b_color_curve = false;
            
            S_Image_Effect.b_template = true;
            S_Image_Effect.str_image_name = "memory.png";
            
            break;
        }
            
        case EImageSuperStar:
        {
            S_Image_Effect.b_hue = false;
            
            S_Image_Effect.b_saturation = false;
            
            S_Image_Effect.b_contrast = true;
            S_Image_Effect.f_contrast = 1.2;
            
            S_Image_Effect.b_brightness = false;
            
            S_Image_Effect.b_gaussion_blur = false;
            
            S_Image_Effect.b_color_curve = false;
            
            S_Image_Effect.b_template = true;
            S_Image_Effect.str_image_name = "SuperStar.png";
            
            break;
        }
        case EImageBW:
        {
            S_Image_Effect.b_hue = false;
            
            S_Image_Effect.b_saturation = true;
            S_Image_Effect.f_saturation = 0;
            
            S_Image_Effect.b_contrast = false;
            
            S_Image_Effect.b_brightness = false;
            
            S_Image_Effect.b_gaussion_blur = false;
            
            S_Image_Effect.b_color_curve = false;
            
            S_Image_Effect.b_template = true;
            S_Image_Effect.str_image_name = "filter_bw.png";
            
            break;
        }
        case EImageCharm:{
            S_Image_Effect.b_hue = true;
            S_Image_Effect.f_hue = 0.25;
            
            S_Image_Effect.b_saturation = true;
            S_Image_Effect.f_saturation = 1.4;
            
            S_Image_Effect.b_contrast = true;
            S_Image_Effect.f_contrast = 1.1;
            
            S_Image_Effect.b_brightness = false;
            
            S_Image_Effect.b_gaussion_blur = true;
            S_Image_Effect.f_gaussion_blur = 0.9;
            
            S_Image_Effect.b_color_curve = true;
            S_Image_Effect.point_first.f_x = 0.204;
            S_Image_Effect.point_first.f_y = 0.24;
            S_Image_Effect.point_second.f_x = 0.5;
            S_Image_Effect.point_second.f_y = 0.5;
            S_Image_Effect.point_third.f_x = 0.765;
            S_Image_Effect.point_third.f_y = 0.733;
            
            S_Image_Effect.b_template = true;
            S_Image_Effect.str_image_name = "charm_filter.png";
            
            break;
        }
            
        default:
            break;
    }
    
    return &S_Image_Effect;
}