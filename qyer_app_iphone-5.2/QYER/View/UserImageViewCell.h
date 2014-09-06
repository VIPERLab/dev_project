//
//  UserImageViewCell.h
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserInfo;
@class MyControl;

@protocol UserImageViewCellDelegate;
@interface UserImageViewCell : UITableViewCell
{
    UIImageView     *_imageView_userPhoto;
    UIImageView     *_imageView_userAvatar;
    //UIImageView     *_imageView_userAvatar_withoutLogin;
    UIButton        *_button_login;
    UIImageView     *_imageView_gender;
    UILabel         *_label_userName;
    UILabel         *_label_userTitle;
    UILabel         *_label_userFans;
    UILabel         *_label_userFollow;
    
    
    UIButton        *_button_follow;            //关注_取消关注
    UIButton        *_button_personalLetter;    //私信
    UILabel         *_intervalLine;             //分割线
    
    NSString        *_follow_status;            //关注状态 (关注TA/已关注/相互关注)
    NSInteger       _user_id;
    UIView          *_view_back;
    
    MyControl       *_control_userPhoto;
    MyControl       *_control_changeAvatar;
    
    id<UserImageViewCellDelegate>   _delegate;
}
@property(nonatomic,retain) UIImageView     *imageView_userPhoto;
@property(nonatomic,retain) UIImageView     *imageView_userAvatar;
//@property(nonatomic,retain) UIImageView     *imageView_userAvatar_withoutLogin;
@property(nonatomic,retain) UIButton        *button_login;
@property(nonatomic,retain) UIImageView     *imageView_gender;
@property(nonatomic,retain) UILabel         *label_userName;
@property(nonatomic,retain) UILabel         *label_userTitle;
@property(nonatomic,retain) UILabel         *label_userFans;
@property(nonatomic,retain) UILabel         *label_userFollow;
@property(nonatomic,retain) NSString        *follow_status;            //关注状态 (关注TA/已关注/相互关注)
@property(nonatomic,assign) NSInteger       user_id;
@property(nonatomic,retain) UIView          *view_back;
@property(nonatomic,retain) UILabel         *intervalLine;
@property(nonatomic,retain) UIButton        *button_follow;            //关注_取消关注
@property(nonatomic,retain) UIButton        *button_personalLetter;    //私信
@property(nonatomic,retain) UIImage         *image_avatar;
@property(nonatomic,retain) UIImage         *image_photo;
@property(nonatomic,assign) id<UserImageViewCellDelegate> delegate;
@property(nonatomic,retain) MyControl *control_userPhoto;
@property(nonatomic,retain) MyControl *control_changeAvatar;
-(void)initWithNotLogin;
-(void)initInfoWithUserData:(UserInfo *)userinfo mine:(BOOL)flag;
@end






#pragma mark -
#pragma mark --- UserImageViewCell - Delegate
@protocol UserImageViewCellDelegate <NSObject>
-(void)loginIn:(UserImageViewCell *)cell;
-(void)addFollow:(UserImageViewCell *)cell;
-(void)sendPersonaLetter:(UserImageViewCell *)cell;
-(void)showFollowsAndFans:(UserImageViewCell *)cell withType:(NSString *)type;
-(void)changeUserAvatar:(UserImageViewCell *)cell;
-(void)changeUserPhoto:(UserImageViewCell *)cell;
@end
