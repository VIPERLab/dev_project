//
//  LastMinuteRecommendView.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-15.
//
//

#import <UIKit/UIKit.h>
@protocol LastMinuteRecommendViewDelegate;

@interface LastMinuteRecommendView : UIView
{
    UIView          *_superView;
    
    UIControl       *_backGround_control;
    UIView          *_homeView;
    UIImageView     *_imageview_icon;
    UILabel         *_label_other;
    UILabel         *_label_lastMinuteName;
    UILabel         *_label_price;
    float           originY;
    
    
    id<LastMinuteRecommendViewDelegate>   _delegate;
}
@property(nonatomic,assign) id<LastMinuteRecommendViewDelegate>  delegate;
-(void)showWithArray:(NSArray *)array andTitle:(NSString *)title inView:(UIView *)superView;

@end



#pragma mark -
#pragma mark --- LastMinuteRecommendView - Delegate
@protocol LastMinuteRecommendViewDelegate <NSObject>
-(void)LastMinuteCellSelectedPosition:(NSInteger)position;
-(void)LastMinuteViewDidHide;
@end