//
//  AllPlaceData.h
//  QYER
//
//  Created by Frank on 14-3-26.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

#if NS_BLOCKS_AVAILABLE
typedef void (^AllPlaceDataSuccessBlock)(NSArray *countries);
typedef void (^AllPlaceDataFailedBlock)(enum QYRequestFailedType type);
#endif

/**
 *	@brief	查询所有目的地数据的类
 */
@interface AllPlaceData : NSObject

/**
 *	@brief	查询所有目的地数据
 *  @param  finishedBlock       查询成功的Block方法
 *  @param  reuseIdentifier     查询失败的Block方法
 */
+ (void)getAllPlaceListSuccess:(AllPlaceDataSuccessBlock)finishedBlock
                        failed:(AllPlaceDataFailedBlock)failedBlock;

@end
