//
//  MusicWebViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "BaseListViewController.h"
#include "MessageManager.h"
#include "globalm.h"
#import "iToast.h"
#include <QuartzCore/QuartzCore.h>
#include "ImageMgr.h"



@interface BaseListViewController ()
{

}



@end

@implementation BaseListViewController
@synthesize musiclibDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGBValue(0xededed);
    
    UIImageView * netfailview = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 320, 416)]autorelease];
    netfailview.tag = TagNetFailView;
    netfailview.userInteractionEnabled = true;
    netfailview.hidden = true;
    netfailview.backgroundColor = UIColorFromRGBValue(0xededed);
    netfailview.image = CImageMgr::GetImageEx("failmsgNoNet.png");
    [self.view addSubview:netfailview];
  
    UIImageView * loadfailview = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 320, 416)]autorelease];
    loadfailview.tag = TagLoadFailView;
    loadfailview.userInteractionEnabled = true;
    loadfailview.hidden = true;
    loadfailview.backgroundColor = UIColorFromRGBValue(0xededed);
    loadfailview.image = CImageMgr::GetImageEx("failmsgLoadFail.png");
    [self.view addSubview:loadfailview];
    
    UIActivityIndicatorView * loading = [[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 86, 86)]autorelease];
    loading.tag = TagLoading;
    loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loading.backgroundColor = UIColorFromRGBAValue(0x000000,0xb5);
    //loading.layer.masksToBounds = true;
    loading.layer.cornerRadius = 10;
    loading.center = CGPointMake(160, 250);
    loading.hidden = true;
    UILabel *label=[[[UILabel alloc] initWithFrame:CGRectMake(0, 56, 86, 30)] autorelease];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setText:@"正在加载中"];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:13]];
    
    [loading addSubview:label];
    
    [self.view addSubview:loading];
    
    
    
}


@end
