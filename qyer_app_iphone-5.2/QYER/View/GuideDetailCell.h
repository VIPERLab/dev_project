//
//  GuideDetailCell.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//


//*** 锦囊简介cell


#import <UIKit/UIKit.h>
@class QYGuide;

@interface GuideDetailCell : UITableViewCell
{
    UIImageView     *_imageView_guideDetailBackground;
    
    UILabel         *_label_guideDetail;
    UIImageView     *_imageView_lastCell;
}
@property(nonatomic,retain) UILabel         *label_guideDetail;

-(void)initCellWithGuideDetailInfo:(QYGuide *)guide;
+(float)cellHeightWithContent:(NSString *)string;

@end

