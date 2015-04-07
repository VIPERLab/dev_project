//
//  ViewController.m
//  2.UIView
//
//  Created by Ming Wang on 10/18/14.
//  Copyright (c) 2014 wangming. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *rootView = self.view;
    
    UIView *subView1 = [[UIView alloc] initWithFrame:CGRectMake(40, 100, 300, 100)];
    subView1.backgroundColor = [UIColor redColor];
    subView1.tag = 101;
    
    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(40, 300, 300, 100)];
    subView2.backgroundColor = [UIColor blackColor];
    subView2.tag = 102;
    
    [rootView addSubview:subView1];
    [rootView addSubview:subView2];
   
       
    NSLog(@"rootView's subViews: %@", rootView.subviews);
    
    UIImageView *imageView = [UIImageView alloc] initWithFrame:<#(CGRect)#>
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"delloc, view'tag: %@",self.view.tag);
}

@end
