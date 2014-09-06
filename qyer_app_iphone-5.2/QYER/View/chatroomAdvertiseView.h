//
//  chatroomAdvertiseView.h
//  QYER
//
//  Created by Qyer on 14-5-28.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineSpaceLabel.h"
@protocol chatroomAdvertiseViewDelegate <NSObject>

-(void)clickBackButton:(id)sender;

-(void)goChatroomButton:(id)sender;

/**
 *  查看更多
 */
-(void)moreDetailAboutChatRoom;

@end

@interface chatroomAdvertiseView : UIView{
    
    LineSpaceLabel* _introduceLabel;
    LineSpaceLabel* _introduceLabel2;
    
    UIButton *btnDetail;
    
    id<chatroomAdvertiseViewDelegate> delegate;
}
@property(assign,nonatomic)id<chatroomAdvertiseViewDelegate> delegate;
/**
 *  请求统计聊天室人数
 */
-(void)getChatroomStats;
@end
