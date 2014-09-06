//
//  CountryNumberViewController.h
//  QYER
//
//  Created by Leno on 14-6-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"

@protocol DidChooseCountryNumberDelegate;

@interface CountryNumberViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIButton            * _cancelButton;

    UITableView         * _countryTableView;
}

@property (assign, nonatomic) id<DidChooseCountryNumberDelegate> delegate;

@end


@protocol DidChooseCountryNumberDelegate<NSObject>

-(void)didChooseCountry:(NSString *)country Number:(NSString *)number;//用户选择国家及编码

@end