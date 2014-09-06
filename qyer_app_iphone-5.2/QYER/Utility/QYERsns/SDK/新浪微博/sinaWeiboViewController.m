//
//  sinaWeiboViewController.m
//  TEST
//
//  Created by an qing on 12-11-20.
//  Copyright (c) 2012年 an qing. All rights reserved.
//


#import "sinaWeiboViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "QYControl.h"
#import "QYERSNS.h"




@interface sinaWeiboViewController ()

@end




@implementation sinaWeiboViewController
@synthesize textV;
@synthesize shareImage;
@synthesize showImageView;
@synthesize isWordTooLong;
@synthesize str_title;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)dealloc
{
    self.str_title = nil;
    self.shareImage = nil;
    
    [_titleLabel removeFromSuperview];
    [_titleLabel release];
    
    [_headView removeFromSuperview];
    [_headView release];
    
    
    [myInputAccessoryView removeFromSuperview];
    [myInputAccessoryView release];
    
    [shuziLabel removeFromSuperview];
    [shuziLabel release];
    
    showImageView.image = nil;
    [showImageView removeFromSuperview];
    [showImageView release];
    
    [shareView removeFromSuperview];
    [shareView release];
    
    takePhotoImageView.image = nil;
    [takePhotoImageView removeFromSuperview];
    [takePhotoImageView release];
    
    positionImageView.image = nil;
    [positionImageView removeFromSuperview];
    [positionImageView release];
    
    [locationManager release];
    [weidu release];
    [jingdu release];
    
    
    [textV removeFromSuperview];
    [textV release];
    
    [super dealloc];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setShuziLabelNumber];
    [self setImageView];
    
    /**
     *  insert by yihui
     */
    if (self.type == 1) {
        _titleLabel.text = @"分享到腾讯微博";
        
    }
}



#pragma mark -
#pragma mark --- 判断在微博里已输入字的个数
//***判断在微博里已输入字的个数
-(int)sinaCountWord:(NSString*)s
{
    int i,n=[s length],l=0,a=0,b=0;
    
    unichar c;
    for(i=0;i<n;i++)
    {
        c=[s characterAtIndex:i];
        
        if(isblank(c))
        {
            b++;
        }else if(isascii(c))
        {
            a++;
        }
        else
        {
            l++;
        }
    }
    if(a==0 && l==0)
        return 0;
    return l+(int)ceilf((float)(a+b)/2.0);
}
- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger number = [self sinaCountWord:textV.text];
    number = 140-number;
    isWordTooLong = 0;
    if(number < 0)
    {
        isWordTooLong = 1;
        shuziLabel.textColor = [UIColor redColor];
    }
    else
    {
        shuziLabel.textColor = [UIColor blackColor];
    }
    
    [shuziLabel setText:[NSString stringWithFormat:@"%d",number]];
    shuziLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark -
#pragma mark --- viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    UIView *rootView;
    if(iPhone5)
    {
        rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460+88)];
        ////textV = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 310, 150+88)];
    }
    else
    {
        rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
        ////textV = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 310, 150)];
    }
    self.view = rootView;
    [rootView setBackgroundColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1]];
    [rootView release];
    
    
    
    [self setNavigationBar];
    
    
    
    [self.view addSubview:textV];
    [textV setFont:[UIFont systemFontOfSize:18]];
    textV.delegate = self;
    [textV.layer setCornerRadius:2];
    [textV becomeFirstResponder];
    myInputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [myInputAccessoryView setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
    textV.inputAccessoryView = myInputAccessoryView;
    
    //textV.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14.0f];
    textV.font = [UIFont fontWithName:@"Arial" size:15.f];
    
    
    
    
    
    
    
    shuziLabel = [[UILabel alloc] initWithFrame:CGRectMake(285, 5, 30, 30)];
    [shuziLabel setBackgroundColor:[UIColor clearColor]];
    shuziLabel.textAlignment = NSTextAlignmentCenter;
    [myInputAccessoryView addSubview:shuziLabel];
    
    
    
    
    
    
//    takePhotoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(245+(40-22)/2, (40-39/2.0)/2.0, 44/2, 39/2.0)];
//    [takePhotoImageView setBackgroundColor:[UIColor clearColor]];
//    [takePhotoImageView setImage:[UIImage imageNamed:@"imageselected.png"]];
//    MyControl *takePhotoControl = [[MyControl alloc] initWithFrame:CGRectMake(245, 0, 40, 40)];
//    takePhotoControl.cornerRadiusFlag = 1;
//    [takePhotoControl addTarget:self action:@selector(doProduceImage) forControlEvents:UIControlEventTouchUpInside];
//    //[myInputAccessoryView addSubview:takePhotoImageView];
//    //[myInputAccessoryView addSubview:takePhotoControl];
//    [takePhotoControl release];
    
    
    
    QYControl *signOutControl = [[QYControl alloc] initWithFrame:CGRectMake(0, 0, 40, 40) andBackGroundColor:[UIColor colorWithRed:234.0/255 green:228.0/255 blue:202.0/255 alpha:1.0]];
//    signOutControl.cornerRadiusFlag = 1;
    [signOutControl addTarget:self action:@selector(doLogOut) forControlEvents:UIControlEventTouchUpInside];
    [myInputAccessoryView addSubview:signOutControl];
    [signOutControl release];
    UIImageView *signOutImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (40-17)/2.0, 35/2.0, 34/2)];
    NSString *str1 =[NSString stringWithFormat:@"%@@2x",@"xiaoren"];
    UIImage *image1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str1 ofType:@"png"]];
    [signOutImageView setImage:image1];
    [signOutImageView setBackgroundColor:[UIColor clearColor]];
    [myInputAccessoryView addSubview:signOutImageView];
    [signOutImageView release];
    
    
    
//    positionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80+(34/2)/2.0+5, (40-45/2.0)/2, 34/2, 45/2.0)];
//    [positionImageView setBackgroundColor:[UIColor clearColor]];
//    //[myInputAccessoryView addSubview:positionImageView];
//    [positionImageView setImage:[UIImage imageNamed:@"未定位.png"]];
//    MyControl *positionImageViewControl = [[MyControl alloc] initWithFrame:CGRectMake(80, 0, 45, 40)];
//    positionImageViewControl.cornerRadiusFlag = 1;
//    [positionImageViewControl addTarget:self action:@selector(doChangeDingweiStatus) forControlEvents:UIControlEventTouchUpInside];
//    //[myInputAccessoryView addSubview:positionImageViewControl];
//    [positionImageViewControl release];
    
    
}

-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 46+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 6, 160, 34)];
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(80, 6+20, 160, 30);
    }
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"分享到新浪微博";
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    
    
    
    
    UIButton *_backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(6, 6, 47, 33);
    if(ios7)
    {
        _backButton.frame = CGRectMake(6, 6+20, 47, 33);
    }
    [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_more_cancel.png"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(doQuit) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    
    UIButton *_sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _sendButton.backgroundColor = [UIColor clearColor];
    _sendButton.frame = CGRectMake(267, 6, 47, 33);
    if(ios7)
    {
        _sendButton.frame = CGRectMake(267, 6+20, 47, 33);
    }
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_more_send.png"] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(doSend) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_sendButton];
    
    
}

-(void)initTitle:(NSString *)title
{
    self.str_title = title;
    
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 6, 160, 34)];
        _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
        //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        //_titleLabel.shadowOffset = CGSizeMake(0, 1);
        [_headView addSubview:_titleLabel];
    }
    _titleLabel.text = self.str_title;
}
-(void)initImageView:(UIImage *)image
{
    self.shareImage = image;
    [self setImageView];
}
-(void)setShuziLabelNumber
{
    NSInteger number = [self sinaCountWord:textV.text];
    number = 140-number;
    isWordTooLong = 0;
    if(number < 0)
    {
        number = 0;
        isWordTooLong = 1;
    }
    [shuziLabel setText:[NSString stringWithFormat:@"%d",number]];
    if(number == 0)
    {
        shuziLabel.textColor = [UIColor redColor];
    }
    else
    {
        shuziLabel.textColor = [UIColor blackColor];
    }
}

-(void)setImageView
{
    if(self.shareImage)
    {
        if([myInputAccessoryView viewWithTag:90001])
        {
            [[myInputAccessoryView viewWithTag:90001] removeFromSuperview];
        }
        QYControl *imagevControl = [[QYControl alloc] initWithFrame:CGRectMake(40, 0, 40, 40) andBackGroundColor:[UIColor colorWithRed:234.0/255 green:228.0/255 blue:202.0/255 alpha:1.0]];
        imagevControl.tag = 90001;
        [imagevControl addTarget:self action:@selector(cropImage) forControlEvents:UIControlEventTouchUpInside];
        [myInputAccessoryView addSubview:imagevControl];
        [imagevControl release];
        
        
        if(!shareView)
        {
            shareView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 0, 40, 40)];
            [shareView setBackgroundColor:[UIColor clearColor]];
        }
        [myInputAccessoryView addSubview:shareView];
        if(showImageView)
        {
            [showImageView removeFromSuperview];
            [showImageView release];
            showImageView = nil;
        }
        if(self.shareImage.size.height - self.shareImage.size.width > 0)
        {
            showImageView = [[UIImageView alloc] initWithFrame:CGRectMake((40-(self.shareImage.size.width*36/self.shareImage.size.height))/2.0, 2, self.shareImage.size.width*36/self.shareImage.size.height, 36)];
        }
        else
        {
            showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, (40-(self.shareImage.size.height*36/self.shareImage.size.width))/2.0, 36, self.shareImage.size.height*36/self.shareImage.size.width)];
        }
        [showImageView setImage:self.shareImage];
        [shareView addSubview:showImageView];
    }
    else
    {
        
    }
}


#pragma mark -
#pragma mark --- 图片缩放
- (void)cropImage
{
    myCropper = [[ImageCropper alloc] initWithImage:showImageView.image];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	[myCropper setDelegate:self];
	[self presentViewController:myCropper animated:YES completion:nil];
    //[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:myCropper animated:YES];
    [myCropper release];
}
- (void)imageCropper:(ImageCropper *)cropper didFinishCroppingWithImage:(UIImage *)image
{
	[showImageView setImage:self.shareImage];
	
	//[self dismissModalViewControllerAnimated:YES];
	//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    //***黑色状态栏:
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarAnimationSlide animated:YES];
    
    [cropper saveImage];
}
- (void)imageCropperDidCancel:(ImageCropper *)cropper
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [textV becomeFirstResponder];
    
    //***黑色状态栏:
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarAnimationSlide animated:YES];
}


-(void)doQuit
{
    isDingweiFlag = 0;
    isWordTooLong = 0;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark --- 登出微博
-(void)doLogOut
{
    UIAlertView *loginOutAlert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"确认登出该微博帐号？"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"登出",nil];
    [loginOutAlert show];
    [loginOutAlert release];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.cancelButtonIndex)
    {
        return;
    }
    else
    {
        /**
         *  insert by yihui
         */
        if (self.type == 1) {
            
            [[QyerSns sharedQyerSns] loginOutTencentWeibo];
            
            isWordTooLong = 0;
            isDingweiFlag = 0;
            
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        //[delegate.myQyersns loginOut];
//        [delegate.myQyersns performSelector:@selector(loginOut) withObject:nil afterDelay:0.1];
        
        
        [[QyerSns sharedQyerSns] loginOutSinaWeibo];
        
        
        isWordTooLong = 0;
        isDingweiFlag = 0;
    }
}

#pragma mark -
#pragma mark --- 发布微博
-(void)doSend
{
    
    //insert by yihui
    /**
     *  如果是腾讯微博的
     */
    if (self.type == 1) {

        if(self.shareImage)
        {
            [[QyerSns sharedQyerSns] shareToTencentWeibo:textV.text andImage:self.shareImage];
        }
        else
        {
            [[QyerSns sharedQyerSns] shareToTencentWeibo:textV.text];
        }
        return;
    }
    
    if(self.shareImage)
    {
        [[QyerSns sharedQyerSns] shareToWeibo:textV.text andImage:self.shareImage];
    }
    else
    {
        [[QyerSns sharedQyerSns] shareToWeibo:textV.text];
    }
    
    
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    if(isDingweiFlag == 1)
//    {
//        [delegate.myQyersns shareToWeiboWithStatus:textV.text andImage:showImageView.image andJingdu:jingdu andWeidu:weidu];
//    }
//    else if(!showImageView.image)
//    {
//        [delegate.myQyersns shareToWeiboWithStatus:textV.text andImage:nil andJingdu:nil andWeidu:nil];
//    }
//    else
//    {
//        [delegate.myQyersns shareToWeiboWithStatus:textV.text andImage:showImageView.image andJingdu:nil andWeidu:nil];
//    }
}




//#pragma mark -
//#pragma mark --- 定位
//-(void)doChangeDingweiStatus
//{
//    if(isDingweiFlag == 1)
//    {
//        //NSLog(@"不显示自己的位置");
//        
//        isDingweiFlag = 0;
//        [positionImageView setImage:[UIImage imageNamed:@"未定位.png"]];
//        
//        //***关闭定位:
//        [locationManager stopUpdatingLocation];
//    }
//    else if(isDingweiFlag == 0)
//    {
//        //NSLog(@"显示自己的位置");
//        
//        isDingweiFlag = 1;
//        [positionImageView setImage:[UIImage imageNamed:@"定位.png"]];
//        
//        //***定位:
//        [self setupLocationManager];
//    }
//}
////***进行定位
//- (void)setupLocationManager
//{
//    [locationManager release];
//    locationManager = [[CLLocationManager alloc] init];
//    
//    if ([CLLocationManager locationServicesEnabled])
//    {
//        //NSLog(@"Starting CLLocationManager");
//        locationManager.delegate = self;
//        //***locationManager.distanceFilter = 100; //当位置移动大于100米时才去调用‘didUpdateToLocation’更新位置坐标
//        locationManager.distanceFilter = kCLDistanceFilterNone;
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        [locationManager startUpdatingLocation];
//        
//    }
//    else
//    {
//        //NSLog(@"Cannot Starting CLLocationManager");
//        /*self.locationManager.delegate = self;
//         self.locationManager.distanceFilter = 200;
//         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//         [self.locationManager startUpdatingLocation];*/
//    }
//}
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    //--(1)新位置
//    float newlatitude = newLocation.coordinate.latitude;
//    //NSLog(@"newLocation.coordinate.latitude = 纬度: %g",newlatitude);
//    float newlongitude = newLocation.coordinate.longitude;
//    //NSLog(@"newLocation.coordinate.longitude = 经度: %g",newlongitude);
//    weidu = [[NSString stringWithFormat:@"%f",newlatitude] retain];
//    jingdu = [[NSString stringWithFormat:@"%f",newlongitude] retain];
//    
//    
//    //--(2)原来位置
//    ////NSLog(@"oldLocationcoordinate.latitude=纬度:%g",oldLocation.coordinate.latitude);
//    ////NSLog(@"oldLocationcoordinate.longitude=经度:%g",oldLocation.coordinate.longitude);
//    
//    
//    //***关闭定位
//    [locationManager stopUpdatingLocation];
//}
//
////***定位失败
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    [locationManager stopUpdatingLocation];
//    
//    [positionImageView setImage:[UIImage imageNamed:@"未定位.png"]];
//    isDingweiFlag = 0;
//    
//    UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle:@"获取位置信息失败"
//                          message:@"您可在该iPhone的设置中打开该应用的定位服务。"
//                          delegate:nil
//                          cancelButtonTitle:@"确定"
//                          otherButtonTitles:nil];
//    [alert show];
//    [alert release];
//}
//
//
//#pragma mark -
//#pragma mark --- 处理照片
//-(void)doProduceImage
//{
//    //NSLog(@"处理照片");
//
//    [textV resignFirstResponder];
//    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:nil
//                                  delegate:self
//                                  cancelButtonTitle:@"取消"
//                                  destructiveButtonTitle:nil
//                                  otherButtonTitles:@"从照片库选择",@"拍照",nil];
//    [actionSheet showInView:self.view];
//    [actionSheet release];
//    
//}
//
///*获取是哪个按钮被按下*/
//- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if(buttonIndex == [actionSheet cancelButtonIndex])
//    {
//        [textV becomeFirstResponder];
//        return;
//    }
//	else if (buttonIndex == 0) //照片库
//	{
//		////NSLog(@"照片库");
//        if(!myProduceMyImage)
//        {
//            myProduceMyImage = [[ ProduceMyImage alloc] init];
//        }
//        
//        [myProduceMyImage produceImage:0];
//        
//	}
//	else if (buttonIndex == 1) //拍照
//	{
//		//////NSLog(@"拍照");
//        if(!myProduceMyImage)
//        {
//            myProduceMyImage = [[ ProduceMyImage alloc] init];
//        }
//        
//        [myProduceMyImage produceImage:1];
//        
//	}
//}


#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end


