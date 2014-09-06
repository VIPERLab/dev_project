//
//  RecomTravelViewController.m
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "RecomTravelViewController.h"

#import "MyItineraryCell.h"
#import "WebViewViewController.h"
#import "PlanData.h"
#import "Plan.h"
#import "Toast+UIView.h"

#import "UsefulGuideController.h"

#import "QYAPIClient.h"

#define reqPageSize @"10"

@interface RecomTravelViewController ()

@end




@implementation RecomTravelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        userPlanListArray = [[NSMutableArray alloc] initWithCapacity:0];//用户精选游记列表
        
        officalPlanListArray = [[NSMutableArray alloc]initWithCapacity:0];//编辑推荐游记列表
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"推荐行程列表"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"推荐行程列表"];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(232, 243, 248);

    _titleLabel.text = @"推荐行程";
    
    
    _userPlanPage = 1;
    _officalPlanPage = 1;
    
    [self queryData];
}



- (void)queryData
{
    if (isNotReachable) {
        [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
        [super setNotReachableView:YES];
        return;
    }else{
        
        [super setNotReachableView:NO];
    }
    
    [self.view makeToastActivity];
    
    [[QYAPIClient sharedAPIClient]getRecommandPlanListByType:_type
                                                          ID:_key
                                                      source:@"user"
                                                        page:@"1"
                                                     success:^(NSDictionary *dic) {
        
                                                         [self.view hideToastActivity];
                                                         [super setNotReachableView:NO];
                                                         
                                                         int statussss = [[dic objectForKey:@"status"]integerValue];
                                                         
                                                         if (statussss == 1) {
                                                             
                                                             NSArray * listArray = (NSArray *)[dic objectForKey:@"data"];
                                                             
                                                             if (listArray.count == 0) {
                                                                 
                                                                 [[QYAPIClient sharedAPIClient]getRecommandPlanListByType:_type ID:_key source:@"editor" page:@"1" success:^(NSDictionary *dic) {
                                                                     
                                                                     [self.view hideToastActivity];
                                                                     int statussss = [[dic objectForKey:@"status"]integerValue];
                                                                     
                                                                     if (statussss == 1) {
                                                                         
                                                                         NSArray * listArray = (NSArray *)[dic objectForKey:@"data"];
                                                                         
                                                                         //没有编辑推荐行程
                                                                         if (listArray.count == 0) {
                                                                             _notDataImageView.hidden = NO;
                                                                             _notDataImageView.image = [UIImage imageNamed:@"not_plan"];
                                                                             [self.view bringSubviewToFront:_notDataImageView];
                                                                         }
                                                                         else{
                                                                             
                                                                             if (listArray.count >= 10) {
                                                                                 _officalPlanPage ++;
                                                                             }
                                                                             
                                                                             [officalPlanListArray addObjectsFromArray:listArray];
                                                                             
                                                                             [self setOnlyEditorPlanListView];
                                                                         }
                                                                     }
                                                                     
                                                                 } failed:^{
                                                                     
                                                                     [self.view hideToastActivity];
                                                                     [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                                     
                                                                     [super setNotReachableView:YES];                                                                 }];
                                                                 
                                                             }else{
                                                                 
                                                                 if (listArray.count >= 10) {
                                                                     _userPlanPage ++;
                                                                 }
                                                                 [userPlanListArray addObjectsFromArray:listArray];
                                                                 
                                                                 [self.view makeToastActivity];
                                                                 
             [[QYAPIClient sharedAPIClient]getRecommandPlanListByType:_type ID:_key source:@"editor" page:@"1" success:^(NSDictionary *dic) {
                 
                 [self.view hideToastActivity];
                 
                 int statussss = [[dic objectForKey:@"status"]integerValue];
                 
                 if (statussss == 1) {
                     
                     NSArray * listArray = (NSArray *)[dic objectForKey:@"data"];
                     
                     //没有编辑推荐行程
                     if (listArray.count == 0) {
                         [self setOnlyUserPlanListView];
                     }
                     else{
                         
                         if (listArray.count >= 10) {
                             _officalPlanPage ++;
                         }
                         
                         [officalPlanListArray addObjectsFromArray:listArray];
                         
                         [self setUserAndEditorPlanListView];
                     }
                 }
                 
             } failed:^{
                 
                 [self setOnlyUserPlanListView];
             }];
                 }
    
             }
                                                         
                                                     } failed:^{
                                                         
                                                         [self.view hideToastActivity];
                                                         [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                         
                                                         [super setNotReachableView:YES];
                                                     }];

}


//显示只有用户推荐行程无编辑推荐行程的View
-(void)setOnlyUserPlanListView
{
    NSLog(@"只有用户行程.........");
    
    userPlanTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, UIHeight - height_need_reduce)];
    userPlanTable.delegate = self;
    userPlanTable.dataSource = self;
    userPlanTable.backgroundColor = [UIColor clearColor];
    userPlanTable.separatorColor = [UIColor clearColor];
    [self.view addSubview:userPlanTable];
    [userPlanTable release];
    
    [self.view sendSubviewToBack:userPlanTable];
    [ChangeTableviewContentInset changeTableView:userPlanTable withOffSet:0];
    
    self.view.backgroundColor = RGB(232, 243, 248);
    
    userPlanTableFootView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    [userPlanTable setTableFooterView:userPlanTableFootView];
    
    if (userPlanListArray.count < [reqPageSize intValue]) {
        userPlanTableFootView.hidden = YES;
    }else{
        userPlanTableFootView.hidden = NO;
    }
    [userPlanTable reloadData];

}

-(void)setOnlyEditorPlanListView
{
    NSLog(@"只有编辑的行程.........");
    
    officalPlanTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, UIHeight - height_need_reduce)];
    officalPlanTable.delegate = self;
    officalPlanTable.dataSource = self;
    officalPlanTable.backgroundColor = [UIColor clearColor];
    officalPlanTable.separatorColor = [UIColor clearColor];
    [self.view addSubview:officalPlanTable];
    [officalPlanTable release];
    
    [self.view sendSubviewToBack:officalPlanTable];
    [ChangeTableviewContentInset changeTableView:officalPlanTable withOffSet:0];
    
    self.view.backgroundColor = RGB(232, 243, 248);
    
    officalPlanTableFootView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    [officalPlanTable setTableFooterView:officalPlanTableFootView];
    
    if (officalPlanListArray.count < [reqPageSize intValue]) {
        officalPlanTableFootView.hidden = YES;
    }else{
        officalPlanTableFootView.hidden = NO;
    }
    [officalPlanTable reloadData];
}



//显示有用户推荐行程和编辑推荐行程的View
-(void)setUserAndEditorPlanListView
{
    NSLog(@"有用户及编辑推荐行程.........");

    UIImageView * topSwitchImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, 40)];
    [topSwitchImgView setBackgroundColor:RGB(255, 255, 255)];
    [topSwitchImgView setUserInteractionEnabled:YES];
    [self.view addSubview:topSwitchImgView];
    
    //最下面的分割线:
    UIView *lineeee = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 0.5)];
    lineeee.backgroundColor = [UIColor colorWithRed:224/255. green:224/255. blue:224/255. alpha:1];
    [topSwitchImgView addSubview:lineeee];
    [lineeee release];
    
    _officalPlanBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_officalPlanBtn setFrame:CGRectMake(0, 0, 160, 37)];
    [_officalPlanBtn setBackgroundColor:[UIColor clearColor]];
    [_officalPlanBtn setTitle:@"编辑推荐" forState:UIControlStateNormal];
    [_officalPlanBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_officalPlanBtn setTitleColor:RGB(130, 153, 165) forState:UIControlStateNormal];
    [_officalPlanBtn setTitleColor:RGB(130, 153, 165) forState:UIControlStateHighlighted];
    [_officalPlanBtn setTitleColor:RGB(44, 170,122) forState:UIControlStateSelected];
    [_officalPlanBtn setSelected:YES];
    [_officalPlanBtn addTarget:self action:@selector(showOfficalPlan:) forControlEvents:UIControlEventTouchUpInside];
    [topSwitchImgView addSubview:_officalPlanBtn];
    
    _userPlanBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_userPlanBtn setFrame:CGRectMake(160, 0, 160, 37)];
    [_userPlanBtn setBackgroundColor:[UIColor clearColor]];
    [_userPlanBtn setTitle:@"用户精选" forState:UIControlStateNormal];
    [_userPlanBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_userPlanBtn setTitleColor:RGB(130, 153, 165) forState:UIControlStateNormal];
    [_userPlanBtn setTitleColor:RGB(130, 153, 165) forState:UIControlStateHighlighted];
    [_userPlanBtn setTitleColor:RGB(44, 170,122) forState:UIControlStateSelected];
    [_userPlanBtn addTarget:self action:@selector(showUserPlan:) forControlEvents:UIControlEventTouchUpInside];
    [topSwitchImgView addSubview:_userPlanBtn];
    
    UIImageView * gapImgView = [[UIImageView alloc]initWithFrame:CGRectMake(159, 10, 1, 15)];
    [gapImgView setBackgroundColor:[UIColor clearColor]];
    [gapImgView setImage:[UIImage imageNamed:@"chat_room_line"]];
    [topSwitchImgView addSubview:gapImgView];
    [gapImgView release];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 38, 160, 2)];
    [line setTag:505050];
    [line setBackgroundColor:RGB(44, 170,122)];
    [topSwitchImgView addSubview:line];
    [line release];
    
    [topSwitchImgView release];
    
    
    _switchScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, height_headerview +40, 320, self.view.frame.size.height - height_headerview -40)];
    [_switchScrollView setPagingEnabled:YES];
    [_switchScrollView setBounces:NO];
    [_switchScrollView setScrollEnabled:NO];
    [_switchScrollView setDelegate:self];
    [_switchScrollView setContentSize:CGSizeMake(640, _switchScrollView.frame.size.height)];
    [_switchScrollView setBackgroundColor:[UIColor clearColor]];
    [_switchScrollView setShowsHorizontalScrollIndicator:NO];
    [_switchScrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_switchScrollView];
    
    
    officalPlanTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, _switchScrollView.frame.size.height)];
    officalPlanTable.delegate = self;
    officalPlanTable.dataSource = self;
    officalPlanTable.backgroundColor = [UIColor clearColor];
    officalPlanTable.separatorColor = [UIColor clearColor];
    [_switchScrollView addSubview:officalPlanTable];
    [_switchScrollView sendSubviewToBack:officalPlanTable];
    
    officalPlanTableFootView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    [officalPlanTable setTableFooterView:officalPlanTableFootView];
    [officalPlanTableFootView release];
    officalPlanTableFootView.hidden = YES;
    
    
    userPlanTable = [[UITableView alloc]initWithFrame:CGRectMake(320, 0, UIWidth, _switchScrollView.frame.size.height)];
    userPlanTable.delegate = self;
    userPlanTable.dataSource = self;
    userPlanTable.backgroundColor = [UIColor clearColor];
    userPlanTable.separatorColor = [UIColor clearColor];
    [_switchScrollView addSubview:userPlanTable];
    [_switchScrollView sendSubviewToBack:userPlanTable];
    
    userPlanTableFootView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    [userPlanTable setTableFooterView:userPlanTableFootView];

    
    if (userPlanListArray.count < [reqPageSize intValue]) {
        userPlanTableFootView.hidden = YES;
    }else{
        userPlanTableFootView.hidden = NO;
    }
    [userPlanTable reloadData];
    
    
    if (officalPlanListArray.count < [reqPageSize intValue]) {
        officalPlanTableFootView.hidden = YES;
    }else{
        officalPlanTableFootView.hidden = NO;
    }
    [officalPlanTable reloadData];

}



#pragma mark
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 197;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([tableView isEqual:userPlanTable]) {
        return userPlanListArray.count;
    }
    if ([tableView isEqual:officalPlanTable]) {
        return officalPlanListArray.count;
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:userPlanTable]) {
        MyItineraryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"User_GuideView_Cell"];
        if(cell == nil)
        {
            cell = [[[MyItineraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"User_GuideView_Cell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundView:nil];
        
        NSDictionary * dict = (NSDictionary *)[userPlanListArray objectAtIndex:indexPath.row];
        [cell updateCell:dict];
        
        return cell;
    }
    
    if ([tableView isEqual:officalPlanTable]) {
        MyItineraryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Offical_GuideView_Cell"];
        if(cell == nil)
        {
            cell = [[[MyItineraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Offical_GuideView_Cell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundView:nil];
        
        NSDictionary * dict = (NSDictionary *)[officalPlanListArray objectAtIndex:indexPath.row];
        [cell updateCell:dict];
        
        return cell;
    }
  
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:userPlanTable]) {
        
        NSDictionary * planData = [userPlanListArray objectAtIndex:indexPath.row];
        
        UsefulGuideController *usefulVc = [[UsefulGuideController alloc]init];
        usefulVc.type = 4;
        usefulVc.strTitle = [planData objectForKey:@"subject"];
        usefulVc.url = [planData objectForKey:@"view_url"];
        
        [self.navigationController pushViewController:usefulVc animated:YES];
        [usefulVc release];
    }
    
    if ([tableView isEqual:officalPlanTable]) {
       
        NSDictionary * planData = [officalPlanListArray objectAtIndex:indexPath.row];
        
        UsefulGuideController *usefulVc = [[UsefulGuideController alloc]init];
        usefulVc.type = 4;
        usefulVc.strTitle = [planData objectForKey:@"subject"];
        usefulVc.url = [planData objectForKey:@"view_url"];
        
        [self.navigationController pushViewController:usefulVc animated:YES];
        [usefulVc release];
    }

}


#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //滚动用户的行程列表
    if ([scrollView isEqual:userPlanTable]) {
        if (userPlanListIsLoading == YES || _userPlanPage == 1) {
            return;
        }
        
        if(userPlanTable.contentOffset.y + userPlanTable.frame.size.height - userPlanTable.contentSize.height >= 5 && userPlanListIsLoading == NO)
        {
            //NSLog(@"再去网上加载数据 ^ ^ ");
            userPlanListIsLoading = YES;
            
            [userPlanTableFootView changeLoadingStatus:userPlanListIsLoading];
            
            [[QYAPIClient sharedAPIClient]getRecommandPlanListByType:_type
                                                                  ID:_key
                                                              source:@"user"
                                                                page:[NSString stringWithFormat:@"%d",_userPlanPage]
                                                             success:^(NSDictionary *dic) {
                                                                 
                                                                 [self.view hideToastActivity];
                                                                 
                                                                 int statussss = [[dic objectForKey:@"status"]integerValue];
                                                                 
                                                                 if (statussss == 1) {
                                                                     
                                                                     NSArray * listArray = (NSArray *)[dic objectForKey:@"data"];
                                                                 
                                                                     if (listArray.count < [reqPageSize intValue]) {
                                                                         userPlanTableFootView.hidden = YES;
                                                                     }else{
                                                                         userPlanTableFootView.hidden = NO;
                                                                     }
                                                                     _userPlanPage ++;
                                                                     [userPlanListArray addObjectsFromArray:listArray];
                                                                     [userPlanTable reloadData];
                                                                     
                                                                     userPlanListIsLoading = NO;
                                                                     [userPlanTableFootView changeLoadingStatus:userPlanListIsLoading];
                                                                 }
                                                                 
                                                                    }failed:^{
                                                                        
                                                                        [self.view hideToastActivity];
                                                                        
                                                                        userPlanListIsLoading = NO;
                                                                        [userPlanTableFootView changeLoadingStatus:userPlanListIsLoading];
                                                                    }];
        }
    }
    
    
    
    //滚动编辑推荐列表
    if ([scrollView isEqual:officalPlanTable]) {
        
        if (officialPlanListIsLoading == YES || _officalPlanPage == 1) {
            return;
        }
        
        if(officalPlanTable.contentOffset.y + officalPlanTable.frame.size.height - officalPlanTable.contentSize.height >= 5 && officialPlanListIsLoading == NO)
        {
            officialPlanListIsLoading = YES;
            
            [officalPlanTableFootView changeLoadingStatus:officialPlanListIsLoading];
            
            [[QYAPIClient sharedAPIClient]getRecommandPlanListByType:_type
                                                                  ID:_key
                                                              source:@"editor"
                                                                page:[NSString stringWithFormat:@"%d",_officalPlanPage]
                                                             success:^(NSDictionary *dic) {
                                                                 
                                                                 [self.view hideToastActivity];
                                                                 
                                                                 int statussss = [[dic objectForKey:@"status"]integerValue];
                                                                 
                                                                 if (statussss == 1) {
                                                                     
                                                                     NSArray * listArray = (NSArray *)[dic objectForKey:@"data"];
                                                                     
                                                                     if (listArray.count < [reqPageSize intValue]) {
                                                                         officalPlanTableFootView.hidden = YES;
                                                                     }else{
                                                                         officalPlanTableFootView.hidden = NO;
                                                                     }
                                                                     _officalPlanPage ++;
                                                                     [officalPlanListArray addObjectsFromArray:listArray];
                                                                     [officalPlanTable reloadData];
                                                                     
                                                                     officialPlanListIsLoading = NO;
                                                                     [officalPlanTableFootView changeLoadingStatus:officialPlanListIsLoading];
                                                                 }
                                                                 
                                                             }failed:^{
                                                                 
                                                                 [self.view hideToastActivity];
                                                                 
                                                                 officialPlanListIsLoading = NO;
                                                                 [officalPlanTableFootView changeLoadingStatus:officialPlanListIsLoading];
                                                             }];
        }
    
    }

}


-(void)showOfficalPlan:(id)sender
{
    [_officalPlanBtn setSelected:YES];
    [_userPlanBtn setSelected:NO];
    
    UIView *line = [self.view viewWithTag:505050];
    [line setFrame:CGRectMake(0, 38, 160, 2)];
    
    [_switchScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view endEditing:YES];
}

-(void)showUserPlan:(id)sender
{
    [_officalPlanBtn setSelected:NO];
    [_userPlanBtn setSelected:YES];
    
    UIView *line = [self.view viewWithTag:505050];
    [line setFrame:CGRectMake(160, 38, 160, 2)];
    
    [_switchScrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    [self.view endEditing:YES];
}










- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    [userPlanListArray release];
    
    QY_VIEW_RELEASE(userPlanTable);
    
    [super dealloc];
}


- (void)touchesView
{
    [super touchesView];
    
    [self queryData];
}
@end
