//
//  RegisterUserNameViewController.h
//  QYER
//
//  Created by Leno on 14-6-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"

#import "QYAPIClient.h"

@interface RegisterUserNameViewController : BaseViewController<UITextFieldDelegate>
{
    UIScrollView    * _scrollView;
    
    UITextField     * _userNameTextField;
    UITextField     * _passWordTextField;
    UITextField     * _passWordRepeatTextField;
    
    UIButton           * _buttonback;
    UIButton           * _doneBtn;
}

@property(retain,nonatomic)NSString * userPhoneNumber;

@end
