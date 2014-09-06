//
//  NoteAndChatViewController.h
//  QYER
//
//  Created by 张伊辉 on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateChatTable.h"
#import "QYBaseViewController.h"
#import "QyerAppNotificationTable.h"

@interface NoteAndChatViewController : QYBaseViewController<PrivateChatTableDelegate>
{
    /**
     *  tab分类 数组
     */
    NSMutableArray *btnsArray;
    /**
     *  tab 分类背景图
     */
    UIImageView *categoryBackImage;
    /**
     *  默认选择
     */
    int select;
    /**
     *  私信table
     */
    PrivateChatTable *chatTable;
    
    /**
     *  通知未读消息条数
     */
    NSInteger noteUnReadNum;
    /**
     *  私信未读消息条数
     */
    NSInteger chatUnReadNum;
    
    QyerAppNotificationTable* notifiTable;
    
    UIImageView *statueImageView;
}

@property(nonatomic,assign) BOOL push_flag;  //来自于小黑板推送

@end
