//
//  playPicturesView.m
//  KwSing
//
//  Created by 改 熊 on 12-7-26.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//
#import "playPicturesView.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageMgr.h"
#import "KwTools.h"


#define SMALL_SIZE 0.25f
#define TIME_FOR_ONE_IMAGE 8.0f
#define TIME_FOR_ANIMATION 1.0f
#define DEFAULT_IMAGE @"topKSongbk.png"

@implementation playPicturesView
@synthesize imageList=_imageList;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        aView=[[[UIImageView alloc] initWithFrame:[self bounds]] autorelease];
        bView=[[[UIImageView alloc] initWithFrame:[self bounds]] autorelease];
        defaultView=[[[UIImageView alloc] initWithFrame:[self bounds]] autorelease];
        
        defaultView.contentMode=UIViewContentModeScaleAspectFit;
        aView.contentMode=UIViewContentModeScaleAspectFit;
        bView.contentMode=UIViewContentModeScaleAspectFit;
        
        [defaultView setImage:[UIImage imageNamed:DEFAULT_IMAGE]];
        
        [self addSubview:aView];
        [self addSubview:bView];
        [self addSubview:defaultView];
        
        isBegin=YES;
        isPlaying=false;
        iter=_imageList.begin();
    }
    return self;
}

-(void)onTimer
{
    if (_imageList.begin() == _imageList.end()) 
        return;
    
    if (iter==_imageList.end()) {
        iter=_imageList.begin();
    }
    if (isBegin) {
        isBegin=NO;
        
        [[[self subviews] objectAtIndex:1] setImage:[UIImage imageWithContentsOfFile:*iter++]];
        [defaultView setHidden:true];
    }
    else {
        int whichType=rand()%2;
        if (whichType==0) {
            //顶部消失，底部的出现
            [[[self subviews] objectAtIndex:0] setImage:[UIImage imageWithContentsOfFile:*iter++]];
            UIImageView *frontObject = [[self subviews] objectAtIndex:1];
            UIImageView *backObject = [[self subviews] objectAtIndex:0];
            
            int random=rand()%4;
            switch (random) {
                case 0:
                {
                    backObject.transform = CGAffineTransformMakeScale(SMALL_SIZE, SMALL_SIZE);
                    backObject.alpha = 0.0f;
                    
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    [UIView beginAnimations:nil context:context];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:TIME_FOR_ANIMATION];
                    
                    frontObject.alpha = 0.0f;
                    backObject.alpha = 1.0f;
                    frontObject.transform = CGAffineTransformMakeScale(SMALL_SIZE, SMALL_SIZE);
                    backObject.transform = CGAffineTransformIdentity;
                    
                    [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
                    [UIView commitAnimations];
                }
                    break;
                case 1:
                {
                    backObject.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                    backObject.alpha = 0.0f;
                    
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    [UIView beginAnimations:nil context:context];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:TIME_FOR_ANIMATION];
                    
                    frontObject.alpha = 0.0f;
                    backObject.alpha = 1.0f;
                    
                    
                    [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
                    [UIView commitAnimations];
                }
                    break;
                case 2:
                {
                    backObject.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                    backObject.alpha = 1.0f;
                    frontObject.alpha=0.0f;
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    [UIView beginAnimations:nil context:context];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:TIME_FOR_ANIMATION];
                    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
                    [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
                    
                    
                    [UIView commitAnimations];
                }
                    break;
                case 3:
                {
                    backObject.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                    backObject.alpha = 1.0f;
                    frontObject.alpha=0.0f;
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    [UIView beginAnimations:nil context:context];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:TIME_FOR_ANIMATION];
                    [UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView:self cache:YES];
                    [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
                    
                    [UIView commitAnimations];
                    
                }
                    break;
                case 4:
                {
                    backObject.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                    backObject.alpha = 1.0f;
                    frontObject.alpha=0.0f;
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    [UIView beginAnimations:nil context:context];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    [UIView setAnimationDuration:TIME_FOR_ANIMATION];
                    [UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:self cache:YES];
                    
                    [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
                    
                    [UIView commitAnimations];
                    
                }
                    break;
                default:
                    break;
            }
            
        }
        else if(whichType==1)
        {
            UIImageView *backObject = [[self subviews] objectAtIndex:0];
            backObject.transform=CGAffineTransformMakeScale(1.0f, 1.0f);
            [[[self subviews] objectAtIndex:0] setImage:[UIImage imageWithContentsOfFile:*iter++]];
            [[[self subviews] objectAtIndex:0] setAlpha:1.0];
            CATransition *animation = [CATransition animation];
            animation.delegate = self;
            animation.duration = TIME_FOR_ANIMATION;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            int random1=rand()%6;
            switch (random1) 
            {
                case 0:
                    animation.type = kCATransitionFade;
                    break;
                case 1:
                    animation.type = kCATransitionMoveIn;
                    break;
                case 2:
                    animation.type = kCATransitionPush;
                    break;
                case 3:
                    animation.type = kCATransitionReveal;
                    break;
                case 4:
                    animation.type=@"rippleEffect";
                    animation.duration = TIME_FOR_ANIMATION*3;
                    break;
                case 5:
                    animation.type=@"suckEffect";
                    break;
                default:
                    break;
            }
            
            int random2=rand()%4;
            switch (random2) {
                case 0:
                    animation.subtype=kCATransitionFromBottom;
                    break;
                case 1:
                    animation.subtype=kCATransitionFromLeft;
                    break;
                case 2:
                    animation.subtype=kCATransitionFromRight;
                case 3:
                    animation.subtype=kCATransitionFromTop;
                    break;
                default:
                    break;
            }
            [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
            [[[self subviews] objectAtIndex:0] setAlpha:0.0];
            [[self layer] addAnimation:animation forKey:nil];
        }
    }
}
//startPlay 会在两种情况下被调用
//1、被播放页面直接调用
//2、后期处理页，如果正在播放，并且第一张图片被添加的时候，addImage自动调用该函数开始轮播
-(void)startPlay
{
    isPlaying=true;
    isBegin=true;
    if ([time isValid]) 
        return;
    if (_imageList.size()>0) {
        [self onTimer];
        time=[NSTimer scheduledTimerWithTimeInterval:TIME_FOR_ONE_IMAGE target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
}
-(void)stop
{
    isPlaying=false;
    if (time!=nil) {
        if ([time isValid]) {
            [time invalidate];
        }
        time=nil;
    }
    if(_imageList.size() == 0){
        [defaultView setHidden:false];
    }
}
-(void)setImageList:(std::vector<NSString *>)imageList
{
    for (std::vector<NSString*>::iterator i=imageList.begin(); i!=imageList.end(); i++) {
        _imageList.push_back([*i retain]);
//        NSLog(@"push image:%@",*i);
    }
    iter=_imageList.begin();
}

-(void)deleleImage:(NSString *)imagePath
{
//    NSLog(@"delete:%@",imagePath);
    for (std::vector<NSString*>::iterator i=_imageList.begin(); i!=_imageList.end(); i++) {
        if ([imagePath isEqualToString:*i]) {
            i=_imageList.erase(i);
//            NSLog(@"delete ok");
            if (_imageList.size() == 0 && isPlaying) {
                //[self stop];
                [defaultView setHidden:false];
            }
            iter=_imageList.begin();
            break;
        }
    }
}
-(void)addImage:(NSString *)imagePath
{
    _imageList.push_back([imagePath copy]);
    iter=_imageList.begin();
    if (_imageList.size() == 1 && isPlaying) {
        [self startPlay];
    }
}
-(void)dealloc
{
    for (std::vector<NSString*>::iterator i=_imageList.begin(); i!=_imageList.end(); i++) {
        [*i release];
    }
    [super dealloc];
}


@end
