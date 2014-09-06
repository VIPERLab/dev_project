//
//  LoginViewController.h
//  KwSing
//
//  Created by 改 熊 on 12-8-2.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//


#ifndef __KWSing__LoginView__
#define __KWSing__LoginView__

#import <UIKit/UIKit.h>
//#import "MusicWebViewController.h"
#import "KSViewController.h"


@interface KSLoginViewController : KSViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITextField* _userName;
    UITextField* _passWord;
    UIButton* _checkPWD;
    UITableView * myTableView;
    NSArray * dataSource;
    UIAlertView *_waitingDialog;

}
@property (nonatomic,retain) UITextField* userName;
@property (nonatomic,retain) UITextField* passWord;
@property (nonatomic,retain) UIButton *checkPWD;
@property (nonatomic,retain) NSArray * dataSource;
@property (nonatomic,retain) UITableView * myTableView;




-(void)loginClicked;
@end

#endif