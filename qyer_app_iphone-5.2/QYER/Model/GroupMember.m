//
//  GroupMember.m
//  QYER
//
//  Created by 张伊辉 on 14-5-13.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GroupMember.h"
#import "QYAPIClient.h"
#import "AppDelegate.h"
#import "QYToolObject.h"
@implementation GroupMember

-(void)dealloc{
    
    self.im_user_id = nil;
    self.username = nil;
    self.avatar = nil;
    self.together_city = nil;
    self.updated_time = nil;
    
    [super dealloc];
}

/**
 *  获取聊天室的所有成员信息
 *
 *  @param chatroom_id 聊天室 id
 *  @param pageCount   每页数量	默认 20 个
 *  @param page        页码	默认第一页
 *
 *  @return void
 */
+(void)getChatroomMembersWithChatroom_id:(NSString *)chatroom_id
                                   count:(NSInteger)pageCount
                                    page:(NSInteger)page
                                 success:(GroupMemberSuccessBlock)finishedBlock
                                  failed:(GroupMemberFailedBlock)failedBlock{
    

    [[QYAPIClient sharedAPIClient]getChatRoomMembersWithRoomID:chatroom_id andCount:[NSString stringWithFormat:@"%d",pageCount] andPage:[NSString stringWithFormat:@"%d",page] success:^(NSDictionary *dic) {
       
        
        if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
        {
            NSLog(@" getChatroomMembersWithChatroom_id 成功 %@",dic);
            NSArray *array = [dic objectForKey:@"data"];
            NSArray *array_out = [[self prepareData:array] retain];
            finishedBlock(array_out);
            [array_out release];
        }
        
    } failed:^{
        
        failedBlock();
    }];
}

+(void)getChatroomMembersWithUserIds:(NSString *)userIds success:(GroupMemberSuccessBlock)finishedBlock failed:(GroupMemberFailedBlock)failedBlock{
    
    
    [[QYAPIClient sharedAPIClient]getChatRoomMembersWithIDs:userIds success:^(NSDictionary *dic) {
        
        if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
        {
            NSLog(@" getChatroomMembersWithChatroom_id 成功 %@",dic);
            NSArray *array = [dic objectForKey:@"data"];
            
            if ([array isKindOfClass:[NSArray class]]) {
                
                if (array.count != 0) {
                    
                    NSArray *array_out = [[self prepareData:array] retain];
                    finishedBlock(array_out);
                    [array_out release];
                }
               
            }
            
        }
        
    } failed:^{
        
        failedBlock();

    }];
    
}


+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_planData = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dic in array)
    {
        if(dic&&[dic isKindOfClass:[NSDictionary class]])
        {
            
            GroupMember *member = [[GroupMember alloc]init];
            
           
            for (int i = 0; i<[[dic allKeys] count]; i++) {
                id value = [[dic allValues] objectAtIndex:i];
                if ([value isEqual:[NSNull null]]) {
                    [dic setObject:@"" forKey:[[dic allKeys] objectAtIndex:i]];
                }
            }
            
            member.user_id = [[dic objectForKey:@"user_id"] intValue];
            member.im_user_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"im_user_id"]];
            member.username = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
            member.avatar = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
            member.gender = [[dic objectForKey:@"gender"]intValue];
            member.lon = [[dic objectForKey:@"lon"] floatValue];
            member.lat = [[dic objectForKey:@"lat"] floatValue];
            member.total_together_city = [[dic objectForKey:@"total_together_city"] intValue];
            member.together_city = [NSString stringWithFormat:@"%@",[dic objectForKey:@"together_city"]];
            member.updated_time = [NSString stringWithFormat:@"%@",[dic objectForKey:@"updated_time"]];
            member.age = [[dic objectForKey:@"age"] intValue];
            
            AppDelegate *dele =(AppDelegate *)[[UIApplication sharedApplication]delegate];
            
            member.distance = [QYToolObject  LantitudeLongitudeDist:[[dic objectForKey:@"lon"] floatValue] other_Lat:[[dic objectForKey:@"lat"] floatValue] self_Lon:dele.locationManager.location.coordinate.longitude self_Lat:dele.locationManager.location.coordinate.latitude];
            
            [array_planData addObject:member];
            
            
            
            [member release];


        }
    }
    
    return [array_planData autorelease];
}
@end
