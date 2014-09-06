//
//  CityLoginViewController.h
//  CityGuide
//
//  Created by lide on 13-3-9.
//  Copyright (c) 2013年 com.qyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

#import "QyerSns.h"
#import "WXApi.h"
#import "SinaWeibo.h"
#import "WeiboApi.h"
#import "QYAPIClient.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "UserNameLogInViewController.h"
#import "CountryNumberViewController.h"

#import "CCActiotSheet.h"

//@class CheckNetStatus;
@class GuideViewCell;
@class CalloutButton;

@interface CityLoginViewController : BaseViewController <UITextFieldDelegate,SinaWeiboDelegate,SinaWeiboRequestDelegate,ASIHTTPRequestDelegate,UserNameDidLogInSuccessDelegate,DidChooseCountryNumberDelegate,CCActiotSheetDelegate>
{
    QyerSns             * _qyer;
    
    UIView              *_scrollView;
    
    UIButton            *_cancelButton;
    UIButton            *_registerButton;
    
    CalloutButton       *_weixinLoginButton;
    CalloutButton       *_weiboLoginButton;
    CalloutButton       *_qqLoginButton;
    
    UIImageView         *_lineImageView;
    UILabel             *_loginLabel;
    
    UITextField         *_usernameTextField;
    UITextField         *_passwordTextField;
    
    
//    CheckNetStatus      *checkNetStatus;
    BOOL                signFlag;  //是否正在登陆的标志
    GuideViewCell       *_guideViewCell;
    BOOL                commontFlag;
    BOOL                _flag_logSuccess; //是否进行登录并登录成功
    
    
    
    NSString            *_weixinCode;
    NSString            *_weixinUserToken;
    NSString            *_weixinUserName;
    NSString            *_weixinOpenID;
    
    
    NSMutableData       *_sinaRequestData;
    NSString            *_sinaUserID;
    NSString            *_sinaUserToken;
    NSString            *_sinaUserName;
    
}

@property(nonatomic,retain) GuideViewCell *guideViewCell;
@property(nonatomic,assign) BOOL commontFlag;

@property(nonatomic,retain)  NSString            *_weixinCode;
@property(nonatomic,retain)  NSString            *_weixinUserToken;
@property(nonatomic,retain)  NSString            *_weixinUserName;
@property(nonatomic,retain)  NSString            *_weixinOpenID;
@property(nonatomic,retain)  NSString            *_sinaUserID;
@property(nonatomic,retain)  NSString            *_sinaUserToken;
@property(nonatomic,retain)  NSString            *_sinaUserName;
@property(nonatomic,retain)  NSString            *type;


@end
