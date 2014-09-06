//
//  GroupMembersViewController.m
//  QYER
//
//  Created by 张伊辉 on 14-5-13.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GroupMembersViewController.h"
#import "GroupMemberCell.h"
#import "GroupMember.h"
#import "QYIMObject.h"
#import "UserInfo.h"
#import "PrivateChatViewController.h"
#import "MineViewController.h"
@interface GroupMembersViewController ()

@end

@implementation GroupMembersViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _titleLabel.text = @"身边人列表";
    
    page = 0;
    pageSize = 20;
    
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.view.backgroundColor = RGB(232, 243, 248);
    
    mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, UIHeight - height_need_reduce)];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.backgroundColor = [UIColor clearColor];
    mainTable.separatorColor = [UIColor clearColor];
    [self.view addSubview:mainTable];
    [mainTable release];
    
    [self.view sendSubviewToBack:mainTable];
    [ChangeTableviewContentInset changeTableView:mainTable withOffSet:0];
   
    
    
    footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    footView.hidden = YES;
    [mainTable setTableFooterView:footView];
    [footView release];
    
    
    
    imUserIds = [[NSMutableArray alloc] init];
    
    
    [self firstRequestGroupMembers];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

-(void)touchesView{
    
    [self firstRequestGroupMembers];
}
-(void)firstRequestGroupMembers{
    
    
    if (isNotReachable) {
        
        [super setNotReachableView:YES];
        
        return;
        
    }else{
        
        [super setNotReachableView:NO];
    }
    

    
    
    [self.view makeToastActivity];
    
    /**
     *  根据聊天室ID得到所有的用户IM ids,然后根据IM ids组合成 AFK13,KFH14格式。
     *
     */
    [[QYIMObject getInstance] getTopicInfo:self.topicId withBlock:^(QYIMObject *imObject, NSArray *userIds, BOOL isSuc) {
        
        
        if (userIds.count == 0 || !isSuc) {
            
            [super setNotReachableView:YES];
            [self.view hideToastActivity];

            return ;
        }
        
        [imUserIds removeAllObjects];
        [imUserIds addObjectsFromArray:userIds];
        
        
        NSString *imUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid_im"];
        if (imUserId) {
            [imUserIds removeObject:imUserId];
            [imUserIds insertObject:imUserId atIndex:0];
        }
        
        NSString *strIds = [[self getUserIdsString:[self getSubArrFrom:imUserIds arrIndex:page*pageSize arrLength:pageSize]] retain];
        [self qyerDataWithUserIds:strIds];
        [strIds release];
        
        
    }];

}


/**
 *  得到 子数组
 *
 *  @param originArray 源数组
 *  @param index       位置索引
 *  @param length      长度
 *
 *  @return 子数组
 */
-(NSArray *)getSubArrFrom:(NSMutableArray *)originArray arrIndex:(int)index arrLength:(int)length{
    
    NSRange range;
    range.location = index;
    range.length = length;
    
    
    if (index + length >= originArray.count) {
        range.length = originArray.count-index;
    }
    
    NSLog(@"== %d",[[originArray subarrayWithRange:range] count]);
    return  [originArray subarrayWithRange:range];
    
}
/**
 *  根据用户数组生成，请求字符串，ID1,ID2,ID3分开
 *
 *  @param userArray
 *
 *  @return sting
 */
-(NSMutableString *)getUserIdsString:(NSArray *)userArray{
    
    NSMutableString *string = [[NSMutableString alloc]initWithString:@""];

    for (int i=0; i<userArray.count; i++) {
        
        if (i<userArray.count-1) {
            
            [string appendFormat:@"%@,",[userArray objectAtIndex:i]];

        }else{
            
            [string appendString:[userArray objectAtIndex:i]];
            
        }
    }
    return [string autorelease];
}

-(void)qyerDataWithUserIds:(NSString *)userIds{
    
    [GroupMember getChatroomMembersWithUserIds:userIds success:^(NSArray *array_planData) {
        
        page++;
        isLoading = NO;
        [footView changeLoadingStatus:isLoading];
        
        
        if (page*pageSize >= imUserIds.count) {
            
            footView.isHaveData = NO;
            
            
        }else{
            
            footView.isHaveData = YES;
        }
        
        [dataArray addObjectsFromArray:array_planData];
        [mainTable reloadData];
        
        footView.hidden = NO;
        
        
        [self.view hideToastActivity];

        
    } failed:^{
        
        isLoading = NO;
        [footView changeLoadingStatus:isLoading];
        
        [self.view hideToastActivity];

        
        if (page == 1) {
            
            [super setNotReachableView:YES];

        }
        
        
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSString *imUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid_im"];
    GroupMember *gm = [dataArray objectAtIndex:indexPath.row];
    if ([gm.im_user_id isEqualToString:imUserId] || gm.total_together_city == 0) {
        return 80;
    }
//    if (indexPath.row == dataArray.count - 1) {
//        return 145;
//    }
    return 135;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *str = @"cell";
    
    GroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[[GroupMemberCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
    }
    [cell updateUIWithFriend:[dataArray objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the cell...
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (mainTable.tableFooterView == nil) {
        return 10;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return [view autorelease];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GroupMember *member = [dataArray objectAtIndex:indexPath.row];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    mineVC.user_id = member.user_id;
    [self.navigationController pushViewController:mineVC animated:YES];
    [mineVC release];
    
    
    /**
     *  之前测试进入私信
     */
//    
//    UserInfo *user = [[UserInfo alloc] init];
//    user.im_user_id = @"AIM7HE6E8IHRZXDOCO75Q49";
//    user.username = member.username;
//    user.avatar = member.avatar;
//    
//    PrivateChatViewController *viewController = [[PrivateChatViewController alloc] init];
//    viewController.toUserInfo = user;
//    [self.navigationController pushViewController:viewController animated:YES];
//    [viewController release];
//    [user release];
//
//    
    

}
/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    

    
    if (footView.isHaveData == NO) {
        return;
    }
//    if (mainTable.tableFooterView == nil) {
//        return;
//    }
//    if (footView.hidden == YES || page == 0) {
//        return;
//    }
    
    if(mainTable.contentOffset.y + mainTable.frame.size.height - mainTable.contentSize.height >= 20 && isLoading == NO)
    {
        //NSLog(@"再去网上加载数据 ^ ^ ");
        isLoading = YES;
        
        [footView changeLoadingStatus:isLoading];
        
        NSString *strIds = [[self getUserIdsString:[self getSubArrFrom:imUserIds arrIndex:page*pageSize arrLength:pageSize]] retain];
        [self qyerDataWithUserIds:strIds];
        [strIds release];

       // [self qyerDataWithUserIds:[self getUserIdsString:[self getSubArrFrom:imUserIds arrIndex:page*pageSize arrLength:pageSize]]];
        

        
    }
    
}
-(void)dealloc{
    
    [dataArray release];
    [imUserIds release];

    [super dealloc];
}
@end
