//
//  PoiImageCell.h
//  QyGuide
//
//  Created by an qing on 13-2-19.
//
//

#import <UIKit/UIKit.h>
#import "MyPoiImageViewControl.h"

@protocol PoiImageCellDelegate;

@interface PoiImageCell : UITableViewCell
{
    UIView      *_bgView;
    
    UIImageView *_imageView1;
    UIImageView *_imageView2;
    UIImageView *_imageView3;
    UIImageView *_imageView4;
    MyPoiImageViewControl   *_control1;
    MyPoiImageViewControl   *_control2;
    MyPoiImageViewControl   *_control3;
    MyPoiImageViewControl   *_control4;
//    UIActivityIndicatorView *_active1;
//    UIActivityIndicatorView *_active2;
//    UIActivityIndicatorView *_active3;
//    UIActivityIndicatorView *_active4;
    
    
    id<PoiImageCellDelegate>   _delegate;
}
@property(nonatomic,retain) UIView      *bgView;
@property(nonatomic,retain) UIImageView *imageView1;
@property(nonatomic,retain) UIImageView *imageView2;
@property(nonatomic,retain) UIImageView *imageView3;
@property(nonatomic,retain) UIImageView *imageView4;
@property(nonatomic,retain) MyPoiImageViewControl   *control1;
@property(nonatomic,retain) MyPoiImageViewControl   *control2;
@property(nonatomic,retain) MyPoiImageViewControl   *control3;
@property(nonatomic,retain) MyPoiImageViewControl   *control4;
//@property(nonatomic,retain) UIActivityIndicatorView *active1;
//@property(nonatomic,retain) UIActivityIndicatorView *active2;
//@property(nonatomic,retain) UIActivityIndicatorView *active3;
//@property(nonatomic,retain) UIActivityIndicatorView *active4;
@property(nonatomic,assign) id<PoiImageCellDelegate> delegate;
//@property(nonatomic,retain) UILabel *ll;
@end


@protocol PoiImageCellDelegate <NSObject>
-(void)PoiImageCellDidSelected:(MyPoiImageViewControl *)control;
@end


