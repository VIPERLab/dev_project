//
//  ImageProcessingView.m
//  KwSing
//
//  Created by 熊 改 on 13-2-25.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "ImageProcessingViewController.h"
#import "KSAppDelegate.h"
#import "ImageMgr.h"
#import "globalm.h"
#import "CoreImageProcess.h"
#import "KwTools.h"

#define GAP_BETWEEN     10
#define BUTTON_WIDTH    75

@interface ImageProcessingViewController()
{
    UIImage * _image;
    UIImage * _processImage;
    UIImageView *imageView;
    UIScrollView * _selectEffectView;
    int numOfEffects;
}
-(void)initSelectEffectView;
@end



@implementation ImageProcessingViewController

-(id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = [image copy];
        _processImage = _image;
        numOfEffects=7;
    }
    return self;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setFrame:[UIScreen mainScreen].bounds];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    imageView=[[[UIImageView alloc] initWithImage:_image] autorelease];
    [imageView setFrame:CGRectMake(0, 0, 320, 320)];
    [[self view] addSubview:imageView];
    
    [self initSelectEffectView];
    [[self view] addSubview:_selectEffectView];
    
    UIView *bottomView=[[[UIView alloc] init] autorelease];
    [bottomView setFrame:BottomRect(self.view.bounds, 70, 0)];
    
    UIImageView *backView=[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("recordbottombk.png")] autorelease];
    [backView setFrame:bottomView.bounds];
    [bottomView addSubview:backView];
    
    UIButton * doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:CImageMgr::GetImageEx("useImage.png") forState:UIControlStateNormal];
    [doneButton setImage:CImageMgr::GetImageEx("useImageDown.png") forState:UIControlStateSelected];
    [doneButton setFrame:CGRectMake(123.5, 7, 73, 35)];
    [doneButton addTarget:self action:@selector(onDone) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:doneButton];
    
    UIButton* returnButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [returnButton setFrame:CGRectMake(14, 15, 37, 27)];
    [returnButton setImage:CImageMgr::GetImageEx("cancelUseImage.png") forState:UIControlStateNormal];
    [returnButton setImage:CImageMgr::GetImageEx("cencelUseImageDonw.png") forState:UIControlStateSelected];
    [returnButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:returnButton];
    
    [[self view] addSubview:bottomView];
    
    
}
-(void)onDone
{
    [[self delegate] onImageProcessingDone:_processImage];
    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
}
-(void)onCancel
{
    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
}
-(void)initSelectEffectView
{
    int int_y=0;
    if (IsIphone5()) 
        int_y=365;
    else
        int_y =329;
    _selectEffectView=[[[UIScrollView alloc] initWithFrame:CGRectMake(0, int_y, 320, BUTTON_WIDTH)] autorelease];
    [_selectEffectView setBackgroundColor:[UIColor clearColor]];
    [_selectEffectView setShowsHorizontalScrollIndicator:false];
    CGFloat contentWidth= numOfEffects*(BUTTON_WIDTH+GAP_BETWEEN)+GAP_BETWEEN;//-[[UIScreen mainScreen] bounds].size.width;
    [_selectEffectView setContentSize:CGSizeMake(contentWidth, BUTTON_WIDTH)];
    
    NSArray* _effectNames=@[@"origion_icon.png",
                  @"charm_icon.png",
                  @"sunny_icon.png",
                  @"oldfilm_icon.png",
                  @"rainbow_icon.png",
                  @"memory_icon.png",
                  @"bw_icon.png"];
    
    for (int i=0; i<numOfEffects; i++) {
        UIButton *button=[[[UIButton alloc] initWithFrame:CGRectMake(GAP_BETWEEN+i*(GAP_BETWEEN+BUTTON_WIDTH), 0, BUTTON_WIDTH, BUTTON_WIDTH)] autorelease];
        [button setTag:i];
//        NSLog(@"%@",(NSString *)_effectNames[i]);
        std::string strIconName=[(NSString*)[_effectNames objectAtIndex:i] UTF8String];
        [button setBackgroundImage:CImageMgr::GetImageEx(strIconName.c_str()) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onEffectSelect:) forControlEvents:UIControlEventTouchUpInside];
        [_selectEffectView addSubview:button];
    }
}
-(void)onEffectSelect:(UIButton*)sender
{
    EImageEffectType type = (EImageEffectType)sender.tag;
    _processImage = CCoreImageProcess::Process(_image, type);
    [imageView setImage:_processImage];
}
-(BOOL)writeImage:(UIImage *)image ToFilePath:(NSString *)aPath
{
    //NSLog(@"write %@",aPath);
    if ((image==nil) || (aPath==nil) ||[aPath isEqualToString:@""]) {
        return FALSE;
    }
    NSData *imageData=UIImagePNGRepresentation(image);
    if ((imageData == nil) || ([imageData length] <= 0)) {
        return FALSE;
    }
    [imageData writeToFile:aPath atomically:YES];
    return TRUE;
}
@end
