//
//  ShowDownloadMask.m
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-19.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "ShowDownloadMask.h"


#define     tag_DownloadMaskView               121221
#define     tag_DownloadMaskcontrol            121223



@implementation ShowDownloadMask

-(void)dealloc
{
    [super dealloc];
}

+(void)showMask
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"download_mask"])
    {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"download_mask"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    UIImageView *maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[[[UIApplication sharedApplication] delegate] window] rootViewController].view.frame.size.width, [[[[UIApplication sharedApplication] delegate] window] rootViewController].view.frame.size.height)];
    maskImageView.userInteractionEnabled = YES;
    UIImage *image_mask = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mark_downloadlist" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    if(image_mask)
    {
        maskImageView.image = image_mask;
    }
    maskImageView.tag = tag_DownloadMaskView;
    maskImageView.backgroundColor = [UIColor clearColor];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view addSubview:maskImageView];
    
    
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, maskImageView.bounds.size.width, maskImageView.bounds.size.height)];
    control.tag = tag_DownloadMaskcontrol;
    [control addTarget:self action:@selector(removeMask:) forControlEvents:UIControlEventTouchUpInside];
    control.backgroundColor = [UIColor clearColor];
    [maskImageView addSubview:control];
    [control release];
    [maskImageView release];
}

+(void)removeMask:(id)sender
{
    if([[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_DownloadMaskcontrol])
    {
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_DownloadMaskcontrol].alpha = 0;
        [[[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_DownloadMaskcontrol] removeFromSuperview];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_DownloadMaskView].alpha = 0;
    } completion:^(BOOL finished) {
        [[[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_DownloadMaskView] removeFromSuperview];
    }];
}

@end
