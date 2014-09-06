//
//  RegisterVerifyViewController.h
//  QYER
//
//  Created by Leno on 14-6-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"

#import "QYAPIClient.h"

@interface RegisterVerifyViewController : BaseViewController<UITextFieldDelegate>
{
    UIButton           * _buttonback;
    
    UITextField        * _codeTextField;
    
    UIButton            * _nextBtn;
    
    int                  _seconds;
}

@property(retain,nonatomic)NSString * userPhoneNumber;
@property(retain,nonatomic)NSString * verifyingCode;



@end
