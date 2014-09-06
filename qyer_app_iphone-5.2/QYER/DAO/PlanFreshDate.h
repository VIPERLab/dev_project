//
//  PlanFreshDate.h
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-11.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^PlanFreshDateFinishedBlock)(void);
typedef void (^PlanFreshDateFailedBlock)(void);
#endif


@interface PlanFreshDate : NSObject

+(void)isFresh:(NSString *)str_planId
      finished:(PlanFreshDateFinishedBlock)finished
        failed:(PlanFreshDateFailedBlock)failed;

@end
