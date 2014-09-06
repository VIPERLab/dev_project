//
//  ViewController.m
//  Snow
//
//  Created by 周 俊杰 on 13-9-16.
//  Copyright (c) 2013年 周 俊杰. All rights reserved.
//

#define SNOW_IMAGENAME         @"snow"

#define IMAGE_X                arc4random()%(int)Main_Screen_Width
#define IMAGE_ALPHA            ((float)(arc4random()%10))/10
#define IMAGE_WIDTH            arc4random()%20 + 10
#define PLUS_HEIGHT            Main_Screen_Height/25

#import "cloudViewController.h"

@interface cloudViewController ()

@end

@implementation cloudViewController

-(UIView*)addCloudView:(NSInteger)index{
    UIView* cloudAnimation=[[UIView alloc] initWithFrame:CGRectMake(index*320, 0, 520, 300)];
    
    UIImageView *imgView1=[[UIImageView alloc] initWithFrame:CGRectMake(45, 255/2, 150, 67)];
    [imgView1 setImage:[UIImage imageNamed:@"cloud2"]];
    [cloudAnimation addSubview:imgView1];
    [imgView1 release];
    
    UIImageView *imgView2=[[UIImageView alloc] initWithFrame:CGRectMake(190, 44/2, 77, 48)];
    [imgView2 setImage:[UIImage imageNamed:@"cloud1"]];
    [cloudAnimation addSubview:imgView2];
    [imgView2 release];
    
    UIImageView *imgView3=[[UIImageView alloc] initWithFrame:CGRectMake(400, 256/2, 150, 67)];
    [imgView3 setImage:[UIImage imageNamed:@"cloud3"]];
    [cloudAnimation addSubview:imgView3];
    [imgView3 release];
    
    UIImageView *imgView4=[[UIImageView alloc] initWithFrame:CGRectMake(400+156, 44/2, 77, 48)];
    [imgView4 setImage:[UIImage imageNamed:@"cloud1"]];
    [cloudAnimation addSubview:imgView4];
    [imgView4 release];
    
    return [cloudAnimation autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _imagesArray = [[NSMutableArray alloc] init];
    
    
    UIView* cloudAnimation=[self addCloudView:1];
    [self.view addSubview:cloudAnimation];
    [_imagesArray addObject:cloudAnimation];
    
    
    
    _cloudAnimation=[self addCloudView:0];
    _cloudAnimation.tag=10080;
    [self.view addSubview:_cloudAnimation];
    [self cloudslider:_cloudAnimation];
    
   
    myTimer=[NSTimer scheduledTimerWithTimeInterval:13 target:self selector:@selector(makeCloud) userInfo:nil repeats:YES];
}

static int i = 0;
- (void)makeCloud
{
    i = i + 1;
    if ([_imagesArray count] > 0) {
        UIView *imageView = [_imagesArray objectAtIndex:0];
        imageView.tag = i;
        [_imagesArray removeObjectAtIndex:0];
        if ([_imagesArray count]<10) {
            UIView* cloudAnimation=[self addCloudView:1];
            [self.view addSubview:cloudAnimation];
            [_imagesArray addObject:cloudAnimation];
        }
        [self cloudslider:imageView];
    }

}

- (void)cloudslider:(UIView *)aImageView
{
    [UIView beginAnimations:[NSString stringWithFormat:@"%li",(long)aImageView.tag] context:nil];
   
    if (aImageView.tag==10080) {
        [UIView setAnimationDelay:2];
        [UIView setAnimationDuration:26];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        aImageView.frame = CGRectMake(-640, aImageView.frame.origin.y, aImageView.frame.size.width, aImageView.frame.size.height);
    }else{
        [UIView setAnimationDuration:26];
        aImageView.frame = CGRectMake(-640, aImageView.frame.origin.y, aImageView.frame.size.width, aImageView.frame.size.height);
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    }
    
    [UIView setAnimationDelegate:self];
    
    NSLog(@" aImageView : %@",aImageView);
    [UIView commitAnimations];
}

-(void)dealloc{
    [myTimer invalidate];
    [_cloudAnimation release];
    [_imagesArray release];
    [super dealloc];
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
