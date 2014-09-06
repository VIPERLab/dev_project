//
//  CoreImageProcess.mm
//  KwSing
//
//  Created by 单 永杰 on 13-3-7.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#include "CoreImageProcess.h"
#import <CoreImage/CIFilter.h>
#import <CoreImage/CoreImage.h>
#include "ImageMgr.h"
#include "ImgEffectParaFactory.h"

UIImage* CCoreImageProcess::Process(UIImage* p_input_img, EImageEffectType e_img_type){
    CImageEffectStruct* p_effect_para = CImgEffectParaFactory::CreateImageEffect(e_img_type);
    if (NULL == p_effect_para) {
        return p_input_img;
    }
    
    CIImage* p_src_img = [CIImage imageWithCGImage:p_input_img.CGImage];
    
    if (p_effect_para->b_hue) {
        CIFilter* p_filter_hue = [CIFilter filterWithName:@"CIHueAdjust"];
        [p_filter_hue setValue:p_src_img forKey:kCIInputImageKey];
        [p_filter_hue setValue:[NSNumber numberWithFloat:p_effect_para->f_hue] forKey:@"inputAngle"];
        p_src_img = [p_filter_hue outputImage];
    }
    
    CIFilter* p_filter_color = nil;
    if (p_effect_para->b_saturation) {
        p_filter_color = [CIFilter filterWithName:@"CIColorControls"];
        [p_filter_color setValue:p_src_img forKey:kCIInputImageKey];
        [p_filter_color setValue:[NSNumber numberWithFloat:p_effect_para->f_saturation] forKey:@"inputSaturation"];
    }
    if (p_effect_para->b_contrast) {
        if (nil == p_filter_color) {
            p_filter_color = [CIFilter filterWithName:@"CIColorControls"];
            [p_filter_color setValue:p_src_img forKey:kCIInputImageKey];
        }
        [p_filter_color setValue:[NSNumber numberWithFloat:p_effect_para->f_contrast] forKey:@"inputContrast"];
    }
    if (p_effect_para->b_brightness) {
        if (nil == p_filter_color) {
            p_filter_color = [CIFilter filterWithName:@"CIColorControls"];
            [p_filter_color setValue:p_src_img forKey:kCIInputImageKey];
        }
        [p_filter_color setValue:[NSNumber numberWithFloat:p_effect_para->f_brightness] forKey:@"inputBrightness"];
    }
    
    if (p_filter_color) {
        p_src_img = [p_filter_color outputImage];
    }
    
    CIFilter* p_blur_filter = nil;
    if (p_effect_para->b_gaussion_blur) {
        p_blur_filter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [p_blur_filter setValue:p_src_img forKey:kCIInputImageKey];
        [p_blur_filter setValue:[NSNumber numberWithFloat:p_effect_para->f_gaussion_blur] forKey:@"inputRadius"];
    }
    if (nil != p_blur_filter) {
        p_src_img = [p_blur_filter outputImage];
    }
    
    if (p_effect_para->b_color_curve) {
        CIFilter* p_img_filter_curve = [CIFilter filterWithName:@"CIToneCurve"];
        [p_img_filter_curve setValue:p_src_img forKey:kCIInputImageKey];
        
        [p_img_filter_curve setValue:[CIVector vectorWithX:0.0 Y:0.0] forKey:@"inputPoint0"];
        [p_img_filter_curve setValue:[CIVector vectorWithX:p_effect_para->point_first.f_x Y:p_effect_para->point_first.f_y] forKey:@"inputPoint1"];
        [p_img_filter_curve setValue:[CIVector vectorWithX:p_effect_para->point_second.f_x Y:p_effect_para->point_second.f_y] forKey:@"inputPoint2"];
        [p_img_filter_curve setValue:[CIVector vectorWithX:p_effect_para->point_third.f_x Y:p_effect_para->point_third.f_y] forKey:@"inputPoint3"];
        [p_img_filter_curve setValue:[CIVector vectorWithX:1.0 Y:1.0] forKey:@"inputPoint4"];
        
        p_src_img = [p_img_filter_curve outputImage];
    }
    
    CIContext* context=[CIContext contextWithOptions:nil];
    CGImageRef ref_cg_img = [context createCGImage:p_src_img fromRect:[p_src_img extent]];
    
    UIImage* p_dest_image = [UIImage imageWithCGImage:ref_cg_img];
    CGImageRelease(ref_cg_img);
    
    if (p_effect_para->b_template) {
        UIImage* img_template = CImageMgr::GetImageEx(p_effect_para->str_image_name.c_str());
        UIGraphicsBeginImageContext(img_template.size);
        [p_dest_image drawInRect:CGRectMake(0, 0, p_dest_image.size.width, p_dest_image.size.height)];
        [img_template drawInRect:CGRectMake(0, 0, img_template.size.width, img_template.size.height)];
        
        p_dest_image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    
    return p_dest_image;
}