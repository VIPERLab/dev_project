//
//  QYMoreAppData.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-15.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYMoreAppData : NSObject

typedef void (^QYMoreAppDataSuccessBlock)(NSArray *array);
typedef void (^QYMoreAppDataFaiedBlock)(void);

+(void)getMoreApplicationSuccess:(QYMoreAppDataSuccessBlock)successBlock
                         failure:(QYMoreAppDataFaiedBlock)failedBlock;

@end
