//
//  QYGuideCategory.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-25.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QYGuideCategory.h"

@implementation QYGuideCategory
@synthesize str_categoryId = _str_categoryId;
@synthesize str_categoryImageUrl = _str_categoryImageUrl;
@synthesize str_categoryName = _str_categoryName;
@synthesize str_categoryNameEn = _str_categoryNameEn;
@synthesize str_categoryNamePy = _str_categoryNamePy;
@synthesize str_guideCount = _str_guideCount;
@synthesize str_mobileGuideCount = _str_mobileGuideCount;



//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
@synthesize categoryId,categoryName,categoryNameEn,categoryNamePy,guideCount,mobileGuideCount,categoryImage;
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]





-(void)dealloc
{
    self.str_mobileGuideCount = nil;
    self.str_guideCount = nil;
    self.str_categoryNamePy = nil;
    self.str_categoryNameEn = nil;
    self.str_categoryName = nil;
    self.str_categoryImageUrl = nil;
    self.str_categoryId = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.str_categoryId = [aDecoder decodeObjectForKey:@"str_categoryId"];
        self.str_categoryName = [aDecoder decodeObjectForKey:@"str_categoryName"];
        self.str_categoryNameEn = [aDecoder decodeObjectForKey:@"str_categoryNameEn"];
        self.str_categoryNamePy = [aDecoder decodeObjectForKey:@"str_categoryNamePy"];
        self.str_guideCount = [aDecoder decodeObjectForKey:@"str_guideCount"];
        self.str_mobileGuideCount = [aDecoder decodeObjectForKey:@"str_mobileGuideCount"];
        self.str_categoryImageUrl = [aDecoder decodeObjectForKey:@"str_categoryImageUrl"];
        
        
        
        
        
        //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        self.categoryId = [aDecoder decodeObjectForKey:@"categoryId"];
        self.categoryName = [aDecoder decodeObjectForKey:@"categoryName"];
        self.categoryNameEn = [aDecoder decodeObjectForKey:@"categoryNameEn"];
        self.categoryNamePy = [aDecoder decodeObjectForKey:@"categoryNamePy"];
        self.guideCount = [aDecoder decodeObjectForKey:@"guideCount"];
        self.mobileGuideCount = [aDecoder decodeObjectForKey:@"mobileGuideCount"];
        self.categoryImage = [aDecoder decodeObjectForKey:@"categoryImage"];
        //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_categoryId forKey:@"str_categoryId"];
    [aCoder encodeObject:self.str_categoryName forKey:@"str_categoryName"];
    [aCoder encodeObject:self.str_categoryNameEn forKey:@"str_categoryNameEn"];
    [aCoder encodeObject:self.str_categoryNamePy forKey:@"str_categoryNamePy"];
    [aCoder encodeObject:self.str_guideCount forKey:@"str_guideCount"];
    [aCoder encodeObject:self.str_mobileGuideCount forKey:@"str_mobileGuideCount"];
    [aCoder encodeObject:self.str_categoryImageUrl forKey:@"str_categoryImageUrl"];
    
    
    
    
    //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    [aCoder encodeObject:self.categoryId forKey:@"categoryId"];
    [aCoder encodeObject:self.categoryName forKey:@"categoryName"];
    [aCoder encodeObject:self.categoryNameEn forKey:@"categoryNameEn"];
    [aCoder encodeObject:self.categoryNamePy forKey:@"categoryNamePy"];
    [aCoder encodeObject:self.guideCount forKey:@"guideCount"];
    [aCoder encodeObject:self.mobileGuideCount forKey:@"mobileGuideCount"];
    [aCoder encodeObject:self.categoryImage forKey:@"categoryImage"];
    //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    //************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    
}


@end


