//
//  PrivateChatTable.m
//  QYER
//
//  Created by 张伊辉 on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PrivateChatTable.h"
#import "LocalData.h"
#import "QYIMObject.h"
#import "QYAPIClient.h"
@implementation PrivateChatTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        // Initialization code
        self.delegate = self;
        self.dataSource = self;
        self.separatorColor = [UIColor clearColor];

    }
    return self;
}

-(void)getLocalData{
    

    [[GlobalObject share].priChatArray removeAllObjects];
    
    NSMutableArray *temparr = [[[LocalData getInstance] queryPrivateChatWithTableName:PrivateChatTableName] retain];
    [[GlobalObject share].priChatArray addObjectsFromArray:temparr];
    [temparr release];
    
    [self reloadData];
    
    //如果数组是0，就显示空
    if ([GlobalObject share].priChatArray.count == 0) {
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNoDataView" object:@"0"];
    }

}


-(void)addNewMessage:(PrivateChat *)chatItem{
    
    
    
    for (int i = 0; i<[GlobalObject share].priChatArray.count; i++) {
        
        
        PrivateChat *tempChat = [[GlobalObject share].priChatArray objectAtIndex:i];
        
        if ([tempChat.clientId isEqual:[NSNull null]]) {
            continue;
        }
        
        if ([tempChat.clientId isEqualToString:chatItem.clientId]) {
//            
//            int unReadNumber = tempChat.unReadNumber;
//            unReadNumber++;
            [[GlobalObject share].priChatArray removeObject:tempChat];
            
//            //如果是当前正在聊天的用户，设置为O
//            if ([[QYIMObject getInstance].privateChatImUserId isEqualToString:chatItem.clientId]) {
//                unReadNumber = 0;
//            }
//            
//            
//            chatItem.unReadNumber = unReadNumber;
            [[GlobalObject share].priChatArray insertObject:chatItem atIndex:0];
            [self reloadData];
            
            return;

        }
    }
    NSLog(@"no item");
    
    [[GlobalObject share].priChatArray insertObject:chatItem atIndex:0];
    [self reloadData];
    
    
}
#pragma mark
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return [[GlobalObject share].priChatArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *strInd = @"cell";
    PrivateChatCell *cell = [tableView dequeueReusableCellWithIdentifier:strInd];
    if (cell == nil) {
        cell = [[[PrivateChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strInd] autorelease];
    }
    [cell updateUIWith:[[GlobalObject share].priChatArray objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    PrivateChat *pcObj = [[GlobalObject share].priChatArray objectAtIndex:indexPath.row];
    
    //记录私信总数，++
    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
    NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
    totalPriChatNum -= pcObj.unReadNumber;
    if (totalPriChatNum < 0) {
        totalPriChatNum = 0;
    }
    [myUserDefault setInteger:totalPriChatNum forKey:TotalPrivateChatNumber];
    [myUserDefault synchronize];
    
    
    
    
    pcObj.unReadNumber = 0;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
  
    
    [[LocalData getInstance] resetPrivateChatUnReadNumberTableName:PrivateChatTableName withObject:pcObj];
    [self.clickDelegate didSelectRowAtIndexPath:pcObj];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatUnReadMsgNum" object:nil];
    NSLog(@"didSelectRowAtIndexPath");
}


- (void)dealloc
{
    [super dealloc];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
//           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return UITableViewCellEditingStyleDelete;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        
//        
//        
//        
//        PrivateChat *pcObj = [[GlobalObject share].priChatArray objectAtIndex:indexPath.row];
//        NSString *selClientId = [pcObj.clientId copy];
//        
//        //记录私信总数，++
//        NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
//        NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
//        totalPriChatNum -= pcObj.unReadNumber;
//        if (totalPriChatNum < 0) {
//            totalPriChatNum = 0;
//        }
//        [myUserDefault setInteger:totalPriChatNum forKey:TotalPrivateChatNumber];
//        [myUserDefault synchronize];
//    
//        pcObj.unReadNumber = 0;
//        [[LocalData getInstance] resetPrivateChatUnReadNumberTableName:PrivateChatTableName withObject:pcObj];
//        
//        
//        [[GlobalObject share].priChatArray removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        
//        /**
//         *  删除数据库中记录
//         *
//         *
//         */
//        
//        [[LocalData getInstance] deleteItemFromPrivateChatWithCliendId:selClientId];
//        [selClientId release];
//        
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatUnReadMsgNum" object:nil];
//
//        
//    }
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
