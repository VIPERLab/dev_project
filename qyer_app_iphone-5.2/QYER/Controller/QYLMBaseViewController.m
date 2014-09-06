//
//  QYLMBaseViewController.m
//  QYER
//
//  Created by 蔡 小雨 on 14-8-7.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QYLMBaseViewController.h"

@interface QYLMBaseViewController ()

@end

@implementation QYLMBaseViewController

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
    
    if (!ios7) {
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
