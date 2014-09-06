//
//  BlackBoardCell.h
//  QYER
//
//  Created by Leno on 14-5-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RTLabel.h"

@interface BlackBoardCell : UITableViewCell
{
    UIView           * _backGroundView;
    UIImageView      * _whiteBoardImgView;
    UILabel          * _typeLabel;
    UIImageView      * _typeIconImgView;
    UIImageView      * _photoImgView;
    UILabel          * _titleLabel;
    UIImageView      * _gapLine;
    RTLabel          * _contentLabel;
    UIImageView      * _bottomImgView;
    UILabel          * _timeLabel;
    UIImageView      * _commentIconImgView;
    UILabel          * _commentNumberLabel;
    UIView           * _shadowView;//点击遮罩的View
    UIView           * _shadow1;
    UIView           * _shadow2;
}

//@property(retain,nonatomic)UIView           * backGroundView;
//@property(retain,nonatomic)UIImageView      * whiteBoardImgView;
//@property(retain,nonatomic)UILabel          * typeLabel;
//@property(retain,nonatomic)UIImageView      * typeIconImgView;
//@property(retain,nonatomic)UIImageView      * photoImgView;
//@property(retain,nonatomic)UILabel          * titleLabel;
//@property(retain,nonatomic)UIImageView      * gapLine;
//@property(retain,nonatomic)RTLabel          * contentLabel;
//@property(retain,nonatomic)UIImageView      * bottomImgView;
//@property(retain,nonatomic)UILabel          * timeLabel;
//@property(retain,nonatomic)UIImageView      * commentIconImgView;
//@property(retain,nonatomic)UILabel          * commentNumberLabel;
//
//
//@property(retain,nonatomic)UIView           * shadowView;//点击遮罩的View
//@property(retain,nonatomic)UIView           * shadow1;
//@property(retain,nonatomic)UIView           * shadow2;

-(void)setCellContentInfo:(NSDictionary *)dict;

@end


