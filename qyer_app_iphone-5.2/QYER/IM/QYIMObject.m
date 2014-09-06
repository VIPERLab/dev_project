
//  QYIMObject.m
//  QYER
//
//  Created by Frank on 14-5-13.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QYIMObject.h"
#import "Message.h"
#import "NSDateUtil.h"
#import "UserInfo.h"
#import "LocalData.h"
#import "OtherMessage.h"
#import "PrivateChat.h"
#import "JSBubbleImageViewFactory.h"
#import "QyYhConst.h"
#import "MTStatusBarOverlay.h"
#import "Toast+UIView.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "AnIMMessage.h"
#import "UserInfoData.h"
#import "LocalData.h"

static QYIMObject *kConfig = nil;

/**
 *  是否绑定过
 */
static BOOL isBinded = false;
/**
 *  消息推送通道
 */
static NSString const *kIMPushChannel = @"QY_IM_PUSH_CHANNEL";
/**
 *  新用户加入聊天室
 */
static NSString const *kUserLabelText = @"加入聊天室";
/**
 *  接收图片类型的私信，在私信列表显示的文案
 */
static NSString *kImageMsgText = @"[图片]";
/**
 *  查询私信消息列表请求的URL地址
 */
static NSString *kQueryPrivateMessageListUrl = @"http://api.im.qyer.com/v1/im/sessions/get.json";

@interface QYIMObject ()

@property (nonatomic, copy) NSString *imUserId;
@property (nonatomic, retain) AnIM *anIM;

@end

@implementation QYIMObject

+ (QYIMObject*)getInstance
{
    @synchronized([QYIMObject class])
	{
		if (!kConfig){
            kConfig = [[self alloc] init];
        }
        [kConfig topicId];
		return kConfig;
	}
	return nil;
}

+ (id)alloc
{
	@synchronized([QYIMObject class])
	{
		NSAssert(kConfig == nil, @"Attempted to allocate a second instance of a singleton.");
		kConfig = [super alloc];
		return kConfig;
	}
	return nil;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (kConfig == nil) {
            kConfig = [super allocWithZone:zone];
            return kConfig;  // assignment and return on first allocation
        }
    }
    
    return nil; //on subsequent allocation attempts return nil
}

- (id)init
{
    self = [super init];
    if (self) {
        self.imVersion = 5.2;
    }
    return self;
}

- (void)dealloc
{
    if (!IsEmpty(_topicId)) {
        [_topicId release];
        _topicId = nil;
    }
    
    [_anId release];
    _anId = nil;
    
    if (!IsEmpty(_onlineStatusUserId)) {
        [_onlineStatusUserId release];
        _onlineStatusUserId = nil;
    }
    
    self.anIM = nil;
    self.imUserId = nil;
    self.offlineMessageItemPrivate = nil;
    self.privateChatImUserId = nil;
    self.publicChatTopicId = nil;
    
    [super dealloc];
}

#pragma mark - 连接和离开服务器
/**
 *  使用IM_USER_ID 连接IM服务器
 *
 *  @param imUserId IM_USER_ID
 */
- (void)connect:(NSString*)imUserId withBlock:(ConnectBlock)block
{
    if (self.connectStatus != QYIMConnectStatusOffLine) {
        if (block) {
            block(self, self.connectStatus);
        }
        return;
    }
    if (IsEmpty(imUserId)) {
        MYLog(@"IM Connect Error, IM_USER_ID is nil");
        return;
    }
    
    @try {
        self.imUserId = imUserId;
        
        [_anIM connect:imUserId];
        
        self.connectStatus = QYIMConnectStatusConnecting;
        
        if (self.offlineMessageItemPrivate) {
            self.offlineMessageItemPrivate = nil;
        }
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        self.offlineMessageItemPrivate = item;
        [item release];
        
        _connectBlock = Block_copy(block);
        
        //如果当前正在打开私聊视图或者聊天室视图，那么进入loading状态
        if (!IsEmpty(self.privateChatImUserId)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PRIVATE" object:nil userInfo:@{@"isLoading":@(YES)}];
        }else if (!IsEmpty(self.publicChatTopicId)){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PUBLIC" object:nil userInfo:@{@"isLoading":@(YES)}];
        }
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }

}

/**
 *  取消连接IM服务器
 *
 *  @param imUserId IM_USER_ID
 *  @param block
 */
- (void)disConnectWithBlock:(ConnectBlock)block
{
    @try {
        [_anIM disconnect];
        _disconnectBlock = Block_copy(block);
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
}

/**
 *  更新用户状态
 *
 *  @param anIM
 *  @param status
 *  @param exception
 */
- (void)anIM:(AnIM *)anIM didUpdateStatus:(BOOL)status exception:(ArrownockException *)exception
{
    if (status) {
        self.connectStatus = QYIMConnectStatusOnLine;
        
        if (_connectBlock) {
            _connectBlock(self, status);
            Block_release(_connectBlock);
            _connectBlock = nil;
        }
        if (!isBinded) {    //上线之后，绑定推送(只绑定一次)。
            [self bindPushServiceWithBlock:nil];
        }
        
        if (!IsEmpty(self.privateChatImUserId)){
            [self queryOfflineHistoryMessagesWithIMUserId:self.privateChatImUserId block:^(NSArray *messages, int count) {
                
                [self.offlineMessageItemPrivate setObject:@(count) forKey:self.privateChatImUserId];
                
                if (messages.count > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"OfflineHistoryMessages_PRIVATE" object:nil];
                }
                //离线消息读取完成，接触loading状态
                [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PRIVATE" object:nil userInfo:@{@"isLoading":@(NO)}];
            }];
        }
        
        if (!IsEmpty(self.publicChatTopicId)){
            //获取当前聊天室的离线消息
            [self queryOfflineHistoryTopicMessagesWithBlock:^(NSArray *messages, int count) {
                if (!IsEmpty(self.publicChatTopicId)) {
                    if (messages.count > 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"OfflineHistoryMessages_PUBLIC" object:nil];
                    }
                    //离线消息读取完成，接触loading状态
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PUBLIC" object:nil userInfo:@{@"isLoading":@(NO)}];
                }
            }];
        }
        
    }else{
        self.connectStatus = QYIMConnectStatusOffLine;
        
        if (_disconnectBlock) {
            _disconnectBlock(self, status);
            Block_release(_disconnectBlock);
            _disconnectBlock = nil;
        }
        
        [GlobalObject share].isAuto = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationFailed" object:nil userInfo:nil];
        
        if (exception.errorCode == IM_FORCE_CLOSED) {
            if (!IsEmpty([QYIMObject getInstance].publicChatTopicId)) {
                UINavigationController *navController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
                if ([navController isKindOfClass:[UINavigationController class]]) {
                    [navController popToRootViewControllerAnimated:YES];
                    UIView *view = navController.topViewController.view;
                    [view makeToast:@"你的账号已在其他设备登录，请退出后重新登录。" duration:2.0f position:@"center" isShadow:NO];
                }
            }
            //解除推送绑定
            [self unBindPushServiceWithBlock:nil];
        }
    }
}

#pragma mark - 获取某个用户的状态
/**
 *  获取用户在线状态
 *
 *  @param userId 用户ID
 *  @param block
 */
- (void)getClientsStatusWithUserId:(NSString*)userId withBlock:(ConnectBlock)block
{
    if (IsEmpty(userId)) {
        MYLog(@"getClientsStatusWithUserId Error, USERID is nil");
        return;
    }
    @try {
        NSSet *clientIds = [NSSet setWithObject:userId];
        [_anIM getClientsStatus:clientIds];
        
        _onlineBlock = Block_copy(block);
        
        if (!IsEmpty(_onlineStatusUserId)) {
            [_onlineStatusUserId release];
            _onlineStatusUserId = nil;
        }
        _onlineStatusUserId = [userId copy];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
}

/**
 *  获取在线状态的回调
 *
 *  @param anIM
 *  @param clientsStatus {@"IM_USER_ID":YES}
 *  @param exception
 */
- (void)anIM:(AnIM *)anIM didGetClientsStatus:(NSDictionary *)clientsStatus exception:(ArrownockException *)exception
{
    if (!IsEmpty(_onlineStatusUserId)) {
        BOOL status = [[clientsStatus objectForKey:_onlineStatusUserId] boolValue];
        if (_onlineBlock) {
            _onlineBlock(self, status);
            Block_release(_onlineBlock);
            _onlineBlock = nil;
        }
    }
}

#pragma mark - 获取聊天室全部聊天记录

/**
 *  查询聊天室聊天记录
 *
 *  @param timestamp 时间
 *  @param block
 */
- (void)queryTopicHistoryWithTimestamp:(NSNumber *)timestamp withBlock:(QueryHistoryBlock)block
{
    if (IsEmpty(_topicId)) {
        MYLog(@"queryTopicHistoryWithTimestamp Error, topicId is nil");
        return;
    }
    @try {
        [_anIM getFullTopicHistory:_topicId limit:IM_QUERY_COUNT timestamp:timestamp success:^(NSArray *messages) {
            if (block) {
                NSArray *msgs = [self configDataWithMessages:messages withTableName:_topicId];
                block(self, msgs);
            }
        } failure:^(ArrownockException *exception) {
            MYLog(@"queryTopicHistoryWithTimestamp Error %@", exception);
        }];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
}

#pragma mark - 获取私聊聊天记录

/**
 *  查询私聊聊天记录
 *
 *  @param userId  对方的IM_USER_ID
 *  @param pageNum 消息页数
 *  @param block
 */
- (void)queryPrivateHistoryWithClientId:(NSString *)userId withTimestamp:(NSNumber *)timestamp withBlock:(QueryHistoryBlock)block
{
    if (IsEmpty(userId) || IsEmpty(_imUserId)) {
        MYLog(@"queryPrivateHistoryWithClientId Error, IM_USER_ID or USERID is nil");
        return;
    }
    @try {
        NSSet *clientIds = [NSSet setWithObject:userId];
        [_anIM getHistory:clientIds clientId:_imUserId limit:IM_QUERY_COUNT timestamp:timestamp success:^(NSArray *messages) {
            if (block) {
                NSArray *msgs = [self configDataWithMessages:messages withTableName:userId];
                block(self, msgs);
            }
        } failure:^(ArrownockException *exception) {
            MYLog(@"PrivateHistoryWithClientId Error %@", exception);
        }];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
}

#pragma mark - 加入或离开聊天室
/**
 *  加入聊天室
 *
 *  @param topicId
 *  @param block
 */
- (void)joinChatRoomWithTopicId:(NSString *)topicId withBlock:(JoinChatRoomBlock)block
{
    if (IsEmpty(topicId) || IsEmpty(_imUserId)) {
        MYLog(@"joinChatRoomWithTopicId Error, _topicId or _imUserId is nil");
        return;
    }
    @try {
        NSSet *clientIds = [NSSet setWithObject:_imUserId];
        [_anIM addClients:clientIds toTopicId:topicId];
        _joinChatRoomBlock = Block_copy(block);
        
        if (!IsEmpty(_topicId)) {
            [_topicId release];
            _topicId = nil;
        }
        _topicId = [topicId copy];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
}

/**
 *  加入聊天室的回调
 *
 *  @param anIM
 *  @param exception
 */
- (void)anIM:(AnIM *)anIM didAddClientsWithException:(ArrownockException *)exception
{
    if (_joinChatRoomBlock) {
        _joinChatRoomBlock(self, IsEmpty(exception.message));
        Block_release(_joinChatRoomBlock);
        _joinChatRoomBlock = nil;
        
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"Join_Topic"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 *  离开聊天室
 *
 *  @param block
 */
- (void)disJoinChatRoomWithBlock:(DisJoinChatRoomBlock)block
{
    if (IsEmpty(_imUserId) || IsEmpty([self topicId])) {
        MYLog(@"disJoinChatRoomWithBlock Error, _imUserId or _topicId is nil");
        return;
    }
    @try {
        NSSet *clientIds = [NSSet setWithObject:_imUserId];
        [_anIM removeClients:clientIds fromTopicId:_topicId];
        _disJoinChatRoomBlock = Block_copy(block);
    }
    @catch (ArrownockException *exception) {
        if (block) {
            block(self, NO);
        }
        MYLog(@"ArrownockException %@", exception.message);
    }
}

/**
 *  退出群的回调
 *
 *  @param anIM
 *  @param exception
 */
- (void)anIM:(AnIM *)anIM didRemoveClientsWithException:(ArrownockException *)exception
{
    BOOL isSuc = IsEmpty(exception.message);
    
    if (_disJoinChatRoomBlock) {
        _disJoinChatRoomBlock(self, isSuc);
    }
    
    if (isSuc)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"IM_TOPIC_ID"];
        [userDefault removeObjectForKey:@"IM_Chatroom_ID"];
        [userDefault synchronize];
        
        //删除聊天室表里面的所有数据
//        NSString *tableName = [self topicId];
//        [[LocalData getInstance] deleteAllDataWithTableName:tableName];
//        NSString *dbPath = [[LocalData getInstance] dbFilePath];
//        NSError *error = nil;
//        //删除本地聊天记录
//        [[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
//        if(error){
//            NSLog(@"didRemoveClientsWithException Error %@", error);
//        }
        //解除推送绑定
        [self unBindPushServiceWithBlock:nil];
    }
}

#pragma mark - 获取聊天室成员
/**
 *  获取聊天室成员的ClientIds
 *
 *  @param imUserId 用户的ClientIds
 */
- (void)getTopicInfo:(NSString*)topicId withBlock:(GetTopicUserIdsBlock)block
{
    if (IsEmpty(topicId)) {
        MYLog(@"getTopicInfo Error, topicId is nil");
        return;
    }
    @try {
        [_anIM getTopicInfo:topicId];
        _getTopicUserIdsBlock = Block_copy(block);
    }
    @catch (ArrownockException *exception) {
        if (block) {
            block(self, nil, NO);
        }
        MYLog(@"ArrownockException %@", exception.message);
    }
}

/**
 *  获取聊天室信息的回调
 *
 *  @param anIM
 *  @param topicId     聊天室ID
 *  @param topicName   聊天室名字
 *  @param parties     聊天室成员ID
 *  @param createdDate 生成日期
 *  @param exception
 */
- (void)anIM:(AnIM *)anIM didGetTopicInfo:(NSString *)topicId name:(NSString *)topicName parties:(NSSet *)parties createdDate:(NSDate *)createdDate exception:(ArrownockException *)exception
{
    BOOL isSuc = IsEmpty(exception.message);
    if (_getTopicUserIdsBlock) {
        _getTopicUserIdsBlock(self, [parties allObjects], isSuc);
    }
}

#pragma mark - 绑定和接触绑定PUSH
/**
 *  绑定推送消息
 */
- (void)bindPushServiceWithBlock:(BindPushServerBlock)block
{
    if (IsEmpty(_anId)) {
        MYLog(@"BindPushServiceWithBlock Error, anID is nil");
        return;
    }
    @try {
        [_anIM bindAnPushService:_anId appKey:IMAppKey deviceType:AnPushTypeiOS];
        _bindPushServerBlock = Block_copy(block);
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
}

/**
 *  绑定PUSH的回调
 *
 *  @param anIM
 *  @param exception
 */
- (void)anIM:(AnIM *)anIM didBindServiceWithException:(ArrownockException *)exception
{
    BOOL isSuc = IsEmpty(exception.message);
    if (isSuc) {
        isBinded = YES;
    }
    if (_bindPushServerBlock) {
        _bindPushServerBlock(self, isSuc);
        Block_release(_bindPushServerBlock);
        _bindPushServerBlock = nil;
    }
}

/**
 *  解除绑定推送消息
 */
- (void)unBindPushServiceWithBlock:(UnBindPushServerBlock)block
{
    @try {
        [_anIM unbindAnPushService:AnPushTypeiOS];
        _unBindPushServerBlock = Block_copy(block);
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
}

/**
 *  接触绑定PUSH的回调
 *
 *  @param anIM
 *  @param exception
 */
- (void)anIM:(AnIM *)anIM didUnbindServiceWithException:(ArrownockException *)exception
{
    BOOL isSuc = IsEmpty(exception.message);
    if (isSuc) {
        isBinded = NO;
    }
    if (_unBindPushServerBlock) {
        _unBindPushServerBlock(self, isSuc);
        Block_release(_unBindPushServerBlock);
        _unBindPushServerBlock = nil;
    }
}

#pragma mark - 消息发送和接收
/**
 *  发送新用户加入的消息
 *
 *  @param username 用户名
 */
- (void)sendNewUserJoinMessageWithUsername:(NSString*)username
{
    if (IsEmpty(_topicId) || IsEmpty(username)) {
        MYLog(@"sendNewUserJoinMessageWithUsername Error, _topicId is nil, username is nil");
        return;
    }
    @try {
        [_anIM sendNotice:@"NEW_USER_JOIN" customData:@{@"type":@(JSBubbleMediaTypeNewUserJoin), @"userName":[NSString stringWithFormat:@"%@%@", username, kUserLabelText]} toTopicId:_topicId needReceiveACK:self.isNeedReceiveACK];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
}


/**
 *  发送消息到联系人
 *
 *  @param fileData 消息
 *  @param item     自定义数据
 *  @param toUserId 联系人ID
 *
 *  @return 消息ID
 */
- (NSString*)sendMessage:(NSString*)message customData:(NSDictionary*)item toUserId:(NSString*)toUserId{
    if (IsEmpty(toUserId)) {
        MYLog(@"sendMessage Error, toUserId is nil");
        return nil;
    }
    NSString *messageId = @"";
    @try {
        NSSet *clientIds = [NSSet setWithObject:toUserId];
        messageId = [_anIM sendMessage:message customData:item toClients:clientIds needReceiveACK:self.isNeedReceiveACK];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
    return messageId;
}

/**
 *  接收私聊消息
 *
 *  @param anIM
 *  @param message
 *  @param customData
 *  @param clientId
 *  @param parties
 *  @param messageId
 *  @param timestamp
 */
- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    //保存到本地，并且返回字典类型
    [self saveLocaDataWithMessage:message withFileData:nil withTopicId:@"" customData:customData from:from messageId:messageId at:timestamp withChatType:ChatTypePrivate];
}

/**
 *  发送文件到联系人
 *
 *  @param fileData 文件
 *  @param item     自定义数据
 *  @param toUserId 联系人ID
 *
 *  @return 消息ID
 */
- (NSString*)sendBinary:(NSData*)fileData customData:(NSDictionary*)item toUserId:(NSString*)toUserId{
    if (IsEmpty(toUserId)) {
        MYLog(@"sendBinary Error, toUserId is nil");
        return nil;
    }
    NSString *messageId = @"";
    @try {
        NSSet *clientIds = [NSSet setWithObject:toUserId];
        messageId = [_anIM sendBinary:fileData fileType:@"IMAGE" customData:item toClients:clientIds needReceiveACK:self.isNeedReceiveACK];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
    return messageId;
}

/**
 *  接收私聊数据
 *
 *  @param anIM
 *  @param data
 *  @param fileType
 *  @param customData
 *  @param from
 *  @param parties
 *  @param messageId
 *  @param timestamp
 */
- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    //保存到本地，并且返回字典类型
    [self saveLocaDataWithMessage:@"" withFileData:data withTopicId:@"" customData:customData from:from messageId:messageId at:timestamp withChatType:ChatTypePrivate];
}


/**
 *  发送消息到聊天室
 *
 *  @param fileData 消息
 *  @param item     自定义数据
 *
 *  @return 消息ID
 */
- (NSString*)sendMessage:(NSString*)message customData:(NSDictionary*)item{
    if (IsEmpty(_topicId)) {
        MYLog(@"sendMessage Error, _topicId is nil");
        return nil;
    }
    NSString *messageId = @"";
    @try {
        messageId = [_anIM sendMessage:message customData:item toTopicId:_topicId needReceiveACK:self.isNeedReceiveACK];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
    return messageId;
}


/**
 *  接收到群组文本消息
 *
 *  @param anIM
 *  @param message
 *  @param customData
 *  @param from
 *  @param topicId
 *  @param messageId
 *  @param timestamp
 */
- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    [self saveLocaDataWithMessage:message withFileData:nil withTopicId:topicId customData:customData from:from messageId:messageId at:timestamp withChatType:ChatTypePublic];
}

/**
 *  发送文件到聊天室
 *
 *  @param fileData 文件
 *  @param item     自定义数据
 *
 *  @return 消息ID
 */
- (NSString*)sendBinary:(NSData*)fileData customData:(NSDictionary*)item{
    if (IsEmpty(_topicId)) {
        MYLog(@"sendBinary Error, _topicId is nil");
        return nil;
    }
    NSString *messageId = @"";
    @try {
        messageId = [_anIM sendBinary:fileData fileType:@"IMAGE" customData:item toTopicId:_topicId needReceiveACK:self.isNeedReceiveACK];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
    }
    return messageId;
}

/**
 *  接收到群组文件消息
 *
 *  @param anIM
 *  @param data
 *  @param fileType
 *  @param customData
 *  @param from
 *  @param topicId
 *  @param messageId
 *  @param timestamp
 */
- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    [self saveLocaDataWithMessage:@"" withFileData:data withTopicId:topicId customData:customData from:from messageId:messageId at:timestamp withChatType:ChatTypePublic];
}

/**
 *  发送图文混排
 *
 *  @param item 字典
 */
- (void)sendRichTextWithItem:(Message*)otherMessage
{
    if (!otherMessage) {
        MYLog(@"sendRichTextWithItem Error, otherMessage is nil");
    }
    [self sendMessage:@"" customData:[otherMessage toDictionary]];
}

/**
 *  接收小黑板数据
 *
 *  @param anIM
 *  @param notice
 *  @param customData
 *  @param from
 *  @param messageId
 *  @param timestamp
 */
- (void)anIM:(AnIM *)anIM didReceiveNotice:(NSString *)notice customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    //如果接收到的事件，和当前聊天室ID不一样，直接返回
    NSString *myTopicId = [[NSUserDefaults standardUserDefaults] objectForKey:@"IM_TOPIC_ID"];
    if (![myTopicId isEqualToString:topicId]) {
        return;
    }
    
    if ([customData isKindOfClass:[NSDictionary class]]) {
        //新用户加入
        if ([customData[@"type"] integerValue] == JSBubbleMediaTypeNewUserJoin) {
            NSString *userName = customData[@"userName"];
            if (!IsEmpty(userName)) {
                //新用户加入
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NewUserJoin" object:nil userInfo:@{@"userName":userName}];
            }
            return;
        }
        
        //敏感词过滤
        BOOL isSensitive = [customData[@"sensitive"] boolValue];
        if (isSensitive) {  //如果是敏感词，发送敏感词通知
            NSString *name = @"Sensitive_PUBLIC";
            NSString *privateChatImUserId = [QYIMObject getInstance].privateChatImUserId;
            if (!IsEmpty(privateChatImUserId)) {
                name = @"Sensitive_PRIVATE";
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:@{@"messageId":customData[@"msg_id"], @"message":customData[@"word"]}];
            return;
        }
        
        //小黑板
        NSString *action = customData[@"action"];
        if ([action isEqualToString:@"wall"]) {   //小黑板
            long long timeSend = [timestamp longLongValue];
            NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:customData[@"user"]];
            OtherMessage *otherMsg = [[OtherMessage alloc] initWithDictionary:customData[@"data"]];
            [item setObject:otherMsg forKey:@"otherMessage"];
            [item setObject:@(timeSend) forKey:@"timeSend"];
            [item setObject:messageId forKey:@"messageId"];
            [item setObject:from forKey:@"fromUserId"];
            [item setObject:topicId forKey:@"topicId"];
            [item setObject:@(JSBubbleMediaTypeRichText) forKey:@"type"];
            [item setObject:@([NSDate date].timeIntervalSince1970 * 1000) forKey:@"timeReceive"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BlockboardData" object:nil userInfo:item];
            //小黑板信息缓存到本地数据库
            Message *msg = [[Message alloc] initWithDictionary:item];
            [[LocalData getInstance] insertWithTableName:topicId withObject:msg];
            //把user数据，更新到本地数据库
            [self replaceUserInfoWithId:from withName:item[@"fromUserName"] withAvatar:item[@"fromUserAvatar"]];
            
            [msg release];
            [item release];
            [otherMsg release];
            return;
        }
    }
}


#pragma mark - 发送消息的回调
/**
 *  消息发送成功触发的方法
 *
 *  @param anIM
 *  @param messageId 消息ID
 */
- (void)anIM:(AnIM *)anIM messageSent:(NSString *)messageId
{
    NSString *name = @"MessageSent_PUBLIC";
    if (!IsEmpty(self.privateChatImUserId)) {
        name = @"MessageSent_PRIVATE";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:@{@"messageId":messageId, @"isSuccess":@(YES)}];
}

/**
 *  消息发送失败触发的方法
 *
 *  @param anIM
 *  @param exception
 *  @param messageId 消息ID
 */
- (void)anIM:(AnIM *)anIM sendReturnedException:(ArrownockException *)exception messageId:(NSString *)messageId
{
    NSString *name = @"MessageSent_PUBLIC";
    if (!IsEmpty(self.privateChatImUserId)) {
        name = @"MessageSent_PRIVATE";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:@{@"messageId":messageId, @"isSuccess":@(NO)}];
}

#pragma mark - 发送消息保存到本地
/**
 *  把接收到的消息保存到本地
 *
 *  @param message    消息
 *  @param fileData   文件
 *  @param topicId    聊天室ID
 *  @param customData 自定义类型
 *  @param from       消息发送者
 *  @param messageId  消息ID
 *  @param timestamp  消息接收时间
 *  @param chatType   消息类型（聊天室PUBLIC、私聊PRIVATE）
 *
 *  @return
 */
- (void)saveLocaDataWithMessage:(NSString *)message withFileData:(NSData*)fileData withTopicId:(NSString*)topicId customData:(NSDictionary *)customData from:(NSString *)from messageId:(NSString *)messageId at:(NSNumber *)timestamp withChatType:(ChatType)chatType
{
    long long  timeSend = [timestamp longLongValue];
    NSInteger type = 0;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init] ;
    
    NSString *fromUserName = @"";
    NSString *fromUserAvatar = @"";
    
    if ([customData isKindOfClass:[NSDictionary class]]) {
        type = [customData[@"type"] integerValue];
        [params setValue:@(type) forKey:@"type"];  //消息类型
        
        if (type == JSBubbleMediaTypeNewUserJoin) {
            [params release];
            return;
        }
        
        fromUserName = customData[@"fromUserName"];       //消息发送人名字
        [params setValue:fromUserName forKey:@"fromUserName"];
    
        fromUserAvatar = customData[@"fromUserAvatar"];   //消息发送人头像
        [params setValue:fromUserAvatar forKey:@"fromUserAvatar"];
        
        NSString *imageUrl = customData[@"imageUrl"];
        [params setValue:imageUrl forKey:@"attribute1"];
    }

    [params setValue:messageId forKey:@"messageId"];    //消息ID
    [params setValue:from forKey:@"fromUserId"];        //发送者的IM_USER_ID
    [params setValue:topicId forKey:@"topicId"];        //聊天室ID
    [params setValue:@(timeSend) forKey:@"timeSend"];   //消息的发送时间
    [params setValue:message forKey:@"message"];        //消息
    [params setValue:fileData forKey:@"fileData"];      //文件
    [params setValue:@([NSDate date].timeIntervalSince1970 * 1000) forKey:@"timeReceive"]; //消息的接收时间
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *imUserId = [userDefault objectForKey:@"userid_im"];
    NSString *username = [userDefault objectForKey:@"username"];
    NSString *avatar = [userDefault objectForKey:@"usericon"];
    [params setValue:imUserId forKey:@"toUserId"];      //消息接收者IM_USER_ID（当前用户）
    [params setValue:username forKey:@"toUserName"];
    [params setValue:avatar forKey:@"toUserAvatar"];
    
    NSString *tableName = @"";
    //私聊，把消息保存到本地数据库
    if (IsEmpty(topicId))
    {
        tableName = from;
        [self showToPrivateTable:params withIsShowStatusBar:YES];
    }else{
        tableName = topicId;
    }
    //查询数据库是否为空
    BOOL isEmpty = [[LocalData getInstance] isEmptyWithTableName:tableName];
    Message *msg = [[Message alloc] initWithDictionary:params];
    msg.isSend = 1;
    msg.showTimestamp = isEmpty;    //如果为空，说明接收的是第一条数据，所以显示时间
    [[LocalData getInstance] insertWithTableName:tableName withObject:msg];
    
    //把user数据，更新到本地数据库
    [self replaceUserInfoWithId:msg.fromUserId withName:msg.fromUserName withAvatar:fromUserAvatar];
    [msg release];
    
    //发送通知显示在聊天室里
    NSString *notificationName = [NSString stringWithFormat:@"Chat_%@", chatType == ChatTypePrivate ? @"PRIVATE" : @"PUBLIC"];
    if (!IsEmpty(messageId)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"messageId":messageId}];
    }
    [params release];
}

#pragma mark - Private Chat

/**
 *  把接收到的消息数组，存储到本地数据库
 *
 *  @param messages 消息数组
 *  @param tableName 表名
 */
- (NSArray*)configDataWithMessages:(NSArray*)messages withTableName:(NSString*)tableName;
{
    NSMutableArray *msgs = [[[NSMutableArray alloc] initWithCapacity:messages.count] autorelease];
    for (NSInteger i=messages.count-1; i>=0; i--) {
        AnIMMessage *anMsg = messages[i];
        
        Message *message = [[Message alloc] initWithAnMessage:anMsg];
        if (message.timeSend > 0) {
            message.isSend = 1;
        }
        [msgs addObject:message];
        if (i == messages.count-1) {   //记录最后一条的发送时间
            BOOL isShow = NO;
            //查询本地数据库是否有数据
            BOOL isEmpty = [[LocalData getInstance] isEmptyWithTableName:tableName];
            if (isEmpty) {
                isShow = YES;
            }else{
                Message *msg = [[LocalData getInstance] queryWithTableName:tableName withMessageId:message.messageId];
                isShow = msg.showTimestamp;
            }
            //数据库为空，显示时间
            message.showTimestamp = isShow;
        }
        message.timeReceive = [NSDate date].timeIntervalSince1970 * 1000 ;
        //保存到本地数据库
        [[LocalData getInstance] insertWithTableName:tableName withObject:message];
        
        //把user数据，更新到本地数据库
        [self replaceUserInfoWithId:message.fromUserId withName:message.fromUserName withAvatar:anMsg.customData[@"fromUserAvatar"]];
        [message release];
    }
    return msgs;
}

/**
 *  把消息显示在私聊列表
 *
 *  @param params 消息
 *  @param isShow 是否显示在StatusBar上，是否改变私信数量
 */
- (void)showToPrivateTable:(NSDictionary*)params withIsShowStatusBar:(BOOL)isShow
{
    if (isShow) {
        [self showStatusBar:params];
    }
    [self savePrivateChatTableAndSendNotification:params withIsUserReceive:isShow];
}

/**
 *  收到私信消息，在状态栏提示
 */
- (void)showStatusBar:(NSDictionary*)item
{
    if (![[QYIMObject getInstance].privateChatImUserId isEqualToString:[item objectForKey:@"fromUserId"]]) {
        
        NSString *strMsg = @"您收到一条新私信";
        
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        overlay.frame = CGRectMake(200, 0, 120, 20);
        overlay.customTextColor = [UIColor whiteColor];
        [overlay postMessage:strMsg];
        
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideStatusBarMessage) userInfo:nil repeats:YES];
        }else{
            _IsShowStatusBarMessage = YES;
        }
    }
}

/**
 *  隐藏状态栏消息
 */
- (void)hideStatusBarMessage
{
    if (!_IsShowStatusBarMessage) {
        [_timer invalidate];
        _timer = nil;
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        [overlay hide];
    }
    _IsShowStatusBarMessage = NO;
}

/**
 *  存储到本地私信表，并且发送通知
 */
- (void)savePrivateChatTableAndSendNotification:(NSDictionary*)item withIsUserReceive:(BOOL)isReceive
{
    
    PrivateChat *tempChat = [[PrivateChat alloc] init];
//    NSLog(@"data  is %@",item);
    
    JSBubbleMessageType type = [item[@"type"] integerValue];
    if (type == JSBubbleMediaTypeText) {
        tempChat.lastMessage = [item objectForKey:@"message"];
    }else if (type == JSBubbleMediaTypeImage){
        tempChat.lastMessage = kImageMsgText;
    }
    
    tempChat.messageId = [item objectForKey:@"messageId"];
    
    if (isReceive) {
        
        tempChat.clientId = [item objectForKey:@"fromUserId"];
        tempChat.chatUserName = [item objectForKey:@"fromUserName"];
        tempChat.chatUserAvatar = [item objectForKey:@"fromUserAvatar"];
        tempChat.lastTime = [NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"timeSend"] longLongValue] / 1000];
        tempChat.unReadNumber = 1;
        
    }else{
        
        tempChat.clientId = [item objectForKey:@"toUserId"];
        tempChat.chatUserName = [item objectForKey:@"toUserName"];
        tempChat.chatUserAvatar = [item objectForKey:@"toUserAvatar"];
        tempChat.lastTime = [NSDate date];
        tempChat.unReadNumber = 0;
        
    }
    
    
    [[LocalData getInstance] insertPrivateChatWithTableName:PrivateChatTableName withObject:tempChat];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatMessage" object:nil userInfo:@{@"item":tempChat}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatUnReadMsgNum" object:nil];
    
    [tempChat release];
}

/**
 *  查询私信历史消息列表
 *
 *  @param date 最后一条消息的时间，如果为nil。从1970开始
 *
 *  @return
 */
- (void)queryPrivateHistoryMessageListWithLastDate:(NSDate *)date withBlock:(QueryHistoryMessageListBlock)block
{
    if (IsEmpty(_imUserId)) {
        MYLog(@"QueryPrivateHistoryMessageListWithLastDate Error, im_user_id is nil");
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@?key=%@&clientid=%@&last_msg=true&count=20", kQueryPrivateMessageListUrl, IMAppKey, _imUserId];
    if (date) {
        url = [NSString stringWithFormat:@"%@&timestamp=%f", url, [date timeIntervalSince1970]];
    }
    
    ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
    request.requestMethod = @"GET";
    request.timeOutSeconds = 10;
    
    //成功回调
    [request setCompletionBlock:^{
        NSData *responseData = request.responseData;
        if (responseData) {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            if (!error && [result isKindOfClass:[NSDictionary class]]) {
                NSInteger statusCode = [result[@"meta"][@"code"] integerValue];
                if (statusCode == 200) {
                    NSArray *sessions = result[@"response"][@"sessions"];
                    NSArray *results = [self sessions2resultList:sessions];
                    if (block) {
                        block(results, YES);
                        return ;
                    }
                }
            }
        }
        if (block) {
            block(nil, NO);
        }
    }];
    //失败回调
    [request setFailedBlock:^{
        MYLog(@"QueryPrivateHistoryMessageListWithLastDate Error, %@", request.error);
        if (block) {
            block(nil, NO);
        }
    }];
    [request startAsynchronous];
}

/**
 *  请求回来的数据，封装成PrivateChat的LIST
 *
 *  @param sessions 封装成的数据
 *
 *  @return
 */
- (NSArray*)sessions2resultList:(NSArray*)sessions
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:sessions.count];
    for (NSDictionary *item in sessions) {
        PrivateChat *pChat = [[PrivateChat alloc] init];
        pChat.privateChatId = item[@"id"];
        pChat.clientId = item[@"last_msg"][@"from"];
        pChat.messageId = item[@"last_msg"][@"msg_id"];
        pChat.chatUserName = item[@"last_msg"][@"customData"][@"fromUserName"];
        pChat.chatUserAvatar = item[@"last_msg"][@"customData"][@"fromUserAvatar"];
        pChat.lastTime = [NSDate dateWithTimeIntervalSince1970:[item[@"timestamp"] longLongValue] / 1000];
        if ([item[@"last_msg"][@"content_type"] isEqualToString:@"text"]) {
            pChat.lastMessage = item[@"last_msg"][@"message"];
        }else if ([item[@"last_msg"][@"content_type"] isEqualToString:@"binary"]) {
            pChat.lastMessage = kImageMsgText;
        }
        [arr addObject:pChat];
        [pChat release];
    }
    return [arr autorelease];
}

#pragma mark - AnPush

- (void)registerChannel
{
    NSArray *channels = [NSArray arrayWithObjects:kIMPushChannel, nil];
    [[AnPush shared] register:channels overwrite:YES];
}

#pragma mark - AnPush Delegate
/**
 *  注册推送成功的方法
 *
 *  @param anid
 *  @param error
 */
- (void)didRegistered:(NSString *)anid withException:(ArrownockException *)exception
{
    if (IsEmpty(_anId)) {
        _anId = [anid retain];
    }
}

/**
 *  注册推送失败的方法
 *
 *  @param success
 *  @param error
 */
- (void)didUnregistered:(BOOL)success withException:(ArrownockException *)exception;
{
    NSLog(@"didUnregistered %@", [NSString stringWithFormat:@"success: %@\nerror: %@", success?@"YES":@"NO", exception]);
}

#pragma mark - Set

- (void)setPublicChatTopicId:(NSString *)publicChatTopicId
{
    if (![_publicChatTopicId isEqualToString:publicChatTopicId]) {
        [_publicChatTopicId release];
        _publicChatTopicId = [publicChatTopicId copy];
        //如果之前已经加入过聊天室，那么当进入聊天视图的时候，
        //从publicChatTopicId中获取聊天室ID
        if (!_topicId) {
            _topicId = [publicChatTopicId copy];
        }
    }
}

- (void)setImUserId:(NSString *)imUserId
{
    if (![_imUserId isEqualToString:imUserId]) {
        [_imUserId release];
        _imUserId = [imUserId copy];
        
        if (!IsEmpty(imUserId)) {
            //箭扣IM注册
            AnIM *anIM = [[AnIM alloc] initWithAppKey:IMAppKey delegate:self secure:YES];
            self.anIM = anIM;
            [anIM release];
        }
    }
}


/**
 *  获取聊天室ID
 *
 *  @return
 */
- (NSString*)topicId
{
    if (IsEmpty(_topicId)) {
        _topicId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"IM_TOPIC_ID"] copy];
    }
    return _topicId;
}


#pragma mark - 离线消息
/**
 *  获取聊天室未读消息
 *
 *  @param block
 */
- (void)queryOfflineHistoryTopicMessagesWithBlock:(QueryOfflineTopicMessageBlock)block
{
    NSString *topicId = [self topicId];
    if (IsEmpty(topicId) || IsEmpty(_imUserId)) {
        MYLog(@"QueryOfflineHistoryPrivateMessages Error, topicId IS NIL");
        return;
    }
    @try {
        [_anIM getOfflineTopicHistory:topicId clientId:_imUserId limit:IM_QUERY_COUNT success:^(NSArray *messages, int count) {
            self.offlineMessageCountPublic = count;
            NSArray *result = [self configMessage:messages withIsPrivate:NO withCount:count];
            if (block) {
                block(result, count);
            }
        } failure:^(ArrownockException *exception) {
            MYLog(@"queryOfflineHistoryTopicMessagesWithBlock Error, %@", exception.message);
            if (block) {
                block(nil, -1);
            }
        }];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
        if (block) {
            block(nil, -1);
        }
    }
}

/**
 *  查询所有私信的离线消息
 *
 *  @param block
 */
- (void)queryOfflineHistoryMessagesWithBlock:(QueryOfflineTopicMessageBlock)block
{
    if (IsEmpty(_imUserId)) {
        MYLog(@"QueryOfflineHistoryMessagesWithBlock Error, topicId IS NIL");
        return;
    }
    @try {
        [_anIM getOfflineHistory:_imUserId limit:IM_QUERY_COUNT success:^(NSArray *messages, int count) {
            NSArray *result = [self configMessage:messages withIsPrivate:YES withCount:count];
            if (block) {
                block(result, count);
            }
        } failure:^(ArrownockException *exception) {
            if (block) {
                block(nil, -1);
            }
        }];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
        if (block) {
            block(nil, -1);
        }
    }
}

/**
 *  查询某个用户的私聊离线消息
 *
 *  @param imUserId 用户
 *  @param block
 */
- (void)queryOfflineHistoryMessagesWithIMUserId:(NSString*)imUserId block:(QueryOfflineTopicMessageBlock)block
{
    if (IsEmpty(_imUserId) || IsEmpty(imUserId)) {
        MYLog(@"queryOfflineHistoryMessagesWithIMUserId Error, imUserId IS NIL");
        return;
    }
    @try {
        NSSet *set = [NSSet setWithObject:imUserId];
        [_anIM getOfflineHistory:set clientId:_imUserId limit:IM_QUERY_COUNT success:^(NSArray *messages, int count) {
            NSArray *result = [self configMessage:messages withIsPrivate:YES withCount:count];
            if (block) {
                block(result, count);
            }
        } failure:^(ArrownockException *exception) {
            if (block) {
                block(nil, -1);
            }
        }];
    }
    @catch (ArrownockException *exception) {
        MYLog(@"ArrownockException %@", exception.message);
        if (block) {
            block(nil, -1);
        }
    }
}

/**
 *  把数组里的ANMessag转化成Message
 *
 *  @param messages  消息
 *  @param isPrivate 是否私聊
 *
 *  @return
 */
- (NSArray*)configMessage:(NSArray*)messages withIsPrivate:(BOOL)isPrivate withCount:(int)count
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *imUserId = [userDefault objectForKey:@"userid_im"];
    NSString *username = [userDefault objectForKey:@"username"];
    NSString *avatar = [userDefault objectForKey:@"usericon"];
    
    BOOL isEmpty = NO;
    
    NSMutableArray *msgs = [[NSMutableArray alloc] initWithCapacity:messages.count];
    for (NSInteger i=messages.count-1; i>=0; i--) {
        AnIMMessage *anMsg = messages[i];
        Message *message = [[Message alloc] initWithAnMessage:anMsg];
        if (isPrivate) {
            message.toUserId = imUserId;
            message.toUserName = username;
            message.toUserAvatar = avatar;
        }
        
        NSString *tableName = (isPrivate ? message.fromUserId : [self topicId]);
        if (i == messages.count - 1) {
            isEmpty = [[LocalData getInstance] isEmptyWithTableName:tableName];
        }
        if (i == 0){
            //数据库为空，显示时间
            message.showTimestamp = isEmpty;
        }
        if (message.timeSend > 0) {
            message.isSend = 1;
        }
        message.timeReceive = [NSDate date].timeIntervalSince1970 * 1000 ;
        [msgs addObject:message];
        //保存到本地数据库
        [[LocalData getInstance] insertWithTableName:tableName withObject:message];
        
        //把user数据，更新到本地数据库
        [self replaceUserInfoWithId:message.fromUserId withName:message.fromUserName withAvatar:anMsg.customData[@"fromUserAvatar"]];
        [message release];
    }
    return [msgs autorelease];
}

- (void)replaceUserInfoWithId:(NSString*)imUserId withName:(NSString*)name withAvatar:(NSString*)avatar
{
    UserInfo *userInfo = [[LocalData getInstance] queryUserWithImUserId:imUserId];
    if (!userInfo) {
        userInfo = [[[UserInfo alloc] init] autorelease];
        userInfo.im_user_id = imUserId;
        userInfo.username = name;
        userInfo.avatar = avatar;
        [[LocalData getInstance] replaceUserWithUserInfo:userInfo];
    }else if (userInfo && ![userInfo.avatar isEqualToString:avatar]) {
        userInfo.avatar = avatar;
        [[LocalData getInstance] replaceUserWithUserInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableView" object:nil];
    }
}

@end
