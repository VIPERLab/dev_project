//
//  GetWidthOrHeight.m
//  QYGuide
//
//  Created by 我去 on 14-2-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GetWidthOrHeight.h"


@implementation GetWidthOrHeight


#pragma mark -
#pragma mark --- getWidth & getHeight
+(float)getWidthWithContent:(NSString *)content andFontName:(NSString *)fontName andFontSize:(float)fontSize andFixedHeight:(float)fix_height andMinLength:(float)minLength
{
    if(ios7)
    {
        fontName = nil;
    }
    
    float width = [self countWidthByString:content andFontName:fontName andFontSize:fontSize andFixedHeight:fix_height andMinWidth:minLength];
    return width;
}
+(float)getHeightWithContent:(NSString *)content andFontName:(NSString *)fontName andFontSize:(float)fontSize andFixedWidth:(float)fix_width andMinHeight:(float)minHeight
{
    if(ios7)
    {
        fontName = nil;
    }
    
    float height = [self countHeightByString:content andFontName:fontName andFontSize:fontSize andFixedWidth:fix_width andMinHeight:minHeight];
    return height;
}



#pragma mark -
#pragma mark --- 计算所需的高度或宽度
+(float)countHeightByString:(NSString *)content andFontName:(NSString *)fontName andFontSize:(float)fontSize andFixedWidth:(float)fixed_width andMinHeight:(float)minHeight
{
    if(fontName)
    {
        CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName size:fontSize] constrainedToSize:CGSizeMake(fixed_width, CGFLOAT_MAX)];
        float height = ((sizeToFit.height - minHeight > 0) ? sizeToFit.height : minHeight);
        return height;
    }
    else //系统的默认字体
    {
        CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(fixed_width, CGFLOAT_MAX)];
        float height = ((sizeToFit.height - minHeight > 0) ? sizeToFit.height : minHeight);
        return height;
    }
}
+(float)countWidthByString:(NSString *)content andFontName:(NSString *)fontName andFontSize:(float)fontSize andFixedHeight:(float)fixed_height andMinWidth:(float)minWidth
{
    if(fontName)
    {
        CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName size:fontSize] constrainedToSize:CGSizeMake(CGFLOAT_MAX, fixed_height)];
        float width = ((sizeToFit.width - minWidth > 0) ? sizeToFit.width : minWidth);
        return width;
    }
    else //系统的默认字体
    {
        CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(CGFLOAT_MAX, fixed_height)];
        float width = ((sizeToFit.width - minWidth > 0) ? sizeToFit.width : minWidth);
        return width;
    }
}


@end

