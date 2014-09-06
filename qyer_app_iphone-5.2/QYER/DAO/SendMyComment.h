//
//  SendMyComment.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^sendMyCommentFinishedBlock)(void);
typedef void (^sendMyCommentFailedBlock)(NSString *info);
#endif


@interface SendMyComment : NSObject

+(void)sendMyCommentByAccessToken:(NSString *)accessToken
                       andGuideId:(NSString *)guideid
                   andCommentText:(NSString *)comment
                         finished:(sendMyCommentFinishedBlock)finished
                           failed:(sendMyCommentFailedBlock)failed;

@end
