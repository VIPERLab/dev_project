//
//  PrivateChat.h
//  QYER
//
//  Created by 张伊辉 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrivateChat : NSObject
{
    
}
/**
 * PrivateChatID
 */
@property (nonatomic, copy) NSString *privateChatId;
/**
 * clientID
 */
@property (nonatomic, copy) NSString *clientId;
/**
 * 消息ID
 */
@property (nonatomic, copy) NSString *messageId;
/**
 *  最后一条消息内容
 */
@property (nonatomic, copy) NSString *lastMessage;

/**
 *  聊天对象 姓名
 */
@property (nonatomic, copy) NSString *chatUserName;
/**
 *  聊天对象 头像
 */
@property (nonatomic, copy) NSString *chatUserAvatar;
/**
 *  时间
 */
@property (nonatomic, strong)NSDate *lastTime;
/**
 *  未读消息个数
 */
@property (nonatomic,assign) NSInteger unReadNumber;
/**
 *  备用属性1
 */
@property (nonatomic, copy) NSString *attribute1;
/**
 *  备用属性2
 */
@property (nonatomic, copy) NSString *attribute2;
/**
 *  备用属性3
 */
@property (nonatomic, copy) NSString *attribute3;
/**
 *  备用属性4
 */
@property (nonatomic, assign) NSInteger attribute4;
/**
 *  备用属性5
 */
@property (nonatomic, assign) NSInteger attribute5;

+(PrivateChat *)prasePrivateChatWithDict:(NSDictionary *)dict;

@end

