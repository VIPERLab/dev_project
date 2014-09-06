//
//  MusicLibViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "MusicLibViewController.h"
#include "KSWebView.h"
#include "SearchViewController.h"
#include "SegmentControl.h"
#include "ImageMgr.h"
#include "globalm.h"
#include "KSMusicLibDelegate.h"
#include "MessageManager.h"
#include "IMusicLibObserver.h"
#include "ArtistCatViewController.h"
#include "LocalMusicRequest.h"
#include "KSAppDelegate.h"
//#include "KSongViewController.h"
#include "NowPlayViewController.h"
#include "FooterTabBar.h"
#include "LocalMusicViewController.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "MobClick.h"
#include "MessageManager.h"
#include "IObserverApp.h"
#include "RankViewController.h"
#include "MySongsViewController.h"
#include "MyOpusData.h"

#define REFRESH_INTERVAL        1

@interface KSMusicLibViewController() <IObserverApp>
{
    UIView * subViewContainer;
    NSTimeInterval m_tLastClickPauseContinueBtnTime;
    
    RankViewController * RankView;
//    LocalMusicViewController * LocalMusicView;
//    KSMySongsViewController * MySongView;
    
    UIView * tipsView;
    
//    SegmentControl *segctrl;
}
//- (void) segmentControl:(SegmentControl*)segmentControl selectedItemChanged:(NSUInteger)index;

-(void)IObserverApp_MemoryWarning;

-(bool)hasShowTips;
-(void)showFirstInTips;
@end

@implementation KSMusicLibViewController
@synthesize musiclibDelegate;

- (void)dealloc{
    
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame{
    
    return [super initWithFrame:frame];
}

-(void)viewWillAppear:(BOOL)animated
{
    //GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
}
-(void)viewWillDisappear:(BOOL)animated
{
    //GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    musiclibDelegate = [[KSMusicLibDelegate alloc]init];
    
	UIView* back_view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    [back_view setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:back_view];
    
    
    CGRect rcSegBk = CGRectMake(120, 10, 85, 30);
    UILabel* label_title = [[[UILabel alloc] initWithFrame:rcSegBk] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setText:@"点歌台"];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:label_title];
    
    CGRect rc = CGRectMake(0, 40, 320, self.view.frame.size.height - back_view.frame.size.height);
    subViewContainer = [[[UIView alloc]initWithFrame:rc]autorelease];
    [[self view] addSubview:subViewContainer];
    
    RankView = [[RankViewController alloc]initWithFrame:subViewContainer.bounds];
    [subViewContainer addSubview:RankView.view];
    RankView.musiclibDelegate = musiclibDelegate;
}

-(void)LocalMusicClick:(id)sender
{
    LocalMusicViewController * viewController = [[[LocalMusicViewController alloc]init]autorelease];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:viewController animated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}



-(bool)hasShowTips
{
    bool res(false);
    KwConfig::GetConfigureInstance()->GetConfigBoolValue("tips", "hasShowTipsOrNot", res);
    return res;
}

-(void)showFirstInTips
{
    tipsView=[[UIView alloc] initWithFrame:self.view.bounds];
    UITapGestureRecognizer *recognizer=[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchTips:)] autorelease];
    recognizer.numberOfTapsRequired=1;
    UIImageView* tipImage=[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("tips.png")] autorelease];
    [tipImage setFrame:CGRectMake(85, 65, 160, 90)];
    [tipsView addSubview:tipImage];
    [tipsView addGestureRecognizer:recognizer];
    [tipsView setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:tipsView];
}
-(void)onTouchTips:(UIGestureRecognizer *)gestureRecognizer
{
    if (tipsView) {
        [tipsView removeFromSuperview];
        [tipsView release];
        tipsView = nil;
    }
    KwConfig::GetConfigureInstance()->SetConfigBoolValue("tips", "hasShowTipsOrNot", true);
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

-(NSString*) AddRandURL:(NSString*)strurl
{
    return [NSString stringWithFormat:@"%@?%@",strurl,GetCurTimeToString()];
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
    if (nil != tipsView) {
        [tipsView release];
        tipsView = nil;
    }
    
//    [self tryDestorySubView:&NewsongView];
//    [self tryDestorySubView:&RankView];
//    [self tryDestorySubView:&SingerView];
}



@end
