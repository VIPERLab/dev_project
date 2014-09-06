//
//  GuideAuthorDetailCell.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//


//*** 锦囊 - 锦囊作者简介cell


#import <UIKit/UIKit.h>
@class QYGuide;

@interface GuideAuthorDetailCell : UITableViewCell
{
    UIImageView     *_imageView_guideAuthorBackground;
    
    UILabel         *_label_authorName;
    UIImageView     *_imageView_authorIcon;
    UILabel         *_label_authorDetailInfo;
    UIImageView     *_imageView_lastCell;
}
@property(nonatomic,retain) UILabel         *label_authorName;
@property(nonatomic,retain) UIImageView     *imageView_authorIcon;
@property(nonatomic,retain) UILabel         *label_authorDetailInfo;

-(void)initCellWithGuideAuthorInfo:(QYGuide *)guide;
+(float)cellHeightWithContent:(NSString *)string;

@end

