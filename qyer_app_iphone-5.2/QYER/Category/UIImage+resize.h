//
//  UIImage+resize.h
//  TravelSubject
//
//  Created by chenguanglin on 14-7-18.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (resize)
/**
 *  返回一张自由拉伸的图片
 */
+ (UIImage *)resizedImageWithName:(NSString *)name;
+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;


+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
@end
