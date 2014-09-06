//
//  WantGo_hasGoneCitiesCell.h
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyControl;

@protocol WantGo_hasGoneCitiesCellDelegate;
@interface WantGo_hasGoneCitiesCell : UITableViewCell
{
    UIView          *_backgroundView_left;
    UIView          *_backgroundView_right;
    UIImageView     *_imageView_poiPhoto_left;
    UILabel         *_label_reviewinfo_left;
    UIImageView     *_imageView_poiPhoto_right;
    UILabel         *_label_reviewinfo_right;
    UILabel         *_label_rate_left;
    UILabel         *_label_rate_right;
    UILabel         *_label_noRate_left;
    UILabel         *_label_noRate_right;
    UILabel         *_label_poiName_cn_left;
    UILabel         *_label_poiName_en_left;
    UILabel         *_label_poiName_cn_right;
    UILabel         *_label_poiName_en_right;
    
    UIButton        *_button_comment_left;
    UIButton        *_button_comment_right;
    MyControl       *control_poicomment_left;
    MyControl       *control_poicomment_right;
}
@property(nonatomic,retain) UIImageView     *imageView_poiPhoto_left;
@property(nonatomic,retain) UILabel         *label_reviewinfo_left;
@property(nonatomic,retain) UIImageView     *imageView_poiPhoto_right;
@property(nonatomic,retain) UILabel         *label_reviewinfo_right;
@property(nonatomic,retain) UILabel         *label_rate_left;
@property(nonatomic,retain) UILabel         *label_rate_right;
@property(nonatomic,retain) UILabel         *label_poiName_cn_left;
@property(nonatomic,retain) UILabel         *label_poiName_en_left;
@property(nonatomic,retain) UILabel         *label_poiName_cn_right;
@property(nonatomic,retain) UILabel         *label_poiName_en_right;
@property(nonatomic,retain) UILabel         *label_noRate_left;
@property(nonatomic,retain) UILabel         *label_noRate_right;
@property(nonatomic,assign) NSInteger       poiId_left;
@property(nonatomic,assign) NSInteger       poiId_right;
@property(nonatomic,assign) BOOL            flag_type;
@property(nonatomic,assign) id<WantGo_hasGoneCitiesCellDelegate> delegate;
-(id)initHasGoneWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andType:(BOOL)type;
-(id)initWantGoWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)initDataWithArray:(NSArray *)array atIndex:(NSInteger)position withType:(NSString *)type isMinInfo:(BOOL)flag;
@end






#pragma mark -
#pragma mark --- WantGo_hasGoneCitiesCell - Delegate
@protocol WantGo_hasGoneCitiesCellDelegate <NSObject>
-(void)selectedLeftImageViewWithPoiId:(NSInteger)poiid;
-(void)selectedRightImageViewWithPoiId:(NSInteger)poiid;
-(void)addCommentLeft:(WantGo_hasGoneCitiesCell *)cell;
-(void)addCommentRight:(WantGo_hasGoneCitiesCell *)cell;
-(void)updateCommentLeft:(MyControl *)control;
-(void)updateCommentRight:(MyControl *)control;
@end


