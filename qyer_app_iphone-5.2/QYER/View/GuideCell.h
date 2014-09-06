//
//  GuideCell.h
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomProessView;
@class QYGuide;
@class MyControl;


@protocol GuideCellDelegate;
@interface GuideCell : UITableViewCell
{
    QYGuide                 *_guide_left;
    QYGuide                 *_guide_right;
    UIImageView             *_imageView_left;
    UIImageView             *_imageView_right;
//    CustomProessView        *_progressView_left;
//    CustomProessView        *_progressView_right;
    UIProgressView          *_progressView_left;
    UIProgressView          *_progressView_right;
    MyControl               *_control_left;
    MyControl               *_control_right;
    UILabel                 *_labelState_left;
    UILabel                 *_labelState_right;
    
    UIView                  *_viewMask_left;    //左侧遮罩
    UIView                  *_viewMask_right;   //右侧遮罩
    
    
    UIImageView             *_imageView_update_left;     //标识本本锦囊有更新
    UIImageView             *_imageView_read_left;       //标识本本锦囊可阅读
    UIImageView             *_imageView_update_right;    //标识本本锦囊有更新
    UIImageView             *_imageView_read_right;      //标识本本锦囊可阅读
    
    id<GuideCellDelegate>   _delegate;
}
@property(nonatomic,retain) QYGuide                 *guide_left;
@property(nonatomic,retain) QYGuide                 *guide_right;
@property(nonatomic,retain) UIImageView             *imageView_left;
@property(nonatomic,retain) UIImageView             *imageView_right;
@property(nonatomic,assign) id<GuideCellDelegate>   delegate;
@property(nonatomic,assign) NSInteger               section;
@property(nonatomic,retain) NSIndexPath             *indexPath_left;
@property(nonatomic,retain) NSIndexPath             *indexPath_right;
//@property(nonatomic,retain) CustomProessView        *progressView_left;
//@property(nonatomic,retain) CustomProessView        *progressView_right;
@property(nonatomic,retain) UIProgressView          *progressView_left;
@property(nonatomic,retain) UIProgressView          *progressView_right;
@property(nonatomic,retain) UIImageView             *imageView_update_left;
@property(nonatomic,retain) UIImageView             *imageView_read_left;
@property(nonatomic,retain) UIImageView             *imageView_update_right;
@property(nonatomic,retain) UIImageView             *imageView_read_right;
@property(nonatomic,retain) UILabel                 *labelState_left;
@property(nonatomic,retain) UILabel                 *labelState_right;
-(void)initWithData:(NSArray *)array atIndexPath:(NSIndexPath *)indexPath_in;
@end







#pragma mark -
#pragma mark --- GuideCell  ---  Delegate
@protocol GuideCellDelegate <NSObject>
-(void)clickAtIndexPath:(NSIndexPath *)indexPath;
@end
