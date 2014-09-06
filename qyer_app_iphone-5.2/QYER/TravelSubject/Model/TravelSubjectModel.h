//
//  TravelSubjectModel.h
//  QYER
//
//  Created by chenguanglin on 14-7-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TravelSubjectModel : NSObject
/**
 *  微锦囊 ID
 */
@property (nonatomic, copy) NSString *ID;
/**
 *  背景图片
 */
@property (nonatomic, copy) NSString *photo;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  用户名
 */
@property (nonatomic, copy) NSString *userName;
/**
 *  用户头像
 */
@property (nonatomic, copy) NSString *avatar;
/**
 *  简介
 */
@property (nonatomic, copy) NSString *description;
/**
 *  旅行地数量
 */
@property (nonatomic, copy) NSString *count;

+ (instancetype)modelWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;


@end
