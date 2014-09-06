//
//  LastMinuteView.h
//  LastMinute
//
//  Created by lide on 13-6-24.
//
//

#import <UIKit/UIKit.h>
#import "LastMinuteDeal.h"

@protocol LastMinuteViewDelegate;

@interface LastMinuteView : UIView <UIGestureRecognizerDelegate>
{
//    UIImageView         *_backgroundImageView;
    
//    UIView              *_maskView;
    
    UIImageView         *_lastMinuteImageView;
    UIImageView         *_redCard;
    
    UILabel             *_lastMinuteTitle;
    
    UIImageView         *_qyerOnlyImageView;//是否穷游儿独享1-是0-否
    UIImageView         *_qyerFirstImageView;//是否穷游首发1-是0-否
    UIImageView         *_qyerLabAuthImageView;//是否穷游实验室认证1-是0-否
    UIImageView         *_qyerTodayNewImageView;//是否今日首发1-是0-否
    
    UIImageView         *_iconTime;
    UILabel             *_finishDateLabel;
    
    UILabel             *_prefixLabel;
    UILabel             *_priceLabel;
    UILabel             *_suffixLabel;
    
    
    UIImageView         *_bottomImgView;
    
    
    LastMinuteDeal          *_lastMinute;
    
    id<LastMinuteViewDelegate>  _delegate;
}

@property (retain, nonatomic) LastMinuteDeal *lastMinute;

@property (assign, nonatomic) id<LastMinuteViewDelegate> delegate;

@end

@protocol LastMinuteViewDelegate <NSObject>

- (void)lastMinuteViewDidTap:(LastMinuteDeal *)lastMinute;

@end
