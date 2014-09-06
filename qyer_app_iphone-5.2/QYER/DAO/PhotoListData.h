//
//  PhotoListData.h
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^PhotoListDataSuccessBlock)(NSArray *array_photoListData);
typedef void (^PhotoListDataFailedBlock)(void);
#endif



@interface PhotoListData : NSObject

+(void)getPhotoListByType:(NSString *)type
              andObjectId:(NSString *)str_id
                  success:(PhotoListDataSuccessBlock)finishedBlock
                   failed:(PhotoListDataFailedBlock)failedBlock;

@end
