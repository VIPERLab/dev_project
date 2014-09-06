//
//  GuideDownloadTime.h
//  QYGuide
//
//  Created by 我去 on 14-2-19.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^GuideDownloadTimeSuccessBlock)(NSArray *array);
typedef void (^GuideDownloadTimeFailedBlock)(void);
#endif



@interface GuideDownloadTime : NSObject

+(void)getGuideDownloadTimeSuccessBlock:(GuideDownloadTimeSuccessBlock)finishedBlock
                            failedBlock:(GuideDownloadTimeFailedBlock)failedBlock;

@end
