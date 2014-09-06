//
//  BoadDetailTopCell.h
//  QYER
//
//  Created by Leno on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DidClickTopUserAvatarDelegate;

@interface BoadDetailTopCell : UITableViewCell
{
    UIView           * _backGroundView;
    UIButton         * _userAvatarButton;
    UILabel          * _userNameLabel;
    UILabel          * _postTimeLabel;
    UIImageView      * _gapImgeView;
    UILabel          * _titleLabel;
    UIImageView      * _contentImgView;
    UILabel          * _contentLabel;
}

@property (assign, nonatomic) id<DidClickTopUserAvatarDelegate> delegate;

//@property(retain,nonatomic)UIView           * backGroundView;
//@property(retain,nonatomic)UIButton         * userAvatarButton;
//@property(retain,nonatomic)UILabel          * userNameLabel;
//@property(retain,nonatomic)UILabel          * postTimeLabel;
//@property(retain,nonatomic)UIImageView      * gapImgeView;
//@property(retain,nonatomic)UILabel          * titleLabel;
//@property(retain,nonatomic)UIImageView      * contentImgView;
//@property(retain,nonatomic)UILabel          * contentLabel;

-(void)setContentInfo:(NSDictionary *)dict;

@end

@protocol DidClickTopUserAvatarDelegate<NSObject>
-(void)didClickTopUserAvatar;
@end





