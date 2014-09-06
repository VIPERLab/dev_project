//
//  UserInfoCell.h
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoCell : UITableViewCell
{
    UILabel     *_label_title;
    UIImageView *_imageView_arrow;
}

@property(nonatomic,retain) UILabel     *label_title;
@property(nonatomic,retain) UIImageView *imageView_arrow;

@end
