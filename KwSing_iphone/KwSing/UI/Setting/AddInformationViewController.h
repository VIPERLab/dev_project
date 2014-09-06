//
//  AddInformationViewController.h
//  KwSing
//
//  Created by 改 熊 on 12-8-28.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSViewController.h"

@interface AddInformationViewController : KSViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITextField *_userNickname;
    UITableView *_myTableView;
    UIAlertView *_waitingDialog;
}
@property (nonatomic,retain) UITextField *userNickname;
@property (nonatomic,retain) UITableView *myTableView;

@end
