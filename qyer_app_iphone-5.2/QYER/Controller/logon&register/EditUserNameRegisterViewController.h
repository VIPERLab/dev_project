//
//  EditUserNameRegisterViewController.h
//  QYER
//
//  Created by Leno on 14-5-23.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"

@protocol EditUserNameSuccessDelegate;

@interface EditUserNameRegisterViewController : BaseViewController<UITextFieldDelegate>
{
    UIButton                *_cancelButton;
    UITextField             *_usernameTextField;
}

@property(retain,nonatomic)NSMutableDictionary * infoDictionary;

//@property(retain,nonatomic)NSString * userName;
//@property(retain,nonatomic)NSString * userID;
//@property(retain,nonatomic)NSString * userToken;
//@property(retain,nonatomic)NSString * typeeeee;

@property (assign, nonatomic) id<EditUserNameSuccessDelegate> delegate;


@end


@protocol EditUserNameSuccessDelegate<NSObject>

-(void)didEditUserNameSuccess;//修改用户名成功

@end



