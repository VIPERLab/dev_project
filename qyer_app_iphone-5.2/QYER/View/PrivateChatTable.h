//
//  PrivateChatTable.h
//  QYER
//
//  Created by 张伊辉 on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateChatCell.h"
#import "PrivateChat.h"
@protocol PrivateChatTableDelegate <NSObject>

-(void)didSelectRowAtIndexPath:(NSObject *)object;

@end


@interface PrivateChatTable : UITableView<UITableViewDelegate,UITableViewDataSource>
{
//    NSMutableArray *muArrData;
}
@property (nonatomic, assign) id<PrivateChatTableDelegate>clickDelegate;

-(void)getLocalData;
-(void)addNewMessage:(PrivateChat *)chatItem;
@end
