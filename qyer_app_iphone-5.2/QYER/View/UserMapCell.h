//
//  UserMapCell.h
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserInfo;
@class MyControl;

@protocol UserMapCellDelegate;
@interface UserMapCell : UITableViewCell
{
    UIView      *_view_background;
    UIImageView *_imageView_map;
    UILabel     *_label_gone;
    UILabel     *_label_country;
    UILabel     *_label_city;
    UILabel     *_label_poi;
    
    UILabel     *_label_country_type;
    UILabel     *_label_city_type;
    UILabel     *_label_poi_type;
    MyControl   *_control;
}
@property(nonatomic,retain) UIView   *view_background;
@property(nonatomic,retain) UIImageView *imageView_map;
@property(nonatomic,retain) UILabel  *label_gone;
@property(nonatomic,retain) UILabel  *label_country;
@property(nonatomic,retain) UILabel  *label_city;
@property(nonatomic,retain) UILabel  *label_poi;
@property(nonatomic,retain) UILabel  *label_country_type;
@property(nonatomic,retain) UILabel  *label_city_type;
@property(nonatomic,retain) UILabel  *label_poi_type;
@property(nonatomic,retain) MyControl *control;
@property(nonatomic,assign) id<UserMapCellDelegate>  delegate;
-(void)initWithNotLogin;
-(void)initInfoWithUserData:(UserInfo *)userinfo mine:(BOOL)flag;
@end




#pragma mark -
#pragma mark --- UserMapCell - Delegate
@protocol UserMapCellDelegate <NSObject>
-(void)selectedUserFootprint;
@end