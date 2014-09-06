//
//  OceaniaCell.h
//  QYER
//
//  Created by 我去 on 14-3-27.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OceaniaCell : UITableViewCell
{
    UILabel     *_label_name;
    UIImageView *_imageView_right;
    UIImageView *_imageView_select;
}

@property(nonatomic,retain) UILabel     *label_name;
@property(nonatomic,retain) UIImageView *imageView_right;
@property(nonatomic,retain) UIImageView *imageView_select;

-(void)setSelectedState;
-(void)setReselectedState;

@end
