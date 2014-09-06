//
//  CityRegisterViewController.h
//  CityGuide
//
//  Created by lide on 13-3-9.
//  Copyright (c) 2013年 com.qyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

//@class CheckNetStatus;

@interface CityRegisterViewController : BaseViewController <UITextFieldDelegate>
{
    UIButton                *_cancelButton;
    UIButton                *button_register;
    
    UIImageView             *_inputImageView;
    UILabel                 *_emailLabel;
    UITextField             *_emailTextField;
    UILabel                 *_usernameLabel;
    UITextField             *_usernameTextField;
    UILabel                 *_passwordLabel;
    UITextField             *_passwordTextField;
    
    BOOL zhuceFlag;
//    
//    CheckNetStatus *checkNetStatus;
}

@end
