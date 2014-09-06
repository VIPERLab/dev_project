//
//  PhoneGetPassWordViewController.h
//  QYER
//
//  Created by Leno on 14-6-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"

#import "CountryNumberViewController.h"

#import "QYAPIClient.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface PhoneGetPassWordViewController : BaseViewController<UITextFieldDelegate,ASIHTTPRequestDelegate,DidChooseCountryNumberDelegate>
{
    UIButton            * _buttonback;

    UILabel             * _numberLabel;
    UILabel             * _countryLabel;
    
    UITextField         * _phoneNumberTxtField;

    UIButton            * _nextBtn;
}

@end
