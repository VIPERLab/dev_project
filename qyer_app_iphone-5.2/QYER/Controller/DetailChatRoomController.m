//
//  DetailChatRoomController.m
//  QYER
//
//  Created by 张伊辉 on 14-6-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "DetailChatRoomController.h"

@interface DetailChatRoomController ()

@end

@implementation DetailChatRoomController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)hideGradientBackground:(UIView*)theView

{
    
    for(UIView* subview in theView.subviews)
        
    {
        
        if([subview isKindOfClass:[UIImageView class]])
            
            subview.hidden = YES;
        [self hideGradientBackground:subview];
        
    }
    
}
- (void)clickBackButton:(UIButton *)btn{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = @"城市列表";
    
    self.view.backgroundColor = RGB(231, 242, 248);
    
    [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_webview_close.png"] forState:UIControlStateNormal];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, UIHeight - height_need_reduce)];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    _webView.scrollView.decelerationRate = 5.0;
    [self.view addSubview:_webView];
    [_webView release];
    
    [self.view sendSubviewToBack:_webView];
    [self hideGradientBackground:_webView];
    
    [ChangeTableviewContentInset changeTableView:_webView.scrollView withOffSet:0];
    
    
    [self loadRequest];
    
    // Do any additional setup after loading the view.
}
-(void)loadRequest{
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"chatroom" ofType:@"html"];
    NSString *filePath = @"http://appview.qyer.com/index.php?action=chatroom&spm=index";
    NSURL *url = [NSURL URLWithString:filePath];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
