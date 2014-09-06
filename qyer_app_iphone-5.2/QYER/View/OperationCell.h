//
//  OperationCell.h
//  QyGuide
//
//  Created by an qing on 12-12-26.
//
//


//*** 首页 - 锦囊运营图片cell


#import <UIKit/UIKit.h>
#import "GuideViewController.h"

@interface OperationCell : UITableViewCell
{
    GuideViewController *RecommendGuideVC;
    
    UIImageView *backGroundView;
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    UIImageView *imageView4;
}

@property(nonatomic,retain) GuideViewController *RecommendGuideVC;

@property(nonatomic,retain) UIImageView *backGroundView;
@property(nonatomic,retain) UIImageView *imageView1;
@property(nonatomic,retain) UIImageView *imageView2;
@property(nonatomic,retain) UIImageView *imageView3;
@property(nonatomic,retain) UIImageView *imageView4;

@end


