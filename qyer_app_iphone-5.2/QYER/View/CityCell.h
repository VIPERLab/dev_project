//
//  CityCell.h
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QyYhConst.h"
@class CityList;
@interface CityCell : UITableViewCell
{
    
}
@property (nonatomic, retain) UIImageView *backImage;
@property (nonatomic, retain) UIImageView *iconImage;
@property (nonatomic, retain) UIImageView *hotImage;
@property (nonatomic, retain) UILabel *titleLbl;
@property (nonatomic, retain) UILabel *willLbl;
@property (nonatomic, retain) UILabel *infoLbl;

@property (nonatomic, retain) UIView *back_click_view;
//************ Insert By ZhangDong 2014.3.31 Start ***********
- (void)configData:(CityList*)cityList;
//************ Insert By ZhangDong 2014.3.31 End ***********
@end
