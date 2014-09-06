//
//  QYImageUtil.h
//  QYER
//
//  Created by Frank on 14-6-23.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYImageUtil : NSObject

+ (NSData*)thumbnailWithImageWithoutScale:(UIImage *)image withMaxScale:(CGFloat)maxScale;

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;
@end
