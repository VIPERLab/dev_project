//
//  PlaceSearchData.h
//  QYER
//
//  Created by Frank on 14-4-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

#if NS_BLOCKS_AVAILABLE
typedef void (^PlaceSearchDataSuccessBlock)(NSArray *array);
typedef void (^PlaceSearchDataFailedBlock)(void);
#endif

@interface PlaceSearchData : NSObject

+ (void)searchDataByText:(NSString*)text page:(NSInteger)page success:(PlaceSearchDataSuccessBlock)finishedBlock
                        failed:(PlaceSearchDataFailedBlock)failedBlock;
@end
