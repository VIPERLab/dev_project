//
//  ShowGuideCover.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-8-16.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "ShowGuideCover.h"
#import "FilePath.h"


#define     tag_coverImageView              121211
#define     tag_titleImageView_background   121212
#define     tag_control                     121213



@implementation ShowGuideCover


-(void)dealloc
{
    [super dealloc];
}

+(void)showGuideCoverWithGuideName:(NSString *)guide_name
{
    NSString *htmlPath = [FilePath getGuideHtmlPathByGuideName:guide_name];
    UIImageView *_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[[[UIApplication sharedApplication] delegate] window] rootViewController].view.frame.size.height, [[[[UIApplication sharedApplication] delegate] window] rootViewController].view.frame.size.height * 2 / 3)];
    if([UIImage imageWithContentsOfFile:[htmlPath stringByAppendingPathComponent:@"coverbg.jpg"]])
    {
        _coverImageView.image = [UIImage imageWithContentsOfFile:[htmlPath stringByAppendingPathComponent:@"coverbg.jpg"]];
    }
    else
    {
        _coverImageView.image = [UIImage imageWithContentsOfFile:[htmlPath stringByAppendingPathComponent:@"coverbg.png"]];
    }
    _coverImageView.tag = tag_coverImageView;
    _coverImageView.backgroundColor = [UIColor clearColor];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view addSubview:_coverImageView];
    [_coverImageView release];
    
    
    
    UIImageView *_titleImageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, _coverImageView.frame.size.height, 320, 200)];
    _titleImageView_background.tag = tag_titleImageView_background;
    _titleImageView_background.backgroundColor = [UIColor blackColor];
    UIImageView *_titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 113)];
    _titleImageView.backgroundColor = [UIColor clearColor];
    if([UIImage imageWithContentsOfFile:[htmlPath stringByAppendingPathComponent:@"covertitle.png"]])
    {
        _titleImageView.image = [UIImage imageWithContentsOfFile:[htmlPath stringByAppendingPathComponent:@"covertitle.png"]];
    }
    else
    {
        _titleImageView.image = [UIImage imageWithContentsOfFile:[htmlPath stringByAppendingPathComponent:@"covertitle.jpg"]];
    }
    [_titleImageView_background addSubview:_titleImageView];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view addSubview:_titleImageView_background];
    [_titleImageView release];
    [_titleImageView_background release];
    
    
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, [[[[UIApplication sharedApplication] delegate] window] rootViewController].view.bounds.size.height)];
    control.tag = tag_control;
    [control addTarget:self action:@selector(removeCover:) forControlEvents:UIControlEventTouchUpInside];
    control.backgroundColor = [UIColor clearColor];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view addSubview:control];
    [control release];
    
    
    [self beginAnimation:_coverImageView];
}
+(void)beginAnimation:(UIImageView *)_coverImageView
{
    [UIView animateWithDuration:2.5 animations:^{
        _coverImageView.frame = CGRectMake(320 - _coverImageView.frame.size.width, 0, _coverImageView.frame.size.width, _coverImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_coverImageView].alpha = 0;
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_titleImageView_background].alpha = 0;
        } completion:^(BOOL finished) {
            [[[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_coverImageView] removeFromSuperview];
            [[[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_titleImageView_background] removeFromSuperview];
            [[[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_control] removeFromSuperview];
        }];
    }];
}


+(void)removeCover:(id)sender
{
    if([[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_control])
    {
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_control].alpha = 0;
        [[[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_control] removeFromSuperview];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_coverImageView].alpha = 0;
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_titleImageView_background].alpha = 0;
    } completion:^(BOOL finished) {
        [[[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_coverImageView] removeFromSuperview];
        [[[[[[UIApplication sharedApplication] delegate] window] rootViewController].view viewWithTag:tag_titleImageView_background] removeFromSuperview];
    }];
}


@end
