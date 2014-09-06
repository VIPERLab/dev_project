//
//  PoiDetailInfoPlayTimeCell.h
//  QyGuide
//
//  Created by an qing on 13-2-22.
//
//

#import <UIKit/UIKit.h>

@interface PoiDetailInfoPlayTimeCell : UITableViewCell
{
    UIView      *_playTimeBackBgView;
    UILabel     *_playTimeLabel;
    UILabel     *_playTimeValueLabel;
    
    UIView      *_commentBackBgView;
    UILabel     *_commentNumLabel;
    UIImageView *_commentArrowImageV;
}

//@property(nonatomic,retain) UIView      *playTimeBackBgView;
//@property(nonatomic,retain) UIView      *commentBackBgView;
@property(nonatomic,retain) UILabel     *playTimeLabel;
@property(nonatomic,retain) UILabel     *playTimeValueLabel;
@property(nonatomic,retain) UILabel     *commentNumLabel;
@property(nonatomic,retain) UIImageView *commentArrowImageV;

@end

