//
//  TSDetailCellModel.h
//  TravelSubject
//
//  Created by chenguanglin on 14-7-21.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSDetailCellModel : NSObject
/**
 *  图片URL
 */
@property (nonatomic, copy) NSString *photo;
/**
 *  推荐星级
 */
@property (nonatomic, assign) float recommandstar;
/**
 *  简介
 */
@property (nonatomic, copy) NSString *description;
/**
 *  图片名
 */
@property (nonatomic, copy) NSString *title;
/**
 *  国家
 */
@property (nonatomic, copy) NSString *countryName;
/**
 *  城市
 */
@property (nonatomic, copy) NSString *cityName;
/**
 *  ID
 */
@property (nonatomic, copy) NSString *ID;


+ (instancetype)modelWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
