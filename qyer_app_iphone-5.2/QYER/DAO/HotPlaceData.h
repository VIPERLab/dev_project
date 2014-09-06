//
//  HotPlaceData.h
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^HotPlaceDataSuccessBlock)(NSArray *array_country,NSArray *array_city);
typedef void (^HotPlaceDataFailedBlock)(void);
#endif


@interface HotPlaceData : NSObject

+(void)getHotPlaceListSuccess:(HotPlaceDataSuccessBlock)finishedBlock
                       failed:(HotPlaceDataFailedBlock)failedBlock;

@end
