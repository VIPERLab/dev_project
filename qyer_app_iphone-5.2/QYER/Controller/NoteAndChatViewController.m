//
//  NoteAndChatViewController.m
//  QYER
//
//  Created by 张伊辉 on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "NoteAndChatViewController.h"
#import "PrivateChatViewController.h"
#import "UserInfo.h"
#import "Account.h"

#import "PrivateChat.h"



@interface NoteAndChatViewController ()

@end

@implementation NoteAndChatViewController
@synthesize push_flag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(privateChatMessage:) name:@"privateChatMessage" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNoDataView:) name:@"showNoDataView" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflushPriteTable) name:@"reflushPriteTable" object:nil];

    }
    return self;
}


/**
 *  刷新table
 */
-(void)reflushPriteTable{
    
    if ([GlobalObject share].priChatArray.count == 0) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNoDataView" object:@"0"];
        
    }else{
        
        [chatTable reloadData];
    }
    
}


-(void)showNoDataView:(NSNotification *)aNote{
    
    int flag = [[aNote object] intValue];
    
    /**
     *  默认进来全部隐藏掉
     */
    _notDataImageView.hidden = YES;
    [super setNotReachableView:NO];


    if (flag == 0) {
        
        _notDataImageView.image = [UIImage imageNamed:@"no_msg"];
        _notDataImageView.hidden = NO;
        [self.view bringSubviewToFront:_notDataImageView];
        [self.view bringSubviewToFront:categoryBackImage];
        
    }else if (flag == 1){
        
        [super setNotReachableView:YES];
        
    }else {
        
        _notDataImageView.hidden = YES;

    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(self.push_flag)
    {
        UIButton *btn = (UIButton *)[categoryBackImage viewWithTag:11];
        [self selectCategory:btn];
    }
    else
    {
        UIButton *btn = (UIButton *)[categoryBackImage viewWithTag:10];
        [self selectCategory:btn];
    }
    
    [self changePirTotalUnReadText];
    [self changeNotoTotalUnReadText];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self changePirTotalUnReadText];
    [self changeNotoTotalUnReadText];
}
/**
 *  改变私信的个数
 */
-(void)changePirTotalUnReadText{
    
    //记录私信总数，++
    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
    NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
    NSLog(@"TotalPrivateChatNumber is %d",totalPriChatNum);
    
    UILabel *lbl = (UILabel *)[[categoryBackImage viewWithTag:10] viewWithTag:1];
    lbl.text = [NSString stringWithFormat:@"%d",totalPriChatNum];
    
    if (totalPriChatNum == 0) {
        lbl.hidden = YES;
    }else{
        lbl.hidden = NO;
    }

}

-(void)changeNotoTotalUnReadText{
    
    //记录私信总数，++
    
    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
    NSInteger totalPriChatNum = [myUserDefault integerForKey:NotificationUnreadCount];
    NSLog(@"TotalPrivateChatNumber is %d",totalPriChatNum);
  
    UILabel *lbl = (UILabel *)[[categoryBackImage viewWithTag:11] viewWithTag:1];
    lbl.text = [NSString stringWithFormat:@"%d",totalPriChatNum];
   
    if (totalPriChatNum == 0) {
        
        lbl.hidden = YES;
        
    }else{
        lbl.hidden = NO;

    }
}

-(void)initData{
    
    btnsArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i = 0; i<2; i++) {
        
        NSMutableDictionary *muDict = [[NSMutableDictionary alloc]init];
        
        switch (i) {
                
            case 0:
                [muDict setObject:@"私信" forKey:@"name"];

                break;
            case 1:
                [muDict setObject:@"通知" forKey:@"name"];

                break;
                
            default:
                break;
        }
        
        [muDict setObject:RGB(44, 171, 121) forKey:@"clickTextColor"];
        [muDict setObject:RGB(130, 153, 165) forKey:@"textColor"];
        
        [btnsArray addObject:muDict];
        [muDict release];
    }
}
/**
 *  创建Table切换
 */
-(void)initTabView{
    
    categoryBackImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, height_headerview, UIWidth, 38)];
    categoryBackImage.backgroundColor =  [UIColor whiteColor];
    categoryBackImage.userInteractionEnabled = YES;
    [self.view addSubview:categoryBackImage];
    [categoryBackImage release];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,height_headerview + 38, UIWidth, 1)];
    line.backgroundColor = RGB(231, 231, 231);
    [self.view addSubview:line];
    [line release];
    
    statueImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 36, 160, 2)];
    statueImageView.backgroundColor = RGB(0, 171, 125);
    [categoryBackImage addSubview:statueImageView];
    [statueImageView release];
    
    for (int i = 0; i< btnsArray.count; i++) {
        
        NSDictionary *dict = [btnsArray objectAtIndex:i];
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i*160, 0, 159, 38)];
        btn.tag = 10+i;
        [btn setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        if (i == 0) {
            
            [btn setTitleColor:[dict objectForKey:@"clickTextColor"] forState:UIControlStateNormal];
            
        }else{
            
            [btn setTitleColor:[dict objectForKey:@"textColor"] forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(selectCategory:) forControlEvents:UIControlEventTouchUpInside];
        
        [categoryBackImage addSubview:btn];
        [btn release];
        
        
        UILabel *lblNewMsgNum = [[UILabel alloc]initWithFrame:CGRectMake(100, 11, 14, 14)];
        lblNewMsgNum.textAlignment = NSTextAlignmentCenter;
        lblNewMsgNum.font = [UIFont fontWithName:Default_Font size:8.0];
        lblNewMsgNum.tag = 1;
        lblNewMsgNum.adjustsFontSizeToFitWidth = YES;
        lblNewMsgNum.layer.cornerRadius = 7.0;
        lblNewMsgNum.layer.masksToBounds = YES;
        lblNewMsgNum.textColor = [UIColor whiteColor];
        lblNewMsgNum.backgroundColor = [UIColor redColor];
        [btn addSubview:lblNewMsgNum];
        [lblNewMsgNum release];
        
        if ( i != btnsArray.count-1) {
            
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(160+i*64, 11, 1, 15)];
            lineView.backgroundColor = RGB(231, 231, 231);
            [categoryBackImage addSubview:lineView];
            [lineView release];
        }

    }
    
}

-(void)touchesView{
    
    UIButton *btn = (UIButton *)[categoryBackImage viewWithTag:select + 10];
    [self selectCategory:btn];
    
}
/**
 *  切换tab选项
 *  如果select = 0，选择通知，= 1选择私信
 *  @param btn
 */
-(void)selectCategory:(UIButton *)btn{
    
    _notDataImageView.hidden = YES;

    if (isNotReachable) {
        
        [super setNotReachableView:YES];

        return;
        
    }else{
        
        [super setNotReachableView:NO];
    }

    
    if (btn.tag - 10 != select) {
        
        NSDictionary *preDict = [btnsArray objectAtIndex:select];
        UIButton *preBtn = (UIButton *)[categoryBackImage viewWithTag:select + 10];
        [preBtn setTitleColor:[preDict objectForKey:@"textColor"] forState:UIControlStateNormal];
        
        NSDictionary *nowDict = [btnsArray objectAtIndex:btn.tag - 10];
        [btn setTitleColor:[nowDict objectForKey:@"clickTextColor"] forState:UIControlStateNormal];
    }
    
    select = btn.tag -10;
    
    if (select == 1) {
        notifiTable.hidden = NO;
        chatTable.hidden = YES;
        statueImageView.frame = CGRectMake(160, 36, 160, 2);
        
        [notifiTable requestDataFromServer:NO];
        self.push_flag = YES;
        
        NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
        [myUserDefault setInteger:0 forKey:NotificationUnreadCount];
        [self changeNotoTotalUnReadText];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatUnReadMsgNum" object:nil];
        
    }
    else{
        notifiTable.hidden = YES;
        chatTable.hidden = NO;
        
        statueImageView.frame = CGRectMake(0, 36, 160, 2);
        self.push_flag = NO;
        
        
    }

}
- (void)initPrivateChatTable{
    
    chatTable = [[PrivateChatTable alloc]initWithFrame:CGRectMake(0,0 ,UIWidth,UIHeight - height_need_reduce)];
    chatTable.hidden = YES;
    chatTable.backgroundColor = [UIColor clearColor];
    chatTable.clickDelegate = self;
    [self.view addSubview:chatTable];
    [chatTable release];
    
    [ChangeTableviewContentInset changeTableView:chatTable withOffSet:39];
    [self.view sendSubviewToBack:chatTable];
    
    [chatTable getLocalData];
}

- (void)initQyerAppNotificationTable{
    
    notifiTable = [[QyerAppNotificationTable alloc]initWithFrame:CGRectMake(0,0 ,UIWidth,UIHeight - height_need_reduce)];
    notifiTable.hidden = YES;
    notifiTable.currentVC=self;
    [self.view addSubview:notifiTable];
    [notifiTable release];
    [ChangeTableviewContentInset changeTableView:notifiTable withOffSet:39];
    [self.view sendSubviewToBack:notifiTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    select = 0; //默认选择第一个分类
    
    _titleLabel.text = @"消息";
    
    [self initData];
    [self initTabView];
    [self initPrivateChatTable];

    [self initQyerAppNotificationTable];
    
    /**
     *  进入这个页面之后，清空，图标。
     */
    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
    NSLog(@"number is %d",[myUserDefault integerForKey:NotificationUnreadCount]);
//    [myUserDefault setInteger:0 forKey:NotificationUnreadCount];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatUnReadMsgNum" object:nil];
//
    
    
    // Do any additional setup after loading the view.
}

-(void)privateChatMessage:(NSNotification *)aNote{
    
    PrivateChat *chatItem = aNote.userInfo[@"item"];
    [chatTable addNewMessage:chatItem];
    
    [self changePirTotalUnReadText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark --PrivateChatTable
/**
 *  选择私信中某一行
 *
 *  @param object 选中当前行的对象
 */
-(void)didSelectRowAtIndexPath:(NSObject *)object{
    
    
    PrivateChat *chatObj = (PrivateChat *)object;
    
    UserInfo *touser = [[UserInfo alloc] init];
    touser.im_user_id = chatObj.clientId;
    touser.username = chatObj.chatUserName;
    touser.avatar = chatObj.chatUserAvatar;
    

    PrivateChatViewController *viewController = [[PrivateChatViewController alloc] init];
    viewController.toUserInfo = touser;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
   
    [touser release];
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

-(void)dealloc{
    
    [btnsArray release];
    btnsArray = nil;
    
    [btnsArray release];
    btnsArray = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"privateChatMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"showNoDataView" object:nil];

    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reflushPriteTable" object:nil];
    
    [super dealloc];
}

@end
