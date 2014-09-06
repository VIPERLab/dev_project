//
//  ImageCropper.m
//  NewPackingList
//
//  Created by an qing on 12-9-25.
//
//

#import "ImageCropper.h"
#import <QuartzCore/QuartzCore.h>



@implementation ImageCropper
@synthesize myScrollView, imageView;
@synthesize delegate;




- (void)dealloc
{
    [alertLabel release];
    [navigationBar release];
	[imageView release];
	[myScrollView release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark --- init
-(id)initWithImage:(UIImage *)image
{
	self = [super init];
    
	
	if (self)
    {
        //*** 状态栏透明
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
		
        
        
        //*** myScrollView
        if(ios7)
        {
            if(iPhone5)
            {
                myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480+88)];
            }
            else
            {
                myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            }
        }
        else
        {
            if(iPhone5)
            {
                myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, -20.0, 320.0, 480.0+88)];
            }
            else
            {
                myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, -20.0, 320.0, 480.0)];
            }
        }
        [myScrollView setBackgroundColor:[UIColor blackColor]];
        [myScrollView setDelegate:self];
        [myScrollView setShowsHorizontalScrollIndicator:NO];
        [myScrollView setShowsVerticalScrollIndicator:NO];
        [myScrollView setMaximumZoomScale:2.0];
        
        
        
        
//        //*** imageView
//        //*** ANQING UPDATE:
//        BOOL flag = 0;
//        CGSize srcSize;
//        NSInteger viewsHeight = 0;
//        if(iPhone5)
//        {
//            viewsHeight = 480+88;
//        }
//        else
//        {
//            viewsHeight = 480;
//        }
//        
//        
//        
//        if(image.size.width > 320)
//        {
//            
//        }
//        else if(image.size.height < viewsHeight  && image.size.width < 320)
//        {
//            flag = 1;
//            UIImageView *imageVTmp = [[UIImageView alloc] initWithImage:image];
//            [imageVTmp setBackgroundColor:[UIColor clearColor]];
//            imageVTmp.frame = CGRectMake(0, (viewsHeight-image.size.height)/2.0, image.size.width, image.size.height);
//            [imageVTmp setImage:image];
//            srcSize = image.size;
//            
//            
//            
//            UIView *viewTmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, viewsHeight)];
//            [viewTmp setBackgroundColor:[UIColor clearColor]];
//            [viewTmp addSubview:imageVTmp];
//            [imageVTmp release];
//            
//            
//            
//            UIGraphicsBeginImageContext(viewTmp.frame.size);
//            [viewTmp.layer renderInContext:UIGraphicsGetCurrentContext()];
//            UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            if(![image isEqual:screenImage])
//            {
//                [image release];
//            }
//            image = [screenImage retain];
//        }
        
        
        
        
        
        
        //# 重要 #此处的rect最好要先初始化一下,要不然坐标值容易出现为nan(not a number)的情况.
        CGRect rect = CGRectZero;
        rect.size.width = image.size.width;
        rect.size.height = image.size.height;
        
        if(imageView)
        {
            [imageView removeFromSuperview];
            [imageView release];
        }
        imageView = [[UIImageView alloc] initWithFrame:rect];
        [imageView setImage:image];
        
        
        
//        if(flag == 0)
//        {
            [myScrollView setContentSize:[imageView frame].size];
//        }
//        else
//        {
//            [myScrollView setContentSize:srcSize];
//        }
        [myScrollView setMinimumZoomScale:[myScrollView frame].size.width / [imageView frame].size.width];
        [myScrollView setZoomScale:[myScrollView minimumZoomScale]];
        [myScrollView addSubview:imageView];
        [[self view] addSubview:myScrollView];
        
        
        
        
        
        //*** navigationBar
		navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        if(ios7)
        {
            navigationBar.frame = CGRectMake(0, 0, 320, 44+20);
        }
		[navigationBar setBarStyle:UIBarStyleDefault];
		[navigationBar setTranslucent:YES];
		//UINavigationItem *aNavigationItem = [[UINavigationItem alloc] initWithTitle:@"移动和缩放"];
        UINavigationItem *aNavigationItem = [[UINavigationItem alloc] init];
		//[aNavigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCropping)] autorelease]];
		//[aNavigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishCropping)] autorelease]];
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(cancelCropping)];
        UIBarButtonItem *senderBarButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(finishCropping)];
        aNavigationItem.rightBarButtonItem = senderBarButton;
        aNavigationItem.leftBarButtonItem = cancelBarButton;
        [senderBarButton release];
        [cancelBarButton release];
		[navigationBar setItems:[NSArray arrayWithObject:aNavigationItem]];
		[aNavigationItem release];
		[[self view] addSubview:navigationBar];
        
        
        
        
        
        //回收navigationBar
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAndHide)];
        [singleTap setNumberOfTapsRequired:1];      //点击1下
        [singleTap setNumberOfTouchesRequired:1];   //单指
        [myScrollView addGestureRecognizer:singleTap];
        [singleTap release];
	}
	
	return self;
}

- (void)cancelCropping
{
	[delegate imageCropperDidCancel:self]; 
}

- (void)finishCropping
{
	float zoomScale = 1.0 / [myScrollView zoomScale];
	
	CGRect rect;
	rect.origin.x = [myScrollView contentOffset].x * zoomScale;
	rect.origin.y = [myScrollView contentOffset].y * zoomScale;
	rect.size.width = [myScrollView bounds].size.width * zoomScale;
	rect.size.height = [myScrollView bounds].size.height * zoomScale;
	
	CGImageRef cr = CGImageCreateWithImageInRect([[imageView image] CGImage], rect);
	
	UIImage *cropped = [UIImage imageWithCGImage:cr];
	
	CGImageRelease(cr);
	
	[delegate imageCropper:self didFinishCroppingWithImage:cropped];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}


#pragma mark -
#pragma mark --- showAndHide
-(void)showAndHide
{
    if(navigationBar.alpha == 0)
    {
        [UIView beginAnimations:@"hello" context:NULL];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:NO];
        [UIView setAnimationRepeatCount:0];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [navigationBar setAlpha:1];
        [UIView commitAnimations];
    }
    else if(navigationBar.alpha == 1)
    {
        [UIView beginAnimations:@"hello" context:NULL];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:NO];
        [UIView setAnimationRepeatCount:0];
        [UIApplication sharedApplication].statusBarHidden = YES;
        [navigationBar setAlpha:0];
        [UIView commitAnimations];
    }
}


#pragma mark -
#pragma mark --- saveImage
-(void)saveImage
{
    //第二个参数是回调目标,第三个参数是选择器,选择器本身带三个参数,一个图像,一个错误,一个上下文信息。
	UIImageWriteToSavedPhotosAlbum([imageView image], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [self performSelector:@selector(showSendStatus) withObject:nil afterDelay:0.0];
}
-(void)showSendStatus
{
    if(!resultView)
    {
        if(iPhone5)
        {
            resultView = [[UIView alloc] initWithFrame:CGRectMake(70, (460+88-53)/2.0, 180, 53)];
        }
        else
        {
            resultView = [[UIView alloc] initWithFrame:CGRectMake(70, (460-53)/2.0, 180, 53)];
        }
    }
    [resultView setBackgroundColor:[UIColor blackColor]];
    [resultView setAlpha:0.8];
    [resultView.layer setCornerRadius:5.0];
    //[resultView.layer setBorderWidth:2];
    [resultView.layer setBorderColor:[UIColor colorWithRed:119/255.0 green:118/255.0 blue:118/255.0 alpha:0.8].CGColor];
    if(!alertLabel)
    {
        alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, 140, 31)];
    }
    [alertLabel setFont:[UIFont systemFontOfSize:14.0]];
    [alertLabel setBackgroundColor:[UIColor clearColor]];
    [alertLabel setTextColor:[UIColor whiteColor]];
    [alertLabel setTextAlignment:NSTextAlignmentCenter];
    [resultView addSubview:alertLabel];
    alertLabel.text = @"正在保存...";
    
    
    //[self.view addSubview:resultView];
    if([[[UIApplication sharedApplication] windows] count] > 1)
    {
        [[[[UIApplication sharedApplication] windows] objectAtIndex:1] addSubview:resultView];
    }
    else
    {
        [[[UIApplication sharedApplication] keyWindow] addSubview:resultView];
    }
    
}
//将图片保存到照片库后的处理(不写这个方法会出错)
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil)
	{
        [self performSelector:@selector(showStatus) withObject:nil afterDelay:0.2];
    }
	else
	{
        [alertLabel setText:@"似乎保存失败了 :( "];
        [self performSelector:@selector(alertShow) withObject:nil afterDelay:1.0];
        //[self performSelector:@selector(doRemoveresultView) withObject:nil afterDelay:1];
	}
}
-(void)showStatus
{
    [alertLabel setText:@"已成功保存到照片库"];
    
    [self performSelector:@selector(alertShow) withObject:nil afterDelay:1.0];
}
-(void)alertShow
{
    //*** 加动画: 渐隐
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
    [animation setToValue:[NSNumber numberWithFloat:0.0]];
    [animation setDuration:0.3];
    [animation setAutoreverses:NO];
    [resultView.layer addAnimation:animation forKey:@"doOpacity"];
    
    [self performSelector:@selector(doRemoveresultView) withObject:nil afterDelay:0.28];
}
-(void)doRemoveresultView
{
    if(resultView)
    {
        [resultView removeFromSuperview];
        [resultView release];
        resultView = nil;
    }
}

@end

