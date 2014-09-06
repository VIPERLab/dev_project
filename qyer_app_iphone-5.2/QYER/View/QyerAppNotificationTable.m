//
//  QyerAppNotificationTable.m
//  QYER
//
//  Created by Qyer on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QyerAppNotificationTable.h"
#import "QyerAppNotificationData.h"
#import "ASIHTTPRequest.h"
#import "SBJsonParser.h"
#import "DeviceInfo.h"
#import "UniqueIdentifier.h"
#import "RegexKitLite.h"
#import "Toast+UIView.h"
#import "MineViewController.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "BoardDetailViewController.h"
#import "MyFriendsViewController.h"
@implementation QyerAppNotificationTable
@synthesize currentVC;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        isCanLoadData=YES;
//        _pageIndex=0;
//        
        
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        muArrData=[[NSMutableArray alloc] initWithCapacity:0];
        //[self loadDataWithCount:@"20" andPage:@"0"];
        
        page = 1;

        
        footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
        footView.hidden = YES;
        [self setTableFooterView:footView];
        [footView release];
        
        
    }
    return self;
}
-(void)requestDataFromServer:(BOOL)isNeedLoadMore{
    
    if (muArrData.count > 0 && isNeedLoadMore  == NO) {
        return;
    }
    
    [self makeToastActivityOffsetTop];
    
    [QyerAppNotificationData getNotificationListWithCount:reqNumber andPage:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array) {
        
        isLoading = NO;
        [footView changeLoadingStatus:isLoading];
        
        if (array.count == 0) {
            
            
        }else{
            
            [muArrData addObjectsFromArray:array];
            page ++;
            if (array.count < [reqNumber intValue]) {
                
                footView.isHaveData = NO;
                
            }else{
                
                footView.isHaveData = YES;
            }
            footView.hidden = NO;
            [self reloadData];

        }
        
        [self hideToastActivity];
     

        if (muArrData.count == 0) {
            //没数据
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showNoDataView" object:@"0"];
            
        }else{
            
            //有数据
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showNoDataView" object:@"2"];
        }
        
    } failed:^{
        
        if (page == 1) {
            //网络错误
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showNoDataView" object:@"1"];
        }
        
        
        [self hideToastActivity];
        isLoading = NO;
        [footView changeLoadingStatus:isLoading];

        
    }];
}

/*
-(void)loadDataWithCount:(NSString*)_count andPage:(NSString*)_page{
    isCanLoadData=NO;
    AppDelegate *_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [_appDelegate.window.rootViewController.view makeToastActivity:@"Center"];
    [QyerAppNotificationData getNotificationListWithCount:_count
                                                  andPage:_page
                                                  success:^(NSArray *_array){
                                                      [_appDelegate.window.rootViewController.view hideToastActivity];
                                                      if (_array && _array.count>0) {
                                                          for (int i=0; i<_array.count; i++) {
                                                              [muArrData addObject:[_array objectAtIndex:i]];
                                                          }
                                                          self.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
                                                          isCanLoadData=YES;
                                                          [self reloadData];
                                                          
                                                      }
                                                      
                                                  }
                                                   failed:^{
                                                       isCanLoadData=YES;
                                                       [_appDelegate.window.rootViewController.view hideToastActivity];
                                                       [self hideToast];
                                                       [self makeToast:@"no data" duration:1.5 position:@"center" isShadow:NO];
                                                }];
}*/

#pragma mark
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return [QyerAppNotificationTableViewCell calculateCellHeightByNotifition:[muArrData objectAtIndex:indexPath.row]];
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [muArrData count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *strInd = @"cell";
    QyerAppNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strInd];
    if (cell == nil) {
        cell = [[[QyerAppNotificationTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strInd] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell updateWithGuide:[muArrData objectAtIndex:indexPath.row]];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QyerAppNotification *notification_obj = [muArrData objectAtIndex:indexPath.row];
    
    /*
     follow (用户关注) / discount(折扣提醒) / hotel(酒店) / etc(其他) / broadcast(全站广播) / wall(小黑板提醒)
     */
    if ([notification_obj.type isEqualToString:@"follow"]) {
        
        if ([notification_obj.numbers intValue] == 1) {
            
            MineViewController *mineVC = [[MineViewController alloc] init];
            mineVC.user_id = [notification_obj.object_id integerValue];
            [currentVC.navigationController pushViewController:mineVC animated:YES];
            [mineVC release];

        }else{ //跳转我的关注
            
            MyFriendsViewController *friendVC = [[MyFriendsViewController alloc] init];
            friendVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
            friendVC.type = @"follows";
            [self.currentVC.navigationController pushViewController:friendVC animated:YES];
            [friendVC release];
        }
        
      
    }else if ([notification_obj.type isEqualToString:@"wall"]){
    
        BoardDetailViewController * detailVC = [[BoardDetailViewController alloc]init];
        detailVC.wallID = notification_obj.object_id;
        detailVC.enteredFromNotification = YES;
        
//        if ([notification_obj.object_photo isKindOfClass:[NSString class]] && notification_obj.object_photo.length >0) {
//            detailVC.photoURL = notification_obj.object_photo;
//        }
        
        [currentVC.navigationController pushViewController:detailVC animated:YES];
        [detailVC release];
    }
    
    
    
    return nil;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:
(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];
        [self deleteNotificaton:[muArrData objectAtIndex:row]];
        [muArrData removeObjectAtIndex:row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)deleteNotificaton:(QyerAppNotification*)_notifition{
    NSString* strUrl=[DomainName stringByAppendingFormat:@"/%@", @"qyer/notification/remove"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:_notifition.notification_id forKey:@"notification_id"];
    strUrl = [self getRequestUrl:strUrl withParameters:params];
    
    NSURL* url=[NSURL URLWithString:strUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setRequestMethod:@"GET"];
    [request setCompletionBlock:^{
                
//        NSString *result = [request responseString];
//        NSLog(@" Request result : %@",result);
        
    }];
    [request setFailedBlock:^{
        
        
        
        NSLog(@" Request Failed! error : %@",[[request error] description]);
        
    }];
    
    
    [request startAsynchronous];

}

-(NSString *)getRequestUrl:(NSString *)string_url withParameters:(NSDictionary *)dic
{
    NSString *track_user_id = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        track_user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    NSString *track_deviceid = [UniqueIdentifier getIdfa];
    NSString *track_app_version = [DeviceInfo getAppVersion];
    NSString *track_device_info = [DeviceInfo getDeviceName_detail];
    track_device_info = [track_device_info stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *track_os = [DeviceInfo getDeviceSystemVersion];
    track_os = [NSString stringWithFormat:@"ios %@",track_os];
    track_os = [track_os stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *channel = [appChannel_UMeng stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    
    
    NSString *str_url = [NSString stringWithString:[string_url stringByAppendingFormat:@"?"]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"client_id=%@",ClientId_QY]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&client_secret=%@",ClientSecret_QY]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&v=%@",API_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_user_id=%@",track_user_id]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_deviceid=%@",track_deviceid]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_version=%@",track_app_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_channel=%@",channel]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_device_info=%@",track_device_info]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_os=%@",track_os]];
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&oauth_token=%@",access_token]];
    }
    
    for(id key in [dic allKeys])
    {
        str_url = [str_url stringByAppendingFormat:@"&%@=%@", key, [dic objectForKey:key]];
    }
    
    return str_url;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    
    if (footView.isHaveData == NO) {
        return;
    }
    
    if(self.contentOffset.y + self.frame.size.height - self.contentSize.height >= 25 && isLoading == NO)
    {
        //NSLog(@"再去网上加载数据 ^ ^ ");
        isLoading = YES;
        [footView changeLoadingStatus:isLoading];
        
        [self requestDataFromServer:YES];

    }
    
    
   /*
        if(self.contentOffset.y + self.frame.size.height > self.contentSize.height +20 )
        {
            //[self loadDataWithCount:@"20" andPage:[NSString stringWithFormat:@"%lu",muArrData.count/20+1]];
           
            if (isCanLoadData) {
                 _pageIndex = _pageIndex + 1;
                [self loadDataWithCount:@"20" andPage:[NSString stringWithFormat:@"%d",_pageIndex]];
            }
            
        }
    */
    
}

-(void)dealloc{
    
    
    [muArrData release];
    [super dealloc];
}
@end
