//
//  PrivateChatViewController.m
//  QYER
//
//  Created by Frank on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PrivateChatViewController.h"
#import "UserInfo.h"
#import "QYIMObject.h"
#import "AppDelegate.h"
@interface PrivateChatViewController ()

@end

@implementation PrivateChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.chatType = ChatTypePrivate;
    
    [self initRootView];

    QYIMObject *im = [QYIMObject getInstance];
    
    //标识正在私聊视图
    im.privateChatImUserId = self.toUserInfo.im_user_id;
    
    [super viewDidLoad];
   
    _isFirstQuery = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PRIVATE" object:nil userInfo:@{@"isLoading":@(YES)}];
    if (im.connectStatus == QYIMConnectStatusOffLine) {
        NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
        NSString *imUserId = [myDefault objectForKey:@"userid_im"];
        [im connect:imUserId withBlock:^(QYIMObject *imObject, QYIMConnectStatus status) {
            if (status != QYIMConnectStatusOffLine) {
                [self queryMessages];
            }
        }];
    }else{
        [self queryMessages];
    }
}

/**
 *  查询消息
 */
- (void)queryMessages
{
    if (isNotReachable) {   //没有网络，从本地获取聊天记录
        [super queryLocalMessages];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PRIVATE" object:nil userInfo:@{@"isLoading":@(NO)}];
        return;
    }
    
    long long timeSend = [self getTheTopMessageTimeSend];
    NSNumber *timeInterval = timeSend > 0 ? @(timeSend) : nil;
    [[QYIMObject getInstance] queryPrivateHistoryWithClientId:self.toUserInfo.im_user_id withTimestamp:timeInterval withBlock:^(QYIMObject *imObject, NSArray *messages) {
        [super queryLocalMessages];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PRIVATE" object:nil userInfo:@{@"isLoading":@(NO)}];
    }];
}

- (void)reloadTableAfterQueryWithArray:(NSArray *)array withIsInit:(BOOL)isInit withIsAdd:(BOOL)isAdd
{
    [super reloadTableAfterQueryWithArray:array withIsInit:isInit withIsAdd:isAdd];

    if (_isFirstQuery) {
        _isFirstQuery = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMLoadingStatus_PRIVATE" object:nil userInfo:@{@"isLoading":@(NO)}];
    }
}


-(void)initRootView
{
    //背景
    UIView * rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    rootView.userInteractionEnabled = YES;
    [self.view insertSubview:rootView atIndex:0];
    [rootView release];
    
    float height_naviViewHeight = (ios7 ? 20+44 : 44);
    
    //导航栏
    UIView * naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_naviViewHeight)];
    naviView.backgroundColor = [UIColor colorWithRed:(float)43/255 green:(float)171/255 blue:(float)121/255 alpha:1.0];
    [self.view addSubview:naviView];
    [naviView release];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 240, 20)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(50, 12+20, 220, 20);
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.toUserInfo.username;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    _titleLabel = [titleLabel retain];
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    
    //返回键
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.frame = CGRectMake(0, 2, 40, 40);
    if(ios7)
    {
        backButton.frame = CGRectMake(0, 2+20, 40, 40);
    }
    [backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:backButton];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)clickBackButton
{
    
    [QYIMObject getInstance].privateChatImUserId = @"";

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - JSMessagesView Delegate

- (CGRect)tableViewFrame
{
    CGFloat y = (ios7 ? 20+44 : 44);
    return CGRectMake(0, y, UIWidth, UIHeight - 64);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"私信"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick endLogPageView:@"私信"];
}

- (void)dealloc
{
    
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
