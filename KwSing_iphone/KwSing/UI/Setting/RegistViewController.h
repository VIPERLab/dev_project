//
//  RegistViewController.h
//  KwSing
//
//  Created by 改 熊 on 12-8-28.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSViewController.h"


@interface RegistViewController : KSViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITextField *_userName;
    UITextField *_passWord;
    UIButton *_showPWD;
    UITableView *_myTableView;
    NSArray *dataSource;
    UIAlertView *_waitingDialog;
}
@property (nonatomic,retain) UITextField *userName;
@property (nonatomic,retain) UITextField *passWord;
@property (nonatomic,retain) UIButton *showPWD;
@property (nonatomic,retain) NSArray *dataSource;
@property (nonatomic,retain) UITableView *myTableView;
@property (nonatomic,retain) UIAlertView *waitingDialog;

-(void)doLoginWithIndex:(NSIndexPath*)indexPath;
@end
