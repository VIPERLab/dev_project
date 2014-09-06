//
//  WantGo_hasGoneCell.h
//  QYER
//
//  Created by 我去 on 14-5-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WantGo_hasGoneCellDelegate;
@interface WantGo_hasGoneCell : UITableViewCell
{
    UIView          *_backgroundView_left;
    UIView          *_backgroundView_right;
    UIImageView     *_imageView_cityPhoto_left;
    UILabel         *_label_info_left;
    UIImageView     *_imageView_cityPhoto_right;
    UILabel         *_label_info_right;
    
    UILabel         *_label_cityName_cn_left;
    UILabel         *_label_cityName_en_left;
    UILabel         *_label_cityName_cn_right;
    UILabel         *_label_cityName_en_right;
}
@property(nonatomic,retain) UIImageView     *imageView_cityPhoto_left;
@property(nonatomic,retain) UILabel         *label_info_left;
@property(nonatomic,retain) UIImageView     *imageView_cityPhoto_right;
@property(nonatomic,retain) UILabel         *label_info_right;
@property(nonatomic,retain) UILabel         *label_cityName_cn_left;
@property(nonatomic,retain) UILabel         *label_cityName_en_left;
@property(nonatomic,retain) UILabel         *label_cityName_cn_right;
@property(nonatomic,retain) UILabel         *label_cityName_en_right;
@property(nonatomic,assign) NSInteger       cityId_left;
@property(nonatomic,assign) NSInteger       cityId_right;
@property(nonatomic,assign) id<WantGo_hasGoneCellDelegate> delegate;
-(void)initDataWithWantGoData:(NSArray *)array atIndex:(NSInteger)position type:(NSString *)type;
@end




#pragma mark -
#pragma mark --- WantGo_hasGoneCell - Delegate
@protocol WantGo_hasGoneCellDelegate <NSObject>
-(void)selectedLeftImageViewWithCityId:(NSInteger)cityid andCityName:(NSString *)cityname;
-(void)selectedRightImageViewWithCityId:(NSInteger)cityid andCityName:(NSString *)cityname;
@end

