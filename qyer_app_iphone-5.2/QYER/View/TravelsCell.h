//
//  TravelsCell.h
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QyYhConst.h"
#import "MicroTravel.h"
@interface TravelsCell : UITableViewCell
{
    
}


@property (nonatomic, retain) UIImageView *backImage;
@property (nonatomic, retain) UIImageView *iconImage;
@property (nonatomic, retain) UILabel *titleLbl;
@property (nonatomic, retain) UILabel *nameTimeLbl;
@property (nonatomic, retain) UIImageView *suppIamgeView;
@property (nonatomic, retain) UILabel *suppNumLabel;
@property (nonatomic, retain) UIImageView *comImageView;
@property (nonatomic, retain) UILabel *comNumLabel;

@property (nonatomic, retain) UIView *back_click_view;
-(void)updateCell:(MicroTravel *)object;
-(void)updateUIWithDict:(NSDictionary *)dict;
@end
