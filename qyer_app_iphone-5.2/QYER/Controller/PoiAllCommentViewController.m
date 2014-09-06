//
//  PoiAllCommentViewController.m
//  QyGuide
//
//  Created by an qing on 13-2-26.
//
//

#import "PoiAllCommentViewController.h"
#import "PoiCommentCell.h"
#import "DYRateView.h"
#import "PoiRateView.h"
#import "GetMinePoiComment.h"
#import "Toast+UIView.h"
#import <QuartzCore/QuartzCore.h>
#import "CityLoginViewController.h"
#import "MobClick.h"
#import "ChangeTableviewContentInset.h"
#import "GetPoiCommentData.h"
#import "PoiComment.h"




#define     titleLabelX         50
#define     titleLabelWidth     220
#define     titleLabelHeight    (ios7 ? 26 : 34)

#define     toolBarHeight       40
#define     getMoreCellHeight   37


#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (7+20) : 10)
#define     positionY_backbutton        (ios7 ? (3+20) : 3)
#define     positionY_tableView         (ios7 ? (44+20) : 44)






@interface PoiAllCommentViewController ()

@end






@implementation PoiAllCommentViewController
@synthesize navigationTitle = _navigationTitle;
@synthesize allCommentNumberStr = _allCommentNumberStr;
@synthesize poiId;
@synthesize commentId_user;
@synthesize userCommentRate = _userCommentRate;
@synthesize commentId = _commentId;
@synthesize userInstruction = _userInstruction;
@synthesize userCommentRateCopy = _userCommentRateCopy;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hotdot_phone:) name:@"hotdot_phone" object:nil];
        
    }
    return self;
}


-(void)dealloc
{
    QY_SAFE_RELEASE(_navigationTitle);
    QY_SAFE_RELEASE(_user_access_token);
    QY_SAFE_RELEASE(_userInstruction);
    QY_SAFE_RELEASE(_userCommentRate);
    QY_SAFE_RELEASE(_userCommentRateCopy);
    QY_SAFE_RELEASE(_allCommentNumberStr);
    
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableView_poiAllComment);
    QY_VIEW_RELEASE(_rateView);
    QY_VIEW_RELEASE(_poiRateView);
    QY_VIEW_RELEASE(_toolBar);
    QY_VIEW_RELEASE(_footView);
    QY_VIEW_RELEASE(_activityView);
    QY_VIEW_RELEASE(_commentLabel);
    
    QY_MUTABLERECEPTACLE_RELEASE(_poiCommentDataArray);
    QY_MUTABLERECEPTACLE_RELEASE(_userCommentDataArray);
    QY_MUTABLERECEPTACLE_RELEASE(_heightDic);
    
    self.commentId_user = nil;
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- 热点 或 打电话
-(void)hotdot_phone:(NSNotification *)noatification
{
    NSDictionary *info = noatification.userInfo;
    if([[info objectForKey:@"type"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:1];
    }
    else if([[info objectForKey:@"type"] isEqualToString:@"0"])
    {
        [self resetRootViewWIthType:0];
    }
}

-(void)resetRootViewWIthType:(BOOL)flag
{
    if(!flag)
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_poiAllComment.frame;
        newFrame.size.height = [self.view bounds].size.height-toolBarHeight;
        _tableView_poiAllComment.frame = newFrame;
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_poiAllComment.frame;
        newFrame.size.height = [self.view bounds].size.height-toolBarHeight;
        _tableView_poiAllComment.frame = newFrame;
        
    }
    
    [self setToolBarView];
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view hideToast];
    
    
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentDidSuccess) name:@"comment_success" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickcanclecomment) name:@"clickcanclecomment" object:nil];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"from_comment_to_login"] isEqualToString:@"3"]) //取消了登录
    {
        _rateView.rate = 0;
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"from_comment_to_login"] isEqualToString:@"2"]) //登录成功
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self getMinePoiCommentFromServer];
        
    }
    else
    {
        self.commentId = 0;
        if([self.allCommentNumberStr floatValue] - 0. > 0)
        {
            [self getPoiCommentDataIsFreshUserRate:1];
        }
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.view hideToast];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    
    [MobClick event:@"poiReview"];
    
    
    
    [self setRootView];
    [self setNavigationBar];
    [self setToolBarView];
    if([self.allCommentNumberStr floatValue] - 0. > 0)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToastActivity];
        
        [self initTableView];
    }
    else
    {
        isDownloadAllComment = 1;
        [self initDefaultView];
        [self initUserRateView:0];
    }
    
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
    _headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, positionY_titlelabel, titleLabelWidth, titleLabelHeight)];
    //_titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"全部点评";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    
    
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
}
-(void)initDefaultView
{
    [self.view hideToastActivity];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300/2., 274/2.)];
    imageView.center = self.view.center;
    CGRect frame = imageView.frame;
    frame.origin.y = frame.origin.y - 20;
    imageView.frame = frame;
    imageView.backgroundColor = [UIColor clearColor];
    NSString *str =[NSString stringWithFormat:@"%@@2x",@"点评为空icon"];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    imageView.image = image;
    [self.view addSubview:imageView];
    [imageView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height+imageView.frame.origin.y, 320, 20)];
    frame = label.frame;
    frame.origin.y = (int)(frame.origin.y+0.5);
    label.frame = frame;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"当前景点没有点评";
    label.font = [UIFont systemFontOfSize:15.];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0.9;
    [self.view addSubview:label];
    [label release];
}
-(void)setToolBarView
{
    float y = ([self.view bounds].size.height-20)-toolBarHeight;
    if(ios7)
    {
        y = [self.view bounds].size.height-toolBarHeight;
    }
    if(!_toolBar)
    {
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320, toolBarHeight)];
        _toolBar.backgroundColor = [UIColor blackColor];
    }
    else
    {
        CGRect newFrame = _toolBar.frame;
        newFrame.origin.y = y;
        _toolBar.frame = newFrame;
    }
    [self.view addSubview:_toolBar];
    
    [self initCommentLabel];
}
-(void)initCommentLabel
{
    if(!_commentLabel)
    {
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 11, 70, 20)];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.textColor = [UIColor whiteColor];
        _commentLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
        _commentLabel.textAlignment = NSTextAlignmentLeft;
        _commentLabel.font = [UIFont systemFontOfSize:14];
    }
    [_toolBar addSubview:_commentLabel];
}
-(void)initUserRateView:(NSInteger)rate
{
    NSString *str =[NSString stringWithFormat:@"%@@2x",@"绿星"];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    
    str =[NSString stringWithFormat:@"%@@2x",@"灰星"];
    UIImage *hollowImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    
    if(!_rateView)
    {
        _rateView = [[DYRateView alloc] initWithFrame:CGRectMake(80, 6, 160, 26) fullStar:image emptyStar:hollowImage];
    }
    _rateView.isShowRateView = 1;
    _rateView.backgroundColor = [UIColor clearColor];
    _rateView.padding = 15;  //间隔
    _rateView.rate = rate;
    _rateView.alignment = RateViewAlignmentCenter;
    _rateView.editable = YES;
    _rateView.delegate = self;
    [_toolBar addSubview:_rateView];
    
    if(rate == 0)
    {
        _commentLabel.text = @"立即点评:";
    }
    else
    {
        //_commentLabel.text = @"立即点评:";
        _commentLabel.text = @"修改点评:";
    }
    
}
-(void)getPoiCommentDataIsFreshUserRate:(BOOL)flag
{
    if(isDownloadAllComment == 1)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
        view.backgroundColor = [UIColor clearColor];
        _tableView_poiAllComment.tableFooterView = view;
        [view release];
    }
    
    
    //*** 获取poi评论数据
    [self getPoiCommentDataWithFreshUserCommentDataFlag:flag completion:^{
        [self loadView_afterGetDataSuccess_isFresh:flag];
    } failed:^{
        MYLog(@"获取poi评论数据,失败啦!!! ");
        [self loadView_afterGetDataFailed_isFresh:flag];
    }];
}
-(void)loadView_afterGetDataSuccess_isFresh:(BOOL)flag
{
    [self.view hideToastActivity];
    MYLog(@"isDownloadAllComment ------ %d",isDownloadAllComment);
    downloadNewDataFlag = 0;
    
    [self reloadMyTableview];
    
    if(flag == 1)
    {
        [self initUserRateView:[self.userCommentRate intValue]/2];
        _userRate = [self.userCommentRate intValue]/2;
        
    }
}
-(void)loadView_afterGetDataFailed_isFresh:(BOOL)flag
{
    _commentLabel.text = @"立即点评:";
    
    [self.view hideToastActivity];
    
    downloadNewDataFlag = 0;
    if(flag == 1)
    {
        [self initUserRateView:0];
    }
    
    if(_activityView && [_activityView isAnimating])
    {
        [_activityView stopAnimating];
    }
    if(_footView && [_footView viewWithTag:1])
    {
        [(UILabel*)[_footView viewWithTag:1] setText:@"加载更多"];
        CGRect frame = [_footView viewWithTag:1].frame;
        frame.origin.x = 110;
        [_footView viewWithTag:1].frame = frame;
    }
    
    [self.view hideToast];
    [self.view makeToast:@"获取评论失败" duration:1 position:@"center" isShadow:NO];
}



-(void)getPoiCommentDataWithFreshUserCommentDataFlag:(BOOL)flag completion:(void (^)(void))completion failed:(void (^)(void))failed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
        {
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"] && ![_user_access_token isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"]])
            {
                _user_access_token = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"] retain];
            }
        }
        
        
        
        [[GetPoiCommentData sharedGetPoiCommentData] getPoiCommentByClientid:ClientId_QY andClientSecrect:ClientSecret_QY andPoiId:poiId andMax_Id:self.commentId andOauth_token:_user_access_token finished:^(NSArray *array_poiComment, NSArray *array_currentUser){
            
            NSLog(@"  --- 获取poi的评论成功啦～～～");
            [self loadView_afterGetPoiDataSuccessWithFlag:flag
                                            andAllComment:array_poiComment
                                           andUserComment:array_currentUser];
            
            dispatch_async(dispatch_get_main_queue(), completion);
            
        } failed:^{
            
            NSLog(@"  --- 获取poi的评论失败啦～～～");
            [self loadView_afterGetPoiDataFalied];
            dispatch_async(dispatch_get_main_queue(), failed);
            
        }];
    });
}
-(void)loadView_afterGetPoiDataSuccessWithFlag:(BOOL)flag
                                 andAllComment:(NSArray *)array_poiComment
                                andUserComment:(NSArray *)array_currentUser
{
    //***(1) 所有用户的评论列表
    if(!_poiCommentDataArray)
    {
        _poiCommentDataArray = [[NSMutableArray alloc] init];
    }
    if(flag == 1)
    {
        [_poiCommentDataArray removeAllObjects];
    }
    [_poiCommentDataArray addObjectsFromArray:array_poiComment];
    PoiComment *poicommentdata = (PoiComment *)[array_poiComment lastObject];
    self.commentId = [poicommentdata.commentId_user intValue]-1;
    
    
    
    if(_activityView && [_activityView isAnimating])
    {
        [_activityView stopAnimating];
    }
    
    
    if([array_poiComment count] == 0)
    {
        isDownloadAllComment = 1;
        
        [self.view hideToast];
        [self.view makeToast:@"没有更多评论" duration:1. position:@"center" isShadow:NO];
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
        view.backgroundColor = [UIColor clearColor];
        _tableView_poiAllComment.tableFooterView = view;
        [view release];
    }
    else if([array_poiComment count] < 20)
    {
        if([GetPoiCommentData sharedGetPoiCommentData].isDeleteUserCommentFlag == 1)
        {
            isDownloadAllComment = 0;
        }
        else
        {
            isDownloadAllComment = 1;
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
            view.backgroundColor = [UIColor clearColor];
            _tableView_poiAllComment.tableFooterView = view;
            [view release];
        }
    }
    else
    {
        isDownloadAllComment = 0;
        [(UILabel*)[_footView viewWithTag:1] setText:@"加载更多"];
        _tableView_poiAllComment.tableFooterView = _footView;
    }
    
    
    if([_poiCommentDataArray count] == [_allCommentNumberStr intValue])
    {
        isDownloadAllComment = 1;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
        view.backgroundColor = [UIColor clearColor];
        _tableView_poiAllComment.tableFooterView = view;
        [view release];
    }
    
    
    
    
    //***(2) 用户自己的评论
    if(array_currentUser && array_currentUser.count > 0)
    {
        if(!_userCommentDataArray)
        {
            _userCommentDataArray = [[NSMutableArray alloc] init];
        }
        [_userCommentDataArray removeAllObjects];
        [_userCommentDataArray addObjectsFromArray:array_currentUser];
        if(_userCommentDataArray && [_userCommentDataArray count] > 0)
        {
            PoiComment *poicommentdata = (PoiComment *)[_userCommentDataArray objectAtIndex:0];
            self.userCommentRate = poicommentdata.rate_user;
            self.userInstruction = poicommentdata.comment_user;
            self.commentId_user = poicommentdata.commentId_user;
            
            _userCommentRateCopy = [poicommentdata.rate_user retain];
        }
    }
    
}
-(void)loadView_afterGetPoiDataFalied
{
    isDownloadAllComment = 1;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
    view.backgroundColor = [UIColor clearColor];
    _tableView_poiAllComment.tableFooterView = view;
    [view release];
}



-(void)initTableView
{
    if(ios7)
    {
        if(!_tableView_poiAllComment)
        {
            _tableView_poiAllComment = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height-toolBarHeight) style:UITableViewStylePlain];
        }
    }
    else
    {
        if(!_tableView_poiAllComment)
        {
            _tableView_poiAllComment = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([self.view bounds].size.height-20)-toolBarHeight) style:UITableViewStylePlain];
        }
    }
    _tableView_poiAllComment.backgroundColor = [UIColor clearColor];
    _tableView_poiAllComment.separatorColor = [UIColor clearColor];
    _tableView_poiAllComment.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setTableViewFooterView];
    [ChangeTableviewContentInset changeWithTableView:_tableView_poiAllComment];
    [self.view addSubview:_tableView_poiAllComment];
    [self.view bringSubviewToFront:_headView];
    [self.view bringSubviewToFront:_toolBar];
}
-(void)setTableViewFooterView
{
    if(!_footView)
    {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    }
    _footView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(110+20, 5, 100, 27)];
    label.tag = 1;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"加载更多";
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:15.];
    label.textAlignment = NSTextAlignmentCenter;
    if(!_activityView)
    {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    _activityView.backgroundColor = [UIColor clearColor];
    _activityView.center = CGPointMake(label.frame.origin.x, 16.5);
    [_activityView startAnimating];
    [_footView addSubview:_activityView];
    [_footView addSubview:label];
    [label release];
}
-(void)reloadMyTableview
{
    _tableView_poiAllComment.delegate = self;
    _tableView_poiAllComment.dataSource = self;
    [_tableView_poiAllComment reloadData];
}



#pragma mark -
#pragma mark --- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_poiCommentDataArray count] == 0)
    {
        isDownloadAllComment = 1;
        return 0;
    }
    else if([_allCommentNumberStr intValue]-20 <= 0 || isDownloadAllComment == 1)
    {
        isDownloadAllComment = 1;
        return [_poiCommentDataArray count];
    }
    else
    {
        isDownloadAllComment = 0;
        return [_poiCommentDataArray count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [_poiCommentDataArray count])
    {
        return getMoreCellHeight;
    }
    else
    {
        PoiComment *poiComment = [_poiCommentDataArray objectAtIndex:indexPath.row];
        return [PoiCommentCell cellHeightWithContent:poiComment.comment_user];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poicommentcell"];
    if(cell == nil)
    {
        cell = [[[PoiCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"poicommentcell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [self initGuideDetailCell:cell andIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
-(void)initGuideDetailCell:(PoiCommentCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    PoiComment *poiComment = [_poiCommentDataArray objectAtIndex:indexPath.row];
    
    
    //设置cell的内容
    [cell initWithPoiComment:poiComment];
    
    
    //第一个评论的上边框
    if(indexPath.row == 0)
    {
        [cell initTopBorderView];
    }
    else
    {
        [cell removeTopBorderView];
    }
    
    
    //用户评星
    [cell initCommentRateViewByRate:poiComment.rate_user];
    
    
    //每条评论的边框不含上边框
    CGRect frame = cell.bgView.frame;
    [cell initBorderViewWithHeight:frame.size.height-1];
    
    
    //下边框虚线还是实线
    [cell setBottomLabelColor:1];
    if(indexPath.row == [_poiCommentDataArray count]-1)
    {
        [cell setBottomLabelColor:0];
    }
    
    
    //加载更多
    if(downloadNewDataFlag == 0 && isDownloadAllComment == 0 && indexPath.row == [_poiCommentDataArray count]-1)
    {
        if(_activityView)
        {
            [_activityView startAnimating];
        }
        [(UILabel*)[_footView viewWithTag:1] setText:@"正在加载..."];
        downloadNewDataFlag = 1;
        [self performSelector:@selector(getPoiCommentDataIsFreshUserRate:) withObject:0 afterDelay:0.1];
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,9)];
    view.backgroundColor = [UIColor clearColor];
    return [view autorelease];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9;
}


#pragma mark -
#pragma mark --- UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark -
#pragma mark --- DYRateViewDelegate
- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate
{
    //MYLog(@"   changedToNewRate ");
}
- (void)rateView:(DYRateView *)rateView showRateView:(NSNumber *)rate
{
    _userRateWhenTapStar = [rate intValue];
    [self showRateView:rate];
}
-(void)showRateView:(NSNumber *)rate
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"] length] > 0)
    {
        
        //poiReviewAdd
        [MobClick event:@"poiReviewAdd"];
        
        NSInteger positionY = 44;
        if(ios7)
        {
            positionY = positionY + 20;
        }
        _poiRateView = [[PoiRateView alloc] initWithFrame:CGRectMake((320-580/2)/2., positionY, 580/2, 1136/2) andLeftButTitle:@"取消" andRightButTitle:@"发送" andRate:[NSString stringWithFormat:@"%@",rate] andVC:self];
        [_poiRateView setTextViewText:self.userInstruction];
        _poiRateView.poiTitle = self.navigationTitle;
        _poiRateView.poiId = self.poiId;
        _poiRateView.commentId_user = self.commentId_user;
    }
    else
    {
        _commentLabel.text = @"立即点评:";
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"您登录之后才能发表点评"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"立即登录",nil];
        [alertView show];
    }
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex])
    {
        _rateView.rate = 0;
        return;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [self presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
    }
}


#pragma mark -
#pragma mark --- 点评成功
-(void)commentDidSuccess
{
    self.commentId = 0;
    [self getPoiCommentDataIsFreshUserRate:1];
}



#pragma mark -
#pragma mark --- 获取用户自己的点评
-(void)getMinePoiCommentFromServer
{
    [self getMinePoiCommentDataCompletion:^{
        [self getMinePoiCommentDataSuccess];
    } failed:^{
            [self showRateView:[NSNumber numberWithBool:0]];
        _userRate = 0;
    }];
}
-(void)getMinePoiCommentDataCompletion:(void (^)(void))completion failed:(void (^)(void))failed
{
    GetMinePoiComment *_getMineComment = [[GetMinePoiComment alloc] init];
    [_getMineComment getMineCommentByClientid:ClientId_QY andPoiId:self.poiId finished:^{
        
        [self getMineCommentByClientidSuccess:_getMineComment];
        completion();
    } failed:^{
        [self getMineCommentByClientidFailed];
        failed();
    }];
    [_getMineComment release];
}
-(void)getMineCommentByClientidSuccess:(GetMinePoiComment *)_getMineComment
{
    if([_getMineComment.userCommentRate floatValue] - 0. > 0)
    {
        self.userCommentRate = [NSString stringWithFormat:@"%d",_userRateWhenTapStar*2];
        self.userInstruction = _getMineComment.userComment;
        
        MYLog(@"登录成功后，用户的评星:%d",[_getMineComment.userCommentRate intValue]);
        
        if(![_userCommentRateCopy isEqualToString:_getMineComment.userCommentRate])
        {
            _userCommentRateCopy = [_getMineComment.userCommentRate retain];
        }
    }
    else
    {
        self.userCommentRate = [NSString stringWithFormat:@"%d",_userRateWhenTapStar*2];
    }
}
-(void)getMinePoiCommentDataSuccess
{
    [self showRateView:[NSNumber numberWithInteger:[self.userCommentRate intValue]/2]];
    _userRate = [self.userCommentRate intValue]/2;
    _poiRateView.myRate = _userRate;
    
    NSLog(@" self.userCommentRate : %@",self.userCommentRate);
    _commentLabel.text = @"修改点评:";
}
-(void)getMineCommentByClientidFailed
{
    self.userCommentRate = @"0";
    self.userInstruction = @"";
}




#pragma mark -
#pragma mark --- clickcanclecomment
-(void)clickcanclecomment
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES || !self.userInstruction || self.userInstruction.length == 0)
    {
        _rateView.rate = 0;
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        MYLog(@"_userCommentRateCopy ==== %@",_userCommentRateCopy);
        _rateView.rate = [_userCommentRateCopy intValue]/2;
    }
    else
    {
        _rateView.rate = _userRate;
    }
}


#pragma mark -
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
{
    isDownloadAllComment = 0;
    downloadNewDataFlag = 0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getPoiCommentDataIsFreshUserRate:) object:nil];
    
    [[GetPoiCommentData sharedGetPoiCommentData] cancle];
    
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

