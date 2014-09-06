//
//  QYGuideCategoryData.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-18.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^getCategorySuccessBlock)(NSArray *array);
typedef void (^getCategoryFailedBlock)(void);


@interface QYGuideCategoryData : NSObject

+(void)getGuideCategoryListMobile:(BOOL)bMobile
                     successBlock:(getCategorySuccessBlock)finishedBlock
                      failedBlock:(getCategoryFailedBlock)failedBlock;

@end
