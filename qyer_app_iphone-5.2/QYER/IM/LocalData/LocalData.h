//
//  LocalData.h
//  IMTest
//
//  Created by Frank on 14-4-25.
//  Copyright (c) 2014年 Frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMConst.h"
@class Message;
@class UserInfo;
@class PrivateChat;

/**
 *  本地消息数据库
 */
@interface LocalData : NSObject
{
    
}
/**
 *  单例初始化
 *
 *  @return
 */
+ (LocalData*)getInstance;

/**
 *  根据表名查询一条数据
 *
 *  @param tableName 表名
 *  @param messageId id
 *
 *  @return 当前消息
 */
- (Message*)queryWithTableName:(NSString*)tableName withMessageId:(NSString*)messageId;

/**
 *  根据表名查询一条数据
 *
 *  @param tableName 表名
 *  @param timeSend  消息发送时间
 *
 *  @return 当前消息
 */
- (Message*)queryWithTableName:(NSString*)tableName withTimeSend:(long long)timeSend;

/**
 *  增加一条数据
 *
 *  @param tableName 表名
 *  @param message   增加的消息
 */
- (void)insertWithTableName:(NSString*)tableName withObject:(Message*)message;

#pragma mark --privateChatList
//insert by yihui


/**
 *  增加一条数据
 *
 *  @param tableName 表名
 *  @param chatObj   增加的消息
 */
- (void)insertPrivateChatWithTableName:(NSString *)tableName withObject:(PrivateChat *)chatObj;
- (void)insertReplacePrivateChatWithTableName:(NSString *)tableName withObject:(PrivateChat *)chatObj;
/**
 *  根据表名查询
 *
 *  @param tableName 表名
 *
 *  @return 查询返回的结果
 */
- (NSMutableArray*)queryPrivateChatWithTableName:(NSString*)tableName;
/**
 *  重新设置未读消息个数
 *
 *  @param tableName
 */
- (void)resetPrivateChatUnReadNumberTableName:(NSString *)tableName withObject:(PrivateChat *)chatObj;
/**
 *
 *  重新设置未读消息个数
 *  @param tableName
 */
- (void)resetAllPrivateChatUnReadNumberTableName:(NSString *)tableName;
/**
 *  删除某一条私信记录
 *
 *  @param clientId 聊天对象ID
 */
- (void)deleteItemFromPrivateChatWithCliendId:(NSString *)clientId;
/**
 *  清空私信列表
 */
- (void)clearPrivateChat;
/**
 *  修改发送状态 0:未发送，1:已发送，2:发送失败
 *
 *  @param message
 */
- (void)updateIsSendWithMessage:(Message*)message;

/**
 *  修改发送内容
 *
 *  @param message
 */
- (void)updateMessageContentWithMessage:(Message*)message;

/**
 *  修改数据的MessageId
 *
 *  @param message
 */
- (void)updateMessageIdWithMessage:(Message*)message;

/**
 *  删除一条记录
 *
 *  @param message
 */
- (void)deleteWithMessage:(Message*)message;

/**
 *  查询某个时间之前的消息
 *
 *  @param tableName 表名
 *  @param timeSend  发送时间
 *  @param isOffline 是否离线消息
 *
 *  @return 
 */
- (NSMutableArray*)queryLocalMessages:(NSString*)tableName timeSend:(long long)timeSend isOffline:(BOOL)isOffline;

/**
 *  数据库是否为空
 *
 *  @param tableName 表名
 *
 *  @return
 */
- (BOOL)isEmptyWithTableName:(NSString*)tableName;

/**
 *  生成数据库文件夹
 *
 *  @param tableName
 *
 *  @return
 */
- (NSString*)dbFilePath;

#pragma mark - USER
/**
 *  通过USERID查询user对象
 *
 *  @param imUserId imUserId
 *
 *  @return UserInfo对象
 */
- (UserInfo*)queryUserWithImUserId:(NSString*)imUserId;

/**
 *  增加或者修改UserInfo对象
 *
 *  @param user UserInfo对象
 */
- (void)replaceUserWithUserInfo:(UserInfo*)user;

/**
 *  删除某张表的所有数据
 *
 *  @param tableName 表名
 */
- (void)deleteAllDataWithTableName:(NSString*)tableName;
@end
