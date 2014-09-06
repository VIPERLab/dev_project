//
//  IMDelegate.h
//  QYER
//
//  Created by Frank on 14-5-13.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnIM.h"
#import "AnPush.h"

@class UserInfo;
/**
 *  当前用户IM连接状态.
 */
typedef NS_ENUM(NSUInteger, QYIMConnectStatus) {
    
    /**
     *  离线.
     */
    QYIMConnectStatusOffLine,
    /**
     *  在线.
     */
    QYIMConnectStatusOnLine,
    /**
     *  连线中.
     */
    QYIMConnectStatusConnecting
    
};

@class QYIMObject;
#if NS_BLOCKS_AVAILABLE
typedef void (^ConnectBlock)(QYIMObject *imObject, QYIMConnectStatus status);
typedef void (^JoinChatRoomBlock)(QYIMObject *imObject, BOOL isSuc);
typedef void (^DisJoinChatRoomBlock)(QYIMObject *imObject, BOOL isSuc);
typedef void (^GetTopicLogBlock)(QYIMObject *imObject, NSArray* logs);
typedef void (^BindPushServerBlock)(QYIMObject *imObject, BOOL isSuc);
typedef void (^UnBindPushServerBlock)(QYIMObject *imObject, BOOL isSuc);
typedef void (^GetTopicUserIdsBlock)(QYIMObject *imObject, NSArray* userIds, BOOL isSuc);
typedef void (^QueryHistoryBlock)(QYIMObject *imObject, NSArray* messages);
typedef void (^QueryHistoryMessageListBlock)(NSArray* privateChats, BOOL isSuc);
typedef void (^QueryOfflineTopicMessageBlock)(NSArray* messages, int count);
#endif



@class Message;
@interface QYIMObject : NSObject<AnIMDelegate, AnPushDelegate>
{
    ConnectBlock            _connectBlock;
    ConnectBlock            _disconnectBlock;
    ConnectBlock            _onlineBlock;
    JoinChatRoomBlock       _joinChatRoomBlock;
    DisJoinChatRoomBlock    _disJoinChatRoomBlock;
    BindPushServerBlock     _bindPushServerBlock;
    UnBindPushServerBlock   _unBindPushServerBlock;
    GetTopicUserIdsBlock    _getTopicUserIdsBlock;
    QueryHistoryBlock       _queryHistoryBlock;
    
    
    AnIM                    *_anIM;
    
    NSString                *_topicId;
    
    NSString                *_anId;
    
    NSString                *_onlineStatusUserId;
    
    BOOL                    _IsShowStatusBarMessage;
    NSTimer                 *_timer;
}

@property (nonatomic) CGFloat imVersion;

/**
 *  是否需要消息回执
 */
@property (nonatomic, assign) BOOL isNeedReceiveACK;

/**
 *  聊天室ID
 */
@property (nonatomic, copy) NSString *publicChatTopicId;

/**
 *  私聊用户ID
 */
@property (nonatomic, copy) NSString *privateChatImUserId;

/**
 *  连接状态
 */
@property (nonatomic, assign) QYIMConnectStatus connectStatus;

/**
 *  私信离线消息数量
 */
@property (nonatomic, retain) NSMutableDictionary *offlineMessageItemPrivate;

/**
 *  聊天室离线消息数量
 */
@property (nonatomic, assign) NSInteger offlineMessageCountPublic;

/**
 *  获取当前实例
 *
 *  @return
 */
+ (QYIMObject*)getInstance;

/**
 *  连接IM服务器
 *
 *  @param imUserId IM_USER_ID
 *  @param block
 */
- (void)connect:(NSString*)imUserId withBlock:(ConnectBlock)block;

/**
 *  连接IM服务器
 *
 *  @param imUserId IM_USER_ID
 */
- (void)disConnectWithBlock:(ConnectBlock)block;

/**
 *  加入聊天室
 *
 *  @param imUserId IM_USER_ID
 *  @param topicId
 *  @param block
 */
- (void)joinChatRoomWithTopicId:(NSString *)topicId withBlock:(JoinChatRoomBlock)block;

/**
 *  离开聊天室
 *
 *  @param block
 */
- (void)disJoinChatRoomWithBlock:(DisJoinChatRoomBlock)block;

/**
 *  发送新用户加入的消息
 *
 *  @param username 用户名
 */
- (void)sendNewUserJoinMessageWithUsername:(NSString*)username;

/**
 *  发送图文混排
 *
 *  @param item 字典
 */
- (void)sendRichTextWithItem:(Message*)otherMessage;

/**
 *  发送消息到联系人
 *
 *  @param fileData 消息
 *  @param item     自定义数据
 *  @param toUserId 联系人ID
 *
 *  @return 消息ID
 */
- (NSString*)sendMessage:(NSString*)message customData:(NSDictionary*)item toUserId:(NSString*)toUserId;

/**
 *  发送文件到联系人
 *
 *  @param fileData 文件
 *  @param item     自定义数据
 *  @param toUserId 联系人ID
 *
 *  @return 消息ID
 */
- (NSString*)sendBinary:(NSData*)fileData customData:(NSDictionary*)item toUserId:(NSString*)toUserId;

/**
 *  发送消息到聊天室
 *
 *  @param fileData 消息
 *  @param item     自定义数据
 *
 *  @return 消息ID
 */
- (NSString*)sendMessage:(NSString*)message customData:(NSDictionary*)item;

/**
 *  发送文件到聊天室
 *
 *  @param fileData 文件
 *  @param item     自定义数据
 *
 *  @return 消息ID
 */
- (NSString*)sendBinary:(NSData*)fileData customData:(NSDictionary*)item;

/**
 *  绑定推送消息
 */
- (void)bindPushServiceWithBlock:(BindPushServerBlock)block;

/**
 *  解除绑定推送消息
 */
- (void)unBindPushServiceWithBlock:(UnBindPushServerBlock)block;

/**
 *  获取聊天室成员ID
 *
 *  @param imUserId 当前用户的id
 *  @param block    
 */
- (void)getTopicInfo:(NSString*)topicId withBlock:(GetTopicUserIdsBlock)block;

/**
 *  注册推送通道
 */
- (void)registerChannel;

/**
 *  把消息显示在私聊列表
 *
 *  @param params 消息
 *  @param isShow 是否显示在StatusBar上，是否改变私信数量
 */
- (void)showToPrivateTable:(NSDictionary*)params withIsShowStatusBar:(BOOL)isShow;

/**
 *  查询聊天室聊天记录
 *
 *  @param timestamp 时间
 *  @param block
 */
- (void)queryTopicHistoryWithTimestamp:(NSNumber *)timestamp withBlock:(QueryHistoryBlock)block;

/**
 *  查询私聊聊天记录
 *
 *  @param userId  对方的IM_USER_ID
 *  @param pageNum 消息页数
 *  @param block
 */
- (void)queryPrivateHistoryWithClientId:(NSString *)userId withTimestamp:(NSNumber*)timestamp withBlock:(QueryHistoryBlock)block;

/**
 *  查询私信历史消息列表
 *
 *  @param date 最后一条消息的时间，如果为nil。从1970开始
 *  @param block
 */
- (void)queryPrivateHistoryMessageListWithLastDate:(NSDate*)date withBlock:(QueryHistoryMessageListBlock)block;

/**
 *  获取聊天室未读消息
 *
 *  @param block
 */
- (void)queryOfflineHistoryTopicMessagesWithBlock:(QueryOfflineTopicMessageBlock)block;

/**
 *  查询所有私信的离线消息
 *
 *  @param block
 */
- (void)queryOfflineHistoryMessagesWithBlock:(QueryOfflineTopicMessageBlock)block;

/**
 *  查询某个用户的私聊离线消息
 *
 *  @param imUserId 用户
 *  @param block
 */
- (void)queryOfflineHistoryMessagesWithIMUserId:(NSString*)imUserId block:(QueryOfflineTopicMessageBlock)block;

/**
 *  获取用户在线状态
 *
 *  @param userId 用户ID
 *  @param block  
 */
- (void)getClientsStatusWithUserId:(NSString*)userId withBlock:(ConnectBlock)block;
@end
