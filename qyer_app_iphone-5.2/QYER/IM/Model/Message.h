//
//  Message.h
//  IMTest
//
//  Created by Frank on 14-4-29.
//  Copyright (c) 2014年 Frank. All rights reserved.
//

#import "BaseModel.h"
#import "JSMessageData.h"
#import "JSBubbleImageViewFactory.h"
#import <UIKit/UIKit.h>

@class OtherMessage;
@class AnIMMessage;
@class UserInfo;
@interface Message : BaseModel<JSMessageData>

/**
 *  聊天室ID
 */
@property (nonatomic, copy) NSString *topicId;
/**
 * 消息ID
 */
@property (nonatomic, copy) NSString *messageId;
/**
 *  消息内容
 */
@property (nonatomic, copy) NSString *message;
/**
 *  发送者ID
 */
@property (nonatomic, copy) NSString *fromUserId;
/**
 *  发送者姓名
 */
@property (nonatomic, copy) NSString *fromUserName;
/**
 *  发送者头像
 */
@property (nonatomic, copy) NSString *fromUserAvatar;
/**
 *  接受者ID
 */
@property (nonatomic, copy) NSString *toUserId;
/**
 *  接受者姓名
 */
@property (nonatomic, copy) NSString *toUserName;
/**
 *  接受者头像
 */
@property (nonatomic, copy) NSString *toUserAvatar;
/**
 *  消息类型
 */
@property (nonatomic, assign) JSBubbleMediaType type;
/**
 *  发送时间
 */
@property (nonatomic, assign) long long timeSend;
/**
 *  接收时间
 */
@property (nonatomic, assign) long long timeReceive;
/**
 *  发送的文件
 */
@property (nonatomic, strong) NSData *fileData;
/**
 *  文件名
 */
@property (nonatomic, copy) NSString *fileName;
/**
 *  文件大小
 */
@property (nonatomic, copy) NSString *fileSize;
/**
 *  文件路径
 */
@property (nonatomic, copy) NSString *filePath;
/**
 *  时长
 */
@property (nonatomic, assign) NSInteger timeLen;
/**
 *  是否已读
 */
@property (nonatomic, assign) NSInteger isRead;
/**
 *  是否发送
 */
@property (nonatomic, assign) NSInteger isSend;
/**
 *  图片ID
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
/**
 * 其他数据
 */
@property (nonatomic, strong) OtherMessage *otherMessage;
/**
 * 新用户名称
 */
@property (nonatomic, copy) NSString *userName;
/**
 *  是否显示时间
 */
@property (nonatomic) BOOL showTimestamp;
/**
 *  小黑板ID
 */
@property (nonatomic, copy) NSString *wid;


#pragma mark
#pragma JSMessageData
/**
 *  The body text of the message. The default value is the empty string `@" "`. This value must not be `nil`.
 */
@property (copy, nonatomic) NSString *text;

/**
 *  The name of user who sent the message. The default value is `nil`.
 */
@property (copy, nonatomic) NSString *sender;

/**
 *  The date that the message was sent. The default value is `nil`.
 */
@property (strong, nonatomic) NSDate *date;

/**
 *  使用箭扣的Message初始化
 *
 *  @param anMessage 箭扣Message
 *
 *  @return
 */
- (id)initWithAnMessage:(AnIMMessage*)anMessage;


@end
