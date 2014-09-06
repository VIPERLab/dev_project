//
//  PrivateChatCell.h
//  QYER
//
//  Created by 张伊辉 on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
#import "PrivateChat.h"
@interface PrivateChatCell : UITableViewCell
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
     *  内容
     */
    UILabel *lblContent;
    /**
     *  时间
     */
    UILabel *lblTime;
    /**
     *  分割线
     */
    UIImageView *lineImageView;
    
    /**
     *  新消息条数
     */
    UILabel *lblNewMsgNum;
}
-(void)updateUIWith:(PrivateChat *)chatItem;

@end
