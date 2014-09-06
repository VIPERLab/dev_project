//
//  BBSDetailViewController.m
//  QYER
//
//  Created by Leno on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BBSDetailViewController.h"

#import "QYAPIClient.h"
#import "Toast+UIView.h"
#import "UIImageView+WebCache.h"

#import "WebViewViewController.h"
#import "CityLoginViewController.h"

#import "MineViewController.h"

#import "QyerSns.h"

#import "Reachability.h"

@interface BBSDetailViewController ()

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic, copy) NSString *fid;

@end

#define     height_headerview           (ios7 ? (44+20) : 44)


@implementation BBSDetailViewController

@synthesize bbsAllUserLink = _bbsAllUserLink;
@synthesize bbsAuthorLink = _bbsAuthorLink;
@synthesize threadTitle = _threadTitle;

@synthesize _threadUserID;
@synthesize _threadUserName;
@synthesize _threadID;
@synthesize _floorID;
@synthesize _floorIndex;


- (NSString *)source
{
    if (!_source) {
        _source = @"";
    }
    return _source;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (NSString *)token
{
    if (!_token) {
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    }
    return _token;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"游记详情"];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"游记详情"];
}

- (void)viewDidLoad
{
    [self.view setMultipleTouchEnabled:NO];
    
    [super viewDidLoad];
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _threadUserID = 0;
    _threadID = 0;
    _floorID = 0;
    _floorIndex = 0;
    
    [self initRootView];
    //监听登录成功的通知，然后获取帖子的收藏状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
}
- (void)loginIn_Success
{
    NSLog(@"loginIn_Success -- bbs成功！！！");
    BOOL isLogIn = [[[NSUserDefaults standardUserDefaults]objectForKey:@"qyerlogin"] boolValue];
    if (isLogIn && self.tid && self.fid) {
        
        [[QYAPIClient sharedAPIClient] getBBSCollectStateWithOauthToken:self.token tid:self.tid source:self.source success:^(NSDictionary *dic) {
            NSLog(@"帖子的状态是------%@",dic);
            _collectButton.selected = [[[dic objectForKey:@"data"] objectForKey:@"result"] intValue];
        } failed:^{
            
        }];
    }
}

-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    rootView.userInteractionEnabled = YES;
    self.view = rootView;
    [rootView release];
    
    //初始化导航栏
    [self setupNavgationBar];
    
    //初始化WebView
    [self setupWebView];
    
    //初始化回复和翻页
//    [self setupPageAndComment];
    
    //初始化Web底部的评论框
    [self setupBottomCommentBar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    _bigPicImgView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [_bigPicImgView setBackgroundColor:[UIColor blackColor]];
    [_bigPicImgView setHidden:YES];
    [_bigPicImgView setUserInteractionEnabled:YES];
    [_bigPicImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_bigPicImgView];
    
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityIndicator setFrame:CGRectMake(140, ([UIScreen mainScreen].bounds.size.height -40)/2, 40, 40)];
    [_bigPicImgView addSubview:_activityIndicator];
    
    UITapGestureRecognizer * bigPicTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBigPic:)];
    [bigPicTap setNumberOfTapsRequired:1];
    [bigPicTap setNumberOfTouchesRequired:1];
    [_bigPicImgView addGestureRecognizer:bigPicTap];
    [bigPicTap release];
    
    
    
    
    //没有缓存提示点击加载的图层
    _reloadLastMinuteView = [[UIView alloc]initWithFrame:_BBSDetailWebView.frame];
    [_reloadLastMinuteView setHidden:YES];
    [_reloadLastMinuteView setBackgroundColor:[UIColor clearColor]];
    [_reloadLastMinuteView setUserInteractionEnabled:YES];
    [self.view addSubview:_reloadLastMinuteView];
    
    UIImageView * noResultImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (_BBSDetailWebView.frame.size.height -180)/2, 320, 180)];
    [noResultImgView setBackgroundColor:[UIColor clearColor]];
    [noResultImgView setImage:[UIImage imageNamed:@"notReachable.png"]];
    [_reloadLastMinuteView addSubview:noResultImgView];
    [noResultImgView release];
    
    _screenTapReloadTappp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reloadBBSContent)];
    [self.view addGestureRecognizer:_screenTapReloadTappp];
    [_screenTapReloadTappp setEnabled:NO];
    
    
    [self loadBBSContent];
    
}
/**
 *  初始化Web底部的评论框
 */
-(void)setupBottomCommentBar
{
    _bottomImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0,height_headerview + _BBSDetailWebView.frame.size.height, 320, 54)];
    [_bottomImgView setBackgroundColor:[UIColor clearColor]];
    [_bottomImgView setUserInteractionEnabled:NO];
    [_bottomImgView setImage:[UIImage imageNamed:@"bbs_comment_dock"]];
    [self.view addSubview:_bottomImgView];
    
    
    //评论TXV的背景
    _txvBackImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 231, 34)];
    [_txvBackImgView setBackgroundColor:[UIColor clearColor]];
    _txvBackImgView.userInteractionEnabled = YES;
    [_txvBackImgView setImage:[UIImage imageNamed:@"bbs_comment_txv_Back"]];
    [_bottomImgView addSubview:_txvBackImgView];
    
    
    //评论的Txv
    _commentTextView = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(0, 0, 231, 34)];
    [_commentTextView setReturnKeyType:UIReturnKeyDone];
    [_commentTextView setBackgroundColor:[UIColor clearColor]];
    [_commentTextView setPlaceholder:@"我要回复"];
    [_commentTextView setFont:[UIFont systemFontOfSize:13]];
    [_commentTextView setTextColor:[UIColor colorWithRed:(float)188/255 green:(float)188/255 blue:(float)188/255 alpha:1.0]];
    [_commentTextView setDelegate:self];
    [_commentTextView setReturnKeyType:UIReturnKeyDefault];
    _commentTextView.layer.cornerRadius = 1;
    _commentTextView.layer.masksToBounds = YES;
    [_txvBackImgView addSubview:_commentTextView];
    
    
    
    //发送按钮
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setFrame:CGRectMake(251, 10, 59, 34)];
    [_sendButton setBackgroundColor:[UIColor clearColor]];
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"bbs_comment_send"] forState:UIControlStateNormal];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor colorWithRed:(float)188/255 green:(float)188/255 blue:(float)188/255 alpha:1.0] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor colorWithRed:(float)188/255 green:(float)188/255 blue:(float)188/255 alpha:1.0] forState:UIControlStateHighlighted];
    [_sendButton addTarget:self action:@selector(sendReplyMessage:) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.enabled = NO;
    [_bottomImgView addSubview:_sendButton];
}
/**
 *  初始化回复和翻页按钮
 */
-(void)setupPageAndComment
{
    //翻页按钮
    CGFloat pageButtonW = 74;
    CGFloat pageButtonH = 28;
    CGFloat pageButtonX = [[UIScreen mainScreen] bounds].size.width - 10 - pageButtonW;
    CGFloat pageButtonY = iOS7Adap([[UIScreen mainScreen] bounds].size.height - 10 - pageButtonH);
    _pageButton = [[UIButton alloc] initWithFrame:CGRectMake(pageButtonX, pageButtonY, pageButtonW, pageButtonH)];
    [_pageButton setBackgroundImage:[UIImage imageNamed:@"page"] forState:UIControlStateNormal];
    [_pageButton setBackgroundImage:[UIImage imageNamed:@"press_page"] forState:UIControlStateHighlighted];
    [_pageButton setBackgroundColor:[UIColor clearColor]];
    [_pageButton addTarget:self action:@selector(pageButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_pageButton setTitle:@"1/12" forState:UIControlStateNormal];
    [_pageButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_pageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_pageButton];
    
    
    //回复按钮
    CGFloat commentButtonW = pageButtonW;
    CGFloat commentButtonH = pageButtonH;
    CGFloat commentButtonX = pageButtonX - commentButtonW - 10;
    CGFloat commentButtonY = pageButtonY;
    _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(commentButtonX, commentButtonY, commentButtonW, commentButtonH)];
    [_commentButton setImage:[UIImage imageNamed:@"command"] forState:UIControlStateNormal];
    [_commentButton setImage:[UIImage imageNamed:@"press_command"] forState:UIControlStateHighlighted];
    [_commentButton setBackgroundColor:[UIColor clearColor]];
    [_commentButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_commentButton];
    
    //翻页的TabBar
    CGFloat pageBarW = 320;
    CGFloat pageBarH = 44;
    CGFloat pageBarX = 0;
    CGFloat pageBarY = [[UIScreen mainScreen] bounds].size.height;
    _pageTabBar = [[UIImageView alloc] initWithFrame:CGRectMake(pageBarX, pageBarY, pageBarW, pageBarH)];
    [_pageTabBar setBackgroundColor:[UIColor clearColor]];
    _pageTabBar.userInteractionEnabled = YES;
    [_pageTabBar setImage:[UIImage imageNamed:@"bg_nextpage"]];
    [self.view addSubview:_pageTabBar];
    
    //上一页
    CGFloat previousW = 84;
    CGFloat previousH = 44;
    CGFloat previousX = 0;
    CGFloat previousY = 0;
    UIButton *previousButton = [[UIButton alloc] initWithFrame:CGRectMake(previousX, previousY, previousW, previousH)];
    [previousButton setTitle:@"上一页" forState:UIControlStateNormal];
    [previousButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [previousButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    previousButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    previousButton.backgroundColor = [UIColor clearColor];
    [_pageTabBar addSubview:previousButton];
    [previousButton release];
    
    //中间的page显示标签
    CGFloat pageLableX = previousW;
    CGFloat pageLableY = 0;
    CGFloat pageLableW = 152;
    CGFloat pageLableH = 44;
    _pageLable = [[UILabel alloc] initWithFrame:CGRectMake(pageLableX, pageLableY, pageLableW, pageLableH)];
    _pageLable.backgroundColor = [UIColor clearColor];
    _pageLable.text = @"3/12";
    _pageLable.font = [UIFont systemFontOfSize:15];
    _pageLable.textColor = RGB(44, 170, 122);
    _pageLable.textAlignment = NSTextAlignmentCenter;
    [_pageTabBar addSubview:_pageLable];
    
    
    //下一页
    CGFloat nextW = 84;
    CGFloat nextH = 44;
    CGFloat nextX = [[UIScreen mainScreen] bounds].size.width - 84;
    CGFloat nextY = 0;
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(nextX, nextY, nextW, nextH)];
    [nextButton setTitle:@"下一页" forState:UIControlStateNormal];
    [nextButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    nextButton.backgroundColor = [UIColor clearColor];
    [_pageTabBar addSubview:nextButton];
    [nextButton release];

}

/**
 *  初始化WebView
 */
-(void)setupWebView
{
    CGFloat BBSDatailWebViewX = 0;
    CGFloat BBSDatailWebViewY = height_headerview;
    CGFloat BBSDatailWebViewW = [[UIScreen mainScreen] bounds].size.width;
//    CGFloat BBSDatailWebViewH = [[UIScreen mainScreen] bounds].size.height - height_headerview;
    CGFloat BBSDatailWebViewH = [[UIScreen mainScreen] bounds].size.height - height_headerview - (ios7 ? 54 : 74);
    _BBSDetailWebView = [[UIWebView alloc] initWithFrame:CGRectMake(BBSDatailWebViewX, BBSDatailWebViewY, BBSDatailWebViewW, BBSDatailWebViewH)];
    
    _BBSDetailWebView.delegate = self;
    _BBSDetailWebView.scrollView.delegate = self;
    _BBSDetailWebView.scalesPageToFit = YES;
    _BBSDetailWebView.backgroundColor = [UIColor clearColor];
    _BBSDetailWebView.scrollView.decelerationRate = 5.0;
    [self.view addSubview:_BBSDetailWebView];
}
/**
 *  初始化导航栏
 */
-(void)setupNavgationBar
{
    float height_naviViewHeight = (ios7 ? 20+44 : 44);
    UIView * naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_naviViewHeight)];
    naviView.backgroundColor = [UIColor colorWithRed:(float)43/255 green:(float)171/255 blue:(float)121/255 alpha:1.0];
    [self.view addSubview:naviView];
    [naviView release];

    
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
    
    
    //分享按钮
    CGFloat shareButtonX = 280;
    CGFloat shareButtonY = ios7 ? 22 : 2;
    CGFloat shareButtonW = 40;
    CGFloat shareButtonH = 40;
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setTag:1010101];
    shareButton.backgroundColor = [UIColor clearColor];
    shareButton.frame = CGRectMake(shareButtonX, shareButtonY, shareButtonW, shareButtonH);
    [shareButton setEnabled:NO];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share_Icon"] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share_Icon_Pressed"] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(shareBBs) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:shareButton];
    
    //收藏按钮
    CGFloat collectButtonY = shareButtonY;
    CGFloat collectButtonW = shareButtonW;
    CGFloat collectButtonH = shareButtonH;
    CGFloat collectButtonX = shareButtonX - collectButtonW - 6;
    _collectButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_collectButton setBackgroundColor:[UIColor clearColor]];
    [_collectButton setFrame:CGRectMake(collectButtonX, collectButtonY, collectButtonW, collectButtonH)];
    [_collectButton setBackgroundImage:[UIImage imageNamed:@"star_uncheck"] forState:UIControlStateNormal];
    [_collectButton setBackgroundImage:[UIImage imageNamed:@"star_checked"] forState:UIControlStateSelected];
    _collectButton.enabled = NO;
    [_collectButton addTarget:self action:@selector(collectBBS:) forControlEvents:UIControlEventTouchUpInside];
    //type == 1 标志着是从我的收藏进入的帖子，应该直接显示为已收藏的状态
    if ([self.source isEqualToString:@"MyPostsViewController"]) {
        _collectButton.selected = YES;
        _collectButton.enabled = YES;
    }

    [naviView addSubview:_collectButton];
    
    //只看楼主按钮
    CGFloat onlyPosterButtonY = collectButtonY + 10;
    CGFloat onlyPosterButtonW = 50;
    CGFloat onlyPosterButtonH = 21;
    CGFloat onlyPosterButtonX = collectButtonX - onlyPosterButtonW - 16;
    _onlyPosterButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_onlyPosterButton setBackgroundColor:[UIColor clearColor]];
    [_onlyPosterButton setFrame:CGRectMake(onlyPosterButtonX, onlyPosterButtonY, onlyPosterButtonW, onlyPosterButtonH)];
    [_onlyPosterButton setBackgroundImage:[UIImage imageNamed:@"BBS_cancel_view_lz"] forState:UIControlStateNormal];
    [_onlyPosterButton setBackgroundImage:[UIImage imageNamed:@"BBS_view_lz"] forState:UIControlStateSelected];
    [_onlyPosterButton setEnabled:NO];
    [_onlyPosterButton addTarget:self action:@selector(showOnlyPoster:) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:_onlyPosterButton];
    
    //默认只看楼主为NO
    _isOnlyPoster = NO;

}

-(void)loadBBSContent
{
    _didLoadBBSDetail = NO;//默认未加载成功帖子详情
    
    
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        
        [_reloadLastMinuteView setHidden:NO];
        [_screenTapReloadTappp setEnabled:YES];
        
    }
    else{
        
        [_reloadLastMinuteView setHidden:YES];
        [_screenTapReloadTappp setEnabled:NO];
        
        [_BBSDetailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.bbsAllUserLink] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:16]];
    }
}

-(void)reloadBBSContent
{
    [self.view makeToastActivity];
    [self loadBBSContent];
}


- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    

    
    UIImage * imageeee = [UIImage imageNamed:@"bbs_comment_dock"];
    imageeee = [imageeee stretchableImageWithLeftCapWidth:0 topCapHeight:20];
    [_bottomImgView setImage:imageeee];
    
    
    UIImage * commentBackImg = [UIImage imageNamed:@"bbs_comment_txv_Back"];
    commentBackImg = [commentBackImg stretchableImageWithLeftCapWidth:0 topCapHeight:17];
    [_txvBackImgView setImage:commentBackImg];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.32f];
    [_bottomImgView setFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - kbSize.height -95, 320, 95)];
    [_txvBackImgView setFrame:CGRectMake(10, 10, 231, 75)];
    [_commentTextView setFrame:CGRectMake(0, 0, 231, 75)];
    [UIView commitAnimations];
    
}


- (void)commentButtonClick
{
    [_commentTextView becomeFirstResponder];
}

- (void)pageButtonClick
{
    CGRect pageBarFrame = _pageTabBar.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.32f];
    if (pageBarFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        [_pageTabBar setFrame:CGRectMake(pageBarFrame.origin.x, pageBarFrame.origin.y - 44, pageBarFrame.size.width, pageBarFrame.size.height)];
    }
    [UIView commitAnimations];
}
/**
 *  隐藏翻页工具栏
 */
-(void)hidePageBar
{

    CGRect pageBarFrame = _pageTabBar.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.32f];
    if (pageBarFrame.origin.y < [[UIScreen mainScreen] bounds].size.height) {
        [_pageTabBar setFrame:CGRectMake(pageBarFrame.origin.x, pageBarFrame.origin.y + 44, pageBarFrame.size.width, pageBarFrame.size.height)];
    }
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIImage * imageeee = [UIImage imageNamed:@"bbs_comment_dock"];
    [_bottomImgView setImage:imageeee];
    
    UIImage * commentBackImg = [UIImage imageNamed:@"bbs_comment_txv_Back"];
    [_txvBackImgView setImage:commentBackImg];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.32f];
    [_bottomImgView setFrame:CGRectMake(0,height_headerview + _BBSDetailWebView.frame.size.height, 320, 54)];
    [_txvBackImgView setFrame:CGRectMake(10, 10, 231, 34)];
    [_commentTextView setFrame:CGRectMake(0, 0, 231, 34)];
    [UIView commitAnimations];
}


- (void)keyboardWasChange:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    
    _keyBoradOrigin = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    //键盘在底部
    if (_keyBoradOrigin == [UIScreen mainScreen].bounds.size.height) {
        
        [_commentTextView setText:@""];
    }
}

//-(void)textViewDidBeginEditing:(UITextView *)textView
//{
//}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    BOOL isLogIn = [[[NSUserDefaults standardUserDefaults]objectForKey:@"qyerlogin"] boolValue];
    
    if (isLogIn) {
        return YES;
    }
    else{
        
        //未登录状态用户提示登录
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [self presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
        
        return NO;
    }
    
    return YES;
}


-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"bbs_comment_send"] forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor colorWithRed:(float)188/255 green:(float)188/255 blue:(float)188/255 alpha:1.0] forState:UIControlStateNormal];
        [_sendButton setEnabled:NO];
    }
    else{
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"bbs_comment_send_hl"] forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setEnabled:YES];
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_BBSDetailWebView.scrollView]) {
        if (_keyBoradOrigin < [UIScreen mainScreen].bounds.size.height) {
            [_commentTextView resignFirstResponder];
        }
        [self hidePageBar];
    }
}



//点击只看楼主/查看全部按钮
-(void)showOnlyPoster:(id)sender
{
    _isOnlyPoster = !_isOnlyPoster;
    
    [_commentTextView resignFirstResponder];
    [_commentTextView setText:@""];
    
    if (_isOnlyPoster) {
        
        [self.view makeToast:@"只看楼主" duration:0.8f position:@"center" isShadow:NO];
        [_onlyPosterButton setSelected:YES];
        
        [self performSelector:@selector(loadOnlyPoster) withObject:nil afterDelay:1.0f];
    }
    else{
        [self.view makeToast:@"查看全部" duration:0.8f position:@"center" isShadow:NO];
        [_onlyPosterButton setSelected:NO];
        
        [self performSelector:@selector(loadAllFloor) withObject:nil afterDelay:1.0f];
    }
}

-(void)loadOnlyPoster
{
    [_BBSDetailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.bbsAuthorLink] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:16]];
}

-(void)loadAllFloor
{
    [_BBSDetailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.bbsAllUserLink] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:16]];
}


-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view makeToastActivity];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_BBSDetailWebView stopLoading];
    
    [self.view hideToastActivity];
    
    if (_didLoadBBSDetail == NO) {
        [_reloadLastMinuteView setHidden:NO];
        [_screenTapReloadTappp setEnabled:YES];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view hideToastActivity];
    _collectButton.enabled = YES;
    if (_didLoadBBSDetail == NO) {
        [_bottomImgView setUserInteractionEnabled:YES];
        
        self.threadTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        NSString * authoronly = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('authoronly')[0].innerHTML"];
        
        //截取链接的字段
        if ([authoronly componentsSeparatedByString:@"&amp;"].count >=2) {
            authoronly = [NSString stringWithFormat:@"%@&%@",[[authoronly componentsSeparatedByString:@"&amp;"] objectAtIndex:0],[[authoronly componentsSeparatedByString:@"&amp;"] objectAtIndex:1]];
            self.bbsAuthorLink = authoronly;
            
            _threadID = [[[[[authoronly componentsSeparatedByString:@"&"] objectAtIndex:0]componentsSeparatedByString:@"tid="]objectAtIndex:1] integerValue];
        }
        
        if ([self.bbsAuthorLink isKindOfClass:[NSString class]] && self.bbsAuthorLink.length >0) {
            [_onlyPosterButton setEnabled:YES];
            
            UIButton * shareButton = (UIButton *)[self.view viewWithTag:1010101];
            [shareButton setEnabled:YES];
        }
        
        self.tid = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('tid')[0].innerHTML"];
        self.fid = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('fid')[0].innerHTML"];
        BOOL isLogIn = [[[NSUserDefaults standardUserDefaults]objectForKey:@"qyerlogin"] boolValue];
        if (isLogIn) {//在登陆状态 获取帖子的收藏数据
            
            [[QYAPIClient sharedAPIClient] getBBSCollectStateWithOauthToken:self.token tid:self.tid source:self.source success:^(NSDictionary *dic) {
                _collectButton.selected = [[[dic objectForKey:@"data"] objectForKey:@"result"] intValue];
            } failed:^{
                
            }];
        }else{
            //不在登录状态也要请求服务器，为了统计source字段数据
            [[QYAPIClient sharedAPIClient] getBBSCollectStateWithOauthToken:@"" tid:self.tid source:self.source success:^(NSDictionary *dic) {
                
            } failed:^{
                
            }];
        }
    }
    _didLoadBBSDetail = YES;
    
    
    //推送相关:(04/09)
    if(!self.bbsAuthorLink)
    {
        NSString *authoronly = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('authoronly')[0].innerHTML"];
        self.bbsAuthorLink = authoronly;
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [_commentTextView resignFirstResponder];
    
    NSString * urlString = [NSString stringWithFormat:@"%@",request.URL];
    
    //点击帖子的图片
    if ([urlString hasPrefix:@"http://pic.qyer.com"]) {
        
        [_bigPicImgView setHidden:NO];
        [_activityIndicator startAnimating];
        
        if (ios7) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
        
        [_bigPicImgView setImageWithURL:[NSURL URLWithString:urlString] success:^(UIImage *image) {
            [_activityIndicator stopAnimating];
        } failure:^(NSError *error) {
            [_activityIndicator stopAnimating];
        }];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [_bigPicImgView setAlpha:1.0];
        [UIView commitAnimations];
        
        return NO;
    }
    
    //点击帖子的翻页,只看楼主/查看全部,回复
    if ([urlString hasPrefix:@"http://appview.qyer.com/bbs"]) {
        
        //点击回复
        if ([urlString hasSuffix:@"#reply"]) {
            
            NSString * lasttt = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
            NSString * infoooo = [[lasttt componentsSeparatedByString:@"#"]objectAtIndex:0];
            
            NSArray * arrayyyy = [infoooo componentsSeparatedByString:@"&"];
            
            _threadUserID = [[[[arrayyyy objectAtIndex:0]componentsSeparatedByString:@"="]objectAtIndex:1] integerValue];
            _floorID =  [[[[arrayyyy objectAtIndex:1]componentsSeparatedByString:@"="]objectAtIndex:1] integerValue];
            
            _threadID = [[[[arrayyyy objectAtIndex:2]componentsSeparatedByString:@"="]objectAtIndex:1] integerValue];
            
            self._threadUserName =  [[[arrayyyy objectAtIndex:3]componentsSeparatedByString:@"="]objectAtIndex:1];
            _floorIndex =  [[[[arrayyyy objectAtIndex:4]componentsSeparatedByString:@"="]objectAtIndex:1] integerValue];
            
            self._threadUserName = [NSString stringWithString:[_threadUserName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            
            [_commentTextView setText:[NSString stringWithFormat:@"回复 %d# %@\n",_floorIndex,self._threadUserName]];
            [_commentTextView becomeFirstResponder];
            
            return NO;
        }
        
        //        if ([urlString componentsSeparatedByString:@"?"].count > 0) {
        //            NSString * infooo = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
        //
        //            NSString * uid = [[infooo componentsSeparatedByString:@"&"] objectAtIndex:0];//帖子的用户名
        //            NSString * pid = [[infooo componentsSeparatedByString:@"&"] objectAtIndex:1];//帖子在数据库的ID
        //
        //            NSLog(@"-----%@-----%@------",uid,pid);
        //        }
        
        return YES;
    }
    
    //推广广告
    if ([urlString hasPrefix:@"http://ad.qyer.com"]) {
        return YES;
    }
    
    //推送(04/09添加):
    if([urlString rangeOfString:@"http://m.qyer.com/bbs/thread"].location != NSNotFound || [urlString rangeOfString:@"http://appview.qyer.com/bbs/thread"].location != NSNotFound)
    {
        return YES;
    }
    
    if ([urlString hasPrefix:@"http://appview.qyer.com/u/"]) {
        NSString * strrr = [[urlString componentsSeparatedByString:@"/u/"] objectAtIndex:1];
        NSString * UID = [[strrr componentsSeparatedByString:@"#"] objectAtIndex:0];
     
        MineViewController *mineVC = [[MineViewController alloc] init];
        mineVC.user_id = [UID integerValue];
        [self.navigationController pushViewController:mineVC animated:YES];
        [mineVC release];
    }
    
    else if ([urlString hasPrefix:@"http:"] && ![urlString hasPrefix:@"http://appview.qyer.com/u/"] ) {
        
        WebViewViewController *  webVC = [[WebViewViewController alloc] init] ;
        [webVC setStartURL:urlString];
        [self presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:nil];
        [webVC release];
        return NO;
    }
    
    return NO;
}

-(void)tapBigPic:(UIGestureRecognizer *)tappp
{
    if (tappp.state == UIGestureRecognizerStateEnded) {
        
        [_activityIndicator stopAnimating];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [_bigPicImgView setAlpha:0.0];
        [UIView setAnimationDidStopSelector:@selector(hideBigPic)];
        [UIView commitAnimations];
        
    }
}

-(void)hideBigPic
{
    [_bigPicImgView setHidden:YES];
    [_bigPicImgView setImageWithURL:nil];
}


//点击发送键
-(void)sendReplyMessage:(id)sender
{
    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];
    
    //输入框内容
    NSString * commentTex = _commentTextView.text;
    
    [_commentTextView resignFirstResponder];
    
    //回复楼层
    if ([commentTex hasPrefix:[NSString stringWithFormat:@"回复 %d# %@\n",_floorIndex,self._threadUserName]]) {
        
        NSLog(@">>>>>>>>>>>>>>>>>>>回复楼层<<<<<<<<<<<<<<<<<<<<<<");
        
        [self.view makeToastActivity];
        
        [[QYAPIClient sharedAPIClient]sendThreadWithThreadID:[NSString stringWithFormat:@"%d",_threadID]
                                                     Message:commentTex
                                                     floorID:[NSString stringWithFormat:@"%d",_floorID]
                                                      userID:[NSString stringWithFormat:@"%d",_threadUserID]
                                                  floorIndex:[NSString stringWithFormat:@"%d",_floorIndex]
                                                  OAuthToken:token
                                                     success:^(NSDictionary *dic) {
                                                         
                                                         NSDictionary * dicttttt = [dic objectForKey:@"data"];
                                                         
                                                         [self.view hideToastActivity];
                                                         [self.view makeToast:[dicttttt objectForKey:@"msg"] duration:1.0f position:@"center" isShadow:NO];
                                                         
                                                         NSString * urlll = [NSString stringWithFormat:@"%@",[dicttttt objectForKey:@"url"]];
                                                         
                                                         if (![urlll isEqualToString:@""] && urlll.length >0) {
                                                             [_BBSDetailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlll]cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:16]];
                                                         }
                                                         
                                                     } failure:^{
                                                         
                                                         [self.view hideToastActivity];
                                                         [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.0f position:@"center" isShadow:NO];
                                                     }];
    }
    
    //回复帖子
    else{
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<回复帖子>>>>>>>>>>>>>>>>>>>>>>>>");
        
        [_commentTextView resignFirstResponder];
        
        [self.view makeToastActivity];
        
        NSString * newMessage = [[commentTex componentsSeparatedByString:[NSString stringWithFormat:@"%@",self._threadUserName]]lastObject];
        
        [[QYAPIClient sharedAPIClient]sendThreadWithThreadID:[NSString stringWithFormat:@"%d",_threadID]
                                                     Message:newMessage
                                                     floorID:@""
                                                      userID:@""
                                                  floorIndex:@""
                                                  OAuthToken:token
                                                     success:^(NSDictionary *dic) {
                                                         
                                                         NSDictionary * dicttttt = [dic objectForKey:@"data"];
                                                         
                                                         [self.view hideToastActivity];
                                                         [self.view makeToast:[dicttttt objectForKey:@"msg"] duration:1.0f position:@"center" isShadow:NO];
                                                         
                                                         NSString * urlll = [NSString stringWithFormat:@"%@",[dicttttt objectForKey:@"url"]];
                                                         
                                                         if (![urlll isEqualToString:@""] && urlll.length >0) {
                                                             [_BBSDetailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlll]cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:16]];
                                                         }
                                                         
                                                     } failure:^{
                                                         
                                                         [self.view hideToastActivity];
                                                         [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.0f position:@"center" isShadow:NO];
                                                     }];
    }
    
}

#pragma mark-
#pragma mark-----收藏游记
//收藏游记
-(void)collectBBS:(id)collectButton
{
    BOOL isLogIn = [[[NSUserDefaults standardUserDefaults]objectForKey:@"qyerlogin"] boolValue];
    
    
    if (!isLogIn) {
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [self presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
    }
    NSString *oper = _collectButton.selected ? @"unfav" : @"fav";
    isLogIn = [[[NSUserDefaults standardUserDefaults]objectForKey:@"qyerlogin"] boolValue];
    if (isLogIn) {
        _collectButton.enabled = NO;
        
        [[QYAPIClient sharedAPIClient] postBBSCollectStateWithOauthToken:self.token tid:self.tid fid:self.fid oper:oper success:^(NSDictionary *dic) {
            
            int result = [[[dic objectForKey:@"data"] objectForKey:@"result"] intValue];
            if (result) {//成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    _collectButton.selected = !_collectButton.selected;
                    if (_collectButton.selected) {
                        [self.view makeToast:@"收藏成功" duration:1.0 position:@"center" isShadow:YES];
                    }else{
                        [self.view makeToast:@"取消收藏成功" duration:1.0 position:@"center" isShadow:YES];
                    }
                });
            }
            _collectButton.enabled = YES;
        } failed:^{
            NSLog(@"失败了");
            _collectButton.enabled = YES;
        }];
    }
    
    
//    _isCollect = !_isCollect;
    
//    if (_isCollect) {
//        
//        [self.view makeToast:@"已收藏" duration:0.8f position:@"center" isShadow:NO];
//        [_collectButton setSelected:YES];
//        
////        [self performSelector:@selector(loadOnlyPoster) withObject:nil afterDelay:1.0f];
//    }
//    else{
//        [self.view makeToast:@"已取消收藏" duration:0.8f position:@"center" isShadow:NO];
//        [_collectButton setSelected:NO];
//        
////        [self performSelector:@selector(loadAllFloor) withObject:nil afterDelay:1.0f];
//    }

}


//分享游记
-(void)shareBBs
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

#pragma mark --- 分享
-(void)youjianfenxiang
{
    NSRange rangee = [self.bbsAllUserLink rangeOfString:@"bbs"];
    
    if (rangee.length > 0) {
        
        NSString * threadlink = [NSString stringWithFormat:@"http://bbs.qyer.com%@?campaign=app_share_qy&category=yj_mail",[[self.bbsAllUserLink componentsSeparatedByString:@"bbs"]objectAtIndex:1]];
        
        [[QyerSns sharedQyerSns] shareToMailWithMailTitle:[NSString stringWithFormat:@"Hi，我在#穷游APP#里发现一篇很赞的游记【%@】",self.threadTitle] andMailInfo:[NSString stringWithFormat:@"Hi~\n\t我在#穷游APP#里发现一篇很赞的游记【%@】\n\t看得我心里各种长草。好东西要和好盆友一起分享，进来看看吧→_→ %@",self.threadTitle,threadlink] andImage: [UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
        
        NSLog(@"\n\n%@\n\n-----------------",threadlink);
    }
    
    else{
        [[QyerSns sharedQyerSns] shareToMailWithMailTitle:@"Hi~我发现了一个出境游的APP#穷游#，你也来下载吧！" andMailInfo:[NSString stringWithFormat:@"Hi~\n\t我在#穷游APP#里发现一篇很赞的游记【%@】\n\n\t关于出境游，这一切，尽在穷游。\n\t只需免费下载穷游APP，你就进入了穷游的世界，这里不仅有准确的指南和给力的折扣，这里还有由经验丰富的穷游网友所组成的社区，通过问答和发帖，大家可以彼此互助。从此，你将永远不会独行，伴随你旅行始终的，将是穷游和穷游的几千万新老朋友。\n\n\t有了穷游APP，你就放心出行吧。\n\n\t穷游，陪你体验整个世界的精彩。\n\n\t扫描二维码即可轻松下载！",self.threadTitle] andImage: [UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
    }
    
    
    
}


-(void)sendmessage
{
    //包含问号
    NSRange rangee = [self.bbsAllUserLink rangeOfString:@"bbs"];
    
    
    if (rangee.length > 0) {
        
        NSString * threadlink = [NSString stringWithFormat:@"http://bbs.qyer.com%@?campaign=app_share_qy&category=yj_ios_message",[[self.bbsAllUserLink componentsSeparatedByString:@"bbs"]objectAtIndex:1]];
        
        NSString * aaaa = [NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→ %@",self.threadTitle,threadlink];
        
        [[QyerSns sharedQyerSns] shareWithShortMessage:aaaa inViewController:self];
    }
    else{
        
        NSString * link = [self.bbsAllUserLink stringByReplacingOccurrencesOfString:@"appview" withString:@"m"];
        link = [NSMutableString stringWithFormat:@"%@?campaign=app_share_qy&category=yj_ios_message",link];
        NSString * aaaa = [NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→ %@",self.threadTitle,link];
        
        [[QyerSns sharedQyerSns] shareWithShortMessage:aaaa inViewController:self];
    }
    
}

-(void)shareToWeixinFriend
{
    //包含问号
    NSRange rangee = [self.bbsAllUserLink rangeOfString:@"bbs"];
    if (rangee.length > 0) {
        
        NSString * threadlink = [NSString stringWithFormat:@"http://bbs.qyer.com%@?campaign=app_share_qy&category=yj_weixin",[[self.bbsAllUserLink componentsSeparatedByString:@"bbs"]objectAtIndex:1]];
        
        NSString * aaaa = [NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→ %@",self.threadTitle,threadlink];
        
        [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:aaaa andImage:[UIImage imageNamed:@"120icon"] andUrl:threadlink];
    }
    
    else{
        
        NSString * link = [self.bbsAllUserLink stringByReplacingOccurrencesOfString:@"appview" withString:@"m"];
        
        link = [NSMutableString stringWithFormat:@"%@?campaign=app_share_qy&category=yj_weixin",link];
        
        NSString * aaaa = [NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→ %@",self.threadTitle,link];
        [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:aaaa andImage:[UIImage imageNamed:@"120icon"] andUrl:link];
    }
    
}

-(void)shareToWeixinFriendCircle
{
    NSLog(@"-----%@------",self.bbsAllUserLink);
    
    //包含问号
    NSRange rangee = [self.bbsAllUserLink rangeOfString:@"bbs"];
    if (rangee.length > 0) {
        
        NSString * threadlink = [NSString stringWithFormat:@"http://bbs.qyer.com%@?campaign=app_share_qy&category=yj_pyq",[[self.bbsAllUserLink componentsSeparatedByString:@"bbs"]objectAtIndex:1]];
        
        [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:[NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→",self.threadTitle] andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:threadlink];
    }
    
    else{
        NSString * link = [self.bbsAllUserLink stringByReplacingOccurrencesOfString:@"appview" withString:@"m"];
        
        link = [NSMutableString stringWithFormat:@"%@?campaign=app_share_qy&category=yj_pyq",link];
     
        [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:[NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→",self.threadTitle] andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:link];
    }
    
}

-(void)shareToSinaWeibo
{
    //包含问号
    NSRange rangee = [self.bbsAllUserLink rangeOfString:@"bbs"];
    
    if (rangee.length > 0) {
        
        NSString * threadlink = [NSString stringWithFormat:@"http://bbs.qyer.com%@?campaign=app_share_qy&category=yj_ios_weibo",[[self.bbsAllUserLink componentsSeparatedByString:@"bbs"]objectAtIndex:1]];
        
        NSString * aaaa = [NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→ %@",self.threadTitle,threadlink];
        
        [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:aaaa andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
    }
    
    else{
        
        NSString * link = [self.bbsAllUserLink stringByReplacingOccurrencesOfString:@"appview" withString:@"m"];
        link = [NSMutableString stringWithFormat:@"%@?campaign=app_share_qy&category=yj_ios_weibo",link];
        
        NSString * aaaa = [NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→ %@",self.threadTitle,link];
        
        [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:aaaa andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
    }
    
}

-(void)shareToTencentWeibo
{
    NSRange rangee = [self.bbsAllUserLink rangeOfString:@"bbs"];
    if (rangee.length > 0) {
       
        NSString * threadlink = [NSString stringWithFormat:@"http://bbs.qyer.com%@?campaign=app_share_qy&category=yj_ios_weibo",[[self.bbsAllUserLink componentsSeparatedByString:@"bbs"]objectAtIndex:1]];
        
        NSString * aaaa = [NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→ %@",self.threadTitle,threadlink];
        
        [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:aaaa andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
    }
    
    else{
        NSString * link = [self.bbsAllUserLink stringByReplacingOccurrencesOfString:@"appview" withString:@"m"];
        
        link = [NSMutableString stringWithFormat:@"%@?campaign=app_share_qy&category=yj_ios_qzone",link];
        
        NSString * aaaa = [NSString stringWithFormat:@"在#穷游APP#里发现一篇很赞的游记【%@】，看得我心里各种长草。分享一下，喜欢的都进来看→_→ %@",self.threadTitle,link];
        
        [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:aaaa andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
    }
}


- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_BBSDetailWebView);
    QY_SAFE_RELEASE(_bbsAllUserLink);
    QY_SAFE_RELEASE(_bbsAuthorLink);
    //    QY_SAFE_RELEASE(_threadUserName);
    //    QY_SAFE_RELEASE(_threadUserID)
    //    QY_SAFE_RELEASE(_floorID);
    //    QY_SAFE_RELEASE(_floorIndex);
    
    QY_VIEW_RELEASE(_bigPicImgView);
    QY_VIEW_RELEASE(_activityIndicator);
    
    QY_VIEW_RELEASE(_reloadLastMinuteView);
    QY_SAFE_RELEASE(_screenTapReloadTappp);
    QY_VIEW_RELEASE(_pageButton);
    QY_VIEW_RELEASE(_pageTabBar);
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end