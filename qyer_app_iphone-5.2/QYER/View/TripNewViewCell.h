//
//  TripNewViewCell.h
//  QYER
//
//  Created by 张伊辉 on 14-6-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QyYhConst.h"
#import "LineSpaceLabel.h"
@interface TripNewViewCell : UITableViewCell
{
    
}
@property (nonatomic, retain) UIImageView *backImage;
@property (nonatomic, retain) UIImageView *iconImage;

@property (nonatomic, retain) LineSpaceLabel *titleLbl;
@property (nonatomic, retain) UILabel *autorAndTimeLbl;

@property (nonatomic, retain) UIView *back_click_view;

-(void)updateUIWithDict:(NSDictionary *)dict;
@end
