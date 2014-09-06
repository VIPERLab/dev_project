//
//  UserImageViewCell.m
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserImageViewCell.h"
#import "UserInfo.h"
#import "UIImageView+WebCache.h"
#import "MyControl.h"


#define  offset_left                10      //用户头像左边距
#define  offset_down                10      //用户头像下边距
#define  size_avatar                98/2    //用户头像大小
#define  offset_avatarandlabel      7       //用户头像和用户名间德间距



@implementation UserImageViewCell
@synthesize imageView_userPhoto = _imageView_userPhoto;
@synthesize imageView_userAvatar = _imageView_userAvatar;
//@synthesize imageView_userAvatar_withoutLogin = _imageView_userAvatar_withoutLogin;
@synthesize button_login = _button_login;
@synthesize imageView_gender = _imageView_gender;
@synthesize label_userName = _label_userName;
@synthesize label_userTitle = _label_userTitle;
@synthesize label_userFans = _label_userFans;
@synthesize label_userFollow = _label_userFollow;
@synthesize delegate = _delegate;
@synthesize follow_status = _follow_status;
@synthesize user_id = _user_id;
@synthesize view_back = _view_back;
@synthesize intervalLine = _intervalLine;
@synthesize button_follow = _button_follow;
@synthesize button_personalLetter = _button_personalLetter;
@synthesize control_userPhoto;
@synthesize control_changeAvatar;
@synthesize image_avatar;
@synthesize image_photo;

-(void)dealloc
{
    //change bu zyh
//    QY_VIEW_RELEASE(_button_login);
//    QY_VIEW_RELEASE(_imageView_userAvatar_withoutLogin);
    QY_VIEW_RELEASE(_label_userFollow);
    QY_VIEW_RELEASE(_label_userFans);
    QY_VIEW_RELEASE(_label_userTitle);
    QY_VIEW_RELEASE(_label_userName);
    QY_VIEW_RELEASE(_imageView_gender);
    QY_VIEW_RELEASE(_control_changeAvatar);
    QY_VIEW_RELEASE(_control_userPhoto);
    QY_VIEW_RELEASE(_view_back);
    QY_VIEW_RELEASE(_imageView_userAvatar);
    QY_VIEW_RELEASE(_imageView_userPhoto);
    
    self.image_photo = nil;
    self.image_avatar = nil;
    self.follow_status = nil;
    self.delegate = nil;
    
    [super dealloc];
}


-(void)loginOut_Success
{
    self.image_avatar = nil;
    self.image_photo = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut_Success) name:@"loginoutsuccess" object:nil];
        
        _imageView_userPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_imageView_user)];
        _imageView_userPhoto.contentMode = UIViewContentModeScaleAspectFill;
        _imageView_userPhoto.clipsToBounds = YES;
        _imageView_userPhoto.backgroundColor = [UIColor clearColor];
        _imageView_userPhoto.userInteractionEnabled = YES;
        [self addSubview:_imageView_userPhoto];
        _control_userPhoto = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, _imageView_userPhoto.frame.size.width, _imageView_userPhoto.frame.size.height) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [_control_userPhoto addTarget:self action:@selector(changePhoto) forControlEvents:UIControlEventTouchUpInside];
        [_imageView_userPhoto addSubview:_control_userPhoto];
        _control_userPhoto.alpha = 0;
        
        
        _view_back = [[UIView alloc] initWithFrame:CGRectMake(0, _imageView_userPhoto.frame.size.height-66/2, 320, 66/2)];
        _view_back.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [_imageView_userPhoto addSubview:_view_back];
        
        
        
        
//        UIImageView *userAvatar_default = [[UIImageView alloc] initWithFrame:CGRectMake(offset_left+0.5, height_imageView_user-offset_down-size_avatar+0.5, size_avatar-1, size_avatar-1)];
//        userAvatar_default.backgroundColor = [UIColor clearColor];
//        userAvatar_default.image = [UIImage imageNamed:@"avatar_default"];
//        userAvatar_default.layer.masksToBounds = YES;
//        [userAvatar_default.layer setCornerRadius:24];
//        [_imageView_userPhoto addSubview:userAvatar_default];
//        [userAvatar_default release];
        _imageView_userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(offset_left, height_imageView_user-offset_down-size_avatar, size_avatar, size_avatar)];
        _imageView_userAvatar.userInteractionEnabled = YES;
        _imageView_userAvatar.backgroundColor = [UIColor clearColor];
        _imageView_userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        _imageView_userAvatar.clipsToBounds = YES;
        _imageView_userAvatar.layer.masksToBounds = YES;
        [_imageView_userAvatar.layer setCornerRadius:24];
        [_imageView_userAvatar.layer setBorderWidth:0.5];
        [_imageView_userAvatar.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_imageView_userPhoto addSubview:_imageView_userAvatar];
        _control_changeAvatar = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, size_avatar, size_avatar) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [_control_changeAvatar addTarget:self action:@selector(changeAvatar) forControlEvents:UIControlEventTouchUpInside];
        [_imageView_userAvatar addSubview:_control_changeAvatar];
        _control_changeAvatar.alpha = 0;
        
        
        
        _label_userName = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_userAvatar.frame.origin.x+_imageView_userAvatar.frame.size.width+offset_avatarandlabel, _imageView_userAvatar.frame.origin.y+2, 245, 20)];
        _label_userName.textAlignment = NSTextAlignmentLeft;
        _label_userName.font = [UIFont systemFontOfSize:15];
        _label_userName.shadowColor = [UIColor blackColor];
        _label_userName.shadowOffset = CGSizeMake(0, 0.3);
        _label_userName.textColor = [UIColor whiteColor];
        _label_userName.backgroundColor = [UIColor clearColor];
        [_imageView_userPhoto addSubview:_label_userName];
        
        
        _imageView_gender = [[UIImageView alloc] initWithFrame:CGRectMake(_label_userName.frame.origin.x, (_view_back.frame.size.height-14)/2, 14, 14)];
        _imageView_gender.backgroundColor = [UIColor clearColor];
        [_view_back addSubview:_imageView_gender];
        
        
        _label_userTitle = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_gender.frame.origin.x+_imageView_gender.frame.size.width+offset_avatarandlabel, (_view_back.frame.size.height-20)/2, 60, 20)];
        _label_userTitle.backgroundColor = [UIColor clearColor];
        _label_userTitle.textColor = [UIColor whiteColor];
        _label_userTitle.font = [UIFont systemFontOfSize:12];
        [_view_back addSubview:_label_userTitle];
        
        
        _label_userFollow = [[UILabel alloc] initWithFrame:CGRectMake(_label_userTitle.frame.origin.x+_label_userTitle.frame.size.width+90, (_view_back.frame.size.height-20)/2, 70, 20)];
        _label_userFollow.textColor = [UIColor whiteColor];
        _label_userFollow.font = [UIFont systemFontOfSize:14];
        _label_userFollow.textAlignment = NSTextAlignmentCenter;
        _label_userFollow.backgroundColor = [UIColor clearColor];
        [_view_back addSubview:_label_userFollow];
        
        
        _intervalLine = [[UILabel alloc] initWithFrame:CGRectMake(_label_userFollow.frame.origin.x+_label_userFollow.frame.size.width+10, (_view_back.frame.size.height-14)/2, 0.5, 14)];
        _intervalLine.backgroundColor = [UIColor whiteColor];
        [_view_back addSubview:_intervalLine];
        
        
        _label_userFans = [[UILabel alloc] initWithFrame:CGRectMake(_label_userFollow.frame.origin.x+_label_userFollow.frame.size.width+21, (_view_back.frame.size.height-20)/2, 75, 20)];
        _label_userFans.textColor = [UIColor whiteColor];
        _label_userFans.font = [UIFont systemFontOfSize:14];
        _label_userFans.backgroundColor = [UIColor clearColor];
        _label_userFans.textAlignment = NSTextAlignmentCenter;
        [_view_back addSubview:_label_userFans];
        
        
        _button_follow = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_follow.frame = CGRectMake(132/2, 40/2, 190/2, 58/2);
        _button_follow.backgroundColor = [UIColor clearColor];
        [_button_follow addTarget:self action:@selector(addFollow) forControlEvents:UIControlEventTouchUpInside];
        [_imageView_userPhoto addSubview:_button_follow];
        _button_follow.hidden = YES;
        
        
        _button_personalLetter = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_personalLetter.frame = CGRectMake(_button_follow.frame.origin.x+_button_follow.frame.size.width+10, 40/2, 190/2, 58/2);
        _button_personalLetter.backgroundColor = [UIColor clearColor];
        [_button_personalLetter addTarget:self action:@selector(sendPersonalLetter) forControlEvents:UIControlEventTouchUpInside];
        [_imageView_userPhoto addSubview:_button_personalLetter];
        _button_personalLetter.hidden = YES;
        
        
//        _imageView_userAvatar_withoutLogin = [[UIImageView alloc] initWithFrame:CGRectMake((320-98/2)/2., 44, 98/2, 98/2)];
//        _imageView_userAvatar_withoutLogin.backgroundColor = [UIColor clearColor];
//        _imageView_userAvatar_withoutLogin.image = [UIImage imageNamed:@"头像"];
//        [_imageView_userPhoto addSubview:_imageView_userAvatar_withoutLogin];
        
        _button_login = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_login.frame = CGRectMake((320-308/2)/2., _imageView_userPhoto.bounds.size.height-168/2-82/2, 308/2, 168/2);
        [_button_login setBackgroundImage:[UIImage imageNamed:@"登陆btn"] forState:UIControlStateNormal];
        _button_login.backgroundColor = [UIColor clearColor];
        [_imageView_userPhoto addSubview:_button_login];
        [_button_login addTarget:self action:@selector(loginIn) forControlEvents:UIControlEventTouchUpInside];
        _imageView_userPhoto.userInteractionEnabled = YES;
        
    }
    return self;
}

-(void)initWithNotLogin
{
    self.view_back.hidden = YES;
    self.imageView_userAvatar.hidden = YES;
    //self.imageView_userAvatar_withoutLogin.hidden = NO;
    self.button_login.hidden = NO;
    self.button_follow.hidden = YES;
    self.button_personalLetter.hidden = YES;
    _control_changeAvatar.alpha = 0;
    _control_userPhoto.alpha = 0;
    self.label_userName.text = @"";
    
    
    [_imageView_userPhoto setImage:[UIImage imageNamed:@"个人中心"]];
    
}

-(void)initInfoWithUserData:(UserInfo *)userinfo mine:(BOOL)flag
{
    self.view_back.hidden = NO;
    self.imageView_userAvatar.hidden = NO;
    //self.imageView_userAvatar_withoutLogin.hidden = YES;
    self.button_login.hidden = YES;
    _control_userPhoto.backgroundColor = [UIColor clearColor];
    
    
    if(flag) //自己的主页
    {
        self.button_follow.hidden = YES;
        self.button_personalLetter.hidden = YES;
        _control_changeAvatar.alpha = 1;
        _control_userPhoto.alpha = 1;
    }
    else //他人的个人中心
    {
        self.button_follow.hidden = NO;
        self.button_personalLetter.hidden = NO;
        _control_changeAvatar.alpha = 0;
        _control_userPhoto.alpha = 0;
        
        [self.button_personalLetter setBackgroundImage:[UIImage imageNamed:@"send mail"] forState:UIControlStateNormal];
        
        self.user_id = userinfo.user_id;
        
        if(userinfo.follow_status)
        {
            self.follow_status = userinfo.follow_status;
            
            NSString *str = @"";
            if([userinfo.follow_status isEqualToString:@"关注 TA"] || [userinfo.follow_status isEqualToString:@"关注TA"])
            {
                str = @"follow";
            }
            else if([userinfo.follow_status isEqualToString:@"已关注"])
            {
                str = @"following";
            }
            else if([userinfo.follow_status isEqualToString:@"相互关注"])
            {
                str = @"friends";
            }
            [self.button_follow setBackgroundImage:[UIImage imageNamed:str] forState:UIControlStateNormal];
        }
    }
    
    

    if(self.image_photo)
    {
        [_imageView_userPhoto setImageWithURL:[NSURL URLWithString:userinfo.cover] placeholderImage:self.image_photo success:^(UIImage *image){
            self.image_photo = image;
        } failure:nil];
    }
    else
    {
        [_imageView_userPhoto setImageWithURL:[NSURL URLWithString:userinfo.cover] placeholderImage:[UIImage imageNamed:@"个人中心"] success:^(UIImage *image){
            self.image_photo = image;
        } failure:nil];
    }
    
    if(self.image_avatar)
    {
        [_imageView_userAvatar setImageWithURL:[NSURL URLWithString:userinfo.avatar] placeholderImage:self.image_avatar success:^(UIImage *image){
            self.image_avatar = image;
        } failure:nil];
    }
    else
    {
        [_imageView_userAvatar setImageWithURL:[NSURL URLWithString:userinfo.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"] success:^(UIImage *image){
            self.image_avatar = image;
        } failure:nil];
    }
    _label_userName.text = userinfo.username;
    
    
    
    self.label_userTitle.text = userinfo.title;
    self.label_userTitle.frame = CGRectMake(_imageView_gender.frame.origin.x+_imageView_gender.frame.size.width+offset_avatarandlabel, _imageView_gender.frame.origin.y-3, 60, 20);
    
    if(userinfo.gender == 0) //性别保密
    {
        _imageView_gender.hidden = YES;
        _label_userTitle.frame = CGRectMake(_imageView_gender.frame.origin.x, _imageView_gender.frame.origin.y-3, 120, 20);
    }
    else
    {
        _imageView_gender.hidden = NO;
        NSString *str = (userinfo.gender == 1 ? @"male" : @"famale");
        UIImage *image = [UIImage imageNamed:str];
        _imageView_gender.image = image;
    }

    
    
    if(userinfo.follow < 10000)
    {
        self.label_userFollow.text = [NSString stringWithFormat:@"%d 关注",userinfo.follow];
    }
    else
    {
        self.label_userFollow.text = [NSString stringWithFormat:@"%d.%d 万关注",userinfo.follow/10000,userinfo.follow%10000/1000];
    }
    if(userinfo.fans < 10000)
    {
        self.label_userFans.text = [NSString stringWithFormat:@"%d 粉丝",userinfo.fans];
    }
    else
    {
        self.label_userFans.text = [NSString stringWithFormat:@"%d.%d 万粉丝",userinfo.fans/10000,userinfo.fans%10000/1000];
    }
    
    
    
    //调整label_userFans的位置与大小:
    float width = [self countContentLabelHeightByString:self.label_userFans.text andHeight:self.label_userFans.frame.size.height andFontSize:14];
    CGRect frame = self.label_userFans.frame;
    frame.size.width = width;
    frame.origin.x = 320-(width+10);
    self.label_userFans.frame = frame;
    [self.view_back addSubview:self.label_userFans];
    MyControl *control_fans = [[MyControl alloc] initWithFrame:CGRectMake(self.label_userFans.frame.origin.x-10, 0, self.label_userFans.frame.size.width+20, self.label_userFans.superview.frame.size.height) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    control_fans.tag = 1;
    [control_fans addTarget:self action:@selector(showFollowsAndFans:) forControlEvents:UIControlEventTouchUpInside];
    [self.view_back insertSubview:control_fans belowSubview:self.label_userFans];
    [control_fans release];
    
    
    
    //调整_intervalLine的位置:
    frame = self.intervalLine.frame;
    frame.origin.x = self.label_userFans.frame.origin.x-10;
    self.intervalLine.frame = frame;
    
    
    
    //调整_label_userFollow的位置与大小:
    self.label_userFollow.backgroundColor = [UIColor clearColor];
    frame = self.label_userFollow.frame;
    width = [self countContentLabelHeightByString:self.label_userFollow.text andHeight:self.label_userFollow.frame.size.height andFontSize:14];
    frame.origin.x = self.intervalLine.frame.origin.x-10-width;
    frame.size.width = width;
    self.label_userFollow.frame = frame;
    [self.view_back addSubview:self.label_userFollow];
    MyControl *control_follows = [[MyControl alloc] initWithFrame:CGRectMake(self.label_userFollow.frame.origin.x-10, 0, self.label_userFollow.frame.size.width+20, self.label_userFollow.superview.frame.size.height) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    control_follows.tag = 2;
    [control_follows addTarget:self action:@selector(showFollowsAndFans:) forControlEvents:UIControlEventTouchUpInside];
    [self.view_back insertSubview:control_follows belowSubview:self.label_userFollow];
    [control_follows release];
    
}



#pragma mark -
#pragma mark --- 计算String所占的宽度
-(float)countContentLabelHeightByString:(NSString *)content andHeight:(float)height andFontSize:(float)font
{
    //CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName_ size:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)];
    
    return sizeToFit.width;
}



#pragma mark -
#pragma mark --- 关注 & 私信 & 更换头像
-(void)loginIn
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(loginIn:)])
    {
        [self.delegate loginIn:self];
    }
}
-(void)addFollow
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(addFollow:)])
    {
        [self.delegate addFollow:self];
    }
}
-(void)sendPersonalLetter
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(sendPersonaLetter:)])
    {
        [self.delegate sendPersonaLetter:self];
    }
}
-(void)showFollowsAndFans:(id)sender
{
    MyControl *control = (MyControl *)sender;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(showFollowsAndFans:withType:)])
    {
        if(control.tag == 1)
        {
            [self.delegate showFollowsAndFans:self withType:@"fans"];
        }
        else if(control.tag == 2)
        {
            [self.delegate showFollowsAndFans:self withType:@"follows"];
        }
    }
}
-(void)changeAvatar
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(changeUserAvatar:)])
    {
        [self.delegate changeUserAvatar:self];
    }
}
-(void)changePhoto
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(changeUserPhoto:)])
    {
        [self.delegate changeUserPhoto:self];
    }
}


#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
