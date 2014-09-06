//
//  UserNameLogInViewController.h
//  QYER
//
//  Created by Leno on 14-6-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"
#import "QYAPIClient.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@protocol UserNameDidLogInSuccessDelegate;

@interface UserNameLogInViewController : BaseViewController<UITextFieldDelegate,ASIHTTPRequestDelegate>
{
    BOOL                signFlag;  //是否正在登陆的标志
    BOOL                _flag_logSuccess; //是否进行登录并登录成功
    
    UIScrollView        * _scrollViewww;
    
    UIButton            * _buttonback;

    UITextField         *_usernameTextField;
    UITextField         *_passwordTextField;
}
@property(nonatomic,assign) BOOL commontFlag;

@property (assign, nonatomic) id<UserNameDidLogInSuccessDelegate> delegate;

@end

@protocol UserNameDidLogInSuccessDelegate<NSObject>

-(void)UserNameDidLogInSuccess;//修改用户名成功

@end



