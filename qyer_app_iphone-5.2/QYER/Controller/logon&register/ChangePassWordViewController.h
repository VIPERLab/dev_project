//
//  ChangePassWordViewController.h
//  QYER
//
//  Created by Leno on 14-6-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"

#import "QYAPIClient.h"

@interface ChangePassWordViewController : BaseViewController<UITextFieldDelegate>
{
    UIButton           * _buttonback;
    
    UITextField        * _topTextField;
    UITextField        * _bottomTextField;
    
    UIButton           * _doneBtn;
}

@property(retain,nonatomic)NSString * userPhoneNumber;

@end
