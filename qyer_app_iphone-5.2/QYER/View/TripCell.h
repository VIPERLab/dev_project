//
//  TripCell.h
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QyYhConst.h"

@interface TripCell : UITableViewCell
{
    
}
@property (nonatomic, retain) UIImageView *backImage;
@property (nonatomic, retain) UIImageView *iconImage;
@property (nonatomic, retain) UIImageView *dayImage;
@property (nonatomic, retain) UILabel *dayLbl;
@property (nonatomic, retain) UILabel *titleLbl;
@property (nonatomic, retain) UILabel *contentLbl;
@property (nonatomic, retain) UILabel *nameTimeLbl;

@end
