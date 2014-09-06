//
//  RPSViewController.m
//  Reese'sParallaxScrollView
//
//  Created by Reese on 13-6-14.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "RPSViewController.h"


#define SCROLL_CONTENT_COUNT 5

#define WIDTH_OF_SCROLL_PAGE 320
#define HEIGHT_OF_SCROLL_PAGE 460
#define WIDTH_OF_IMAGE 320
#define HEIGHT_OF_IMAGE 284
#define LEFT_EDGE_OFSET 0

@interface RPSViewController ()

@end

@implementation RPSViewController


-(void)clickGointoButton:(id)sender{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"introductory_pages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"showActivityView" object:nil userInfo:nil];
    [self.view removeFromSuperview];
    [self release];
    //showActivityView
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor=[UIColor colorWithRed:199.0/255.0 green:224.0/255.0 blue:226.0/255.0 alpha:1.0];
    
    cloud=[[cloudViewController alloc] init];
    [self.view addSubview:cloud.view];
    
    parallaxScrollView=[[A3ParallaxScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    parallaxScrollView.showsHorizontalScrollIndicator = NO;
    parallaxScrollView.showsVerticalScrollIndicator = NO;
    
    if(iPhone5)
    {
        parallaxScrollView.frame=CGRectMake(0, 60, 320, 508);
        [parallaxScrollView setContentSize:CGSizeMake(320*5, 508)];
    }
    [parallaxScrollView setContentSize:CGSizeMake(320*5, 480)];
    parallaxScrollView.pagingEnabled=YES;
    [self.view addSubview:parallaxScrollView];
    parallaxScrollView.delegate=self;
    parallaxScrollView.backgroundColor=[UIColor clearColor];
   
    
    [parallaxScrollView setContentOffset:CGPointMake(0, 0)];
    [self.view addSubview:parallaxScrollView];
    
    
    bg_imgview=[[UIImageView alloc] initWithFrame:CGRectMake(0, parallaxScrollView.frame.size.height-90, 320*5*1.1, 90)];
    if(iPhone5)
    {
         bg_imgview.image=[UIImage imageNamed:@"bg_mountain_iphone5"];
    }else{
         bg_imgview.image=[UIImage imageNamed:@"bg_mountain"];
    }
   
    [parallaxScrollView addSubview:bg_imgview withAcceleration:CGPointMake(1.1f, 0)];
    
    
 
    for (int i=0; i<SCROLL_CONTENT_COUNT; i++) {
        UIImageView* superman_imgView=[[UIImageView alloc] initWithFrame:CGRectMake(60+(1.2*320*i), 20/2, 74, 16)];
        superman_imgView.image=[UIImage imageNamed:@"bg_superman"];
        superman_imgView.tag=1111;
        [parallaxScrollView addSubview:superman_imgView withAcceleration:CGPointMake(1.2f, 0)];
        [superman_imgView release];
        
        UIImageView* plan1_imgView=[[UIImageView alloc] initWithFrame:CGRectMake(23+(1.2*320*i), 160, 33, 13)];
        plan1_imgView.image=[UIImage imageNamed:@"plane1" ];
        plan1_imgView.tag=1112;
        [parallaxScrollView addSubview:plan1_imgView withAcceleration:CGPointMake(1.2f, 0)];
        [plan1_imgView release];
        
        UIImageView* iphone_imgView=[[UIImageView alloc] initWithFrame:CGRectMake(156/2+(320*i), 70/2, 158, 383)];
        iphone_imgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"phone%d", i+1]];
        iphone_imgView.tag=2111;
        [parallaxScrollView addSubview:iphone_imgView withAcceleration:CGPointMake(1.0f, 0)];
        [iphone_imgView release];
        
        UIImageView* plan2_imgView=[[UIImageView alloc] initWithFrame:CGRectMake(436/2+(1.2*320*i), 120/2, 61, 16)];
        plan2_imgView.image=[UIImage imageNamed:@"plane2" ];
        plan2_imgView.tag=1113;
        [parallaxScrollView addSubview:plan2_imgView withAcceleration:CGPointMake(1.2f, 0)];
        [plan2_imgView release];
        
        UIImageView* page_imgView=[[UIImageView alloc] initWithFrame:CGRectMake(222/2+(1.6*320*i), 778/2, 90, 12)];
        page_imgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"page%d", i+1]];
        iphone_imgView.tag=3111;
        [parallaxScrollView addSubview:page_imgView withAcceleration:CGPointMake(1.6f, 0)];
        [page_imgView release];
        
        UIImageView* cloud1_imgView=[[UIImageView alloc] initWithFrame:CGRectMake(32/2+(1.8*320*i), 548/2, 168, 75)];
        cloud1_imgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"引导图%d云a", i+1]];
        iphone_imgView.tag=4111;
        [parallaxScrollView addSubview:cloud1_imgView withAcceleration:CGPointMake(1.8f, 0)];
        [cloud1_imgView release];
        
        UIImageView* cloud2_imgView=[[UIImageView alloc] initWithFrame:CGRectMake(386/2+(1.8f*320*i), 420/2, 104, 50)];
        if (i==1) {
            cloud2_imgView.frame=CGRectMake(414/2+(1.8f*320*i), 410/2, 82, 87);
        }
        if (i==2) {
            cloud2_imgView.frame=CGRectMake(414/2+(1.8f*320*i), 280/2, 78, 78);
        }
        if (i==3) {
            cloud2_imgView.frame=CGRectMake(414/2+(1.8f*320*i), 418/2, 78, 78);
        }
        if (i==4) {
            cloud2_imgView.frame=CGRectMake(410/2+(1.8f*320*i), 340/2, 78, 78);
        }
        cloud2_imgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"引导图%d云b", i+1]];
        cloud2_imgView.tag=4112;
        [parallaxScrollView addSubview:cloud2_imgView withAcceleration:CGPointMake(1.8f, 0)];
        [cloud2_imgView release];
        
        if (i==4) {
            UIButton* _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            _backButton.backgroundColor = [UIColor clearColor];
            _backButton.frame = CGRectMake(180/2+(320*i), 846/2, 135, 35);
//            if(iPhone5)
//            {
//                _backButton.frame = CGRectMake(180/2+(320*i), 846/2, 135, 35);
//            }
            [_backButton setBackgroundImage:[UIImage imageNamed:@"press_btn"] forState:UIControlStateNormal];
            [_backButton addTarget:self action:@selector(clickGointoButton:) forControlEvents:UIControlEventTouchUpInside];
            [parallaxScrollView addSubview:_backButton];
        }
        
    
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    

}


- (void)dealloc {
    [cloud release];
    [parallaxScrollView release];
    [bg_imgview release];
    [super dealloc];
}


@end
