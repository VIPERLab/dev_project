//
//  PoiRateView.h
//  QyGuide
//
//  Created by an qing on 13-3-5.
//
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#import "SlurImageView.h"

@class PoiAllCommentViewController;

@interface PoiRateView : UIView <UITextViewDelegate,DYRateViewDelegate>
{
    CGRect          _srcFrame;
    
    SlurImageView   *_bgView;
    UITextView      *_textView;
    DYRateView      *_rateView;
    UILabel         *_placeHoderLabel;
    NSString        *poiTitle;
    UIImageView     *_imageView_toast;
    UIButton        *_button_left;
    UIButton        *_button_right;
    
    BOOL            _hasCommented;  //是否已评论过
    
    PoiAllCommentViewController *_poiAllCommentVC_no_release;
}

@property(nonatomic,assign) NSInteger   poiId;
@property(nonatomic,retain) NSString    *commentId_user;
@property(nonatomic,assign) NSInteger   myRate;
@property(nonatomic,retain) NSString    *poiTitle;
@property(nonatomic,retain) UILabel     *placeHoderLabel;

-(void)setTextViewText:(NSString *)text;
-(PoiRateView *)initWithFrame:(CGRect)frame andLeftButTitle:(NSString*)leftTitle andRightButTitle:(NSString*)rightTitle andRate:(NSString*)rateStr andVC:(UIViewController*)vc;

@end
