//
//  ActionListView.h
//  QyGuide
//
//  Created by 你猜你猜 on 13-12-19.
//
//

#import <UIKit/UIKit.h>

@protocol ActionListViewDelegate;


@interface ActionListView : UIView
{
    UIControl *control;
    UIButton *_butAddBookMark;  //添加书签
    UIButton *_butShare;        //分享
    UIButton *_butFeedBack;     //反馈
    
    UIButton *_butFresh;        //刷新
    BOOL      _flag_plan;
}
@property (assign, nonatomic) id<ActionListViewDelegate> delegate;
@property (retain, nonatomic) UIImage  *image_n; //normal
@property (retain, nonatomic) UIImage  *image_h; //highLight
+(ActionListView *)sharedActionListView;
-(void)showActionListViewInGuideReaderView:(UIView *)view andDelegate:(id)delegate;
-(void)showActionListViewInMyPlanView:(UIView *)view andDelegate:(id)delegate;
-(void)changeBookMarImageViewWithNormalImage:(UIImage *)image_n andHighLightImage:(UIImage *)image_h;
-(void)doCancle;
@end




#pragma mark -
#pragma mark --- ActionListView - Delegate
@protocol ActionListViewDelegate <NSObject>
-(void)addBookMark;
-(void)share;
-(void)feedBack;
-(void)doFresh;
-(void)clickRefresh_plan;
@end

