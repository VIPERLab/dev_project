//
//  GroupMember.h
//  QYER
//
//  Created by 张伊辉 on 14-5-13.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "BaseModel.h"
typedef void (^GroupMemberSuccessBlock)(NSArray *array_planData);
typedef void (^GroupMemberFailedBlock)(void);


@interface GroupMember : BaseModel
{
    
}
/**
 *  用户 id
 */
@property (nonatomic, assign) NSInteger user_id;
/**
 *  IM 用户 id
 */
@property (nonatomic, retain) NSString *im_user_id;
/**
 *  昵称
 */
@property (nonatomic, retain) NSString *username;
/**
 *  头像链接
 */
@property (nonatomic, retain) NSString *avatar;
/**
 *  性别 1 男 0 女
 */
@property (nonatomic, assign) NSInteger gender;

/**
 *  年龄
 */
@property (nonatomic, assign) NSInteger age;
/**
 *  精度
 */
@property (nonatomic, assign) CGFloat lon;
/**
 *  纬度
 */
@property (nonatomic, assign) CGFloat lat;
/**
 *  和TA共同去过城市数量
 */
@property (nonatomic, assign) NSInteger total_together_city	;
/**
 *  和TA共同去过城市
 */
@property (nonatomic, retain) NSString *together_city;
/**
 *  TA位置最后更新时间
 */
@property (nonatomic, retain) NSString *updated_time;

/**
 *  距离
 */
@property (nonatomic, assign) CGFloat distance;
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
                                  failed:(GroupMemberFailedBlock)failedBlock;

+(void)getChatroomMembersWithUserIds:(NSString *)userIds success:(GroupMemberSuccessBlock)finishedBlock failed:(GroupMemberFailedBlock)failedBlock;














@end
