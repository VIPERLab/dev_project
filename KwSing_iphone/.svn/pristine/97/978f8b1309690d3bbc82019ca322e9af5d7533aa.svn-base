//
//  WelcomeView.m
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-28.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "WelcomeView.h"
#include "ImageMgr.h"
#include "KwTools.h"
#include "globalm.h"
#include "KwConfig.h"
#include "KwConfigElements.h"

@interface WelcomeView () <UIScrollViewDelegate>
{
    UIScrollView* pScrollView;
    UIButton* pButton;
    int nTotalPage;
}

- (void)dealloc;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)onClickBtn:(id)sender;

@end

@implementation WelcomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        
        pScrollView=[[[UIScrollView alloc] initWithFrame:frame] autorelease];
        [self addSubview:pScrollView];
        
        while (true) {
            UIImage* pImg=CImageMgr::GetImageEx(KwTools::StringUtility::Format("welcome%d.jpg",nTotalPage+1).c_str());
            if (!pImg) {
                break;
            }
            
            UIImageView* pView=[[[UIImageView alloc] initWithImage:pImg] autorelease];
            pView.frame=CGRectMake(frame.size.width*nTotalPage, 0, frame.size.width, frame.size.height);
            [pScrollView addSubview:pView];
            
            ++nTotalPage;
        }
        if (nTotalPage) {
            pScrollView.contentSize=CGSizeMake(frame.size.width*nTotalPage, frame.size.height);
        }
        pScrollView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.7];
        pScrollView.showsVerticalScrollIndicator=NO;
        pScrollView.showsHorizontalScrollIndicator=NO;
        pScrollView.delegate=self;
        pScrollView.scrollEnabled=YES;
        pScrollView.pagingEnabled=YES;
        pScrollView.bounces=YES;
        
        CGRect rcBtn=BottomRect(frame, 47, 48);
        pButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [pButton setFrame:rcBtn];
        [self addSubview:pButton];
        pButton.adjustsImageWhenHighlighted=FALSE;
        [pButton setImage:CImageMgr::GetImageEx("welcomebtnDown.png") forState:UIControlStateHighlighted];
        [pButton setImage:CImageMgr::GetImageEx("welcomebtnDown.png") forState:UIControlStateDisabled];
        [pButton addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        pButton.hidden=YES;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(pScrollView.contentOffset.x-self.bounds.size.width*(nTotalPage-1)>80) {
        [self onClickBtn:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int nPage=fabs(pScrollView.contentOffset.x)/self.bounds.size.width;

    if (nPage==nTotalPage-1 && pButton.hidden) {
        pButton.hidden=NO;
    } else if(nPage==nTotalPage-2 && !pButton.hidden) {
        pButton.hidden=YES;
    }
}

- (void)onClickBtn:(id)sender
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=0.0;
    } completion:^(BOOL bFinished){
        [self removeFromSuperview];
        KwConfig::GetConfigureInstance()->SetConfigBoolValue(SPLASH_NEW_GROUP, SPLASH_FINISH, true);
    }];
}

- (void)dealloc
{
    for (int i=0; i<nTotalPage; ++i) {
        std::string strName=KwTools::StringUtility::Format("welcome%d.jpg",i+1);
        CImageMgr::RemoveImage(strName.c_str());
    }
    
    CImageMgr::RemoveImage("welcomebtnNormal.png");
    CImageMgr::RemoveImage("welcomebtnDown.png");
    
    [super dealloc];
}


@end
