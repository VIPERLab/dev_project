//
//  QYImageUtil.m
//  QYER
//
//  Created by Frank on 14-6-23.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QYImageUtil.h"

@implementation QYImageUtil

/**
 *  图片最大KB数
 */
static CGFloat const kMaxImageLength = 150.0f;

+ (NSData*)thumbnailWithImageWithoutScale:(UIImage *)image withMaxScale:(CGFloat)maxScale
{
    CGFloat width = 0;
    CGFloat height = 0;
    if (image.size.width > maxScale || image.size.height > maxScale) {
        if (image.size.width > image.size.height) {
            width = maxScale;
            height = image.size.height / (image.size.width / width);
        }else{
            height = maxScale;
            width = image.size.width / (image.size.height / height);
        }
    }
    UIImage *thumbnail = image;
    if (width > 0 && height > 0) {
        thumbnail = [QYImageUtil thumbnailWithImageWithoutScale:image size:CGSizeMake(width, height)];
    }
    return [QYImageUtil imageToData:thumbnail];
}

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    if (!image) {
        return nil;
    }
    
    CGSize oldsize = image.size;
    CGRect rect;
    if (asize.width/asize.height > oldsize.width/oldsize.height) {
        rect.size.width = asize.height*oldsize.width/oldsize.height;
        rect.size.height = asize.height;
        rect.origin.x = (asize.width - rect.size.width)/2;
        rect.origin.y = 0;
    }
    else{
        rect.size.width = asize.width;
        rect.size.height = asize.width*oldsize.height/oldsize.width;
        rect.origin.x = 0;
        rect.origin.y = (asize.height - rect.size.height)/2;
    }
    UIGraphicsBeginImageContext(asize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
    [image drawInRect:rect];
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimage;
}

/**
 *  UIImage 转换成 NSData
 *
 *  @param image UIImage
 *
 *  @return NSData
 */
+ (NSData*)imageToData:(UIImage*)image
{
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    return data;
//    NSInteger length = data.length / 1024;
//    if (length < kMaxImageLength) { //如果图片大小低于150k，直接返回，不需要压缩
//        return data;
//    }else{
//        if (length > kMaxImageLength && length < 500) {
//            data = UIImageJPEGRepresentation(image, 0.6);
//        }else if (length > 500 && length < 1000) {
//            data = UIImageJPEGRepresentation(image, 0.5);
//        }else if (length > 1000 && length < 1500){
//            data = UIImageJPEGRepresentation(image, 0.3);
//        }else if (length > 1500 && length < 2000){
//            data = UIImageJPEGRepresentation(image, 0.1);
//        }
//    }
//    return data;
}

@end
