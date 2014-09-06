//
//  GetWidthOrHeight.h
//  QYGuide
//
//  Created by 我去 on 14-2-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetWidthOrHeight : NSObject

+(float)getWidthWithContent:(NSString *)content andFontName:(NSString *)fontName andFontSize:(float)fontSize andFixedHeight:(float)height andMinLength:(float)minLength;
+(float)getHeightWithContent:(NSString *)content andFontName:(NSString *)fontName andFontSize:(float)fontSize andFixedWidth:(float)length andMinHeight:(float)minHeight;

@end
