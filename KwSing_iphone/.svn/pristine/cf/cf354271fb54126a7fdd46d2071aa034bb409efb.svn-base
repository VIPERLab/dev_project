//
//  SquareView.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-7-31.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "SquareViewController.h"
#import "SegmentControl.h"
#include "ImageMgr.h"
#import "globalm.h"
#import "KSWebView.h"
#include "MobClick.h"
#include "MessageManager.h"
#include "IObserverApp.h"
#import "HotSongsView.h"
#import "KSongsView.h"
#import "NewSongsView.h"

#define HEADER_TITLE_HEIGHT 45
#define TAG_LABEL_SQURE_TITLE 110

@interface KSSquareViewController()<SegmentControlDelegate,IObserverApp>
{
    HotSongsView *hotSongsView;
    KSongsView *kSongsView;
    NewSongsView *newSongsView;
    
    UIView* subViewContainer;
}

- (void)segmentControl:(SegmentControl *)segmentControl selectedItemChanged:(NSUInteger)index;

-(void)IObserverApp_MemoryWarning;
@end

@implementation KSSquareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, 320, HEADER_TITLE_HEIGHT)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(108, 7, 104, 30)] autorelease];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTag:TAG_LABEL_SQURE_TITLE];
    [label_title setText:@"热门作品"];
    [self.view addSubview:label_title];
    
	UIImage* pTopBkImg=CImageMgr::GetImageEx("topBk.png");
    UIImageView * imageView = [[[UIImageView alloc]initWithImage:pTopBkImg]autorelease];
    CGRect rcBkg(self.view.bounds);
    rcBkg.size.height=pTopBkImg.size.height;
    rcBkg.origin.y += HEADER_TITLE_HEIGHT;
//    [imageView setFrame:rcBkg];
//    [self.view addSubview:imageView];
    
//    UIImage* pShadow=CImageMgr::GetImageEx("topShadow.png");
//    UIImageView * topshadowView = [[[UIImageView alloc]initWithImage:pShadow]autorelease];
//    CGRect rcshadow = rcBkg;
//    rcshadow.origin.y += rcshadow.size.height;
//    rcshadow.size.height = pShadow.size.height;
//    [topshadowView setFrame:rcshadow];
//    [self.view addSubview:topshadowView];
//    
//    UIImageView * SegBkView = [[[UIImageView alloc]init]autorelease];
//    CGRect rcSegBk = CGRectMake(27, 6, 267, 32);
//    [SegBkView setFrame:rcSegBk];
//    [SegBkView setImage:CImageMgr::GetImageEx("topNavSegBk_12.png")];
//    [self.view addSubview:SegBkView];
    
    SegmentControl *segctrl = [[[SegmentControl alloc]initWithFrame:CGRectMake(0, view_title.frame.size.height, 320, 45)] autorelease];
    segctrl.delegate = self;
    segctrl.segmentSize = CGSizeMake(106.5, 45);
    segctrl.segmentSpace = CGSizeMake(0, 0);
    [segctrl insertSegmentWithTitle:@"热门作品" atIndex:0 animated:NO];
    [segctrl insertSegmentWithTitle:@"K歌达人" atIndex:1 animated:NO];
    [segctrl insertSegmentWithTitle:@"最新作品" atIndex:2 animated:NO];
    
//    [segctrl setTextShadowColor:[UIColor blackColor]];
//    [segctrl setTextShadowColorSelected:[UIColor blackColor]];
    [segctrl setTextColor:[UIColor blackColor]];
    [segctrl setTextColorSelected:[UIColor blackColor]];
//
    [segctrl setSegmentBackgroundImageFirst: CImageMgr::GetImageEx("KgeSegementNormal.png") selectedImage:CImageMgr::GetImageEx("KgeSegmentSelected.png")];
     [segctrl setSegmentBackgroundImage: CImageMgr::GetImageEx("KgeSegementNormal.png") selectedImage:CImageMgr::GetImageEx("KgeSegmentSelected.png")];
     [segctrl setSegmentBackgroundImageLast: CImageMgr::GetImageEx("KgeSegementNormal.png") selectedImage:CImageMgr::GetImageEx("KgeSegmentSelected.png")];
    
     [[self view] addSubview:segctrl];
    
    CGRect rc = TopRect(self.view.bounds, self.view.bounds.size.height-rcBkg.size.height - HEADER_TITLE_HEIGHT, rcBkg.size.height + HEADER_TITLE_HEIGHT);
    subViewContainer=[[UIView alloc] initWithFrame:rc];
    [self.view addSubview:subViewContainer];
    
    [segctrl setSelectedSegmentIndex:0];
    
//    [self.view bringSubviewToFront:topshadowView];
    
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
}

- (void)dealloc
{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    [super dealloc];
}


- (void)tryHideSubView:(UIView*)pView
{
    if (!pView.hidden) {
        pView.hidden=YES;
        [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(pView)]];
    }
}

- (void)tryShowSubView:(UIView*)pView
{
    pView.hidden=NO;
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(pView)]];
}

-(void)segmentControl:(SegmentControl *)segmentControl selectedItemChanged:(NSUInteger)index
{
    [self tryHideSubView:hotSongsView];
    [self tryHideSubView:newSongsView];
    [self tryHideSubView:kSongsView];
    switch (index) {
        case 0: {
            if (!hotSongsView) {
                hotSongsView=[[[HotSongsView alloc] initWithFrame:subViewContainer.bounds] autorelease];
                [subViewContainer addSubview:hotSongsView];
            }
            [self tryShowSubView:hotSongsView];
            
            UILabel* label_title = (UILabel*)[self.view viewWithTag:TAG_LABEL_SQURE_TITLE];
            if (label_title) {
                [label_title setText:@"热门作品"];
            }
        }
            break;
        case 1: {
            if (!kSongsView) {
                kSongsView=[[[KSongsView alloc] initWithFrame:subViewContainer.bounds] autorelease];
                [subViewContainer addSubview:kSongsView];
            }
            [self tryShowSubView:kSongsView];
            UILabel* label_title = (UILabel*)[self.view viewWithTag:TAG_LABEL_SQURE_TITLE];
            if (label_title) {
                [label_title setText:@"K歌达人"];
            }
        }
            break;
        case 2: {
            if (!newSongsView) {
                newSongsView=[[[NewSongsView alloc] initWithFrame:subViewContainer.bounds] autorelease];
                [subViewContainer addSubview:newSongsView];
            }
            [self tryShowSubView:newSongsView];
            UILabel* label_title = (UILabel*)[self.view viewWithTag:TAG_LABEL_SQURE_TITLE];
            if (label_title) {
                [label_title setText:@"最新作品"];
            }
        }
            break;
        default: break;
    }
}


- (void)tryDestorySubView:(UIView**)ppView
{
    UIView*& pView=*ppView;
    if ( pView && pView.hidden) {
        [pView removeFromSuperview];
        pView=NULL;
    }
}

-(void)IObserverApp_MemoryWarning
{
    [self tryDestorySubView:&hotSongsView];
    [self tryDestorySubView:&newSongsView];
    [self tryDestorySubView:&kSongsView];
}

@end