//
//  GroupMemberCell.h
//  QYER
//
//  Created by 张伊辉 on 14-5-13.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"

#import "GroupMember.h"
@interface GroupMemberCell : UITableViewCell
{
    /**
     *  背景图
     */
    UIImageView *backImageView;
    /**
     *  头像
     */
    UIImageView *logoImageView;
    /**
     *  名字
     */
    UILabel *lblName;
    /**
     *  距离
     */
    UILabel *lblDistance;
    /**
     *  时间
     */
    UILabel *lblTime;
    
    /**
     *  性别背景
     */
    UIImageView *sexBackImageView;
    /**
     *  性别图片
     */
    UIImageView *sexImageView;
    /**
     *  年龄
     */
    UILabel *lblAge;
    
    /**
     *  分割线
     */
    UIImageView *lineImageView;
    
    /**
     *  你和Ta公同去过14个城市
     */
    UILabel *lblManyPlace;
    /**
     *  哪些国家，京都、东京...
     */
    UILabel *lblPlace;
}

/**
 *  刷新UI
 *
 *  @param fOjbect 好友对象
 */
-(void)updateUIWithFriend:(GroupMember *)gOjbect;

@end
