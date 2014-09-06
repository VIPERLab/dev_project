//
//  CountryList.h
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryList : NSObject <NSCoding>
{
    NSString    *_str_catename;     //中文名称
    NSString    *_str_catename_en;  //英文名
    NSString    *_str_photo;        //封面图
    NSString    *_str_ishot;        //是否热门国家,为true时为热门
}

@property(nonatomic,retain) NSString    *str_catename;     //中文名称
@property(nonatomic,retain) NSString    *str_catename_en;  //英文名
@property(nonatomic,retain) NSString    *str_photo;        //封面图
@property(nonatomic,retain) NSString    *str_ishot;        //是否热门国家,为true时为热门

//********** Insert By ZhangDong 2014.3.27 Start **********
/**
 *  @brief 洲id
 */
@property(nonatomic,retain) NSString    *str_id;

/**
 *  @brief 城市或者POI个数
 */
@property (nonatomic, assign) NSInteger count;

/**
 *  @brief 类型
 */
@property (nonatomic, assign) NSInteger flag;

/**
 *  @brief 类型名称
 */
@property (nonatomic, retain) NSString *label;


/**
 *  使用字典初始化
 *
 *  @param dict 
 *
 *  @return
 */
- (id)initWithDictionary:(NSDictionary*)dict;
//********** Insert By ZhangDong 2014.3.27 End **********
@end
