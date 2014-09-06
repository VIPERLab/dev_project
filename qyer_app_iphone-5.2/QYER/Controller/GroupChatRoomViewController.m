//
//  GroupChatRoomViewController.m
//  QYER
//
//  Created by Leno on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GroupChatRoomViewController.h"

#import "QYAPIClient.h"
#import "BlackBoardCell.h"

#import "Toast+UIView.h"

#import "GroupMembersViewController.h"

#import "Message.h"
#import "QYIMObject.h"
#import "NSDateUtil.h"
#import "UserInfo.h"

#import "OtherMessage.h"
#import "LocalData.h"

#define     height_headerview           (ios7 ? (44+20) : 44)

static NSInteger kBlackBoardTableTag = 1001;

@interface GroupChatRoomViewController ()

@end

@implementation GroupChatRoomViewController

@synthesize roomInfoDictionary = _roomInfoDictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        NSDictionary *dict = [[NSDictionary alloc]init];
        self.roomInfoDictionary = dict;
        [dict release];
    }
    return self;
}

- (void)viewDidLoad
{
    self.chatType = ChatTypePublic;
    
    [self initRootView];
    
    [self.view setMultipleTouchEnabled:NO];
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBlockboardData:) name:@"BlockboardData" object:nil];
    
    /**
     *  如果没有网络，直接退出聊天室。
     */
    if (isNotReachable) {
        
        [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboard:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboard:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [QYIMObject getInstance].publicChatTopicId = self.topicId;
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
    naviView.tag = 10001;
    [self.view addSubview:naviView];
    [naviView release];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 240, 20)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(50, 12+20, 220, 20);
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = [NSString stringWithFormat:@"%@身边人", self.roomInfoDictionary[@"chatroom_name"]];
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
    
    
    //查看身边人的按钮
    UIButton * checkPeopleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkPeopleBtn.backgroundColor = [UIColor clearColor];
    checkPeopleBtn.frame = CGRectMake(280, 2, 40, 40);
    if(ios7)
    {
        checkPeopleBtn.frame = CGRectMake(280, 2+20, 40, 40);
    }
    [checkPeopleBtn setBackgroundImage:[UIImage imageNamed:@"nearUserIcon"] forState:UIControlStateNormal];
    [checkPeopleBtn addTarget:self action:@selector(checkPeopleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:checkPeopleBtn];
    
 
    _switchScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, [[UIScreen mainScreen] bounds].size.height -height_headerview )];
    [_switchScrollView setPagingEnabled:YES];
    [_switchScrollView setBounces:NO];
    [_switchScrollView setScrollEnabled:NO];
    [_switchScrollView setDelegate:self];
    [_switchScrollView setContentSize:CGSizeMake(640, _switchScrollView.frame.size.height)];
    [_switchScrollView setBackgroundColor:[UIColor clearColor]];
    [_switchScrollView setShowsHorizontalScrollIndicator:NO];
    [_switchScrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_switchScrollView];
    
    
    _topSwitchImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, height_naviViewHeight, 320, 40)];
    [_topSwitchImgView setBackgroundColor:RGB(255, 255, 255)];
    [_topSwitchImgView setUserInteractionEnabled:YES];
    [self.view addSubview:_topSwitchImgView];

    
    //最下面的分割线:
    UIView *lineeee = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 0.5)];
    lineeee.backgroundColor = [UIColor colorWithRed:224/255. green:224/255. blue:224/255. alpha:1];
    [_topSwitchImgView addSubview:lineeee];
    [lineeee release];
    
    
    _groupChatBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_groupChatBtn setFrame:CGRectMake(0, 0, 160, 37)];
    [_groupChatBtn setBackgroundColor:[UIColor clearColor]];
    [_groupChatBtn setTitle:@"聊天室" forState:UIControlStateNormal];
    [_groupChatBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_groupChatBtn setTitleColor:RGB(130, 153, 165) forState:UIControlStateNormal];
    [_groupChatBtn setTitleColor:RGB(130, 153, 165) forState:UIControlStateHighlighted];
    [_groupChatBtn setTitleColor:RGB(44, 170,122) forState:UIControlStateSelected];
    [_groupChatBtn setSelected:YES];
    [_groupChatBtn addTarget:self action:@selector(showGroupChat) forControlEvents:UIControlEventTouchUpInside];
    [_topSwitchImgView addSubview:_groupChatBtn];
    
    
    _blackBoardBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_blackBoardBtn setFrame:CGRectMake(160, 0, 160, 37)];
    [_blackBoardBtn setBackgroundColor:[UIColor clearColor]];
    [_blackBoardBtn setTitle:@"小黑板" forState:UIControlStateNormal];
    [_blackBoardBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_blackBoardBtn setTitleColor:RGB(130, 153, 165) forState:UIControlStateNormal];
    [_blackBoardBtn setTitleColor:RGB(130, 153, 165) forState:UIControlStateHighlighted];
    [_blackBoardBtn setTitleColor:RGB(44, 170,122) forState:UIControlStateSelected];
    [_blackBoardBtn addTarget:self action:@selector(showBlackBoard) forControlEvents:UIControlEventTouchUpInside];
    [_topSwitchImgView addSubview:_blackBoardBtn];
    
    
    UIImageView * gapImgView = [[UIImageView alloc]initWithFrame:CGRectMake(159, 10, 1, 15)];
    [gapImgView setBackgroundColor:[UIColor clearColor]];
    [gapImgView setImage:[UIImage imageNamed:@"chat_room_line"]];
    [_topSwitchImgView addSubview:gapImgView];
    [gapImgView release];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 38, 160, 2)];
    [line setTag:505050];
    [line setBackgroundColor:RGB(44, 170,122)];
    [_topSwitchImgView addSubview:line];
    [line release];
    
    
    
    _blackBoardTable = [[UITableView alloc]initWithFrame:CGRectMake(320, 40, 320, _switchScrollView.frame.size.height -40 -44)];
    
    if (ios7) {
        [_blackBoardTable setFrame:CGRectMake(320, 40, 320, _switchScrollView.frame.size.height -40 -44)];
    }
    else{
        [_blackBoardTable setFrame:CGRectMake(320, 40, 320, _switchScrollView.frame.size.height -40 -64)];
    }
    
    _blackBoardTable.tag = kBlackBoardTableTag;
    [_blackBoardTable setBackgroundColor:[UIColor clearColor]];
    [_blackBoardTable setBackgroundView:nil];
    [_blackBoardTable setDelegate:self];
    [_blackBoardTable setDataSource:self];
    [_blackBoardTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_switchScrollView addSubview:_blackBoardTable];
    
    
//    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -20, _blackBoardTable.frame.size.width, 20)];
//    _refreshHeaderView.delegate = self;
//    [_blackBoardTable addSubview:_refreshHeaderView];
//    [_refreshHeaderView refreshLastUpdatedDate];
    
    _refeshControl = [[ODRefreshControl alloc]initInScrollView:_blackBoardTable];
    [_refeshControl addTarget:self action:@selector(dropViewDidBeginRefreshing) forControlEvents:UIControlEventValueChanged];
    _refeshControl.hidden = YES;
    
    
    _refreshMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [_refreshMoreView setHidden:YES];
    _refreshMoreView.backgroundColor = [UIColor clearColor];
    [_blackBoardTable addSubview:_refreshMoreView];
    
    _refreshMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 2, 160, 20)];
    _refreshMoreLabel.backgroundColor = [UIColor clearColor];
    _refreshMoreLabel.textColor = [UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
    _refreshMoreLabel.font = [UIFont systemFontOfSize:17.0f];
    _refreshMoreLabel.text = @"加载列表中...";
    _refreshMoreLabel.textAlignment = NSTextAlignmentCenter;
    [_refreshMoreView addSubview:_refreshMoreLabel];
    
    _activityIndicatior = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatior.frame = CGRectMake(195, (24 - _activityIndicatior.frame.size.height) / 2, _activityIndicatior.frame.size.width, _activityIndicatior.frame.size.height);
    [_refreshMoreView addSubview:_activityIndicatior];
    
    
    UIButton * addMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (ios7) {
        [addMessageBtn setFrame:CGRectMake(320,  _switchScrollView.frame.size.height -44, 320, 44)];
    }
    else{
        [addMessageBtn setFrame:CGRectMake(320,  _switchScrollView.frame.size.height -64, 320, 44)];
    }
    
    [addMessageBtn setBackgroundColor:[UIColor clearColor]];
    [addMessageBtn setBackgroundImage:[UIImage imageNamed:@"BoardAddMessage"] forState:UIControlStateNormal];
    [addMessageBtn setBackgroundImage:[UIImage imageNamed:@"BoardAddMessage_hl"] forState:UIControlStateHighlighted];
    [addMessageBtn addTarget:self action:@selector(addMessage:) forControlEvents:UIControlEventTouchUpInside];
    [_switchScrollView addSubview:addMessageBtn];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _getWallListPageIndex = 1;
    _wallListArray = [[NSMutableArray alloc]init];
    //获取小黑板的列表
    [self getWallList];
    
}

-(void)dropViewDidBeginRefreshing{
    
    if (_refeshControl.hidden == YES) {
        return;
    }

    _getWallListPageIndex = 1;
    [self getWallList];
}



-(void)LoadDataDone
{
    NSLog(@" 下拉刷新 加载完数据");
    if(_refeshControl)
    {
        _isLoadingWallLists = NO;
        
        _refeshControl.hidden = NO;
        [_refeshControl endRefreshing];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    if ([scrollView isEqual:_blackBoardTable]) {
//        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
//    }else{
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//    }
}

//-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
//{
//    _getWallListPageIndex = 1;
//    [self getWallList];
//}
//
//-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
//{
//    return _isLoadingWallLists;
//}
//
//-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
//{
//    return [NSDate date];
//}







/**
 *  insert by yihui
 *  进入群组成员列表
 *  @param btn
 */
-(void)checkPeopleBtnAction:(UIButton *)btn{
    
    [self.view endEditing:YES];
    GroupMembersViewController *memberVc = [[GroupMembersViewController alloc]init];
    memberVc.topicId = self.topicId;
    [self.navigationController pushViewController:memberVc animated:YES];
    [memberVc release];
}


-(void)getWallList
{
    //正在加载
    _isLoadingWallLists = YES;
    
    [self.view hideToast];
    [self.view hideToastActivity];
    
    if (_getWallListPageIndex ==1) {
        [self.view makeToastActivity];
    }
 
    
    [[QYAPIClient sharedAPIClient]getChatRoomWallListWithRoomID:[self.roomInfoDictionary objectForKey:@"chatroom_id"]
                                                           page:_getWallListPageIndex
                                                        success:^(NSDictionary *dic) {
                                                                                                                        
                                                            [self.view hideToastActivity];
                                                            
                                                            _isLoadingWallLists = NO;
                                                            
                                                            NSArray * array = (NSArray *)[dic objectForKey:@"data"];
                                                            //保存缓存
                                                            if (_getWallListPageIndex == 1)
                                                            {                                                                
                                                                [_wallListArray removeAllObjects];
                                                                
                                                                [self LoadDataDone];
                                                                
                                                                NSString * roomID = [self.roomInfoDictionary objectForKey:@"chatroom_id"];
                                                                [[NSUserDefaults standardUserDefaults]setValue:array forKeyPath:[NSString stringWithFormat:@"OffLineWall-%@",roomID]];
                                                            }
    
                                                            [_wallListArray addObjectsFromArray:array];
                                                            
                                                            if (_isAddNewBoard) {
                                                                _isAddNewBoard = NO;
                                                                //显示刚发布的小黑板
                                                                [self showMyPublishBlackBoard:array];
                                                            }
                                                            
                                                            //判断是否可加载更多
                                                            if (_wallListArray.count % 10 == 0 && array.count >0) {
                                                                _canLoadMoreWallLists = YES;
                                                            }
                                                            else{
                                                                _canLoadMoreWallLists = NO;
                                                            }
                                                            
                                                            [_blackBoardTable reloadData];
                                                            
                                                            [_refreshMoreView setFrame:CGRectMake(0, _blackBoardTable.contentSize.height -30, 320, 30)];
                                                            [_refreshMoreView setHidden:YES];
                                                            [_activityIndicatior stopAnimating];
  
                                                        }
                                                         failed:^{
                                                             
                                                             _refeshControl.hidden = NO;
                                                             [_refeshControl endRefreshing];
                                                             
                                                             
                                                             [self.view hideToastActivity];
                                                             
                                                             [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                             
                                                             //显示离线数据
                                                             if (_getWallListPageIndex == 1) {
                                                                 
                                                                 [_wallListArray removeAllObjects];
                                                                 
                                                                 NSString * roomID = [self.roomInfoDictionary objectForKey:@"chatroom_id"];
                                                                 
                                                                 if ([[[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"OffLineWall-%@",roomID]] isKindOfClass:[NSArray class]] && ![[[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"OffLineWall-%@",roomID]] isEqual:[NSNull null]]) {
                                                                     
                                                                     NSArray * array = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"OffLineWall-%@",roomID]];
                                                                     
                                                                     if (array.count > 0) {
                                                                         [_wallListArray addObjectsFromArray:array];
                                                                         [_blackBoardTable reloadData];
                                                                     }
                                                                 }
                                                             }
                                                             
                                                             [_refreshMoreView setHidden:YES];
                                                             [_activityIndicatior stopAnimating];
                                                             
                                                             _isLoadingWallLists = NO;
                                                             
                                                             [self performSelector:@selector(setOption) withObject:nil afterDelay:2.0f];
                                                         }];
}

-(void)setOption
{
    _canLoadMoreWallLists = YES;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag != kBlackBoardTableTag) {
        return 0;
    }
    
    if ([tableView isEqual:_blackBoardTable]) {
        return 20;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag != kBlackBoardTableTag) {
        return nil;
    }

    if ([tableView isEqual:_blackBoardTable]) {
        UIView * viewwww = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)]autorelease];
        return viewwww;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag != kBlackBoardTableTag) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    if ([tableView isEqual:_blackBoardTable]) {
    
        if (_canLoadMoreWallLists == YES) {

            if (indexPath.row == _wallListArray.count -1) {
                return 190 +30;
            }
            else{
                return 190;
            }
        }
        
        
        else{
            return 190;
        }
    }

    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag != kBlackBoardTableTag) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
    if ([tableView isEqual:_blackBoardTable]) {
        return _wallListArray.count;
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag != kBlackBoardTableTag) {
        return [super numberOfSectionsInTableView:tableView];
    }
    
    if ([tableView isEqual:_blackBoardTable]) {
        return 1;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag != kBlackBoardTableTag) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    if ([tableView isEqual:_blackBoardTable]) {
        
        BlackBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideView_Cell"];
        if(cell == nil)
        {
            cell = [[[BlackBoardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideView_Cell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = nil;
        }
        
        if ([_wallListArray count] >0) {
                        
            if ([_wallListArray objectAtIndex:indexPath.row] != nil) {
                
                NSDictionary * dict = (NSDictionary *)[_wallListArray objectAtIndex:indexPath.row];
                
                [cell setCellContentInfo:dict];
            }
        }
        
        return cell;
    }
    
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_blackBoardTable]) {
        NSDictionary * dict = [_wallListArray objectAtIndex:indexPath.row];
        
        _detailIndex = (int)indexPath.row;
        
        BoardDetailViewController * detailVC = [[BoardDetailViewController alloc]init];
        detailVC.wallID = [dict objectForKey:@"wall_id"];
        detailVC.delegate = self;
        if ([[dict objectForKey:@"photo"] isKindOfClass:[NSString class]] && ![[dict objectForKey:@"photo"] isEqualToString:@""]) {
            detailVC.photoURL = [dict objectForKey:@"photo"];
        }
        [self.navigationController pushViewController:detailVC animated:YES];
        [detailVC release];
    }
}

-(void)didDeleteMessageSuccess
{
    _getWallListPageIndex = 1;
    _canLoadMoreWallLists = YES;
    
    [_refreshMoreView setHidden:YES];
    [_activityIndicatior stopAnimating];
    
    [self getWallList];
}

-(void)didAddCommentSuccess
{
    NSDictionary * dict = [_wallListArray objectAtIndex:_detailIndex];

    NSInteger  commentCount= [[dict objectForKey:@"total_comments"]integerValue];//点评数目
    commentCount = commentCount +1;
    
    [dict setValue:[NSString stringWithFormat:@"%d",commentCount] forKey:@"total_comments"];
    
    [_blackBoardTable reloadData];
}


-(void)loadMoreWallLists
{
    _getWallListPageIndex = _getWallListPageIndex +1;
    
    [self getWallList];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_blackBoardTable]) {
        
//        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
        
        if (_canLoadMoreWallLists == YES && _isLoadingWallLists == NO) {
            
            if(_blackBoardTable.contentOffset.y + _blackBoardTable.frame.size.height > _blackBoardTable.contentSize.height - 200)
            {
                _canLoadMoreWallLists = NO;
                
                [_refreshMoreView setHidden:NO];
                [_activityIndicatior startAnimating];
                
                [self loadMoreWallLists];
            }
            
        }
        
        
    }else{
        [super scrollViewDidScroll:scrollView];
    }
    
}





-(void)showGroupChat
{
    [_groupChatBtn setSelected:YES];
    [_blackBoardBtn setSelected:NO];
    
    
    CGRect frame = self.messageInputView.frame;
    frame.origin.x = 0;

    UIView *line = [self.view viewWithTag:505050];
    [line setFrame:CGRectMake(0, 38, 160, 2)];

//    [UIView beginAnimations:@"messageViewHidden" context:nil];
//    [UIView setAnimationDuration:0.3];
//    [UIView commitAnimations];

    [_switchScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    self.messageInputView.frame = frame;
}


-(void)showBlackBoard
{
    [_groupChatBtn setSelected:NO];
    [_blackBoardBtn setSelected:YES];
    
    CGRect frame = self.messageInputView.frame;
    frame.origin.x = -UIWidth;

    UIView *line = [self.view viewWithTag:505050];
    [line setFrame:CGRectMake(160, 38, 160, 2)];

//    [UIView beginAnimations:@"messageViewHidden" context:nil];
//    [UIView setAnimationDuration:0.3];
//    [UIView commitAnimations];
    
    [_switchScrollView setContentOffset:CGPointMake(UIWidth, 0) animated:NO];
    self.messageInputView.frame = frame;
    
    [self.view endEditing:YES];
}


-(void)addMessage:(id)sender
{
    if ([[self.roomInfoDictionary objectForKey:@"chatroom_id"] isKindOfClass:[NSString class]]) {
        AddBoardMessgeViewController * addVC = [[AddBoardMessgeViewController alloc]init];
        addVC.roomNumber = [self.roomInfoDictionary objectForKey:@"chatroom_id"];
        [addVC setDelegate:self];
        [self.navigationController presentViewController:addVC animated:YES completion:nil];
        [addVC release];
    }
  
}

-(void)didAddMessageSuccess:(NSString *)token
{
    _blackBoardToken = [token retain];
    
    _getWallListPageIndex = 1;
    _canLoadMoreWallLists = YES;
    
    [_refreshMoreView setHidden:YES];
    [_activityIndicatior stopAnimating];
    
    _isAddNewBoard = YES;
    [self getWallList];
}

-(void)clickBackButton
{
    [self.view hideToastActivity];

    self.messageInputView.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - JSMessagesView Delegate

- (CGRect)tableViewFrame
{
    CGFloat y = _topSwitchImgView.frame.size.height;
    return CGRectMake(0, y, UIWidth, UIHeight - y - 64);
}

- (UIView*)tableViewSuperView
{
    return _switchScrollView;
}

/**
 *  显示发布的小黑板信息
 *
 *  @param message
 */
- (void)showMyPublishBlackBoard:(NSArray *)array
{
    if (!_blackBoardToken || [_blackBoardToken isEqualToString:@""]) {
        return;
    }
    NSString *token = @"";
    NSDictionary *dict = nil;
    for (NSDictionary *item in array) {
        token = [NSString stringWithFormat:@"%@%@", item[@"title"], item[@"content"]];
        if ([token isEqualToString:_blackBoardToken]) {
            dict = item;    //从返回列表里，找到匹配的小黑板对象
            break;
        }
    }
    
    if (dict) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *imUserId = [userDefault objectForKey:@"userid_im"];
        NSString *username = [userDefault objectForKey:@"username"];
        NSString *avatar = [userDefault objectForKey:@"usericon"];
        
        OtherMessage *oMsg = [[OtherMessage alloc] initWithDictionary:dict];
        oMsg.wid = dict[@"wall_id"];
        
        Message *msg = [[Message alloc] init];
        msg.type = JSBubbleMediaTypeRichText;
        msg.timeSend = [NSDate date].timeIntervalSince1970 * 1000;
        msg.fromUserAvatar = avatar;
        msg.fromUserId = imUserId;
        msg.fromUserName = username;
        msg.otherMessage = oMsg;
        msg.messageId = [NSString stringWithFormat:@"%@-%@-%lld", oMsg.title, oMsg.content, msg.timeSend];
        [self showOtherMessage:[msg toDictionary]];
        
        [oMsg release];
        [msg release];
    }
}

- (void)showOtherMessage:(NSDictionary *)customData
{
    Message *msg = [[Message alloc] initWithDictionary:customData];
    [[LocalData getInstance] insertWithTableName:self.topicId withObject:msg];
    [self.messages addObject:msg];
    [self finishSend];
    [self scrollToBottomAnimated:YES];    
    [msg release];
}

/**
 *  收到小黑板数据，触发的通知
 *
 *  @param notification
 */
- (void)showBlockboardData:(NSNotification*)notification
{
    [self showOtherMessage:notification.userInfo];
}


- (void)queryLocalMessages
{
    [super queryLocalMessages];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    BOOL isJoinTopic = [[userDefault objectForKey:@"Join_Topic"] boolValue];
    if (isJoinTopic) {
        [userDefault setObject:@(NO) forKey:@"Join_Topic"];
        [userDefault synchronize];
        
        [self showTipsText];
    }
}

/**
 *  TIPS
 *
 *  @param notification
 */
- (void)showTipsText
{
    if (self.chatType == ChatTypePrivate) {
        return;
    }
    Message *msg = [[Message alloc] init];
    msg.type = JSBubbleMediaTypeTips;
    NSString *roomName = self.roomInfoDictionary[@"chatroom_name"];
    msg.userName = [NSString stringWithFormat:@"恭喜你已加入%@聊天室\n这里还有%d位同在%@的穷游er\n快和他们打个招呼吧！", roomName, self.roomMemberCount, roomName];
    [self.messages addObject:msg];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
    [msg release];
}

#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    CGRect frame = self.view.bounds;
    frame.size.height = self.view.bounds.size.height - self.messageInputView.frame.size.height - 20;
    self.tableView.frame = frame;
    
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _topSwitchImgView.hidden = YES;
    }];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    self.tableView.frame = [self tableViewFrame];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _topSwitchImgView.hidden = NO;
    }];
}

-(void)dealloc
{
    QY_SAFE_RELEASE(_roomInfoDictionary);
    QY_SAFE_RELEASE(_wallListArray);
    
    QY_VIEW_RELEASE(_blackBoardTable);
//    QY_VIEW_RELEASE(_refreshHeaderView);
    QY_VIEW_RELEASE(_topSwitchImgView);
    QY_VIEW_RELEASE(_blackBoardBtn);
    QY_VIEW_RELEASE(_groupChatBtn);
    QY_VIEW_RELEASE(_switchScrollView);
    QY_VIEW_RELEASE(_blackBoardTable);
    QY_VIEW_RELEASE(_refreshMoreView);
    QY_VIEW_RELEASE(_refreshMoreLabel);
    QY_VIEW_RELEASE(_activityIndicatior);
    
    [_blackBoardToken release];
    _blackBoardToken = nil;
    
    [QYIMObject getInstance].publicChatTopicId = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"聊天室"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick endLogPageView:@"聊天室"];
}



@end
