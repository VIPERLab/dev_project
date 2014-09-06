//
//  QYGuideCategory.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-25.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QYGuideCategory : NSObject <NSCoding>
{
    NSString    *_str_categoryId;           //分类id
    NSString    *_str_categoryName;         //分类名称
    NSString    *_str_categoryNameEn;       //分类英文名
    NSString    *_str_categoryNamePy;       //分类拼音
    NSString    *_str_guideCount;           //分类图片
    NSString    *_str_mobileGuideCount;     //副分类图片
    NSString    *_str_categoryImageUrl;     //HTML锦囊数
}

@property(nonatomic,retain) NSString    *str_categoryId;
@property(nonatomic,retain) NSString    *str_categoryName;
@property(nonatomic,retain) NSString    *str_categoryNameEn;
@property(nonatomic,retain) NSString    *str_categoryNamePy;
@property(nonatomic,retain) NSString    *str_guideCount;
@property(nonatomic,retain) NSString    *str_mobileGuideCount;
@property(nonatomic,retain) NSString    *str_categoryImageUrl;









//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
@property (retain, nonatomic) NSNumber *categoryId;
@property (retain, nonatomic) NSString *categoryName;
@property (retain, nonatomic) NSString *categoryNameEn;
@property (retain, nonatomic) NSString *categoryNamePy;
@property (retain, nonatomic) NSNumber *guideCount;
@property (retain, nonatomic) NSNumber *mobileGuideCount;
@property (retain, nonatomic) NSString *categoryImage;
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//************************************************************ fuck [ 为了兼容之前的版本,仅版本替换时使用 ]


@end
