//
//  QYBaseViewController.h
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Toast+UIView.h"
#import "QyYhConst.h"
#import "QYToolObject.h"
#import "ChangeTableviewContentInset.h"
#import "NotReachableView.h"


#define     height_need_reduce          (ios7 ? 0 : 20)
#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (4+20) : 6)
#define     height_titlelabel           (ios7 ? (30) : 34)
#define     positionY_backbutton        (ios7 ? 20 : 0)
#define     positionY_sharebutton       (ios7 ? 20 : 0)

@class ILTranslucentView;


@interface QYBaseViewController : UIViewController<NotReachableViewDelegate>
{
//    ILTranslucentView * _headView;
    UIImageView *_headView;
    
    UILabel *_titleLabel;
    UIButton *_backButton;
    UIButton *_closeButton;
    UIButton *_rightButton;
    
    UIImageView *_notDataImageView;
    
    BOOL        _isScolling;//判断是否在左右滑动
}



@property(nonatomic,retain) NSString *buttontype;
- (void)clickBackButton:(UIButton *)btn;
- (void)clickCloseButton:(id)sender;
- (void)clickCloseButton:(id)sender completion: (void (^)(void))completion;
- (void)clickRightButton:(UIButton *)btn;

/**
 *  是否显示没有网络视图
 */
- (void)setNotReachableView:(BOOL)isVisible;
@end
