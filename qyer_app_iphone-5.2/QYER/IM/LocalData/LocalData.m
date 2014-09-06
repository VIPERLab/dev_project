//
//  LocalData.m
//  IMTest
//
//  Created by Frank on 14-4-25.
//  Copyright (c) 2014年 Frank. All rights reserved.
//

#import "LocalData.h"
#import "FMDatabase.h"
#import "Message.h"
#import "NSDateUtil.h"
#import "IMConst.h"
#import "PrivateChat.h"

#import "QyYhConst.h"
#import "QYIMObject.h"
#import "OtherMessage.h"

#import "UserInfo.h"
@implementation LocalData

static LocalData *instance = nil;

/**
 *  单例初始化
 *
 *  @return
 */

+ (LocalData*)getInstance
{
    @synchronized([LocalData class])
	{
		if (!instance)
			instance = [[self alloc] init];
        return instance;
	}
	return nil;
}

+ (id)alloc
{
	@synchronized([LocalData class])
	{
		NSAssert(instance == nil, @"Attempted to allocate a second instance of a singleton.");
		instance = [super alloc];
		return instance;
	}
	return nil;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

/**
 *  生成数据库和表
 *
 *  @param tableName 表名
 *
 *  @return
 */
- (FMDatabase*)createDatabaseWithTableName:(NSString*)tableName
{
    if ([tableName isEqual:[NSNull null]]) {
        return nil;
    }
    NSString *imUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid_im"];
    if ([imUserId isEqualToString:@""] || !imUserId) {
        return nil;
    }
    NSString *filePath = [self dbFilePath];
    NSString *dbPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", imUserId]];
//    NSLog(@"Database Path %@", dbPath);
    FMDatabase *db = [[[FMDatabase alloc] initWithPath:dbPath] autorelease];
    if ([db open]) {
        if ([tableName isEqualToString:PrivateChatTableName]) {
            [self createPrivateChatWithName:PrivateChatTableName withDB:db];
        }else{
            [self createTableWithName:tableName withDB:db];
        }
        return db;
    }
    NSLog(@"Database Open Error!");
    return nil;
}

/**
 *  如果表不存在，生成
 *
 *  @param tableName 表名
 *  @param db
 */
- (void)createTableWithName:(NSString*)tableName withDB:(FMDatabase*)db
{
    if (IsEmpty(tableName)) {
        return;
    }
   
    BOOL success = NO;
   
    if (![tableName isEqualToString:@"T_BLACK_BOARD"] && ![tableName isEqualToString:@"T_USER"]) {
        NSString *createStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'T_%@' ('messageNo' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, 'messageId' VARCHAR , 'message' VARCHAR, 'fromUserId' VARCHAR, 'fromUserName' VARCHAR, 'fromUserAvatar' VARCHAR, 'toUserId' VARCHAR, 'toUserName' VARCHAR, 'toUserAvatar' VARCHAR, 'timeSend' BIGINT, 'timeReceive' BIGINT, 'type' INTEGER, 'filePath' VARCHAR, 'fileName' VARCHAR, 'fileSize' INTEGER, 'timeLen' INTEGER, 'isRead' INTEGER, 'isSend' INTEGER, 'topicId' VARCHAR, 'wid' VARCHAR,'showTimestamp' INTEGER, 'attribute1' VARCHAR, 'attribute2' VARCHAR, 'attribute3' VARCHAR, 'attribute4' INTEGER, 'attribute5' INTEGER)", tableName];
        success = [db executeUpdate:createStr];
        if (!success) {
            NSLog(@"Create Table Error, TableName %@", tableName);
        }
    }
    NSString *createBlackboardTableStr = @"CREATE TABLE IF NOT EXISTS 'T_BLACK_BOARD' ('wid' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'title' VARCHAR, 'photo' VARCHAR, 'content' VARCHAR, 'boardType' INTEGER, 'attribute1' VARCHAR, 'attribute2' VARCHAR, 'attribute3' VARCHAR, 'attribute4' INTEGER, 'attribute5' INTEGER)";
    success = [db executeUpdate:createBlackboardTableStr];
    if (!success) {
        NSLog(@"Create Table Error, TableName %@", tableName);
    }
    
    NSString *createUserTableStr = @"CREATE TABLE IF NOT EXISTS 'T_USER' ('im_user_id' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'age' INTEGER, 'can_dm' INTEGER, 'username' VARCHAR, 'gender' INTEGER, 'title' VARCHAR, 'avatar' VARCHAR, 'cover' VARCHAR, 'footprint' VARCHAR, 'follow_status' VARCHAR, 'fans' INTEGER, 'follow' INTEGER, 'countries' INTEGER, 'cities' INTEGER, 'pois' INTEGER, 'trips' INTEGER, 'wants' INTEGER, 'attribute1' VARCHAR, 'attribute2' VARCHAR, 'attribute3' VARCHAR, 'attribute4' INTEGER, 'attribute5' INTEGER)";
    success = [db executeUpdate:createUserTableStr];
    if (!success) {
        NSLog(@"Create Table Error, TableName %@", tableName);
    }
}

/**
 *  根据表名和页数查询一条数据
 *
 *  @param tableName 表名
 *  @param messageId id
 *
 *  @return 当前消息
 */
- (Message*)queryWithTableName:(NSString *)tableName withMessageId:(NSString *)messageId
{
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    
    if (!db) {
        return nil;
    }
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM T_%@ WHERE messageId = '%@'", tableName, messageId];
    
    FMResultSet *result = [db executeQuery:queryStr];
    
    Message *message = nil;
    if ([result next]) {
        message = [self resultSet2Object:result];
    }
    [result close];
    return message;
}

/**
 *  根据表名查询一条数据
 *
 *  @param tableName 表名
 *  @param timeSend  消息发送时间
 *
 *  @return 当前消息
 */
- (Message*)queryWithTableName:(NSString*)tableName withTimeSend:(long long)timeSend
{
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    
    if (!db) {
        return nil;
    }
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM T_%@ WHERE timeSend = %lld", tableName, timeSend];
    
    FMResultSet *result = [db executeQuery:queryStr];
    Message *message = nil;
    if ([result next]) {
        message = [self resultSet2Object:result];
    }
    [result close];
    return message;
}

/**
 *  编辑数据
 *
 *  @param tableName 表名
 *  @param updateSql 编辑数据的sql语句
 */
- (void)executeUpdateWithTableName:(NSString*)tableName withUpdateSql:(NSString*)updateSql
{
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    if (!db) {
        return;
    }
    BOOL isSuccess = [db executeUpdate:updateSql];
    if (!isSuccess) {
        NSLog(@"executeUpdateWithTableName %@ Error, UpdateSQL %@", tableName, updateSql);
    }
}

/**
 *  增加一条数据
 *
 *  @param tableName 表名
 *  @param message   增加的消息
 */
- (void)insertWithTableName:(NSString*)tableName withObject:(Message*)message
{
    if (!IsEmpty(message.messageId)) {
        Message *msg = [self queryWithTableName:tableName withMessageId:message.messageId];
        if (msg) {
            return;
        }
    }
    
    NSString *insertStr = [NSString stringWithFormat:@"INSERT INTO T_%@ (messageId, message, fromUserId, fromUserName, fromUserAvatar, toUserId, toUserName, toUserAvatar, timeSend, timeReceive, type, filePath, fileName, fileSize, timeLen, isRead, isSend, topicId, wid, showTimestamp, attribute1, attribute2, attribute3, attribute4, attribute5) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@',%lld, %lld, %d,'%@','%@','%@', %d, %d,%d,'%@','%@', %d,'%@','%@','%@',%d, %d)", tableName, message.messageId, message.message, message.fromUserId, message.fromUserName, message.fromUserAvatar, message.toUserId, message.toUserName, message.toUserAvatar, message.timeSend, message.timeReceive, message.type, message.filePath , message.fileName, message.fileSize, message.timeLen, message.isRead, message.isSend, message.topicId, message.otherMessage.wid, message.showTimestamp, message.attribute1, message.attribute2, message.attribute3, message.attribute4, message.attribute5];

    [self executeUpdateWithTableName:tableName withUpdateSql:insertStr];
    
    if (message.type == JSBubbleMediaTypeRichText) {
        OtherMessage *otherMessage = message.otherMessage;
        insertStr = [NSString stringWithFormat:@"INSERT INTO T_BLACK_BOARD (wid, title, photo, content, boardType, attribute1, attribute2, attribute3, attribute4, attribute5) VALUES ('%@', '%@', '%@', '%@', %d, '%@', '%@', '%@', %d, %d)", otherMessage.wid, otherMessage.title, otherMessage.photo, otherMessage.content, otherMessage.type, otherMessage.attribute1, otherMessage.attribute2, otherMessage.attribute3, otherMessage.attribute4, otherMessage.attribute5];
        
        [self executeUpdateWithTableName:@"T_BLACK_BOARD" withUpdateSql:insertStr];
    }
}

/**
 *  删除某张表的所有数据
 *
 *  @param tableName 表名
 */
- (void)deleteAllDataWithTableName:(NSString*)tableName
{
    if (IsEmpty(tableName)) {
        NSLog(@"deleteAllDataWithTableName Error, TableName is nil");
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    [self executeUpdateWithTableName:tableName withUpdateSql:sql];
}

/**
 *  修改发送状态 0:未发送，1:已发送，2:发送失败
 *
 *  @param message
 */
- (void)updateIsSendWithMessage:(Message*)message
{
    NSString *tableName = (message.topicId && ![message.topicId isEqualToString:@""]) ? message.topicId : message.toUserId;
    if (IsEmpty(tableName)) {
        MYLog(@"updateMessageContentWithMessage Error, tableName is nil");
        return;
    }
    NSString *updateStr = [NSString stringWithFormat:@"UPDATE T_%@ SET isSend = %d WHERE messageId = '%@'", tableName, message.isSend, message.messageId];
    [self executeUpdateWithTableName:tableName withUpdateSql:updateStr];
}

/**
 *  修改发送内容
 *
 *  @param message
 */
- (void)updateMessageContentWithMessage:(Message*)message
{
    NSString *tableName = (message.topicId && ![message.topicId isEqualToString:@""]) ? message.topicId : message.toUserId;
    if (IsEmpty(tableName)) {
        MYLog(@"updateMessageContentWithMessage Error, tableName is nil");
        return;
    }
    NSString *updateStr = [NSString stringWithFormat:@"UPDATE T_%@ SET message = '%@' WHERE messageId = '%@'", tableName, message.message, message.messageId];
    
    [self executeUpdateWithTableName:tableName withUpdateSql:updateStr];
}

/**
 *  修改数据的MessageId
 *
 *  @param message
 */
- (void)updateMessageIdWithMessage:(Message*)message
{
    NSString *tableName = (message.topicId && ![message.topicId isEqualToString:@""]) ? message.topicId : message.toUserId;
    if (IsEmpty(tableName)) {
        MYLog(@"updateMessageIdWithMessage Error, tableName is nil");
        return;
    }
    NSString *updateStr = [NSString stringWithFormat:@"UPDATE T_%@ SET messageId = '%@', attribute1 = '%@' WHERE timeSend = %lld", tableName, message.messageId, message.attribute1, message.timeSend];
    
    [self executeUpdateWithTableName:tableName withUpdateSql:updateStr];
}

/**
 *  删除一条记录
 *
 *  @param message
 */
- (void)deleteWithMessage:(Message*)message
{
    NSString *tableName = (message.topicId && ![message.topicId isEqualToString:@""]) ? message.topicId : message.toUserId;
    if (IsEmpty(tableName)) {
        MYLog(@"deleteWithMessage Error, tableName is nil");
        return;
    }
    
    NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM T_%@ ", tableName];
    if (!IsEmpty(message.messageId)) {
        updateStr = [NSString stringWithFormat:@"%@ WHERE messageId = '%@'", updateStr, message.messageId];
    }else{
        updateStr = [NSString stringWithFormat:@"%@ WHERE timeSend = %lld", updateStr, message.timeSend];
    }
    
    [self executeUpdateWithTableName:tableName withUpdateSql:updateStr];
}

/**
 *  查询小黑板信息
 *
 *  @param wId 小黑板ID
 *
 *  @return
 */
- (OtherMessage*)queryBlackBoardWithWid:(NSString*)wId
{
    FMDatabase* db = [self createDatabaseWithTableName:@"T_BLACK_BOARD"];
    if (!db) {
        return nil;
    }
    NSString *queryStr = [NSString stringWithFormat:@"SELECT B.* FROM T_BLACK_BOARD AS B WHERE B.wid = '%@'", wId];
    FMResultSet *result = [db executeQuery:queryStr];
    OtherMessage *message = nil;
    if ([result next]) {
        message = [self resultSet2OtherMessage:result];
    }
    [result close];
    return message;
}

/**
 *  FMResultSet转换成Array
 *
 *  @param result FMResultSet
 *
 *  @return Array
 */
- (NSMutableArray*)resultSet2List:(FMResultSet*)result
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while ([result next]) {
        Message *message = [self resultSet2Object:result];
        if (message.type == JSBubbleMediaTypeRichText) {
            OtherMessage *otherMsg = [self queryBlackBoardWithWid:message.wid];
            message.otherMessage = otherMsg;
        }
        [array addObject:message];
    }
    //颠倒一下顺序
    NSMutableArray *msgList = [[NSMutableArray alloc] init];
    for (int i=array.count-1; i>=0; i--) {
        [msgList addObject:array[i]];
    }
    [array release];
    return [msgList autorelease];
}

/**
 *  FMResultSet转换成Message
 *
 *  @param result FMResultSet
 *
 *  @return Message
 */
- (Message*)resultSet2Object:(FMResultSet*)result
{
    Message *msg = [[Message alloc] init];
    msg.topicId = [result stringForColumn:@"topicId"];
    msg.messageId = [result stringForColumn:@"messageId"];
    msg.message = [result stringForColumn:@"message"];
    msg.fromUserId = [result stringForColumn:@"fromUserId"];
    msg.fromUserName = [result stringForColumn:@"fromUserName"];
    msg.fromUserAvatar = [result stringForColumn:@"fromUserAvatar"];
    msg.toUserId = [result stringForColumn:@"toUserId"];
    msg.toUserName = [result stringForColumn:@"toUserName"];
    msg.toUserAvatar = [result stringForColumn:@"toUserAvatar"];
    msg.timeSend = [[result stringForColumn:@"timeSend"] longLongValue];
    msg.timeReceive = [[result stringForColumn:@"timeReceive"] longLongValue];
    msg.type = [result intForColumn:@"type"];
    msg.filePath = [result stringForColumn:@"filePath"];
    msg.fileName = [result stringForColumn:@"fileName"];
    msg.fileSize = [result stringForColumn:@"fileSize"];
    msg.timeLen = [result intForColumn:@"timeLen"];
    msg.isRead = [result intForColumn:@"isRead"];
    msg.isSend = [result intForColumn:@"isSend"];
    msg.wid = [result stringForColumn:@"wid"];
    msg.showTimestamp = [result boolForColumn:@"showTimestamp"];
    msg.attribute1 = [result stringForColumn:@"attribute1"];
    msg.attribute2 = [result stringForColumn:@"attribute2"];
    msg.attribute3 = [result stringForColumn:@"attribute3"];
    msg.attribute4 = [result intForColumn:@"attribute4"];
    msg.attribute5 = [result intForColumn:@"attribute5"];
    return [msg autorelease];
}

/**
 *  result转换成OtherMessage
 *
 *  @param result
 *
 *  @return
 */
- (OtherMessage*)resultSet2OtherMessage:(FMResultSet*)result
{
    OtherMessage *other = [[OtherMessage alloc] init];
    other.wid = [result stringForColumn:@"wid"];
    other.title = [result stringForColumn:@"title"];
    other.photo = [result stringForColumn:@"photo"];
    other.content = [result stringForColumn:@"content"];
    other.type = [result intForColumn:@"boardType"];
    return [other autorelease];
}

/**
 *  查询某个时间之前的消息
 *
 *  @param timeSend 发送时间
 *
 *  @return
 */
- (NSMutableArray*)queryLocalMessages:(NSString *)tableName timeSend:(long long)timeSend isOffline:(BOOL)isOffline
{
    if (tableName == nil) {
        return nil;
    }
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    if (!db) {
        return [[[NSMutableArray alloc] init] autorelease];
    }
    NSString *queryStr = [NSString stringWithFormat:@"SELECT A.* FROM T_%@ AS A ORDER BY A.timeSend DESC LIMIT 0, %d", tableName, IM_QUERY_COUNT];
    if (timeSend > 0) {
        queryStr = [NSString stringWithFormat:@"SELECT A.* FROM T_%@ AS A WHERE %lld %@ A.timeSend ORDER BY A.timeSend DESC LIMIT 0, %d", tableName, timeSend, isOffline ? @"<" : @">", IM_QUERY_COUNT];
    }
    FMResultSet *result = [db executeQuery:queryStr];
    NSMutableArray *resultArr = [self resultSet2List:result];
    [result close];
    return resultArr;
}

/**
 *  数据库是否为空
 *
 *  @param tableName 表名
 *
 *  @return
 */
- (BOOL)isEmptyWithTableName:(NSString*)tableName
{
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    if (!db) {
        return YES;
    }
    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM T_%@ ", tableName];
    FMResultSet *result = [db executeQuery:queryStr];
    BOOL isEmpty = ![result next];
    [result close];
    return isEmpty;
}


#pragma mark - USER
/**
 *  通过USERID查询user对象
 *
 *  @param imUserId imUserId
 *
 *  @return UserInfo对象
 */
- (UserInfo*)queryUserWithImUserId:(NSString*)imUserId
{
    UserInfo *user = nil;
    FMDatabase* db = [self createDatabaseWithTableName:@"T_BLACK_BOARD"];
    if (!db) {
        return user;
    }
    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM T_USER WHERE im_user_id = '%@'", imUserId];
    FMResultSet *result = [db executeQuery:queryStr];
    
    if ([result next]) {
        user = [[UserInfo alloc] init];
        user.im_user_id = [result stringForColumn:@"im_user_id"];
        user.age = [result intForColumn:@"age"];
        user.can_dm = [result intForColumn:@"can_dm"];
        user.username = [result stringForColumn:@"username"];
        user.gender = [result intForColumn:@"gender"];
        user.title = [result stringForColumn:@"title"];
        user.avatar = [result stringForColumn:@"avatar"];
        user.cover = [result stringForColumn:@"cover"];
        user.footprint = [result stringForColumn:@"footprint"];
        user.follow_status = [result stringForColumn:@"follow_status"];
        user.fans = [result intForColumn:@"fans"];
        user.follow = [result intForColumn:@"follow"];
        user.countries = [result intForColumn:@"countries"];
        user.cities = [result intForColumn:@"cities"];
        user.pois = [result intForColumn:@"pois"];
        user.trips = [result intForColumn:@"trips"];
        user.wants = [result intForColumn:@"wants"];
        user.attribute1 = [result stringForColumn:@"attribute1"];
        user.attribute2 = [result stringForColumn:@"attribute2"];
        user.attribute3 = [result stringForColumn:@"attribute3"];
        user.attribute4 = [result intForColumn:@"attribute4"];
        user.attribute5 = [result intForColumn:@"attribute5"];
    }
    [result close];
    return [user autorelease];
}

/**
 *  增加或者修改UserInfo对象
 *
 *  @param user UserInfo对象
 */
- (void)replaceUserWithUserInfo:(UserInfo*)user
{
    NSString *insertStr = [NSString stringWithFormat:@"REPLACE INTO T_USER (im_user_id, age, can_dm, username, gender, title, avatar, cover, footprint, follow_status, fans, follow, countries, cities, pois, trips, wants, attribute1, attribute2, attribute3, attribute4, attribute5) VALUES ('%@', %d, %d, '%@', %d, '%@', '%@','%@','%@','%@',%d, %d, %d, %d, %d, %d, %d, '%@','%@','%@',%d, %d)", user.im_user_id, user.age, user.can_dm, user.username, user.gender, user.title, user.avatar, user.cover, user.footprint, user.follow_status, user.fans, user.follow, user.countries, user.cities, user.pois, user.trips, user.wants, user.attribute1, user.attribute2, user.attribute3, user.attribute4, user.attribute5];
    
    [self executeUpdateWithTableName:@"T_USER" withUpdateSql:insertStr];
}

#pragma mark --privateChatList

//**************************************
/**
 *  创建聊天对象表
 */

- (void)createPrivateChatWithName:(NSString*)tableName withDB:(FMDatabase*)db
{

    NSString *createStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'T_%@' ('clientId' VARCHAR PRIMARY KEY NOT NULL UNIQUE, 'messageId' VARCHAR , 'lastMessage' VARCHAR, 'chatUserName' VARCHAR, 'chatUserAvatar' VARCHAR,'lastTime' DATETIME,'unReadNumber' INTEGER, 'attribute1' VARCHAR, 'attribute2' VARCHAR, 'attribute3' VARCHAR, 'attribute4' INTEGER, 'attribute5' INTEGER)", tableName];
    BOOL success = [db executeUpdate:createStr];
    if (!success) {
        NSLog(@"Create Table Error!");
    }
}
/**
 *  增加一条数据
 *
 *  @param tableName 表名
 *  @param chatObj   增加的消息
 */
- (void)insertPrivateChatWithTableName:(NSString *)tableName withObject:(PrivateChat *)chatObj{
    NSString *queryStr = [NSString stringWithFormat:@"SELECT unReadNumber FROM T_%@ WHERE clientId = '%@'",tableName,chatObj.clientId];
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    if (!db) {
        return;
    }
    
    //如果正在跟当前用户聊天，那么就是0
    if ([[QYIMObject getInstance].privateChatImUserId isEqualToString:chatObj.clientId]) {
        chatObj.unReadNumber = 0;
    }else{
        
        FMResultSet *result = [db executeQuery:queryStr];
        if ([result next]) {
            int unNumber = [result intForColumn:@"unReadNumber"];
            if (unNumber != 0) {
                unNumber ++;
                chatObj.unReadNumber = unNumber;

            }
            
            NSLog(@"1 = %d",unNumber);
            NSLog(@"2 = %d",chatObj.unReadNumber);
        }
        [result close];
        
        //记录私信总数，++
        NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
        NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
        totalPriChatNum++;
        NSLog(@"==== %d",totalPriChatNum);
        [myUserDefault setInteger:totalPriChatNum forKey:TotalPrivateChatNumber];
        [myUserDefault synchronize];
    }
    
    NSString *insertStr = [NSString stringWithFormat:@"INSERT OR REPLACE INTO T_%@ (clientId, messageId, lastMessage, chatUserName, chatUserAvatar, lastTime, unReadNumber, attribute1, attribute2, attribute3, attribute4, attribute5) VALUES ('%@','%@','%@','%@','%@','%@','%d','%@','%@','%@',%d, %d)",tableName,chatObj.clientId,chatObj.messageId,chatObj.lastMessage,chatObj.chatUserName,chatObj.chatUserAvatar,[NSDateUtil stringFromDate:chatObj.lastTime],chatObj.unReadNumber,chatObj.attribute1,chatObj.attribute2,chatObj.attribute3,chatObj.attribute4,chatObj.attribute5];
    
    [self executeUpdateWithTableName:tableName withUpdateSql:insertStr];
}
-(void)insertReplacePrivateChatWithTableName:(NSString *)tableName withObject:(PrivateChat *)chatObj{
    
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT unReadNumber FROM T_%@ WHERE clientId = '%@'",tableName,chatObj.clientId];

    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    if (!db) {
        return;
    }
    
    BOOL isNeedInsert = NO;
    FMResultSet *result = [db executeQuery:queryStr];
    if ([result next]) {
        
        int unNumber = [result intForColumn:@"unReadNumber"];
        //如果数据库的个数小于箭扣的个数，才会insert
        if (unNumber < chatObj.unReadNumber) {
            //才会插入
            isNeedInsert = YES;
        }
        
    }else{
        
        isNeedInsert = YES;
    }
    [result close];
    
    
    if (isNeedInsert == YES) {
        
        
        NSString *insertStr = [NSString stringWithFormat:@"INSERT OR REPLACE INTO T_%@ (clientId, messageId, lastMessage, chatUserName, chatUserAvatar, lastTime, unReadNumber, attribute1, attribute2, attribute3, attribute4, attribute5) VALUES ('%@','%@','%@','%@','%@','%@','%d','%@','%@','%@',%d, %d)",tableName,chatObj.clientId,chatObj.messageId,chatObj.lastMessage,chatObj.chatUserName,chatObj.chatUserAvatar,[NSDateUtil stringFromDate:chatObj.lastTime],chatObj.unReadNumber,chatObj.attribute1,chatObj.attribute2,chatObj.attribute3,chatObj.attribute4,chatObj.attribute5];
        
        [self executeUpdateWithTableName:tableName withUpdateSql:insertStr];
    }
   
}

/**
 *  根据表名查询私聊的列表
 *
 *  @param tableName 表名
 *
 *  @return 查询返回的结果
 */
- (NSMutableArray*)queryPrivateChatWithTableName:(NSString*)tableName{
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    if (!db) {
        return [[[NSMutableArray alloc] init] autorelease];
    }
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM T_%@  ORDER BY lastTime DESC", tableName];
    //    NSLog(@"queryStr %@", queryStr);
    FMResultSet *result = [db executeQuery:queryStr];
    
    NSMutableArray *resultArr = [[[NSMutableArray alloc]init] autorelease];
    while ([result next]) {
        PrivateChat *pChat = [[PrivateChat alloc]init];
        pChat.messageId = [result stringForColumn:@"messageId"];
        pChat.lastMessage = [result stringForColumn:@"lastMessage"];
        pChat.clientId = [result stringForColumn:@"clientId"];
        pChat.chatUserName = [result stringForColumn:@"chatUserName"];
        pChat.chatUserAvatar = [result stringForColumn:@"chatUserAvatar"];
        pChat.lastTime =  [NSDateUtil dateFromString:[result stringForColumn:@"lastTime"]];
        pChat.unReadNumber = [result intForColumn:@"unReadNumber"];
        pChat.attribute1 = [result stringForColumn:@"attribute1"];
        pChat.attribute2 = [result stringForColumn:@"attribute2"];
        pChat.attribute3 = [result stringForColumn:@"attribute3"];
        pChat.attribute4 = [result intForColumn:@"attribute4"];
        pChat.attribute5 = [result intForColumn:@"attribute5"];
        
        [resultArr addObject:pChat];
        [pChat release];
        
    }
    
    NSLog(@"resultArr is %@",resultArr);

    [result close];
    return resultArr;
}
/**
 *  重新设置未读消息个数
 *
 *  @param tableName
 */
- (void)resetPrivateChatUnReadNumberTableName:(NSString *)tableName withObject:(PrivateChat *)chatObj{
    NSString *queryStr = [NSString stringWithFormat:@"UPDATE T_%@ SET unReadNumber =%d WHERE clientId = '%@'",tableName,0,chatObj.clientId];
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    if (!db) {
        return;
    }
    [db executeUpdate:queryStr];
}
/**
 *
 *  重新设置未读消息个数
 *  @param tableName
 */
- (void)resetAllPrivateChatUnReadNumberTableName:(NSString *)tableName{
    
    NSString *queryStr = [NSString stringWithFormat:@"UPDATE T_%@ SET unReadNumber =%d;",tableName,0];
    FMDatabase* db = [self createDatabaseWithTableName:tableName];
    if (!db) {
        return;
    }
    [db executeUpdate:queryStr];
}

/**
 *  删除某一条私信记录
 *
 *  @param clientId 聊天对象ID
 */
- (void)deleteItemFromPrivateChatWithCliendId:(NSString *)clientId{
    
    NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM T_%@ WHERE clientId = '%@'",PrivateChatTableName,clientId];
    [self executeUpdateWithTableName:PrivateChatTableName withUpdateSql:updateStr];
}
/**
 *  清空私信列表
 */
- (void)clearPrivateChat{
    
    NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM T_%@;",PrivateChatTableName];
    [self executeUpdateWithTableName:PrivateChatTableName withUpdateSql:updateStr];
}
//*************************************************





/**
 *  生成数据库文件夹
 *
 *  @param tableName
 *
 *  @return
 */
- (NSString*)dbFilePath
{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:IMRootDirectory];
    BOOL isDirectory;
    NSError *error = nil;
    NSFileManager *fileMagager = [NSFileManager defaultManager] ;
    BOOL isExist = [fileMagager fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (!isExist) {
        [fileMagager createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return filePath;
}

- (void)dealloc
{
    [super dealloc];
}

@end
