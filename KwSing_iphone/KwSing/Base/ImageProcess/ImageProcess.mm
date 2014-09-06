//
//  ImageProcess.mm
//  KwSing
//
//  Created by 单 永杰 on 13-2-27.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#include "ImageProcess.h"

const float lomo_color_matrix[] = {
    1.7f, 0.1f, 0.1f, 0,    -73.1f,
    0,    1.7f, 0.1f, 0,    -73.1f,
    0,    0.1f, 1.6f, 0,    -73.1f,
    0,    0,    0,    1.0f, 0
};

const float blue_color_matrix[] = {
    2.1f, -1.4f, 0.6f, 0.0f, -31.0f,
    -0.3f, 2.0f, -0.3f, 0.0f, -31.0f,
    -1.1f, -0.2f, 2.6f, 0.0f, -31.0f,
    0.0f,  0.0f,  0.0f, 1.0f, 0.0f
};

const float night_color_matrix[] = {
    1.0f, 0.0f, 0.0f, 0.0f, -66.6f,
    0.0f, 1.1f, 0.0f, 0.0f, -66.6f,
    0.0f, 0.0f, 1.0f, 0.0f, -66.6f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

const float gothic_color_matrix[] = {
    1.9f, -0.3f, -0.2f, 0, -87.0f,
    -0.2f, 1.7f, -0.1f, 0, -87.0f,
    -0.1f, -0.6f, 2.0f, 0, -87.0f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

CGContextRef CreateRGBABitmapContext(CGImageRef in_image){
    CGContextRef context = NULL;
    CGColorSpaceRef color_space = NULL;
    void* p_bitmap_data = NULL;
    int n_bitmap_byte_count(0);
    int n_bitmap_byte_per_row(0);
    
    size_t un_pixel_width = CGImageGetWidth(in_image);
    size_t un_pixel_height = CGImageGetHeight(in_image);
    n_bitmap_byte_per_row = un_pixel_width * 4;
    n_bitmap_byte_count = un_pixel_height * n_bitmap_byte_per_row;
    color_space = CGColorSpaceCreateDeviceRGB();
    if (NULL == color_space) {
        return NULL;
    }
    
    p_bitmap_data = malloc(n_bitmap_byte_count);
    if (NULL == p_bitmap_data) {
        CGColorSpaceRelease(color_space);
        return NULL;
    }
    
    context = CGBitmapContextCreate(p_bitmap_data, un_pixel_width, un_pixel_height, 8, n_bitmap_byte_per_row, color_space, kCGImageAlphaPremultipliedLast);
    if (NULL == context) {
        free(p_bitmap_data);
    }
    CGColorSpaceRelease(color_space);
    
    return context;
}

unsigned char* RequestImagePixelData(UIImage* p_in_image){
    CGImageRef image = [p_in_image CGImage];
    CGSize cg_size = [p_in_image size];
    CGContextRef cg_context_ref = CreateRGBABitmapContext(image);
    if (NULL == cg_context_ref) {
        return NULL;
    }
    
    CGRect cg_rect = {{0, 0}, {cg_size.width, cg_size.height}};
    CGContextDrawImage(cg_context_ref, cg_rect, image);
    unsigned char* p_data = (unsigned char*)CGBitmapContextGetData(cg_context_ref);
    CGContextRelease(cg_context_ref);
    
    return p_data;
}

void ChangeRGBA(int& n_red, int& n_green, int& n_blue, int& n_alpha, const float* f_matrix){
    int n_red_v(n_red), n_green_v(n_green), n_blue_v(n_blue), n_alpha_v(n_alpha);
    n_red = f_matrix[0] * n_red_v + f_matrix[1] * n_green_v + f_matrix[2] * n_blue_v + f_matrix[3] * n_alpha_v + f_matrix[4];
    n_green = f_matrix[0 + 5] * n_red_v + f_matrix[1 + 5] * n_green_v + f_matrix[2 + 5] * n_blue_v + f_matrix[3 + 5] * n_alpha_v + f_matrix[4 + 5];
    n_blue = f_matrix[0 + 5 * 2] * n_red_v + f_matrix[1 + 5 * 2] * n_green_v + f_matrix[2 + 5 * 2] * n_blue_v + f_matrix[3 + 5 * 2] * n_alpha_v + f_matrix[4 + 5 * 2];
    n_alpha = f_matrix[0 + 5 * 3] * n_red_v + f_matrix[1 + 5 * 3] * n_green_v + f_matrix[2 + 5 * 3] * n_blue_v + f_matrix[3 + 5 * 3] * n_alpha_v + f_matrix[4 + 5 * 3];
    
    n_red = n_red > 255 ? 255 : n_red;
    n_red = n_red < 0 ? 0 : n_red;
    
    n_green = n_green > 255 ? 255 : n_green;
    n_green = n_green < 0 ? 0 : n_green;
    
    n_blue = n_blue > 255 ? 255 : n_blue;
    n_blue = n_blue < 0 ? 0 : n_blue;
    
    n_alpha = n_alpha > 255 ? 255 : n_alpha;
    n_alpha = n_alpha < 0 ? 0 : n_alpha;
}

UIImage* CImageProcess::Process(UIImage *p_image, EImageEffectType e_effect_type){
    
/*    if (p_image == nil) {
        return nil;
    }
    unsigned char* p_img_pixel = RequestImagePixelData(p_image);
    CGImageRef in_image_ref = [p_image CGImage];
    GLuint un_width = CGImageGetWidth(in_image_ref);
    GLuint un_height = CGImageGetHeight(in_image_ref);
    
    int n_woff(0);
    int n_pixoff(0);
    
    switch (e_effect_type) {
        case EImageOrigion:
        {
            return p_image;
        }
        case EImageBW:
        {
            for (GLuint n_y = 0; n_y < un_height; ++n_y) {
                n_pixoff = n_woff;
                
                for (GLuint n_x = 0; n_x < un_width; ++n_x) {
                    int n_red = (unsigned char)p_img_pixel[n_pixoff];
                    int n_green = (unsigned char)p_img_pixel[n_pixoff + 1];
                    int n_blue = (unsigned char)p_img_pixel[n_pixoff + 2];
                    
                    int n_new_value = (int)((n_red + n_green + n_blue) / 3.0);
                    //int n_new_value = n_average > 128 ? 255 : 0;
                    p_img_pixel[n_pixoff] = n_new_value;
                    p_img_pixel[n_pixoff + 1] = n_new_value;
                    p_img_pixel[n_pixoff + 2] = n_new_value;
                    
                    n_pixoff += 4;
                }
                
                n_woff += un_width * 4;
            }
            
            break;
        }
        case EImageLomo:
        {
            for (GLuint un_y = 0; un_y < un_height; ++un_y) {
                n_pixoff = n_woff;
                
                for (GLuint un_x = 0; un_x < un_width; ++un_x) {
                    int n_red = (unsigned char)p_img_pixel[n_pixoff];
                    int n_green = (unsigned char)p_img_pixel[n_pixoff + 1];
                    int n_blue = (unsigned char)p_img_pixel[n_pixoff + 2];
                    int n_alpha = (unsigned char)p_img_pixel[n_pixoff + 3];
                    
                    ChangeRGBA(n_red, n_green, n_blue, n_alpha, lomo_color_matrix);
                    p_img_pixel[n_pixoff] = n_red;
                    p_img_pixel[n_pixoff + 1] = n_green;
                    p_img_pixel[n_pixoff + 2] = n_blue;
                    p_img_pixel[n_pixoff + 3] = n_alpha;
                    
                    n_pixoff += 4;
                }
                
                n_woff += un_width * 4;
            }
            
            break;
        }
        case EImageNight:
        {
            for (GLuint un_y = 0; un_y < un_height; ++un_y) {
                n_pixoff = n_woff;
                
                for (GLuint un_x = 0; un_x < un_width; ++un_x) {
                    int n_red = (unsigned char)p_img_pixel[n_pixoff];
                    int n_green = (unsigned char)p_img_pixel[n_pixoff + 1];
                    int n_blue = (unsigned char)p_img_pixel[n_pixoff + 2];
                    int n_alpha = (unsigned char)p_img_pixel[n_pixoff + 3];
                    
                    ChangeRGBA(n_red, n_green, n_blue, n_alpha, night_color_matrix);
                    p_img_pixel[n_pixoff] = n_red;
                    p_img_pixel[n_pixoff + 1] = n_green;
                    p_img_pixel[n_pixoff + 2] = n_blue;
                    p_img_pixel[n_pixoff + 3] = n_alpha;
                    
                    n_pixoff += 4;
                }
                
                n_woff += un_width * 4;
            }
            
            break;
        }
        case EImageBlue:
        {
            for (GLuint un_y = 0; un_y < un_height; ++un_y) {
                n_pixoff = n_woff;
                
                for (GLuint un_x = 0; un_x < un_width; ++un_x) {
                    int n_red = (unsigned char)p_img_pixel[n_pixoff];
                    int n_green = (unsigned char)p_img_pixel[n_pixoff + 1];
                    int n_blue = (unsigned char)p_img_pixel[n_pixoff + 2];
                    int n_alpha = (unsigned char)p_img_pixel[n_pixoff + 3];
                    
                    ChangeRGBA(n_red, n_green, n_blue, n_alpha, blue_color_matrix);
                    p_img_pixel[n_pixoff] = n_red;
                    p_img_pixel[n_pixoff + 1] = n_green;
                    p_img_pixel[n_pixoff + 2] = n_blue;
                    p_img_pixel[n_pixoff + 3] = n_alpha;
                    
                    n_pixoff += 4;
                }
                
                n_woff += un_width * 4;
            }
            
            break;
        }
        case EImageGothic:
        {
            for (GLuint un_y = 0; un_y < un_height; ++un_y) {
                n_pixoff = n_woff;
                
                for (GLuint un_x = 0; un_x < un_width; ++un_x) {
                    int n_red = (unsigned char)p_img_pixel[n_pixoff];
                    int n_green = (unsigned char)p_img_pixel[n_pixoff + 1];
                    int n_blue = (unsigned char)p_img_pixel[n_pixoff + 2];
                    int n_alpha = (unsigned char)p_img_pixel[n_pixoff + 3];
                    
                    ChangeRGBA(n_red, n_green, n_blue, n_alpha, gothic_color_matrix);
                    p_img_pixel[n_pixoff] = n_red;
                    p_img_pixel[n_pixoff + 1] = n_green;
                    p_img_pixel[n_pixoff + 2] = n_blue;
                    p_img_pixel[n_pixoff + 3] = n_alpha;
                    
                    n_pixoff += 4;
                }
                
                n_woff += un_width * 4;
            }
            
            break;
        }
        case EImageScanLine:
        {
            for (GLuint un_y = 0; un_y < un_height; un_y+=2) {
                n_pixoff = n_woff;
                
                for (GLuint un_x = 0; un_x < un_width; ++un_x) {
                    int n_red = (unsigned char)p_img_pixel[n_pixoff];
                    int n_green = (unsigned char)p_img_pixel[n_pixoff + 1];
                    int n_blue = (unsigned char)p_img_pixel[n_pixoff + 2];
                    
                    int n_new_red(0), n_new_green(0), n_new_blue(0);
                    
                    int n_rr = n_red * 2;
                    n_new_red = n_rr > 255 ? 255 : n_rr;
                    
                    int n_gg = n_green * 2;
                    n_new_green = n_gg > 255 ? 255 : n_gg;
                    
                    int n_bb = n_blue * 2;
                    n_new_blue = n_bb > 255 ? 255 : n_bb;
                    
                    p_img_pixel[n_pixoff] = n_new_red;
                    p_img_pixel[n_pixoff + 1] = n_new_green;
                    p_img_pixel[n_pixoff + 2] = n_new_blue;
                    
                    n_pixoff += 4;
                }
                
                n_woff += un_width * 4 * 2;
            }
            
            break;
        }
        case EImageCube:
        {
            unsigned char* p_image_temp = new unsigned char[un_width * un_height * 4];
            memcpy(p_image_temp, p_img_pixel, un_width * un_height * 4);
            n_woff = un_width * 4 + 4;
            
            for (GLuint un_y = 1; un_y < un_height; ++un_y) {
                n_pixoff = n_woff;
                for (GLuint un_x = 1; un_x < un_width; ++un_x) {
                    int n_red_pre = (unsigned char)p_image_temp[n_pixoff - un_width * 4 - 4];
                    int n_green_pre = (unsigned char)p_image_temp[n_pixoff - un_width * 4 - 3];
                    int n_blue_pre = (unsigned char)p_image_temp[n_pixoff - un_width * 4 - 2];
                    
                    int n_red_cur = (unsigned char)p_image_temp[n_pixoff];
                    int n_green_cur = (unsigned char)p_image_temp[n_pixoff + 1];
                    int n_blue_cur = (unsigned char)p_image_temp[n_pixoff + 2];
                    
                    int n_new_red(0), n_new_green(0), n_new_blue(0);
                    n_new_red = n_red_cur + 0.25 * abs(n_red_cur - n_red_pre);
                    n_new_green = n_green_cur + 0.25 * abs(n_green_cur - n_green_pre);
                    n_new_blue = n_blue_cur + 0.25 * abs(n_blue_cur - n_blue_pre);
                    
                    p_img_pixel[n_pixoff] = n_new_red;
                    p_img_pixel[n_pixoff + 1] = n_new_green;
                    p_img_pixel[n_pixoff + 2] = n_new_blue;
                    
                    n_pixoff += 4;
                }
                n_woff += (un_width * 4);
            }
            
            delete [] p_image_temp;
            p_image_temp = NULL;
            
            break;
        }
        case EImageEmbossm:
        {
            unsigned char* p_image_temp = new unsigned char[un_width * un_height * 4];
            memcpy(p_image_temp, p_img_pixel, un_width * un_height * 4);
            n_woff = un_width * 4 + 4;
            
            for (GLuint un_y = 1; un_y < un_height; ++un_y) {
                n_pixoff = n_woff;
                for (GLuint un_x = 1; un_x < un_width; ++un_x) {
                    int n_red_pre = (unsigned char)p_image_temp[n_pixoff - 4];
                    int n_green_pre = (unsigned char)p_image_temp[n_pixoff - 3];
                    int n_blue_pre = (unsigned char)p_image_temp[n_pixoff - 2];
                    
                    int n_red_cur = (unsigned char)p_image_temp[n_pixoff];
                    int n_green_cur = (unsigned char)p_image_temp[n_pixoff + 1];
                    int n_blue_cur = (unsigned char)p_image_temp[n_pixoff + 2];
                    
                    int n_new_red(0), n_new_green(0), n_new_blue(0);
                    n_new_red = 128 + (n_red_cur - n_red_pre);
                    n_new_green = 128 + (n_green_cur - n_green_pre);
                    n_new_blue = 128 + (n_blue_cur - n_blue_pre);
                    
                    p_img_pixel[n_pixoff] = n_new_red;
                    p_img_pixel[n_pixoff + 1] = n_new_green;
                    p_img_pixel[n_pixoff + 2] = n_new_blue;
                    
                    n_pixoff += 4;
                }
                n_woff += un_width * 4;
            }
            
            delete [] p_image_temp;
            p_image_temp = NULL;
            
            break;
        }
        default:
            break;
    }
    
    
    NSInteger n_data_len = un_width * un_height * 4;
    CGDataProviderRef ref_provider = CGDataProviderCreateWithData(NULL, p_img_pixel, n_data_len, NULL);
    int n_bits_per_component(8);
    int n_bits_per_Pixel(32);
    int n_bytes_per_row = 4 * un_width;
    CGColorSpaceRef color_space_ref = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmap_info = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent render_intent = kCGRenderingIntentDefault;
    
    CGImageRef image_ref = CGImageCreate(un_width, un_height, n_bits_per_component, n_bits_per_Pixel, n_bytes_per_row, color_space_ref, bitmap_info, ref_provider, NULL, false, render_intent);
    UIImage* p_image_result = [UIImage imageWithCGImage:image_ref];
    
    CFRelease(image_ref);
    CGColorSpaceRelease(color_space_ref);
    CGDataProviderRelease(ref_provider);
    
    return p_image_result;*/
    return NULL;
}

