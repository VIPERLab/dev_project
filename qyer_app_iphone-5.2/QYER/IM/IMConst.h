//
//  IMConst.h
//  QYER
//
//  Created by Frank on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  聊天类型
 */
typedef NS_ENUM(NSUInteger, ChatType) {
    /**
     *  私聊
     */
    ChatTypePrivate,
    /**
     *  聊天室
     */
    ChatTypePublic
};

static NSString *IMRootDirectory = @"/IM";

@interface IMConst : NSObject

@end
