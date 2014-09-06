//
//  SpecialGuideDetailCell.h
//  QyGuide
//
//  Created by an qing on 12-12-31.
//
//



//*** 锦囊的专题推荐cell



#import <UIKit/UIKit.h>

@interface SpecialGuideDetailCell : UITableViewCell
{
    UIImageView *backGroundView;
    
    UILabel *_titleDetailLabel;
    UILabel *_contentLabel;
}

@property(nonatomic,retain) UIImageView *backGroundView;

@property(nonatomic,retain) UILabel *titleDetailLabel;
@property(nonatomic,retain) UILabel *contentLabel;


@end

