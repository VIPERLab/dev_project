//
//  CategoryCell.h
//  QYER
//
//  Created by 我去 on 14-3-26.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell
{
    UIImageView     *_imageView_backGround;
    UILabel         *_label_name;
}

@property(nonatomic,retain) UIImageView     *imageView_backGround;
@property(nonatomic,retain) UILabel         *label_name;

@end
