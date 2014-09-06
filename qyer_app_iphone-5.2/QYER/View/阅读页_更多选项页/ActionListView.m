//
//  ActionListView.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-12-19.
//
//

#import "ActionListView.h"



#define  width_actionView       180/2
#define  height_actionView      180/2
#define  height_interval        60/2



@implementation ActionListView


-(void)dealloc
{
    QY_VIEW_RELEASE(control);
    
    self.image_n = nil;
    self.image_h = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code
    }
    return self;
}




#pragma mark -
#pragma mark --- 单例
static ActionListView *sharedActionListView = nil;
+(ActionListView *)sharedActionListView
{
    @synchronized(sharedActionListView)
    {
        if(!sharedActionListView)
        {
            sharedActionListView = [[self alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
        }
        return sharedActionListView;
    }
}





#pragma mark -
#pragma mark --- 锦囊阅读页使用
-(void)showActionListViewInGuideReaderView:(UIView *)view andDelegate:(id)delegate
{
    [view addSubview:sharedActionListView];
    sharedActionListView.delegate = delegate;
    sharedActionListView.userInteractionEnabled = YES;
    
    [sharedActionListView initBackGroundView];
    [sharedActionListView initActionListView_guideReader];
    [sharedActionListView addAnimation];
}
-(void)initBackGroundView
{
    if(!control)
    {
        control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    }
    [control addTarget:sharedActionListView action:@selector(doCancle) forControlEvents:UIControlEventTouchUpInside];
    control.tag = 110;
    control.backgroundColor = [UIColor blackColor];
    control.alpha = 0.1;
    [sharedActionListView addSubview:control];
}
-(void)initActionListView_guideReader
{
    _flag_plan = NO;
    
    if(!_butAddBookMark)
    {
        _butAddBookMark = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _butAddBookMark.frame = CGRectMake((320-width_actionView)/2., ([[UIScreen mainScreen] bounds].size.height-(height_actionView*3 + 60))/2., width_actionView, height_actionView);
    _butAddBookMark.backgroundColor = [UIColor clearColor];
    if(sharedActionListView.image_n)
    {
        [_butAddBookMark setBackgroundImage:sharedActionListView.image_n forState:UIControlStateNormal];
        [_butAddBookMark setBackgroundImage:sharedActionListView.image_h forState:UIControlStateHighlighted];
    }
    else
    {
        [_butAddBookMark setBackgroundImage:[UIImage imageNamed:@"btn_reader_bookmark_.png"] forState:UIControlStateNormal];
        [_butAddBookMark setBackgroundImage:[UIImage imageNamed:@"btn_reader_bookmark_pressed.png"] forState:UIControlStateHighlighted];
    }
    [_butAddBookMark addTarget:sharedActionListView action:@selector(doAddBookMark) forControlEvents:UIControlEventTouchUpInside];
    [sharedActionListView addSubview:_butAddBookMark];
    _butAddBookMark.alpha = 0;
    _butAddBookMark.tag = 120;
    
    
    if(!_butShare)
    {
        _butShare = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _butShare.frame = CGRectMake((320-width_actionView)/2., _butAddBookMark.frame.origin.y+_butAddBookMark.frame.size.height + height_interval, width_actionView, height_actionView);
    _butShare.backgroundColor = [UIColor clearColor];
    [_butShare setBackgroundImage:[UIImage imageNamed:@"btn_reader_share_.png"] forState:UIControlStateNormal];
    [_butShare setBackgroundImage:[UIImage imageNamed:@"btn_reader_share_pressed.png"] forState:UIControlStateHighlighted];
    [_butShare addTarget:sharedActionListView action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    [sharedActionListView addSubview:_butShare];
    _butShare.alpha = 0;
    _butShare.tag = 121;
    
    
    if(!_butFeedBack)
    {
        _butFeedBack = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _butFeedBack.frame = CGRectMake((320-width_actionView)/2., _butShare.frame.origin.y+_butShare.frame.size.height + height_interval, width_actionView, height_actionView);
    _butFeedBack.backgroundColor = [UIColor clearColor];
    [_butFeedBack setBackgroundImage:[UIImage imageNamed:@"btn_reader_feedback_.png"] forState:UIControlStateNormal];
    [_butFeedBack setBackgroundImage:[UIImage imageNamed:@"btn_reader_feedback_pressed.png"] forState:UIControlStateHighlighted];
    [_butFeedBack addTarget:sharedActionListView action:@selector(doFeedBack) forControlEvents:UIControlEventTouchUpInside];
    [sharedActionListView addSubview:_butFeedBack];
    _butFeedBack.alpha = 0;
    _butFeedBack.tag = 122;
    
}
-(void)changeBookMarImageViewWithNormalImage:(UIImage *)image_n andHighLightImage:(UIImage *)image_h
{
    if(image_n)
    {
        sharedActionListView.image_n = image_n;
        [_butAddBookMark setBackgroundImage:image_n forState:UIControlStateNormal];
    }
    
    if(image_h)
    {
        sharedActionListView.image_h = image_h;
        [_butAddBookMark setBackgroundImage:image_h forState:UIControlStateHighlighted];
    }
}
-(void)addAnimation
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         [sharedActionListView viewWithTag:110].alpha = 0.7;
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              [sharedActionListView viewWithTag:120].alpha = 1;
                                              [sharedActionListView viewWithTag:121].alpha = 1;
                                              [sharedActionListView viewWithTag:122].alpha = 1;
                                              if(_flag_plan)
                                              {
                                                  [sharedActionListView viewWithTag:123].alpha = 1;
                                              }
                                          } completion:^(BOOL finished){
                                              
                                          }];
                     }];
}
-(void)doAddBookMark
{
    if(sharedActionListView.delegate && [sharedActionListView.delegate respondsToSelector:@selector(addBookMark)])
    {
        [sharedActionListView.delegate addBookMark];
    }
}
-(void)doShare
{
    if(sharedActionListView.delegate && [sharedActionListView.delegate respondsToSelector:@selector(share)])
    {
        [sharedActionListView.delegate share];
    }
}
-(void)doFeedBack
{
    if(sharedActionListView.delegate && [sharedActionListView.delegate respondsToSelector:@selector(feedBack)])
    {
        [sharedActionListView.delegate feedBack];
    }
}
-(void)doFresh
{
    if(sharedActionListView.delegate && [sharedActionListView.delegate respondsToSelector:@selector(clickRefresh_plan)])
    {
        [sharedActionListView.delegate clickRefresh_plan];
    }
}
-(void)doCancle
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         [sharedActionListView viewWithTag:110].alpha = 0;
                         [sharedActionListView viewWithTag:120].alpha = 0;
                         [sharedActionListView viewWithTag:121].alpha = 0;
                         [sharedActionListView viewWithTag:122].alpha = 0;
                         [sharedActionListView viewWithTag:123].alpha = 0;
                         
                     } completion:^(BOOL finished){
                         
                         [sharedActionListView removeFromSuperview];
                         [sharedActionListView release];
                         sharedActionListView = nil;
                     }];
}




#pragma mark -
#pragma mark --- 我的行程页使用
-(void)showActionListViewInMyPlanView:(UIView *)view andDelegate:(id)delegate
{
    [view addSubview:sharedActionListView];
    sharedActionListView.delegate = delegate;
    sharedActionListView.userInteractionEnabled = YES;
    
    [sharedActionListView initBackGroundView];
    [sharedActionListView initActionListView_myplan];
    [sharedActionListView addAnimation];
}
-(void)initActionListView_myplan
{
    _flag_plan = YES;
    
    if(!_butShare)
    {
        _butShare = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _butShare.frame = CGRectMake((320-width_actionView)/2., ([[UIScreen mainScreen] bounds].size.height-(height_actionView*2 + 60))/2., width_actionView, height_actionView);
    _butShare.backgroundColor = [UIColor clearColor];
    [_butShare setBackgroundImage:[UIImage imageNamed:@"分享btn"] forState:UIControlStateNormal];
    [_butShare setBackgroundImage:[UIImage imageNamed:@"分享btn_pressed"] forState:UIControlStateHighlighted];
    [_butShare addTarget:sharedActionListView action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    [sharedActionListView addSubview:_butShare];
    _butShare.alpha = 0;
    _butShare.tag = 121;
    
    
    if(!_butFresh)
    {
        _butFresh = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _butFresh.frame = CGRectMake((320-width_actionView)/2., _butShare.frame.origin.y+_butShare.frame.size.height + height_interval, width_actionView, height_actionView);
    _butFresh.backgroundColor = [UIColor clearColor];
    [_butFresh setBackgroundImage:[UIImage imageNamed:@"刷新btn"] forState:UIControlStateNormal];
    [_butFresh setBackgroundImage:[UIImage imageNamed:@"刷新btn_pressed"] forState:UIControlStateHighlighted];
    [_butFresh addTarget:sharedActionListView action:@selector(doFresh) forControlEvents:UIControlEventTouchUpInside];
    [sharedActionListView addSubview:_butFresh];
    _butFresh.alpha = 0;
    _butFresh.tag = 123;
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end

