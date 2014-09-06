//
//  KSSearchDetailViewController.m
//  KwSing
//
//  Created by 单 永杰 on 13-10-30.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "KSSearchDetailViewController.h"
#import "KSAppDelegate.h"
#import "ImageMgr.h"
#include "globalm.h"
#include "CacheMgr.h"
#import "HttpRequest.h"
#include "MessageManager.h"
#include "KwTools.h"
#include "SBJsonParser.h"
#include "User.h"
#import "MyPageViewController.h"
#import "BaseWebViewController.h"
#import "KSOtherLoginViewController.h"
#import "LoginViewController.h"
#import "KSInviteFriendViewController.h"
#include "IInviteFriendObserver.h"
#import "iToast.h"

#define TagListLabelName 100
#define TagCellLoading 101
#define TagListArrow 102

#define ALERT_SINA_TAG 110
#define ALERT_QQ_TAG 111

#define TAG_STATE_BTN       112
#define TAG_NICK_LABEL      113
#define TAG_GENDER_LABEL    114

@interface KSFriendInfo : NSObject
@property (retain,nonatomic) NSString *headPickURL;
@property (retain,nonatomic) NSString *nickName;
@property (retain,nonatomic) NSString *remarkName;
@property (retain,nonatomic) NSString *sex;
@property (retain,nonatomic) NSString *userId;
@property (retain,nonatomic) NSString *city;
@property (retain,nonatomic) NSString *age;
@property (retain,nonatomic) NSString *weiboId;
@property (assign,atomic)    NSInteger state;

@end
@implementation KSFriendInfo


@end

@interface KSSearchDetailViewController ()<UISearchBarDelegate, UIAlertViewDelegate, IUserStatusObserver, IInviteStateObserver>{
    NSMutableArray* friend_list;
    UISearchBar* search_view;
    UITableView* table_friends;
    UIView* _noNetworkView;
    CHttpRequest* _request;
    UIView* pNeedLoginMsgView;
    BOOL _bHasMore;
    NSInteger _nCurrentPage;
    
    NSIndexPath* _curRow;
    UIAlertView *_waitingDialog;
    UILabel *_tipsLable;
}
-(void)initAllData;
@end

@implementation KSSearchDetailViewController

@synthesize searchType = _searchType;

static KwTools::CLock S_SEARCH_FRIEND_LOCK;

#define KUWO_SEARCH_URL "http://changba.kuwo.cn/kge/search/KgeUserNameService?act=search&name="
#define OTHER_SEARCH_URL   "http://changba.kuwo.cn/kge/search/KgeUserBindRelationService?"
//#define KUWO_SEARCH_URL "http://60.28.200.79:8180/kge/search/KgeUserNameService?act=search&name="
//#define OTHER_SEARCH_URL   "http://60.28.200.79:8180/kge/search/KgeUserBindRelationService?"
#define URL_USERACTION  @"http://changba.kuwo.cn/kge/mobile/userAction"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_INVITESTATUS, IInviteStateObserver);
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_INVITESTATUS, IInviteStateObserver);
    if (table_friends) {
        [table_friends setDelegate:nil];
        [table_friends setDataSource:nil];
        [table_friends release];
        table_friends = nil;
    }
    
    if (friend_list) {
        [friend_list removeAllObjects];
        [friend_list release];
        friend_list = nil;
    }
    
    if (search_view) {
        [search_view setDelegate:nil];
        [search_view release];
        search_view = nil;
    }
    
    if (_noNetworkView) {
        [_noNetworkView release];
        _noNetworkView = nil;
    }
    
    if (_request) {
        delete _request;
        _request = NULL;
    }
    
    if (pNeedLoginMsgView) {
        [pNeedLoginMsgView release];
        pNeedLoginMsgView = nil;
    }
    if (_waitingDialog) {
        [_waitingDialog release];
        _waitingDialog = nil;
    }
    if (_tipsLable) {
        [_tipsLable release];
        _tipsLable =nil;
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    [self.view setBackgroundColor:UIColorFromRGBValue(0xededed)];
    
    switch (_searchType) {
        case E_SEARCH_KUWO:
            label_title.text = @"酷我好友";
            break;
        
        case E_SEARCH_SINA:
            label_title.text = @"新浪微博好友";
            break;
            
        case E_SEARCH_QQ:
            label_title.text = @"腾讯微博好友";
            break;
            
        default:
            break;
    }
    
    table_friends = [[UITableView alloc] init];
    [table_friends setDataSource:self];
    [table_friends setDelegate:self];
    
    
    _waitingDialog=[[UIAlertView alloc] initWithTitle:@"正在加载数据,请稍后..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activity=[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [activity setCenter:CGPointMake(150, 50)];
    [activity startAnimating];
    [_waitingDialog addSubview:activity];
    
    
    if (E_SEARCH_KUWO == _searchType) {
        search_view = [[UISearchBar alloc] init];
        [search_view setDelegate:self];
        [search_view setBackgroundColor:[UIColor clearColor]];
        if (NSOrderedAscending == [[[UIDevice currentDevice] systemVersion] compare:@"7.0"]) {
            [[[search_view subviews] objectAtIndex:0] removeFromSuperview];
        }else {
            [search_view setBarTintColor:[UIColor clearColor]];
        }
        search_view.frame = CGRectMake(65, 9, 250, 28);
        [self.view addSubview:search_view];
        
        table_friends.frame = CGRectMake(0, ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height, 320, [UIScreen mainScreen].bounds.size.height - ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height - 20);
        [self.view addSubview:table_friends];
        
        [search_view becomeFirstResponder];
    }else {
        
        table_friends.frame = CGRectMake(0, ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height, 320, [UIScreen mainScreen].bounds.size.height - ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height - 20);
        [self.view addSubview:table_friends];
        
        //[self fetchJsonData];
    }
    
    _tipsLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [_tipsLable setText:@"没有搜索到任何好友"];
    [_tipsLable setTextAlignment:NSTextAlignmentCenter];
    [_tipsLable setCenter:self.view.center];
    [_tipsLable setHidden:YES];
    [[self view] addSubview:_tipsLable];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self initAllData];
    if (E_SEARCH_KUWO != _searchType) {
        [self fetchJsonData];
    }
}
-(void)showNoNetwork
{
    if (!_noNetworkView) {
        CGRect mainRect=self.view.bounds;
        mainRect=BottomRect(mainRect, mainRect.size.height-ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height, 0);
        _noNetworkView = [[UIView alloc] initWithFrame:mainRect];
        [_noNetworkView setBackgroundColor:[UIColor whiteColor]];
        UIImageView *imageView=[[[UIImageView alloc] initWithFrame:mainRect] autorelease];
        [imageView setImage:CImageMgr::GetImageEx("failmsgNoNet.png")];
        [_noNetworkView addSubview:imageView];
        
        [[self view] addSubview:_noNetworkView];
        
        UITapGestureRecognizer *tapGestureRecognize=[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapErrorViewGestureRecognizer:)] autorelease];
        tapGestureRecognize.numberOfTapsRequired=1;
        
        [_noNetworkView addGestureRecognizer:tapGestureRecognize];
    }
    [_noNetworkView setHidden:false];
}
-(void)initAllData
{
    friend_list = [[NSMutableArray alloc] init];
    _bHasMore = NO;
    _nCurrentPage = 1;
}
-(void)fetchJsonData
{
    if (_noNetworkView) {
        [_noNetworkView setHidden:true];
    }
    
    if (CHttpRequest::GetNetWorkStatus() == NETSTATUS_NONE){
        [self showNoNetwork];
        return;
    }
    KS_BLOCK_DECLARE{
        KwTools::CAutoLock auto_lock(&S_SEARCH_FRIEND_LOCK);
        
        std::string str_friend_search_url = "";
        switch (_searchType) {
            case E_SEARCH_KUWO:
                str_friend_search_url += KUWO_SEARCH_URL;
                str_friend_search_url += [KwTools::Encoding::UrlEncode([search_view text]) UTF8String];
                str_friend_search_url += [[NSString stringWithFormat:@"&pn=%d&ps=100", _nCurrentPage] UTF8String];
                if (User::GetUserInstance()->isOnline()) {
                    str_friend_search_url += [[NSString stringWithFormat:@"&id=%@&sid=%@", User::GetUserInstance()->getUserId(), User::GetUserInstance()->getSid()] UTF8String];
                }
                break;
                
            case E_SEARCH_QQ:
                str_friend_search_url += OTHER_SEARCH_URL;
                str_friend_search_url += [[NSString stringWithFormat:@"pn=%d&ps=30&type=qq&uid=%@&sid=%@", _nCurrentPage, User::GetUserInstance()->getUserId(), User::GetUserInstance()->getSid()] UTF8String];
                break;
                
            case E_SEARCH_SINA:
                str_friend_search_url += OTHER_SEARCH_URL;
                str_friend_search_url += [[NSString stringWithFormat:@"pn=%d&ps=30&type=weibo&uid=%@&sid=%@", _nCurrentPage, User::GetUserInstance()->getUserId(), User::GetUserInstance()->getSid()] UTF8String];
                break;
                
            default:
                break;
        }
        
        
        if (NULL != _request) {
            _request->StopRequest();
            delete _request;
            _request = NULL;
        }
        _request =new CHttpRequest(str_friend_search_url);
        _request->SetTimeOut(5000);
        BOOL res=_request->SyncSendRequest();
        
        if (res) {
            //请求成功
            void * buf(NULL);
            unsigned l(0);
            _request->ReadAll(buf, l);
            NSData *retData=[NSData dataWithBytesNoCopy:buf length:l freeWhenDone:YES];
            [self parserJsonData:retData];
            _nCurrentPage++;
        }else {
            _bHasMore = NO;
        }
        KS_BLOCK_DECLARE
        {
            if (friend_list.count == 0) {
                [_tipsLable setHidden:NO];
            }
            else{
                [_tipsLable setHidden:YES];
            }
            [_waitingDialog dismissWithClickedButtonIndex:0 animated:YES];
            [table_friends reloadData];
        }KS_BLOCK_SYNRUN()
    }
    KS_BLOCK_RUN_THREAD()
}
-(void)parserJsonData:(NSData *)jsonData
{
    if (friend_list == nil) {
        return;
    }
    if ([friend_list count] > 0 && !_bHasMore) {
        return;
//        [friend_list removeAllObjects];
    }
    SBJsonParser *parser=[[SBJsonParser alloc] init];
    NSDictionary *parserDic=[parser objectWithData:jsonData];
    [parser release];
    //NSLog(@"ret dic:%@",[parserDic description]);
    NSString *retStat=[parserDic objectForKey:@"ret"];
    if (0 <= [retStat intValue]) {
        NSArray *friendList=[parserDic objectForKey:@"prolist"];
        for (NSDictionary * item in friendList) {
            KSFriendInfo * iData = [[KSFriendInfo alloc] init];
            
            iData.headPickURL = [item objectForKey:@"bimg"];
            iData.userId = [item objectForKey:@"uid"];
            iData.nickName = [item objectForKey:@"nickname"];
            iData.remarkName = [item objectForKey:@"remarkname"];
            iData.state = [[item objectForKey:@"state"] integerValue];
            NSInteger n_sex = [[item objectForKey:@"sex"] integerValue];
            switch (n_sex) {
                case 0:
                    iData.sex =  @"保密";
                    break;
                case 1:
                    iData.sex =  @"男";
                    break;
                default:
                    iData.sex =  @"女";
                    break;
            }
            iData.age = [item objectForKey:@"age"];
            iData.city = [item objectForKey:@"city"];
            iData.weiboId = [item objectForKey:@"weiboId"];
            
            
            [friend_list addObject:iData];
            [iData release];
        }
    }
    
    else {
//        if(E_SEARCH_QQ == _searchType){
//            KS_BLOCK_DECLARE{
//                UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的QQ账号还未绑定，是否立即绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
//                [alert setTag:ALERT_QQ_TAG];
//                [alert show];
//            }
//            KS_BLOCK_SYNRUN();
//        }else {
//            KS_BLOCK_DECLARE{
//                UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的新浪微博账号还未绑定，是否立即绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
//                [alert setTag:ALERT_SINA_TAG];
//                [alert show];
//            }
//            KS_BLOCK_SYNRUN();
//        }
        return;
    }
    
    switch (_searchType) {
        case E_SEARCH_KUWO:
            if (0 < ([[parserDic objectForKey:@"totalcount"] integerValue] - _nCurrentPage * 100)) {
                _bHasMore = YES;
            }else {
                _bHasMore = NO;
            }
            break;

        default:
            if (0 == [[parserDic objectForKey:@"hasnext"] integerValue]) {
                _bHasMore = YES;
            }else {
                _bHasMore = NO;
            }
            
            break;
    }
}

-(void)fetchHeadPicAtURL:(NSString *)imageUrl inView:(UIImageView *)view
{
    __block void* imageData(NULL);
    __block unsigned length(0);
    BOOL outOfTime(true);
    if ( (nil != imageUrl) && CCacheMgr::GetInstance()->Read([imageUrl UTF8String], imageData, length, outOfTime)) {
        NSData *cacheImageData=[[NSData alloc] initWithBytesNoCopy:imageData length:length freeWhenDone:YES];
        UIImage *image=[[UIImage alloc] initWithData:cacheImageData];
        [view setImage:image];
        [cacheImageData release];
        [image release];
    }
    else
    {
        KS_BLOCK_DECLARE{
            if (nil == imageUrl || 0 == [imageUrl length]) {
                return;
            }
            bool retRes=CHttpRequest::QuickSyncGet([imageUrl UTF8String], imageData, length);
            KS_BLOCK_DECLARE{
                if (retRes) {
                    NSData* webImageData=[[NSData alloc] initWithBytesNoCopy:imageData length:length freeWhenDone:true];
                    CCacheMgr::GetInstance()->Cache(T_DAY, 3, [imageUrl UTF8String], [webImageData bytes], [webImageData length]);
                    UIImage *image=[[UIImage alloc] initWithData:webImageData];
                    
                    [view setImage:image];
                    [webImageData release];
                    [image release];
                }
            }KS_BLOCK_SYNRUN()
        }KS_BLOCK_RUN_THREAD()
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) ReturnBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    if (_bHasMore) {
        return [friend_list count] + 1;
    }
    return [friend_list count];
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger n_row = indexPath.row;
    
    static NSString* friend_table_identifier = @"FriendTableIdentifier";
    static NSString* load_more_identifier = @"LoadingMoreIdentifier";
    UITableViewCell* cell = nil;
    if (n_row < [friend_list count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:friend_table_identifier];
        KSFriendInfo* friend_info = [friend_list objectAtIndex:n_row];
        
        if (nil == cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:friend_table_identifier] autorelease];
            [cell setBackgroundColor:[UIColor whiteColor]];
            UIButton* btn_state = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn_state setTag:TAG_STATE_BTN];
            
            [btn_state setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn_state setBackgroundColor:[UIColor clearColor]];
            
            btn_state.frame = CGRectMake(250, 8, 60, 28);
            [btn_state addTarget:self action:@selector(btnStateClicked:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:btn_state];
            
            UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(74, 4, 150, 25)];
            [nickLabel setTextAlignment:NSTextAlignmentLeft];
            [nickLabel setBackgroundColor:[UIColor clearColor]];
            [nickLabel setTag:TAG_NICK_LABEL];
            [[cell contentView] addSubview:nickLabel];
            
            UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(74, 32, 100, 15)];
            [genderLabel setTextAlignment:NSTextAlignmentLeft];
            [genderLabel setBackgroundColor:[UIColor clearColor]];
            [genderLabel setTag:TAG_GENDER_LABEL];
            [cell.contentView addSubview:genderLabel];
        }
        
        UIButton* btn_state = (UIButton*)[cell.contentView viewWithTag:TAG_STATE_BTN];
        if (nil != btn_state) {
            switch (friend_info.state) {
                case 0:
                    [btn_state setTitle:@"邀请" forState:UIControlStateNormal];
                    [btn_state setBackgroundImage:CImageMgr::GetImageEx("KsongBtn.png") forState:UIControlStateNormal];
                    [btn_state setBackgroundImage:CImageMgr::GetImageEx("KsongBtnDown.png") forState:UIControlStateHighlighted];
                    [cell setBackgroundColor:UIColorFromRGBValue(0xededed)];
                    [btn_state setEnabled:YES];
                    break;
                    
                case 1:
                    [btn_state setTitle:@"已邀请" forState:UIControlStateNormal];
                    [btn_state setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnNormal.png") forState:UIControlStateNormal];
                    [btn_state setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnDown.png") forState:UIControlStateHighlighted];
                    [btn_state setEnabled:NO];
                    break;
                    
                case 2:
                    [btn_state setTitle:@"关注" forState:UIControlStateNormal];
                    [btn_state setBackgroundImage:CImageMgr::GetImageEx("KsongBtn.png") forState:UIControlStateNormal];
                    [btn_state setBackgroundImage:CImageMgr::GetImageEx("KsongBtnDown.png") forState:UIControlStateHighlighted];
                    [btn_state setEnabled:YES];
                    break;
                    
                case 3:
                    [btn_state setTitle:@"已关注" forState:UIControlStateNormal];
                    [btn_state setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnNormal.png") forState:UIControlStateNormal];
                    [btn_state setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnDown.png") forState:UIControlStateHighlighted];
                    [cell setBackgroundColor:UIColorFromRGBValue(0xededed)];
                    [btn_state setEnabled:YES];
                    break;
                    
                default:
                    break;
            }
        }
        
        cell.imageView.frame =  CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, 40, 40);
        [cell.imageView setImage:CImageMgr::GetImageEx("defaultHeadPic.jpg")];
        [self fetchHeadPicAtURL:friend_info.headPickURL inView:cell.imageView];
        
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:TAG_NICK_LABEL];
        [label setText : friend_info.nickName];
        NSLog(@"cell text frame:%@",NSStringFromCGRect(cell.textLabel.frame));
        
        NSString* str_detail_info = [NSString stringWithFormat:@"%@  %@  %@", nil == friend_info.sex ? @"保密" : friend_info.sex, nil == friend_info.city ? @"保密" : friend_info.city, friend_info.age];
        UILabel *genderLabel = (UILabel *)[cell.contentView viewWithTag:TAG_GENDER_LABEL];
        [genderLabel setText:str_detail_info];
        
    }else {
        cell= [tableView dequeueReusableCellWithIdentifier:load_more_identifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:load_more_identifier] autorelease];
            
//            int cellheight = [table_friends heightForRowAtIndexPath:indexPath];
            UIImageView * bkimage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 180)]autorelease];
            bkimage.image = CImageMgr::GetImageEx("listbk_5_1.png");
            [cell.contentView addSubview:bkimage];
            
            UIImage * image = CImageMgr::GetImageEx("blackArrow.png");
            UIImageView* imageview = [[[UIImageView alloc]initWithImage:image]autorelease];
            imageview.frame = CGRectMake(10, 10, image.size.width, image.size.height);
            imageview.tag = TagListArrow;
            [cell.contentView addSubview:imageview];
            imageview.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            
            UILabel *textLabel = [[[UILabel alloc]initWithFrame:CGRectMake(35, 17, 95, 17)]autorelease];
            textLabel.font= [UIFont systemFontOfSize:13];
            textLabel.textColor = UIColorFromRGBValue(0x969696);
            textLabel.backgroundColor = [UIColor clearColor];
            [textLabel setTag:TagListLabelName];
            [cell.contentView addSubview:textLabel];
            
            UIActivityIndicatorView *activiter = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
            activiter.center = CGPointMake(130, 22);
            
            activiter.tag = TagCellLoading;
            activiter.hidden = true;
            [cell addSubview:activiter];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        UILabel *textLabel = (UILabel*)[cell viewWithTag:TagListLabelName];
        [textLabel setText:@"上拉加载更多"];
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row =[indexPath row];
    KSFriendInfo* friend_info = [friend_list objectAtIndex:row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (2 > friend_info.state ) {
        return;
    }else {
        BaseWebViewController *homePage=[[[BaseWebViewController alloc] init] autorelease];
        [homePage setStrUrl:[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/webmobile/ios/userhome.html?=111=%@",friend_info.userId]];
        [homePage setTitle:[NSString stringWithFormat:@"%@的个人主页",friend_info.nickName]];
        [ROOT_NAVAGATION_CONTROLLER pushViewController:homePage animated:YES];
    }
}

- (void)singleTapErrorViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    KSLoginViewController* loginController=[[[KSLoginViewController alloc] init] autorelease];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:loginController animated:YES];
}

- (void)showNeedLoginView
{
    if (!pNeedLoginMsgView) {
        CGRect rc=[self view].bounds;
        CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
        CGRect back=BottomRect(rc, rc.size.height-rcna.size.height, 0);
        pNeedLoginMsgView=[[UIView alloc] initWithFrame:back];
        [pNeedLoginMsgView setBackgroundColor:[UIColor whiteColor]];
        UIImage *needLoginImage=CImageMgr::GetImageEx("needLogin.png");
        UIImageView *needLoginView=[[UIImageView alloc] initWithFrame:CGRectMake(35, 116, needLoginImage.size.width,needLoginImage.size.height)];
        [needLoginView setImage:needLoginImage];
        [pNeedLoginMsgView addSubview:needLoginView];
        [needLoginView release];
        [self.view addSubview:pNeedLoginMsgView];
        
        UITapGestureRecognizer *tapGestureRecognize=[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapErrorViewGestureRecognizer:)] autorelease];
        tapGestureRecognize.numberOfTapsRequired=1;
        [pNeedLoginMsgView addGestureRecognizer:tapGestureRecognize];
    }
    pNeedLoginMsgView.hidden=NO;
}

-(void)btnStateClicked:(UIButton *)sender{
    if (!User::GetUserInstance()->isOnline()) {
        [self showNeedLoginView];
        
        return;
    }
    
    UITableViewCell* cell = nil;
    if (NSOrderedAscending != [[[UIDevice currentDevice] systemVersion] compare:@"7.0"]) {
        cell = (UITableViewCell*)[[[(UIButton*)sender superview]superview] superview];
    }else {
        cell = (UITableViewCell*)[[(UIButton*)sender superview]superview];
    }
    
    NSIndexPath *indexPath = [table_friends indexPathForCell:cell];
    
    if (nil == indexPath) {
        return;
    }
    
    if (_curRow) {
        [_curRow release];
        _curRow = nil;
    }
    _curRow = [indexPath retain];
    
    KSFriendInfo* friend_info = [friend_list objectAtIndex:indexPath.row];
    
    switch (friend_info.state) {
        case 0:
        {
            //邀请操作
            KSInviteFriendViewController* invite_view = [[[KSInviteFriendViewController alloc] init] autorelease];
            NSString* str_search_type = nil;
            switch (_searchType) {
                case E_SEARCH_SINA:
                    str_search_type = @"weibo";
                    break;
                case E_SEARCH_QQ:
                    str_search_type = @"qq";
                    break;
                default:
                    break;
            }
            [invite_view setStrShareType:str_search_type];
            [invite_view setStrNickName:friend_info.remarkName];
            [ROOT_NAVAGATION_CONTROLLER pushViewController:invite_view animated:YES];
            
            break;
        }
        case 1:
        {
            //已邀请，不处理
            [sender setTitle:@"已邀请" forState:UIControlStateNormal];
            [sender setEnabled:NO];
            
            break;
        }
        case 2:
        {
            //关注操作
            
            NSString *strURL = [NSString stringWithFormat:@"%@?fid=%@&tid=%@&sid=%@&type=care",URL_USERACTION,
                                                     User::GetUserInstance()->getUserId(),friend_info.userId,
                                                     User::GetUserInstance()->getSid()];
            KS_BLOCK_DECLARE
            {
                std::string strOut;
                BOOL bret = CHttpRequest::QuickSyncGet([strURL UTF8String], strOut);
                if(bret)
                {
                    std::map<std::string,std::string> mapToken;
                    KwTools::StringUtility::TokenizeKeyValue(strOut, mapToken,"&","=");
                    if(mapToken["result"] == "ok")
                    {
                        KS_BLOCK_DECLARE
                        {
                            friend_info.state = 3;
                            [sender setTitle:@"已关注" forState:UIControlStateNormal];
                            [sender setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnNormal.png") forState:UIControlStateNormal];
                            [sender setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnDown.png") forState:UIControlStateHighlighted];
                        }
                        KS_BLOCK_SYNRUN();
                    }
                }
            }
            KS_BLOCK_RUN_THREAD();
            
            break;
        }
        case 3:
        {
            //取消关注操作
            NSString *strURL = [NSString stringWithFormat:@"%@?fid=%@&tid=%@&sid=%@&type=care&act=del%d",URL_USERACTION,
                                                     User::GetUserInstance()->getUserId(),friend_info.userId,
                                                     User::GetUserInstance()->getSid(), rand()];
            KS_BLOCK_DECLARE
            {
                std::string strOut;
                BOOL bret = CHttpRequest::QuickSyncGet([strURL UTF8String], strOut);
                if(bret)
                {
                    std::map<std::string,std::string> mapToken;
                    KwTools::StringUtility::TokenizeKeyValue(strOut, mapToken,"&","=");
                    if(mapToken["result"] == "ok")
                    {
                        KS_BLOCK_DECLARE
                        {
                            friend_info.state = 2;
                            [sender setTitle:@"关注" forState:UIControlStateNormal];
                            [sender setBackgroundImage:CImageMgr::GetImageEx("KsongBtn.png") forState:UIControlStateNormal];
                            [sender setBackgroundImage:CImageMgr::GetImageEx("KsongBtnDown.png") forState:UIControlStateHighlighted];
                        }
                        KS_BLOCK_SYNRUN();
                    }
                }
            }
            KS_BLOCK_RUN_THREAD();
            
            break;
        }
        default:
            break;
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar becomeFirstResponder];
    [searchBar setText:@""];
    searchBar.frame = CGRectMake(65, 9, 250, 28);
    [table_friends setHidden:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [_waitingDialog show];
    _nCurrentPage = 1;
    _bHasMore = NO;
    [friend_list removeAllObjects];
    [table_friends reloadData];
    [searchBar resignFirstResponder];
    [self fetchJsonData];
    [table_friends setHidden:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!_bHasMore)
        return;
    if(table_friends != scrollView)
        return;
    if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height + 30) && scrollView.isTracking) {
        
        UITableViewCell *moreCell = [table_friends cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[friend_list count] inSection:0]];
        
        if (moreCell) {
            
            UIImageView * imageview = (UIImageView*) [moreCell viewWithTag:TagListArrow];
            
            [UIView animateWithDuration:0.2 animations:^{
                imageview.transform = CGAffineTransformMakeRotation(0);
            } ];
            
            UILabel *textLabel = (UILabel*)[moreCell viewWithTag:TagListLabelName];
            [textLabel setText:@"松开即可更新"];
            
        }
	}
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!_bHasMore)
        return;
    if(table_friends != scrollView)
        return;
    if (!_bHasMore) {
		return;
	}
    
    if (scrollView.contentOffset.y > (scrollView.contentSize.height - table_friends.frame.size.height + 5)) {
        
        UITableViewCell *moreCell = [table_friends cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[friend_list count] inSection:0]];
        
        if (moreCell) {
            UIActivityIndicatorView	*activiter = (UIActivityIndicatorView*)[moreCell viewWithTag:TagCellLoading];
            if (activiter != nil) {
                [activiter startAnimating];
                activiter.hidden = false;
            }
            UIImageView * imageview = (UIImageView*) [moreCell viewWithTag:TagListArrow];
            [UIView animateWithDuration:0.2 animations:^{
                imageview.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            } ];
            
            UILabel *textLabel = (UILabel*)[moreCell viewWithTag:TagListLabelName];
            [textLabel setText:@"正在加载数据"];
            
        }
        
        [self fetchJsonData];
	}
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    switch (alertView.tag) {
        case ALERT_SINA_TAG:
        {
            KSOtherLoginViewController *loginViewController=[[KSOtherLoginViewController alloc] initWithType:SINA];
            [loginViewController setIsShare:true];
            [ROOT_NAVAGATION_CONTROLLER pushViewController:loginViewController animated:YES];
            [loginViewController release];
            loginViewController = nil;
        }
            break;
        case ALERT_QQ_TAG:
        {
            KSOtherLoginViewController *loginViewController=[[KSOtherLoginViewController alloc] initWithType:QQ];
            [loginViewController setIsShare:true];
            [ROOT_NAVAGATION_CONTROLLER pushViewController:loginViewController animated:YES];
            [loginViewController release];
            loginViewController = nil;
        }
            break;
            
        default:
            break;
    }
}

-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE) type :(LOGIN_TIME)first
{
    if (pNeedLoginMsgView) {
        [pNeedLoginMsgView removeFromSuperview];
        [pNeedLoginMsgView release];
        pNeedLoginMsgView=NULL;
    }
    
    if (!User::GetUserInstance()->isOnline()) {
        [self showNeedLoginView];
    }else {
        _nCurrentPage = 1;
        [friend_list removeAllObjects];
        [self fetchJsonData];
    }
}
-(void)IUserStatusObserver_Logout
{
    [self showNeedLoginView];
}

-(void)IInviteStateObserver_Result:(kInviteResult)invite_result{
    if (nil == _curRow) {
        return;
    }
    
    if (INVITE_SUCCESS == invite_result) {
        UITableViewCell* cell = [table_friends cellForRowAtIndexPath:_curRow];
        UIButton* state_btn = (UIButton*)[cell.contentView viewWithTag:TAG_STATE_BTN];
        if (state_btn) {
            [state_btn setTitle:@"已邀请" forState:UIControlStateNormal];
            [state_btn setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnNormal.png") forState:UIControlStateNormal];
            [state_btn setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnDown.png") forState:UIControlStateHighlighted];
            [state_btn setEnabled:NO];
            ((KSFriendInfo*)[friend_list objectAtIndex:_curRow.row]).state = 1;
        }
    }
}

@end
