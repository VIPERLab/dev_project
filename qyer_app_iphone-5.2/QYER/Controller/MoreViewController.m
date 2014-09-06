//
//  MoreViewController.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-8-28.
//
//

#import "MoreViewController.h"
#import "MobClick.h"
#import "MoreSettingCell.h"
#import "AboutViewController.h"
#import "QuestionsViewController.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "RegexKitLite.h"
#import "AppDelegate.h"
#import "MyMoreControl.h"
#import "CityLoginViewController.h"
#import "FeedBackViewController.h"
#import "QYMoreAppData.h"
#import "DeviceInfo.h"
#import "QYMoreApp.h"
#import "QyerSns.h"
#import "ChangeTableviewContentInset.h"
#import "QYIMObject.h"
#import "FilePath.h"
#import "TestListViewController.h"


#define     title_section0  @"基本设置"
#define     title_section1  @"其它"
//#define     title_section2  @"穷游其它应用"


#define     title_cell0     @"穷游帐号"
#define     title_cell1     @"仅在wifi环境下下载锦囊"
#define     title_cell2     @"常见问题"
#define     title_cell3     @"关于穷游"
#define     title_cell4     @"意见反馈"
#define     title_cell5     @"评价我们"
#define     title_cell6     @"分享穷游"
//#define     title_cell7     @"穷游推荐应用"


#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (6+20) : 11)
#define     height_titlelabel           (ios7 ? (30) : 34)
#define     positionY_backbutton        (ios7 ? (3+20) : 3)
#define     positionY_tableView         (ios7 ? (44+20) : 44)




@interface MoreViewController ()
@property (nonatomic, copy) NSString *imUserId;
@end






@implementation MoreViewController
@synthesize currentVC = _currentVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(void)dealloc
{
    QY_VIEW_RELEASE(_headView);
    QY_SAFE_RELEASE(_tableView_moreVC);
    QY_SAFE_RELEASE(_currentVC);
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_section);
    QY_MUTABLERECEPTACLE_RELEASE(_array_basicSetting);
    QY_MUTABLERECEPTACLE_RELEASE(_array_other);
    QY_MUTABLERECEPTACLE_RELEASE(_array_otherApp);
    QY_MUTABLERECEPTACLE_RELEASE(_applicationArray);
    
    self.imUserId = nil;
    
    [super dealloc];
}





#pragma mark -
#pragma mark --- viewDidAppear & viewDidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    
    [MobClick beginLogPageView:@"更多页"];
    
    
    
    [_tableView_moreVC reloadData];
//    if(!_applicationArray || _applicationArray.count == 0)
//    {
//        [self getMoreApplication];
//    }
//    else
//    {
//        [_tableView_moreVC reloadData];
//    }
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"qyerlogin"])
    {
        [_tableView_moreVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        [_tableView_moreVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    [MobClick endLogPageView:@"更多页"];
    
}
//- (void)getMoreApplication
//{
//    if(!_applicationArray)
//    {
//        _applicationArray = [[NSMutableArray alloc] init];
//    }
//    [_applicationArray removeAllObjects];
//    
//    
//    [QYMoreAppData getMoreApplicationSuccess:^(NSArray *array){
//        
//        NSLog(@" getMoreApplication 成功!");
//        if(array && [array count] == 0)
//        {
//            NSLog(@" moreApplication 没有数据");
//            return;
//        }
//        
//        [self loadView_afterGetData:array];
//        
//    } failure:^{
//        NSLog(@" getMoreApplication 失败 失败～～");
//    }];
//}
//-(void)loadView_afterGetData:(NSArray *)array
//{
//    [_applicationArray addObjectsFromArray:array];
//    [_tableView_moreVC reloadData];
//}




#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    

    
    [self setRootView];
    [self setNavigationBar];
    [self performSelector:@selector(initTableView) withObject:nil afterDelay:0];
}
-(void)setRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, positionY_titlelabel, 160, height_titlelabel)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"更多设置";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    [_headView addSubview:titleLabel];
    [titleLabel release];
    
    
    _buttonback = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonback.backgroundColor = [UIColor clearColor];
    _buttonback.frame = CGRectMake(0, 3, 40, 40);
    if(ios7)
    {
        _buttonback.frame = CGRectMake(0, 3+20, 40, 40);
    }
    [_buttonback setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_buttonback addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_buttonback];
    
    NSArray *whiteList = @[
                           @"1",        // 面哥
                           @"13807",    // miles
                           @"1347074",  // 张路
                           @"1357827",  // i打头的       王燊
                           @"3686757",  // mfree        张栋
                           @"1031490",  // 牛牛安        安慰
                           @"2927321",  // 牛小安安      安慰
                           @"3927977",  // 下部w         回启辰
                           @"275710",   // julyutopia   小海
                           @"1739172",  // myeye        安庆
                           ];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userid"];
    if ([whiteList indexOfObject:userId] != NSNotFound) {
        // 只有白名单的用户可见聊天室切换测试按钮
        [self addTestBtn];
    }
}

-(void)addTestBtn{
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    testBtn.backgroundColor = [UIColor clearColor];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    testBtn.frame = CGRectMake(270, 3, 40, 40);
    if(ios7)
    {
        testBtn.frame = CGRectMake(270, 3+20, 40, 40);
    }
    [testBtn addTarget:self action:@selector(testBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:testBtn];
}
/**
 *  测试事件
 */
-(void)testBtnAction{
    
    TestListViewController *testList = [[TestListViewController alloc]init];
    [self.navigationController pushViewController:testList animated:YES];
    [testList release];
}



-(void)initTableView
{
    [self initTableViewData];
    
    
    if(ios7)
    {
        if(!_tableView_moreVC)
        {
            _tableView_moreVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
        }
    }
    else
    {
        if(!_tableView_moreVC)
        {
            _tableView_moreVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([[UIScreen mainScreen] bounds].size.height-20)) style:UITableViewStylePlain];
        }
    }
    _tableView_moreVC.backgroundColor = [UIColor clearColor];
    _tableView_moreVC.separatorColor = [UIColor clearColor];
    _tableView_moreVC.delegate = self;
    _tableView_moreVC.dataSource = self;
    _tableView_moreVC.layer.masksToBounds = NO;
    
    
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    headView.backgroundColor = [UIColor clearColor];
    _tableView_moreVC.tableHeaderView = headView;
    [headView release];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    footView.backgroundColor = [UIColor clearColor];
    _tableView_moreVC.tableFooterView = footView;
    [footView release];
    [_tableView_moreVC reloadData];
    
    
    [ChangeTableviewContentInset changeWithTableView:_tableView_moreVC];
    [self.view addSubview:_tableView_moreVC];
    [self.view bringSubviewToFront:_headView];
}
-(void)initTableViewData
{
    if(!_array_section)
    {
        _array_section = [[NSMutableArray alloc] init];
    }
    if(!_array_basicSetting)
    {
        _array_basicSetting = [[NSMutableArray alloc] init];
    }
    if(!_array_other)
    {
        _array_other = [[NSMutableArray alloc] init];
    }
    if(!_array_otherApp)
    {
        _array_otherApp = [[NSMutableArray alloc] init];
    }
    [_array_section removeAllObjects];
    [_array_basicSetting removeAllObjects];
    [_array_other removeAllObjects];
    [_array_otherApp removeAllObjects];
    
    [_array_section addObject:title_section0];
    [_array_section addObject:title_section1];
    //[_array_section addObject:title_section2];
    [_array_basicSetting addObject:title_cell0];
    [_array_basicSetting addObject:title_cell1];
    [_array_basicSetting addObject:title_cell2];
    [_array_basicSetting addObject:title_cell3];
    [_array_other addObject:title_cell4];
    [_array_other addObject:title_cell5];
    [_array_other addObject:title_cell6];
    //[_array_otherApp addObject:title_cell7];
}


#pragma mark -
#pragma mark --- UITableView - datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_array_section count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35.)];
    headerView.backgroundColor = [UIColor clearColor];
    
    
    UIImageView *imagView_background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"categorylist_headerinsection_bg.png"]];
    imagView_background.frame = CGRectMake(8, 0, 320-8*2, 35);
    [headerView addSubview:imagView_background];
    [imagView_background release];
    
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(8+8, 8, 160, 25)];
    if([[[UIDevice currentDevice] systemVersion] floatValue] - 7. >= 0)
    {
        label_title.frame = CGRectMake(8+8, 6, 160, 25);
    }
    label_title.backgroundColor = [UIColor clearColor];
    label_title.textColor = [UIColor blackColor];
    label_title.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
    label_title.text = [_array_section objectAtIndex:section];
    [headerView addSubview:label_title];
    [label_title release];
    
    
    return [headerView autorelease];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return [_array_basicSetting count]+1;
    }
    else if(section == 1)
    {
        return [_array_other count]+1;
    }
    else if(section == 2)
    {
        if(_applicationArray && _applicationArray.count > 0)
        {
            return [_array_otherApp count]+1;
        }
        return [_array_otherApp count];
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2 && indexPath.row == 0)  //穷游其他应用
    {
        if(!_applicationArray || _applicationArray.count == 0)  //穷游推荐应用
        {
            return 45+2;
        }
        
        NSUInteger line = 0;
        if([_applicationArray count]%4 == 0)
        {
            line = [_applicationArray count]/4;
        }
        else
        {
            line = [_applicationArray count]/4 + 1;
        }
        return 88*line + 10;
    }
    else if(indexPath.section == 2 && indexPath.row == 1)
    {
        return 45+2;
    }
    else if((indexPath.section == 0 && indexPath.row == [_array_basicSetting count]) || (indexPath.section == 1 && indexPath.row == [_array_other count]))  //各section之间的空隙
    {
        //        if(ios7)
        //        {
        //            return 40;
        //        }
        return 8;
    }
    else if(indexPath.section == 0 && indexPath.row == [_array_basicSetting count]-1)
    {
        return 45+2;
    }
    else if(indexPath.section == 1 && indexPath.row == [_array_other count]-1)
    {
        return 45+2;
    }
    return 45;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoreSettingCell *cell_moreSetting = [tableView dequeueReusableCellWithIdentifier:@"MoreIdentifier"];
    if(cell_moreSetting == nil)
    {
        cell_moreSetting = [[[MoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreIdentifier"] autorelease];
        cell_moreSetting.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell_moreSetting.imageView_lastCell.alpha = 0;
    cell_moreSetting.label_userName.alpha = 0;
    cell_moreSetting.imageView_arrow.alpha = 1;
    cell_moreSetting.switch_download.alpha = 0;
    cell_moreSetting.flag_noBackGroundColor = 0;
    
    
    
    UITableViewCell *spacecell = [tableView dequeueReusableCellWithIdentifier:@"spacecell"];
    if(spacecell == nil)
    {
        spacecell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"spacecell"] autorelease];
        spacecell.backgroundColor = [UIColor clearColor];
        spacecell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.section == 0) //基本设置
    {
        if(indexPath.row == [_array_basicSetting count])
        {
            return spacecell;
        }
        else
        {
            cell_moreSetting.label_titleName.text = [_array_basicSetting objectAtIndex:indexPath.row];
            
            if(indexPath.row == 0)
            {
                cell_moreSetting.label_userName.alpha = 1;
                
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
                {
                    cell_moreSetting.label_userName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
                }
                else
                {
                    cell_moreSetting.label_userName.text = @"未登录";
                }
            }
            else if(indexPath.row == 1)     //switch
            {
                cell_moreSetting.imageView_arrow.alpha = 0;
                cell_moreSetting.switch_download.alpha = 1;
                cell_moreSetting.flag_noBackGroundColor = 1;
            }
            else if(indexPath.row == [_array_basicSetting count]-1)
            {
                cell_moreSetting.imageView_lastCell.alpha = 1;
            }
        }
    }
    else if (indexPath.section == 1) //其它
    {
        if(indexPath.row == [_array_other count])
        {
            return spacecell;
        }
        else
        {
            cell_moreSetting.label_titleName.text = [_array_other objectAtIndex:indexPath.row];
            if(indexPath.row == [_array_other count]-1)
            {
                cell_moreSetting.imageView_lastCell.alpha = 1;
            }
        }
    }
    else if(indexPath.section == 2) //穷游其它应用
    {
        if(_applicationArray && _applicationArray.count > 0)
        {
            if(indexPath.row == 0)
            {
                MoreSettingCell *applicationCell = [tableView dequeueReusableCellWithIdentifier:@"ApplicationIdentifier"];
                if(applicationCell == nil)
                {
                    applicationCell = [[[MoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ApplicationIdentifier"] autorelease];
                    applicationCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    applicationCell.imageView_lastCell.alpha = 0;
                }
                
                for(UIView *view in applicationCell.imageView_label_nameBackGround.subviews)
                {
                    [view removeFromSuperview];
                }
                [applicationCell setAppWithArray:_applicationArray];
                
                return applicationCell;
            }
            else
            {
                cell_moreSetting.label_titleName.text = [_array_otherApp objectAtIndex:indexPath.row-1];
                if(indexPath.row == [_array_otherApp count])
                {
                    cell_moreSetting.imageView_lastCell.alpha = 1;
                }
            }
        }
        else
        {
            cell_moreSetting.label_titleName.text = [_array_otherApp objectAtIndex:indexPath.row];
            NSLog(@" cell_moreSetting.label_titleName.text : %@",cell_moreSetting.label_titleName.text);
            
            if(indexPath.row == [_array_otherApp count]-1)
            {
                cell_moreSetting.imageView_lastCell.alpha = 1;
            }
        }
    }
    
    return cell_moreSetting;
}



#pragma mark -
#pragma mark --- UITableView - delegate
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                [self doLogin];
            }
                break;
            case 2:
            {
                //[MobClick event:@"moreClickAbout"];
                
                QuestionsViewController *questionVC = [[QuestionsViewController alloc] init];
                [self.navigationController pushViewController:questionVC animated:YES];
                [questionVC release];
            }
                break;
            case 3:
            {
                
                AboutViewController *aboutVC = [[AboutViewController alloc] init];
                [self.navigationController pushViewController:aboutVC animated:YES];
                [aboutVC release];
            }
                break;
                
            default:
                break;
        }
    }
    else if(indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                
                [self feedBack];
            }
                break;
            case 1:
            {
                
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                NSString *appVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
                appVersion = [appVersion stringByReplacingOccurrencesOfRegex:@"." withString:@"_"];
                NSString *key = [NSString stringWithFormat:@"comment_app_V%@",appVersion];
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=563467866"]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d&at=10l6dK",APPSTOREAPPLICATIONID]];
                if(ios7)
                {
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d?at=10l6dK",APPSTOREAPPLICATIONID]];
                }
                [[UIApplication sharedApplication] openURL:url];
                
            }
                break;
            case 2:
            {
                [self showShareAppView];
            }
                break;
                
            default:
                break;
        }
    }
    else if(indexPath.section == 2)
    {
        MoreSettingCell *cell = (MoreSettingCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:2]];
        if(cell.label_titleName.text.length > 0)
        {
            if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
            {
                [self.view hideToast];
                [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1.0 position:@"center" isShadow:NO];
            }
            else
            {
                
            }
        }
    }
    
    return nil;
}


#pragma mark -
#pragma mark --- 反馈
-(void)feedBack
{
//    if([QyerSns canSendMail])
//    {
//        NSString *version = [DeviceInfo getDeviceSystemVersion];
//        NSString *device = [DeviceInfo getDeviceName_detail];
//        NSString *appname = [NSString stringWithFormat:@"%@ iPhone版",[DeviceInfo getAppName]];
//        NSString *appversion = [DeviceInfo getAppVersion];
//        
//        NSString *str_feedBack = [NSString stringWithFormat:@"\n\n\n\n\n\nsystem version：%@\nplatform：%@\n%@\napp version：%@",version,device,appname,appversion];
//        NSDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"穷游锦囊iPhone反馈",@"title",[NSArray arrayWithObject:@"mfb@qyer.com"],@"mailaddress",str_feedBack,@"info", nil];
//        [[QyerSns sharedQyerSns] feedBackWithMailInfo:dic];
//    }
//    else
//    {
        FeedBackViewController *feedbackVC = [[FeedBackViewController alloc] init];
        [self presentViewController:feedbackVC animated:YES completion:nil];
        [feedbackVC release];
//    }
}



#pragma mark -
#pragma mark --- 登陆
-(void)doLogin
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES) //已登录
    {
        NSLog(@" 已登陆 ");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"确认登出?"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    else{
        
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [self presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
    
    }
     
}


#pragma mark -
#pragma mark --- showShareAppView
-(void)showShareAppView
{
    BOOL flag = [[QyerSns sharedQyerSns] getIsWeixinInstalled];
    NSString *versonStr = [[QyerSns sharedQyerSns] getWeixinVerson];
    BOOL SMSFlag = [[QyerSns sharedQyerSns] isCanSendSMS];
    
    if (SMSFlag)
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
            actionSheet.delegate = self;
            
            [actionSheet show];
            [actionSheet release];
        }
        else
        {
            if(flag == 0 || [versonStr floatValue] - 1.1 < 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"邮件", @"短信", nil] imageArray:[NSArray arrayWithObjects: @"btn_actionsheet_weibo",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
            else if(flag == 1 && [versonStr floatValue] - 1.1 >= 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信",  nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo",@"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
        }
    }
    else
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
            actionSheet.delegate = self;
            
            [actionSheet show];
            [actionSheet release];
        }
        else
        {
            if(flag == 0 || [versonStr floatValue] - 1.1 < 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"邮件", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
            else if(flag == 1 && [versonStr floatValue]  - 1.1 >= 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",  nil] imageArray:[NSArray arrayWithObjects: @"btn_actionsheet_weibo", @"btn_actionsheet_weixin",@"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
                actionSheet.delegate = self;
                
                [actionSheet show];
                [actionSheet release];
            }
        }
    }
}


#pragma mark -
#pragma mark --- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        
    }
    else
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        self.imUserId = [userDefault objectForKey:@"im_user_id"];
        
        
        [userDefault setBool:NO forKey:@"qyerlogin"];
        [userDefault setValue:nil forKey:@"user_access_token"];
        [userDefault setValue:nil forKey:@"userid_im"];
        [userDefault setValue:nil forKey:@"im_user_id"];
        [userDefault setValue:nil forKey:@"userid"];
        [userDefault setValue:nil forKey:@"username"];
        [userDefault setValue:nil forKey:@"usericon"];
        
//        [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
//        [myDefault setValue:[dic valueForKey:@"access_token"] forKey:@"user_access_token"];
//        
//        if (![[dic objectForKey:@"im_user_id"] isEqual:[NSNull null]]) {
//            [myDefault setValue:[dic valueForKey:@"im_user_id"] forKey:@"userid_im"];
//        }
//        
//        [myDefault setObject:[[dic objectForKey:@"userinfo"] objectForKey:@"uid"] forKey:@"userid"];
//        [myDefault setValue:[[dic objectForKey:@"userinfo"] objectForKey:@"username"] forKey:@"username"];
//        [myDefault setValue:[[dic objectForKey:@"userinfo"] objectForKey:@"avatar"] forKey:@"usericon"];
//        [myDefault synchronize];
        
        
        [userDefault synchronize];
        
        [_tableView_moreVC reloadData];
        
        [self.view makeToast:@"登出成功" duration:1 position:@"center" isShadow:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginoutsuccess" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationFailed" object:nil userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isShowNoteMsg" object:nil userInfo:@{@"count":@(YES)}];

        
        
        
//        //清除用户的行程缓存:
//        NSString *pathName = [NSString stringWithFormat:@"webviewCache/plan"];
//        NSString *path = [[FilePath sharedFilePath] getFilePath:pathName];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
//        {
//            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//        }
        
        
        
        
        [[QYIMObject getInstance] disConnectWithBlock:^(QYIMObject *imObject, QYIMConnectStatus status) {
            if (status == QYIMConnectStatusOffLine) {
                //获取当前用户是否在线，如果不在线，退出聊天室
                [imObject getClientsStatusWithUserId:self.imUserId withBlock:^(QYIMObject *imObject, QYIMConnectStatus onlineStatus) {
                    if (status == QYIMConnectStatusOffLine) {
                        //退出聊天室:
                        [[QYIMObject getInstance] disJoinChatRoomWithBlock:nil];
                    }
                }];
                [QYIMObject getInstance].connectStatus = QYIMConnectStatusOffLine;
            }
        }];
        
    }
}


#pragma mark -
#pragma mark --- MYActionSheet - Delegate
- (void)cancelButtonDidClick:(MYActionSheet *)actionSheet
{
    
}
-(void)actionSheetButtonDidClickWithType:(NSString*)type
{
    if([type isEqualToString:@"邮件"])
    {
        //[MobClick event:@"setting" label:@"邮件分享"];
        [self youjianfenxiang];
    }
    if([type isEqualToString:@"短信"])
    {
        //[MobClick event:@"setting" label:@"短信"];
        [self sendmessage];
    }
    else if([type isEqualToString:@"新浪微博"])
    {
        //[MobClick event:@"setting" label:@"新浪微博分享"];
        [self shareToSinaWeibo];
    }
    else if([type isEqualToString:@"微信"])
    {
        //[MobClick event:@"setting" label:@"微信分享"];
        [self shareToWeixinFriend];
    }
    else if([type isEqualToString:@"微信朋友圈"])
    {
        //[MobClick event:@"setting" label:@"微信朋友圈"];
        [self shareToWeixinFriendCircle];
    }
    else if([type isEqualToString:@"腾讯微博"])
    {
        [self shareToTencentWeibo];
    }
}




#pragma mark -
#pragma mark --- 分享
-(void)youjianfenxiang
{
    [[QyerSns sharedQyerSns] shareToMailWithMailTitle:@"Hi~我发现了一个出境游的APP#穷游#，你也来下载吧！" andMailInfo:@"穷游锦囊升级啦！\n\t新版#穷游APP#汇集了更多丰富实用的出境旅行指南，更给力的折扣信息，更精彩的旅行游记，更好用的行程助手！ \n\t这么棒的旅行应用，小伙伴你还不快来下载一个！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_app" andImage: [UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)sendmessage
{
    [[QyerSns sharedQyerSns] shareWithShortMessage:@"穷游锦囊升级啦！新版#穷游APP#汇集了更多丰富实用的出境旅行指南，更给力的折扣信息，更精彩的旅行游记，更好用的行程助手！ 这么棒的旅行应用，小伙伴你还不快来下载一个！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_app" inViewController:self];
}

-(void)shareToWeixinFriend
{
    [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:@"穷游锦囊升级啦！新版#穷游APP#汇集了更多丰富实用的出境旅行指南，更给力的折扣信息，更精彩的旅行游记，更好用的行程助手！ 这么棒的旅行应用，小伙伴你还不快来下载一个！ " andImage:[UIImage imageNamed:@"120icon"] andUrl:@"http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_app"];
}

-(void)shareToWeixinFriendCircle
{
     [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:@"穷游锦囊升级啦！新版#穷游APP#汇集了更多丰富实用的出境旅行指南，更给力的折扣信息，更精彩的旅行游记，更好用的行程助手！ 这么棒的旅行应用，小伙伴你还不快来下载一个！" andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:@"http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_app"];
    
}
-(void)shareToSinaWeibo
{
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:@"穷游锦囊升级啦！新版#穷游APP#汇集了更多丰富实用的出境旅行指南，更给力的折扣信息，更精彩的旅行游记，更好用的行程助手！ 这么棒的旅行应用，小伙伴你还不快来下载一个！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_app" andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}
-(void)shareToTencentWeibo
{
    [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:@"穷游锦囊升级啦！新版#穷游APP#汇集了更多丰富实用的出境旅行指南，更给力的折扣信息，更精彩的旅行游记，更好用的行程助手！ 这么棒的旅行应用，小伙伴你还不快来下载一个！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_app" andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
}



#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
