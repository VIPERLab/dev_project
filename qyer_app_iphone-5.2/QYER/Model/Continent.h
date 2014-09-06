//
//  Continent.h
//  QYER
//
//  Created by Frank on 14-3-26.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
/**
 *	@brief	洲的Model类
 */
@interface Continent : BaseModel


/**
 *	@brief	中文名称
 */
@property (nonatomic, retain) NSString *catename;

/**
 *	@brief	英文名称
 */
@property (nonatomic, retain) NSString *catename_en;

/**
 *	@brief	缩略图
 */
@property (nonatomic, retain) NSString *photo;

/**
 *	@brief	热门国家
 */
@property (nonatomic, retain) NSArray *hotcountrylist;

/**
 *	@brief	其他国家
 */
@property (nonatomic, retain) NSArray *countrylist;

@end
