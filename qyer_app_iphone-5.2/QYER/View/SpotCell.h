//
//  SpotCell.h
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#import "QyYhConst.h"
#import "CityPoi.h"
@interface SpotCell : UITableViewCell
{
    
}
-(void)setNearByPoi:(CityPoi *)data;
-(void)setCityPoi:(CityPoi *)data;
@property (nonatomic, retain) UIImageView *backImage;
@property (nonatomic, retain) UIImageView *iconImage;
@property (nonatomic, retain) UIImageView *hotImage;
@property (nonatomic, retain) UIImageView *lineImageView;


@property (nonatomic, retain) UILabel *titleLbl;
@property (nonatomic, retain) UILabel *willLbl;
@property (nonatomic, retain) DYRateView *rateView;
@property (nonatomic, retain) UILabel *rateLbl;
@property (nonatomic, retain) UILabel *label_distance;

@property (nonatomic, retain) UIView *back_click_view;

@end
