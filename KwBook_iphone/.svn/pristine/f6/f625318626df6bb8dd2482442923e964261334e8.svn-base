//
//  RecommendViewController.m
//  kwbook
//
//  Created by 熊 改 on 13-11-28.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import "RecommendViewController.h"
#import "KBSegmentControl.h"

@interface RecommendViewController ()<KBSegmentProtocol>
@property (nonatomic , strong) UIView *topBar;
@property (nonatomic , strong) KBSegmentControl *segmentControl;
@end

@implementation RecommendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[self view] setBackgroundColor:[UIColor purpleColor]];
    
    self.topBar = ({
        UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        [topBar setBackgroundColor:[UIColor blueColor]];
        topBar;
    });
    [[self view] addSubview:self.topBar];
    
    self.segmentControl = ({
        KBSegmentControl *segmentControl = [[KBSegmentControl alloc] initWithItems:@[@"最新",@"最热",@"排行"]];
        [segmentControl setFrame:CGRectMake(0, 20, 240, 44)];
        [segmentControl setBackgroundColor:[UIColor clearColor]];
        [segmentControl setDelegate:self];
        segmentControl;
    });
    [self.topBar addSubview:self.segmentControl];
    
    [self.segmentControl selectIndex:1];
}
-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s",__func__);
}
-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s",__func__);
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s",__func__);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)didSegmentControlSelectIndex:(NSUInteger)index
{
    NSLog(@"%d",index);
}
@end
