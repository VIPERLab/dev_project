//
//  ViewController.m
//  ChatMessageTableViewController
//
//  Created by Yongchao on 21/11/13.
//  Copyright (c) 2013 Yongchao. All rights reserved.
//

#import "ChatViewController.h"
#import "Message.h"
#import "LocalData.h"
#import "JSBubbleImageViewFactory.h"
#import "LoadMoreView.h"
#import "PhotoListController.h"
#import "UserInfo.h"
#import "NSDateUtil.h"
#import "UIImageView+WebCache.h"
#import "QYIMObject.h"
#import "OtherMessage.h"
#import "MineViewController.h"
#import "BoardDetailViewController.h"
#import "JSBubbleView.h"
#import "QYIMObject.h"
#import "QYImageUtil.h"
#import "ASIFormDataRequest.h"
#import "NSData+Base64.h"

/**
 *  消息之间间隔多久，显示时间，单位是毫秒
 */
static NSInteger const kShowTimeInterval = 300000;

/**
 *  敏感词
 */
static NSString const *kSensitiveText = @"包含敏感词汇，发送失败！";

/**
 *  新用户加入聊天室
 */
static NSString const *kUserLabelText = @"加入聊天室";


@implementation ChatViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    //菊花
    _activityView = [[UIActivityIndicatorView alloc] init];
    _activityView.frame = CGRectMake(100, ios7 ? 28 : 8, 30, 30);
    _activityView.backgroundColor = [UIColor clearColor];
    _activityView.hidden = YES;
    [self.view addSubview:_activityView];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    self.messages = array;
    [array release];
    
    _photoBrowser = [[CXPhotoBrowser alloc] initWithDataSource:self delegate:self];
    _photoBrowser.wantsFullScreenLayout = YES;
    _photoDataSource = [[NSMutableArray alloc] init];
    
    _sendMsgItem = [[NSMutableDictionary alloc] init];
    _sendImageIndexPathItem = [[NSMutableDictionary alloc] init];
    
    //设置发送人
    [self configFromUserInfo];
    
    //当前消息发送人
    self.sender = _fromUserInfo.username;
    
    NSString *chatName = [self notificationNameWithName:@"Chat"];
    NSString *offlineName = [self notificationNameWithName:@"OfflineHistoryMessages"];
    NSString *loadStatusName = [self notificationNameWithName:@"IMLoadingStatus"];
    NSString *messageSentName = [self notificationNameWithName:@"MessageSent"];
    NSString *sensitiveName = [self notificationNameWithName:@"Sensitive"];
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(chatHandler:) name:chatName object:nil];
    [notification addObserver:self selector:@selector(messageSent:) name:messageSentName object:nil];
    [notification addObserver:self selector:@selector(sensitiveHandler:) name:sensitiveName object:nil];
    [notification addObserver:self selector:@selector(queryOfflineHistoryMessages:) name:offlineName object:nil];
    [notification addObserver:self selector:@selector(showNewUserJoin:) name:@"NewUserJoin" object:nil];
    [notification addObserver:self selector:@selector(changeLoadStatus:) name:loadStatusName object:nil];
    [notification addObserver:self selector:@selector(reloadTableView) name:@"ReloadTableView" object:nil];
    
    if (self.chatType == ChatTypePublic) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PUBLIC" object:nil userInfo:@{@"isLoading":@(YES)}];
        [self queryOfflineMessages];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Private

/**
 *  加载状态发生改变，触发的通知
 *
 *  @param notification
 */
- (void)changeLoadStatus:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    BOOL isLoading = [userInfo[@"isLoading"] boolValue];
    if (isLoading) {    //正在重新连接获取离线消息
        NSString *loadingStr = @"   收取中...";
        if ([_titleLabel.text isEqualToString:loadingStr]) {
            return;
        }
        if (_navigationTitle) {
            [_navigationTitle release];
            _navigationTitle = nil;
        }
        _navigationTitle = [_titleLabel.text retain];
        _titleLabel.text = loadingStr;
        _activityView.hidden = NO;
        [_activityView startAnimating];
        [self.messageInputView setEnable:NO];
    }else{      //连接完成
        if (_navigationTitle && ![_navigationTitle isEqualToString:@""]) {
            _titleLabel.text = _navigationTitle;
        }
        _activityView.hidden = YES;
        [_activityView stopAnimating];
        [self.messageInputView setEnable:YES];
    }
}

/**
 *  刷新表格
 */
- (void)reloadTableView
{
    [self.tableView reloadData];
}

/**
 *  上传图片到服务器
 *
 *  @param data 图片
 */
- (void)uploadImageWithData:(NSData*)data withBlock:(UploadImageBlock)block
{
    if (!data) {
        NSLog(@"uploadImageWithData 上传的图片为nil");
        return;
    }
    NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/qyer/chatroom/upload_photo",DomainName];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    request.delegate = self;
    request.timeOutSeconds = 10;
    [request setRequestMethod:@"POST"];
    [request addPostValue:ClientId_QY forKey:@"client_id"];
    [request addPostValue:ClientSecret_QY forKey:@"client_secret"];
    [request addPostValue:token forKey:@"oauth_token"];
    [request setData:data withFileName:@"photo" andContentType:@"image/png" forKey:@"photo"];
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        NSDictionary *resultItem = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (block) {
            block(resultItem[@"data"], [resultItem[@"status"] intValue] == 1);
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"uploadImageWithData Error %@", request.error);
        if (block) {
            block(nil, NO);
        }
    }];
    [request startAsynchronous];
}

/**
 *  显示新用户加入
 *
 *  @param notification
 */
- (void)showNewUserJoin:(NSNotification*)notification
{
    if (self.chatType == ChatTypePrivate) {
        return;
    }
    NSDictionary *item = notification.userInfo;
    NSString *userName = item[@"userName"];   //新用户名字
    Message *msg = [[Message alloc] init];
    msg.type = JSBubbleMediaTypeNewUserJoin;
    msg.userName = [NSString stringWithFormat:@"%@", userName];
    
    BOOL isShowLastCell = [self isShowLastCell];
    [self.messages addObject:msg];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
    if (isShowLastCell) {
        [self performSelector:@selector(scrollToBottomAnimated:) withObject:@(YES) afterDelay:0];
    }
    [msg release];
}

/**
 *  当触发通知的时候，查询聊天室的离线数据显示到列表
 */
- (void)queryOfflineHistoryMessages:(NSNotification*)notification
{
    long long timeSend = 0;
    if (self.messages.count > 0) {  //获取最后一条消息的发送时间
        Message *message = self.messages[self.messages.count - 1];
        timeSend = message.timeSend;
    }
    NSString *tableName = self.topicId;
    if (self.chatType == ChatTypePrivate) {
        tableName = self.toUserInfo.im_user_id;
    }
    //查询比最后一条发送消息晚的所有消息
    NSArray* array = [[LocalData getInstance] queryLocalMessages:tableName timeSend:timeSend isOffline:YES];
    NSInteger count = [QYIMObject getInstance].offlineMessageCountPublic;
    if (self.chatType == ChatTypePrivate) {
        count = [[QYIMObject getInstance].offlineMessageItemPrivate[self.toUserInfo.im_user_id] integerValue];
    }
    if (count == 0) {    //如果没有未读消息了，那么追加到现在消息后面
        [self reloadTableAfterQueryWithArray:array withIsInit:NO withIsAdd:YES];
    }else{                  //如果还有未读消息，那么删除以前消息，只显示当前10条
        [self reloadTableAfterQueryWithArray:array withIsInit:YES withIsAdd:NO];
    }
}

/**
 *  查询消息
 */
- (void)queryMessages
{
    if (!isNotReachable) {
        [self queryOfflineMessages];
    }else{
        [self queryLocalMessages];
    }
}

/**
 *  查询离线消息
 */
- (void)queryOfflineMessages
{
    if (isNotReachable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PUBLIC" object:nil userInfo:@{@"isLoading":@(NO)}];
        [self queryLocalMessages];
        return;
    }
    _isQueryOffline = YES;
    
    long long timeSend = [self getTheTopMessageTimeSend];
    NSNumber *timeInterval = timeSend > 0 ? @(timeSend) : nil;
    [[QYIMObject getInstance] queryTopicHistoryWithTimestamp:timeInterval withBlock:^(QYIMObject *imObject, NSArray *messages) {
        [self queryLocalMessages];
      
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PUBLIC" object:nil userInfo:@{@"isLoading":@(NO)}];
    }];
    
//    [[QYIMObject getInstance] queryOfflineHistoryTopicMessagesWithBlock:^(NSArray *messages, int count) {
//        [self queryLocalMessages];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PUBLIC" object:nil userInfo:@{@"isLoading":@(NO)}];
//    }];
}

/**
 *  从本地数据库获取数据
 *
 *  @param pageNum 页数
 */
- (void)queryLocalMessages
{
    _isQueryOffline = NO;
    //获取最上面一条消息的发送时间
    long long timeSend = [self getTheTopMessageTimeSend];
    NSArray *array = [self queryLocalDataWithTimeSend:timeSend];
    [self reloadTableAfterQueryWithArray:array withIsInit:(timeSend == 0) withIsAdd:NO];
    if (array.count == 0) {
        [_loadMoreView removeFromSuperview];
        [_loadMoreView release];
        _loadMoreView = nil;
        self.tableView.tableHeaderView = nil;
    }
}

/**
 *  查询之后，刷新表格
 *
 *  @param array  数组
 *  @param isInit 是否初始化数组
 */
- (void)reloadTableAfterQueryWithArray:(NSArray*)array withIsInit:(BOOL)isInit withIsAdd:(BOOL)isAdd
{
    _isLoading = NO;
    if (array.count == 0) {
        return;
    }
    if (isInit) {   //如果是初始化，那么重新清空原来消息，初始化一个新messages
        [self configMessagesWithArray:array];
    }else {
        if (isAdd){  //如果是添加的，那么把消息添加到messages末尾
            BOOL isShowLastCell = [self isShowLastCell];
            [self.messages addObjectsFromArray:array];
            [self.tableView reloadData];
            if (isShowLastCell) {
                //接收到新消息，如果显示最后一行，那么滚动到最底部。
                [self scrollToBottomAnimated:YES];
            }
        }else {             //否则，把消息插入到messages开头
            [self.messages insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [array count])]];
            [self performSelector:@selector(endLoading:) withObject:@([array count]) afterDelay:0];
        }
        
    }
    //把消息里面的图片，加入到图片数组
    [self photoBrowserAddImageWithMessages:array];
}

/**
 *  根据聊天类型，获取通知名字
 *
 *  @param chatType 聊天类型
 *  @param name     通知名字
 *
 *  @return 变更之后的名字
 */
- (NSString*)notificationNameWithName:(NSString*)name
{
    return [NSString stringWithFormat:@"%@_%@", name, (self.chatType == ChatTypePrivate) ? @"PRIVATE" : @"PUBLIC"];
}

/**
 *  把messages里面的图片加入到图片数组中
 *
 *  @param messages 消息
 *  @param pageNum  当前页数
 */
- (void)photoBrowserAddImageWithMessages:(NSArray*)array
{
    //如果是图片类型，加入到图片数组中
    for (NSInteger i = 0; i < [array count]; i++) {
        Message *message = array[i];
        if (message.type == JSBubbleMediaTypeImage) {
            CXPhoto *photo = [[CXPhoto alloc] initWithImage:[UIImage imageWithData:message.fileData]];
            photo.imageUrl = message.attribute1;
            photo.timeSend = message.timeSend;
            [_photoDataSource addObject:photo];
            [photo release];
        }
    }
    //按照发送时间，把照片排序
    _photoDataSource = [[_photoDataSource sortedArrayUsingComparator:^NSComparisonResult(CXPhoto *obj1, CXPhoto *obj2) {
        return obj1.timeSend > obj2.timeSend;
    }] mutableCopy];
    [_photoBrowser reloadData];
}

/**
 *  从本地读取用户信息
 */
- (void)configFromUserInfo
{
    NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
    if (_fromUserInfo) {
        [_fromUserInfo release];
        _fromUserInfo = nil;
    }
    _fromUserInfo = [[UserInfo alloc] init];
    _fromUserInfo.username = [myDefault objectForKey:@"username"];
    _fromUserInfo.avatar = [myDefault objectForKey:@"usericon"];
    _fromUserInfo.im_user_id = [myDefault objectForKey:@"userid_im"];
}

/**
 *  根据页数查询本地消息历史记录
 *
 *  @param pageNum 页数
 *
 *  @return 查询结果
 */
- (NSMutableArray*)queryLocalDataWithTimeSend:(long long)timeSend
{
    NSString *tableName = self.topicId;
    if (self.chatType == ChatTypePrivate) {
        tableName = self.toUserInfo.im_user_id;
    }
    return [[LocalData getInstance] queryLocalMessages:tableName timeSend:timeSend isOffline:NO];
}

/**
 *  向下滑动加载更多历史记录
 *
 *  @param scrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isUserScrolling) {
        [self.messageInputView resignFirstResponder];
        return;
    }
    if (scrollView.contentOffset.y < 0 && (_loadMoreView && _loadMoreView.hidden) && !_isLoading) {
        _isLoading = YES;
        _loadMoreView.hidden = NO;
        [_loadMoreView changeLoadingStatus:YES];
        [self queryMessages];
    }
}

/**
 *  结束加载状态, 刷新表格，滚动到上次数据位置
 */
- (void)endLoading:(NSNumber*)count
{
    [_loadMoreView changeLoadingStatus:NO];
    _loadMoreView.hidden = YES;
    [self.tableView reloadData];
    
    CGFloat height = 0;
    for (int i=0; i<[count integerValue]; i++) {
        height += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    //表格滚动到上次加在的位置
    
    self.tableView.contentOffset = CGPointMake(0, height);
    
    if ([count integerValue] < IM_QUERY_COUNT && !_isQueryOffline) {
        [_loadMoreView removeFromSuperview];
        [_loadMoreView release];
        _loadMoreView = nil;
        self.tableView.tableHeaderView = nil;
    }
}

/**
 *  是否显示最后一个单元格
 *
 *  @return
 */
- (BOOL)isShowLastCell
{
    CGPoint offset = self.tableView.contentOffset;
    CGRect bounds = self.tableView.bounds;
    CGSize size = self.tableView.contentSize;
    UIEdgeInsets inset = self.tableView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float height = size.height;
    
    return y == height;
}

/**
 *  AppDelegate接收到消息之后，触发通知，把接收到的消息，显示在表格上
 *
 *  @param notification
 */
- (void)chatHandler:(NSNotification*)notification
{
    NSString *messageId = notification.userInfo[@"messageId"];
    
    NSString *tableName = self.chatType == ChatTypePrivate ? self.toUserInfo.im_user_id : self.topicId;
    Message *message = [[LocalData getInstance] queryWithTableName:tableName withMessageId:messageId];
    
    //如果是私聊，判断cliendId是否和当前一致。
    //如果是聊天室，判断是否是同一个聊天室ID
    
    BOOL privateBool = (self.chatType == ChatTypePrivate &&
                        [self.toUserInfo.im_user_id isEqualToString:message.fromUserId]);
    BOOL publicBool = (self.chatType == ChatTypePublic &&
                       [self.topicId isEqualToString:message.topicId]);
    
    if (privateBool || publicBool) {
        BOOL isShowLastCell = [self isShowLastCell];
        [self.messages addObject:message];
        [self.tableView reloadData];
        if (isShowLastCell) {
            //接收到新消息，如果显示最后一行，那么滚动到最底部。
            [self scrollToBottomAnimated:YES];
        }
        //如果是图片类型，把图片加入到图片数据源
        if (message.type == JSBubbleMediaTypeImage) {
            CXPhoto *photo = [[CXPhoto alloc] initWithImage:[UIImage imageWithData:message.fileData]];
            photo.imageUrl = message.attribute1;
            photo.timeSend = message.timeSend;
            [_photoDataSource addObject:photo];
            [photo release];
            [_photoBrowser reloadData];
        }
    }
}

/**
 *  发送的消息中，包含敏感词触发的通知
 *
 *  @param notification
 */
- (void)sensitiveHandler:(NSNotification*)notification
{
    //获取到敏感词汇消息的消息ID
    NSString *messageId = notification.userInfo[@"messageId"];
    NSString *tableName = self.chatType == ChatTypePrivate ? self.toUserInfo.im_user_id : self.topicId;
    Message *message = [[LocalData getInstance] queryWithTableName:tableName withMessageId:messageId];
    if (!message) {
        message = [[[Message alloc] init] autorelease];
    }
    message.message = [NSString stringWithFormat:@"\"%@\" %@", message.message, kSensitiveText];
    [[LocalData getInstance] updateMessageContentWithMessage:message];
}

/**
 *  消息送达服务器触发的方法
 *
 *  @param notification
 */
- (void)messageSent:(NSNotification*)notification
{
    NSDictionary *item = notification.userInfo;
    BOOL isSuc = [item[@"isSuccess"] boolValue];    //是否发送成功
    NSString *messageId = item[@"messageId"];
    NSInteger indexPathRow = [_sendMsgItem[messageId] integerValue];    //当前行
    
    if (self.messages.count > indexPathRow) {
        Message *message = self.messages[indexPathRow];
        if (message) {  //当前行数据
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexPathRow inSection:0];
            JSBubbleMessageCell *cell = (JSBubbleMessageCell*)[self.tableView cellForRowAtIndexPath:indexPath];//当前行单元格
            if (isSuc) {
                message.messageId = messageId;
                message.isSend = 1;
                cell.bubbleView.sendAgainButton.hidden = YES;
                //如果发送成功，把当前图片从图片字典中移除掉
                NSString *key = [NSString stringWithFormat:@"%lld", message.timeSend];
                [_sendImageIndexPathItem removeObjectForKey:key];
                [self removeImageDataWithKey:key];
            }else{
                message.isSend = 2; //发送失败
                //如果发送失败，显示重新发送按钮
                cell.bubbleView.sendAgainButton.hidden = NO;
            }
            [cell.bubbleView.activityView performSelector:@selector(setHidden:) withObject:@(YES) afterDelay:0];
            [[LocalData getInstance] updateIsSendWithMessage:message];
            [self.tableView reloadData];
            [_sendMsgItem removeObjectForKey:messageId];
        }
    }
}

/**
 *  返回上一个视图控制器
 */
- (void)backFromPhotoViewButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  图片保存按钮触发的方法
 *
 *  @param button
 */
- (void)savePhotoViewButton:(UIButton*)button
{
    if (!_isSavePhotoing) {
        button.highlighted = YES;
        _isSavePhotoing = YES;
        CXPhoto *photo = _photoDataSource[_photoBrowser.currentPageIndex];
        
        if (photo.underlyingImage) {
            UIImageWriteToSavedPhotosAlbum(photo.underlyingImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

/**
 *  上传图片到服务器
 *
 *  @param paramItem
 */
- (void)uploadImageToRemote:(NSMutableDictionary*)paramItem
{
    NSData *thumbnailData = paramItem[@"thumbnailData"];    //缩略图
    NSData *imageData = paramItem[@"imageData"];            //大图
    NSString *imageName = paramItem[@"imageName"];          //图片名
    NSString *imgUrl = paramItem[@"imageUrl"];              //图片URL
    
    if (!thumbnailData) {
        return;
    }
    
    long long timeSend = [NSDate date].timeIntervalSince1970 * 1000;    //取系统时间当发送时间
    NSString *key = [NSString stringWithFormat:@"%lld", timeSend];
    [self setImageDataToLocal:imageData withKey:key];   //用发送时间当key，存储把大图存储到本地
    
    //把缩略图显示在表格上，并且把数据保存到本地数据库
    [self saveLocaDataWithMessage:@"" withMessageId:@"" withType:JSBubbleMediaTypeImage withFileData:thumbnailData withTimeSend:timeSend];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
    
    if (IsEmpty(imgUrl)) {      //当上传图片服务器成功，但发送到IM服务器失败时，imgUrl会有值
        //通过图片名字，从本地获取图片远程URL
        imgUrl = [self getImageUrlFromImageName:imageName];
    }
    if (!IsEmpty(imgUrl)) { //如果有图片URL，那么把缩略图加入到图片浏览视图，并且发送到IM服务器
        [paramItem setValue:imgUrl forKey:@"imageUrl"];
        [paramItem setValue:@(timeSend) forKey:@"timeSend"];
        [self addPhotoBrowserAndSendImage:paramItem];
        return;
    }
    
    //如果本地没有图片的URL，那么上传图片到服务器
    [self uploadImageWithData:imageData withBlock:^(NSDictionary *resultItem, BOOL status) {
        if (status && [resultItem isKindOfClass:[NSDictionary class]]) {   //上传成功
            NSString *imageUrl = resultItem[@"original_photo"]; //图片远程URL
            //通过图片名字，把图片远程URL保存到本地
            [self saveImageUrlWithImageName:imageName withImageUrl:imageUrl];
            
            //把缩略图加入到图片浏览视图，并且发送到IM服务器
            [paramItem setValue:imageUrl forKey:@"imageUrl"];
            [paramItem setValue:@(timeSend) forKey:@"timeSend"];
            [self addPhotoBrowserAndSendImage:paramItem];
        }else{      //上传失败
            //通过发送时间，获取当前行数
            [self uploadImageToRemoteFailWithKey:key];
        }
    }];
}

/**
 *  把图片加入图片浏览器，并且发送图片到IM服务器
 *
 *  @param item 发送时间
 */
- (void)addPhotoBrowserAndSendImage:(NSDictionary*)item
{
    NSData *thumbnailData = item[@"thumbnailData"]; //缩略图
    NSString *imageUrl = item[@"imageUrl"];         //大图
    long long timeSend = [item[@"timeSend"] longLongValue]; //发送时间
    NSString *key = [NSString stringWithFormat:@"%lld", timeSend];
    
    //把缩略图加入到图片浏览器
    CXPhoto *photo = [[CXPhoto alloc] initWithImage:[UIImage imageWithData:thumbnailData]];
    photo.imageUrl = imageUrl;
    photo.timeSend = timeSend;
    [_photoDataSource addObject:photo];
    [photo release];
    [_photoBrowser reloadData];
    
    if (IsEmpty(imageUrl)) {
        NSLog(@"uploadImageWithData imageUrl is nil");
        [self uploadImageToRemoteFailWithKey:key];
        return ;
    }
    //IM发送图片
    [self sendImage:item];
}

/**
 *  上传服务器失败，标记当前行发送失败
 *
 *  @param key
 */
- (void)uploadImageToRemoteFailWithKey:(NSString*)key
{
    NSInteger rowNumber = [_sendImageIndexPathItem[key] integerValue];
    
    if (self.messages.count > rowNumber) {
        Message *message = self.messages[rowNumber];
        if (message) {  //当前行数据
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowNumber inSection:0];
            JSBubbleMessageCell *cell = (JSBubbleMessageCell*)[self.tableView cellForRowAtIndexPath:indexPath];//当前行单元格
            message.isSend = 2; //发送失败
            //如果发送失败，显示重新发送按钮
            cell.bubbleView.sendAgainButton.hidden = NO;
            [cell.bubbleView.activityView performSelector:@selector(setHidden:) withObject:@(YES) afterDelay:0];
            [[LocalData getInstance] updateIsSendWithMessage:message];
            [self.tableView reloadData];
            [_sendImageIndexPathItem removeObjectForKey:key];
        }
    }
}


/**
 *  发送图片
 *
 *  @param willSendImage 图片
 */
- (void)sendImage:(NSDictionary*)paramItem
{
    NSData *thumbnailData = paramItem[@"thumbnailData"];
    NSString *imageUrl = paramItem[@"imageUrl"];
    long long timeSend = [paramItem[@"timeSend"] longLongValue];
    
    if (!thumbnailData) {
        return;
    }
    //把消息类型存入到customData
    NSDictionary *customData = @{@"type":@(JSBubbleMediaTypeImage), @"imageUrl":imageUrl, @"fromUserAvatar":[[NSUserDefaults standardUserDefaults] objectForKey:@"usericon"], @"fromUserName":_fromUserInfo.username};
    NSString *messageId = @"";
    if (self.chatType == ChatTypePublic) {
        //群聊
        messageId = [[QYIMObject getInstance] sendBinary:thumbnailData customData:customData];
    }else{
        //私聊
        messageId = [[QYIMObject getInstance] sendBinary:thumbnailData customData:customData toUserId:self.toUserInfo.im_user_id];
    }
    
    NSNumber *count = @(self.messages.count - 1);
    if (!IsEmpty(messageId)) {
        [_sendMsgItem setValue:count forKey:messageId];
    }
    
    NSString *tableName = self.topicId;
    if (self.chatType == ChatTypePrivate) {
        tableName = self.toUserInfo.im_user_id;
    }
    Message *message = [[LocalData getInstance] queryWithTableName:tableName withTimeSend:timeSend];
    message.messageId = messageId;
    message.attribute1 = imageUrl;
    [[LocalData getInstance] updateMessageIdWithMessage:message];
}

/**
 *  消息存放到本地
 *
 *  @param messageId 消息ID
 *  @param mediaType 消息类型
 *  @param fileData  文件
 */
- (void)saveLocaDataWithMessage:(NSString*)message withMessageId:(NSString*)messageId withType:(JSBubbleMediaType)mediaType withFileData:(NSData*)fileData withTimeSend:(long long)timeSend
{
    Message *msg = [[Message alloc] init];
    msg.topicId = self.chatType == ChatTypePrivate ? @"" : self.topicId;
    msg.sender = _fromUserInfo.username;
    msg.fromUserId = _fromUserInfo.im_user_id;
    msg.fromUserName = _fromUserInfo.username;
    msg.fromUserAvatar = _fromUserInfo.avatar;
    msg.toUserId = self.toUserInfo.im_user_id;
    msg.toUserName = self.toUserInfo.username;
    msg.toUserAvatar = self.toUserInfo.avatar;
    msg.messageId = messageId;
    msg.type = mediaType;
    msg.timeSend = timeSend;
    msg.fileData = fileData;
    msg.message = message;
    
    
    NSString *tableName = self.topicId;
    if (self.chatType == ChatTypePrivate) {
        tableName = msg.toUserId;
        //把消息显示在私信列表里。
        [[QYIMObject getInstance] showToPrivateTable:[msg toDictionary] withIsShowStatusBar:NO];
    }
    
    //如果是第一条消息，把显示时间，放入Message
    if (self.messages.count == 0) {
        msg.showTimestamp = YES;
    }
    
    NSNumber *count = @(self.messages.count);
    if (IsEmpty(messageId)) {
        //把发送时间当key，存储当前行数。
        [_sendImageIndexPathItem setValue:count forKey:[NSString stringWithFormat:@"%lld", timeSend]];
    }else{
        [_sendMsgItem setObject:count forKey:messageId];
    }
    //存储到本地数据库
    [[LocalData getInstance] insertWithTableName:tableName withObject:msg];
    [self.messages addObject:msg];
    [msg release];
}


/**
 *  相机按钮触发的方法
 *
 *  @param sender
 */
- (void)mediaPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    NSArray *array = [NSArray arrayWithObjects:@"从相册选择",@"拍照",nil];
    //CCActiotSheet *sheet = [[CCActiotSheet alloc]initWithDelegate:self array:array];
    CCActiotSheet *sheet = [[CCActiotSheet alloc] initWithTitle:nil andDelegate:self andArrayData:array];
    [sheet show];
}

/**
 *  触摸用户头像触发的方法
 */
- (void)touchUserAvatarHandler:(UIGestureRecognizer*)gesture
{
    [self.view endEditing:YES];
    
    NSInteger row = gesture.view.tag - kUserAvatarTag;
    Message *message = self.messages[row];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    mineVC.imUserId = message.fromUserId;
    [self.navigationController pushViewController:mineVC animated:YES];
    [mineVC release];
}

/**
 *  显示图片
 *
 *  @param indexPath
 */
- (void)showImageWithIndexPath:(NSIndexPath*)indexPath
{
    [self.view endEditing:YES];
    
    NSInteger index = 0;
    Message *currentMessage = self.messages[indexPath.row];
    if (currentMessage.isSend == 0) {
        return;
    }
    for (NSInteger i = 0; i < [_photoDataSource count]; i++) {
        // 替换为中等尺寸图片
        CXPhoto *photo = _photoDataSource[i];
        if (currentMessage.timeSend == photo.timeSend) {
            index = i;
            break;
        }
    }
    [_photoBrowser setInitialPageIndex:index];
    [self.navigationController pushViewController:_photoBrowser animated:YES];
}

/**
 *  获取最上面一条消息的发送时间
 *
 *  @return
 */
- (long long)getTheTopMessageTimeSend
{
    if (self.messages.count > 0) {
        Message *message = self.messages[0];
        return message.timeSend;
    }
    return 0;
}

/**
 *  使用数组初始化messages
 *
 *  @param array
 */
- (void)configMessagesWithArray:(NSArray*)array;
{
    if (_photoDataSource) {
        [_photoDataSource removeAllObjects];
        [_photoDataSource release];
        _photoDataSource = nil;
    }
    _photoDataSource = [[NSMutableArray alloc] init];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:array];
    self.messages = arr ;
    [arr release];
    if ([self.messages count] == IM_QUERY_COUNT) {
        if (!_loadMoreView) {
            _loadMoreView = [[LoadMoreView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            _loadMoreView.hidden = YES;
            self.tableView.tableHeaderView = _loadMoreView;
        }
    }
    [self.tableView reloadData];
    [self scrollToBottomAnimated:NO];
}

#pragma mark - JSBubbleView Delegate
/**
 *  重新发送
 *
 *  @param indexPath 当前行的indexPath
 */
- (void)sendAgainWithIndexPath:(NSIndexPath *)indexPath
{
    //如果键盘打开状态，那么关闭键盘
    if (_keyboardIsVisible) {
        [self.messageInputView resignFirstResponder];
        return;
    }
    if (_indexPath) {
        [_indexPath release];
        _indexPath = nil;
    }
    _indexPath = [indexPath retain];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"重新发送" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

/**
 *  改变当前消息的发送状态
 *
 *  @param activityView
 *  @param indexPath
 */
- (void)changeMessageSendStatus:(NSIndexPath *)indexPath
{
    JSBubbleMessageCell *cell = (JSBubbleMessageCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    Message *message = (Message*)[self.dataSource messageForRowAtIndexPath:indexPath];
    
    JSBubbleView *bubbleView = cell.bubbleView;
    switch (message.isSend) {
        case 0:         //发送中
            [bubbleView.activityView startAnimating];
            bubbleView.activityView.hidden = NO;
            bubbleView.sendAgainButton.hidden = YES;
            break;
        case 1:         //发送成功
            [bubbleView.activityView stopAnimating];
            bubbleView.sendAgainButton.hidden = YES;
            bubbleView.activityView.hidden = YES;
            break;
        case 2:         //发送失败
            bubbleView.activityView.hidden = YES; //发送失败
            bubbleView.sendAgainButton.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - JSBubbleMessageCell Delegate
/**
 *  触摸图片或者其他视图触发的方法
 *
 *  @param indexPath
 */
- (void)tapViewWithIndexPath:(NSIndexPath *)indexPath
{
    JSBubbleMessageCell *cell = (JSBubbleMessageCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    switch (cell.mediaType) {
        case JSBubbleMediaTypeImage:    //如果是图片，点击放大
        {
            //显示图片
            [self showImageWithIndexPath:indexPath];
            break;
        }
        case JSBubbleMediaTypeRichText:
        {
            [self.view endEditing:YES];
            
            OtherMessage *otherMsg = [self.dataSource dataForRowAtIndexPath:indexPath];
            BoardDetailViewController * detailVC = [[BoardDetailViewController alloc]init];
            detailVC.wallID = otherMsg.wid;
            
            if ([otherMsg.photo isKindOfClass:[NSString class]] && ![otherMsg.photo isEqualToString:@""]) {
                detailVC.photoURL = [NSString stringWithFormat:@"%@",otherMsg.photo];
            }
            [self.navigationController pushViewController:detailVC animated:YES];
            [detailVC release];
            break;
        }
        default:
            break;
    }
}

/**
 *  触摸单元格触发的方法
 */
- (void)touchesCell
{
    [self.messageInputView resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view delegate: REQUIRED
/**
 *  发送消息
 *
 *  @param text   消息内容
 *  @param sender 发送者
 *  @param date   发送日期
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(long long)date
{
    //把消息类型存入到customData
    NSDictionary *customData = @{@"type":@(JSBubbleMediaTypeText), @"fromUserAvatar":[[NSUserDefaults standardUserDefaults] objectForKey:@"usericon"], @"fromUserName":_fromUserInfo.username};
    NSString *messageId = @"";
    //私聊
    if (self.chatType == ChatTypePublic) {
        //群聊
        messageId = [[QYIMObject getInstance] sendMessage:text customData:customData];
    }else{
        messageId = [[QYIMObject getInstance] sendMessage:text customData:customData toUserId:self.toUserInfo.im_user_id];
    }
    
    //把消息存放到本地
    [self saveLocaDataWithMessage:text withMessageId:messageId withType:JSBubbleMediaTypeText withFileData:nil withTimeSend:[NSDate date].timeIntervalSince1970 * 1000];
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}

/**
 *  消息归属 GO、COME
 *
 *  @param indexPath
 *
 *  @return
 */
- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.messages.count > indexPath.row) {
        Message *message = self.messages[indexPath.row];
        //发送者和当前用户相同，表示GO
        return ([message.fromUserId isEqualToString:_fromUserInfo.im_user_id]) ? JSBubbleMessageTypeOutgoing : JSBubbleMessageTypeIncoming;
    }
    return JSBubbleMessageTypeOutgoing;
}

/**
 *  消息背景图片
 *
 *  @param type      消息归属
 *  @param indexPath
 *
 *  @return
 */
- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.messages.count <= indexPath.row) {
        return nil;
    }
    Message *message = self.messages[indexPath.row];
    if (message.type == JSBubbleMediaTypeText) {
        //发送者和当前用户相同，使用蓝色背景图片
        if ([message.fromUserId isEqualToString:_fromUserInfo.im_user_id]) {
            return [JSBubbleImageViewFactory bubbleImageViewForType:type color:RGB(125, 208, 216)];
        }else{
            return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor whiteColor]];
        }
    }
    return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor clearColor]];
}

/**
 *  输入框样式
 *
 *  @return
 */
- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStylePhoto;
}

#pragma mark - Messages view delegate: OPTIONAL
/**
 *  当前行是否显示时间
 *
 *  @param indexPath
 *
 *  @return
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.messages.count <= indexPath.row) {
        return NO;
    }
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    if (message.showTimestamp) {
        return YES;
    }
    if (message.type == JSBubbleMediaTypeNewUserJoin || message.type == JSBubbleMediaTypeTips) { //新用户加入类型的消息，不显示时间
        return NO;
    }
    if (indexPath.row > 1) {
        Message *preMessage = self.messages[(indexPath.row - 1)];
        if (preMessage.type == JSBubbleMediaTypeNewUserJoin || message.type == JSBubbleMediaTypeTips) {
            return NO;
        }
        long long preDate = preMessage.timeSend;
        long long date = message.timeSend;
        long long count = (date - preDate);
        return count >= kShowTimeInterval;
    }
    return NO;
}

//  *** Implement to prevent auto-scrolling when message is added
//
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return NO;  //来新消息，是否自动滚动到底部
}

// *** Implemnt to enable/disable pan/tap todismiss keyboard
//
/**
 *  是否允许滑动消失键盘
 *
 *  @return
 */
- (BOOL)allowsPanToDismissKeyboard
{
    return NO;
}

#pragma mark - Messages view data source: REQUIRED
/**
 *  消息对象
 *
 *  @param indexPath
 *
 *  @return
 */
- (Message *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.messages.count > indexPath.row) {
        return self.messages[indexPath.row];
    }
    return nil;
}

- (NSString*)avatarImageUrlForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.messages.count <= indexPath.row) {
        return nil;
    }
    Message *message = [self.messages objectAtIndex:indexPath.row];
    if (message.type == JSBubbleMediaTypeNewUserJoin || message.type == JSBubbleMediaTypeTips) { //新用户加入类型的消息，没有用户头像
        return nil;
    }
    
    JSBubbleMessageType messageType = [self messageTypeForRowAtIndexPath:indexPath];
    if (messageType == JSBubbleMessageTypeOutgoing){ //如果是发送的消息，从本地取图片
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"usericon"];
    }else{
        return message.fromUserAvatar;
    }
}

/**
 *  返回当前行的数据
 *
 *  @param indexPath
 *
 *  @return
 */
- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    id data = nil;
    switch (message.type) {
        case JSBubbleMediaTypeImage:
            data = message.fileData;
            break;
        case JSBubbleMediaTypeRichText:
            data = message.otherMessage;
            break;
        case JSBubbleMediaTypeNewUserJoin:
            data = message.userName;
            break;
        case JSBubbleMediaTypeTips:
            data = message.userName;
            break;
        default:
            break;
    }
    return data;
}

/**
 *  当前行消息的类型
 *
 *  @param indexPath
 *
 *  @return
 */
- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.messages.count <= indexPath.row) {
        return JSBubbleMediaTypeText;
    }
    Message *message = [self.messages objectAtIndex:indexPath.row];
    return message.type;
}

/**
 *  自定义相机按钮
 *
 *  @return
 */
- (UIButton *)mediaButtonForInputView
{
    UIImage* image = [UIImage imageNamed:@"button-photo"];
    UIImage* imagePress = [UIImage imageNamed:@"button-photo-press"];
    CGRect frame = CGRectMake(11.0f, 6.0f, image.size.width, image.size.height);
    
    UIButton* mediaButton = [[UIButton alloc] initWithFrame:frame];
    [mediaButton setBackgroundImage:image forState:UIControlStateNormal];
    [mediaButton setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    [mediaButton addTarget:self action:@selector(mediaPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    return mediaButton;
}


/**
 
 insert by zhangyhui
 */

#pragma mark
#pragma mark CustomPickerImageDelegate

//实现CustomPickerImageDelegate方法
-(void)customImagePickerController:(UIViewController *)picker image:(UIImage *)image imageName:(NSString *)imageName
{
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    [item setValue:imageName forKey:@"imageName"];
    [item setValue:image forKey:@"image"];
    [self performSelectorInBackground:@selector(resizeImage:) withObject:item];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [item release];
}

-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        //创建图像选取控制器
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        //设置图像选取控制器的来源模式为相机模式
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //设置委托对象
        imagePickerController.delegate = self;
        //以模视图控制器的形式显示
        [self presentViewController:imagePickerController animated:YES completion:nil];
        [imagePickerController release];
    }
}
#pragma UIImagePicker Delegate
#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /**
     *  insert by zhangyihui
     拍照之后，对图片进行处理，不然，内存泄露
     */
//    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//    NSLog(@"%@", mediaType);
    
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset)
    {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSString *fileName = [representation filename];
        [item setValue:fileName forKey:@"imageName"];
    };
    
    ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    [assetslibrary assetForURL:imageURL
                   resultBlock:resultblock
                  failureBlock:nil];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (!image) {
        [picker dismissViewControllerAnimated:YES completion:NULL];
        return;
    }
    [item setValue:image forKey:@"image"];
    [self performSelectorInBackground:@selector(resizeImage:) withObject:item];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [item release];
}

- (void)resizeImage:(NSDictionary*)dict
{
    UIImage *image = dict[@"image"];
    NSData *imageData = [QYImageUtil thumbnailWithImageWithoutScale:image withMaxScale:1080];
    NSData *thumbnailData = [QYImageUtil thumbnailWithImageWithoutScale:image withMaxScale:280];
    
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    [item setValue:thumbnailData forKey:@"thumbnailData"];
    [item setValue:imageData forKey:@"imageData"];
    [item setValue:dict[@"imageName"] forKey:@"imageName"];
    [self performSelectorOnMainThread:@selector(uploadImageToRemote:) withObject:item waitUntilDone:NO];
    [item release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark Super

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.topicId = nil;
    self.messages = nil;
    self.toUserInfo = nil;
    
    [_navigationTitle release];
    _navigationTitle = nil;
    
    [_titleLabel release];
    _titleLabel = nil;
    
    [_activityView release];
    _activityView = nil;
    
    [_navBarView release];
    _navBarView = nil;
    
    [_photoBrowser release];
    _photoBrowser = nil;
    
    [_photoDataSource release];
    _photoDataSource = nil;
    
    [_sendMsgItem release];
    _sendMsgItem = nil;
    
    [_sendImageIndexPathItem release];
    _sendImageIndexPathItem = nil;
    
    [_indexPath release];
    _indexPath = nil;
    
    [_fromUserInfo release];
    _fromUserInfo = nil;
    [super dealloc];
}

#pragma mark
#pragma mark actionsheet
//*********** Insert By zhangyihui
/**
 *
 *  @param buttonIndex
 */
- (void)ccActionSheet:(CCActiotSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) { //从相册选择
        //自定义相册调用方法
        PhotoListController *photoVc = [[PhotoListController alloc]init];
        photoVc.delegate = self.delegate;
        UINavigationController *navPhoto = [[UINavigationController alloc]initWithRootViewController:photoVc];
        navPhoto.navigationBar.hidden = YES;
        [self presentViewController:navPhoto animated:YES completion:nil];
        [photoVc release];
        [navPhoto release];
    }else if (buttonIndex == 2){ //拍照
        [self takePhoto];
        //[QYToolObject transferSystemPicture:self.delegate type:1 isPermitEdit:NO];
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        Message *message = [self.messages[_indexPath.row] retain];//当前行数据
        JSBubbleMediaType type = [self messageMediaTypeForRowAtIndexPath:_indexPath];
        
        [_sendMsgItem removeObjectForKey:message.messageId];    //从字典中删除
        [self.messages removeObjectAtIndex:_indexPath.row];      //从列表种删除
        [[LocalData getInstance] deleteWithMessage:message];    //从本地数据库中删除
        
        if (type == JSBubbleMediaTypeText) {                    //重新发送消息
            [self didSendText:message.text fromSender:message.fromUserName onDate:message.timeSend];
        }else if (type == JSBubbleMediaTypeImage){
            //从发送图片字典中，取出1080的大图数据
            NSString *key = [NSString stringWithFormat:@"%lld", message.timeSend];
            NSData *imageData = [self imageDataFromLocalWithKey:key];
            [self removeImageDataWithKey:key];
            
            NSString* imageUrl = @"";
            for (CXPhoto *photo in _photoDataSource) {
                if (photo.timeSend == message.timeSend) {
                    imageUrl = photo.imageUrl;
                    [_photoDataSource removeObject:photo];
                    break;
                }
            }
            
            if (message.fileData && imageData) {
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                [item setValue:message.fileData forKey:@"thumbnailData"];
                [item setValue:imageData forKey:@"imageData"];
                [item setValue:imageUrl forKey:@"imageUrl"];
                [self uploadImageToRemote:item];
                [item release];
            }
        }
        [message release];
    }
}


#pragma mark - CXPhotoBrowserDataSource

- (NSUInteger)numberOfPhotosInPhotoBrowser:(CXPhotoBrowser *)photoBrowser
{
    return [_photoDataSource count];
}

- (id <CXPhotoProtocol>)photoBrowser:(CXPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _photoDataSource.count)
        return [_photoDataSource objectAtIndex:index];
    return nil;
}

- (CXBrowserNavBarView *)browserNavigationBarViewOfOfPhotoBrowser:(CXPhotoBrowser *)photoBrowser withSize:(CGSize)size
{
    if (!_navBarView)
    {
        CGRect frame;
        frame.origin = CGPointMake(0, 0);
        frame.size = CGSizeMake(size.width, ios7 ? 66 : 44);
        
        _navBarView = [[CXBrowserNavBarView alloc] initWithFrame:frame];
        
        UIView *view = [[UIView alloc] initWithFrame:_navBarView.frame];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.68;
        [_navBarView addSubview:view];
        [view release];
        
        //返回键
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.backgroundColor = [UIColor clearColor];
        backButton.frame = CGRectMake(0, ios7 ? 22 : 2, 40, 40);
        [backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backFromPhotoViewButton) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:backButton];
        
        UIButton * saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.tag = 1003;
        saveButton.backgroundColor = [UIColor clearColor];
        saveButton.frame = CGRectMake(UIWidth - 40 - 10, ios7 ? 10 : -10, 60, 60);
        [saveButton setBackgroundImage:[UIImage imageNamed:@"IM_Photo_save"] forState:UIControlStateNormal];
        [saveButton setBackgroundImage:[UIImage imageNamed:@"IM_Photo_save_press"] forState:UIControlStateHighlighted];
        [saveButton addTarget:self action:@selector(savePhotoViewButton:) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:saveButton];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setFrame:CGRectMake((size.width - 200)/2, ios7 ? 22 : 2, 200, 40)];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:20.]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [titleLabel setTag:10001];
        [_navBarView addSubview:titleLabel];
        [titleLabel release];
    }
    
    return _navBarView;
}

#pragma mark - CXPhotoBrowserDelegate
/**
 *  大图模式，切换图片触发的方法
 *
 *  @param photoBrowser 图片浏览器
 *  @param index        索引
 */
- (void)photoBrowser:(CXPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index
{
    UILabel *titleLabel = (UILabel *)[_navBarView viewWithTag:10001];
    if (titleLabel)
    {
        titleLabel.text = [NSString stringWithFormat:@"%i / %i", index+1, photoBrowser.photoCount];
    }
}

/**
 *  图片保存完成
 *
 *  @param image       图片
 *  @param error       错误信息
 *  @param contextInfo
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    _isSavePhotoing = NO;
    UIButton *button = (UIButton*)[_navBarView viewWithTag:1003];
    button.highlighted = NO;
    if (error != NULL){
        [self.view makeToast:@"保存图片错误" duration:1.2f position:@"center" isShadow:NO];
    }
    else{
        [self.view makeToast:@"保存图片成功" duration:1.2f position:@"center" isShadow:NO];
    }
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (indexPath.row == self.messages.count - 1) {
        return height + 6;
    }
    return height;
}

#pragma mark - ImageDataCache

- (void)setImageDataToLocal:(NSData*)data withKey:(NSString*)key
{
    NSString *dataStr = [data base64EncodedString];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *item = [[userDefault objectForKey:@"IM_REMOTE_IMAGE_DATA_ITEM"] mutableCopy];
    if (!item) {
        item = [[NSMutableDictionary alloc] init];
    }
    [item setValue:dataStr forKey:key];
    [userDefault setValue:item forKeyPath:@"IM_REMOTE_IMAGE_DATA_ITEM"];
    [userDefault synchronize];
    [item release];
}

- (NSData*)imageDataFromLocalWithKey:(NSString*)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *item = [userDefault objectForKey:@"IM_REMOTE_IMAGE_DATA_ITEM"];
    NSString *dataStr = [item objectForKey:key];
    NSData* imageData = [NSData dataFromBase64String:dataStr];
    return imageData;
}

- (void)removeImageDataWithKey:(NSString*)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *item = [[userDefault objectForKey:@"IM_REMOTE_IMAGE_DATA_ITEM"] mutableCopy];
    [item removeObjectForKey:key];
    [userDefault synchronize];
    [item release];
}

- (void)saveImageUrlWithImageName:(NSString*)imageName withImageUrl:(NSString*)imageUrl
{
    if (IsEmpty(imageName)) {
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *item = [[userDefault objectForKey:@"IM_REMOTE_IMAGE_URL"] mutableCopy];
    if (!item) {
        item = [[NSMutableDictionary alloc] init];
    }
    [item setValue:imageUrl forKey:imageName];
    [userDefault setValue:item forKeyPath:@"IM_REMOTE_IMAGE_URL"];
    [userDefault synchronize];
    [item release];
}

- (NSString*)getImageUrlFromImageName:(NSString*)imageName
{
    if (IsEmpty(imageName)) {
        return @"";
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *item = [userDefault objectForKey:@"IM_REMOTE_IMAGE_URL"];
    NSString *imageUrl = [item objectForKey:imageName];
    return imageUrl;
}

@end
