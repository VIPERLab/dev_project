//
//  ActivityViewController.m
//  QYER
//
//  Created by Frank on 14-4-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "ActivityViewController.h"
#import <Social/Social.h>
#import "QyYhConst.h"
#import "QyerSns.h"

static  NSString *kShareText = @"#五一出行季#，来试试手气吧。下载#穷游APP#，分享活动页面。每天iPad Mini、”THE WORLD“纪念Tee、《穷游锦囊》大礼包等着你哦。";

static  NSString *kShareURL = @"http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_campaign0425";

@interface ActivityViewController ()

@end

@implementation ActivityViewController

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
    
    self.view.backgroundColor = RGB(20, 120, 80);
    
    //滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 625);
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    //活动的图片视图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x, scrollView.bounds.origin.y, scrollView.contentSize.width, scrollView.contentSize.height)];
    imageView.image = [UIImage imageNamed:@"activity_qyer"];
    imageView.userInteractionEnabled = YES;
    [scrollView addSubview:imageView];
    [imageView release];
    
    //关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(scrollView.bounds.size.width - 32 - 6, iOS7Adap(26), 32, 32);
    [closeBtn setImage:[UIImage imageNamed:@"activity_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    //分享按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - 67, self.view.bounds.size.width, 67);
    [shareBtn setImage:[UIImage imageNamed:@"activity_share"] forState:UIControlStateNormal];
    [shareBtn setImage:[UIImage imageNamed:@"activity_share_selected"] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self action:@selector(shareHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
    [scrollView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark Private
/**
 *  新浪微博分享
 */
- (void)shareHandler
{
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:[NSString stringWithFormat:@"%@%@", kShareText, kShareURL] andImage:[UIImage imageNamed:@"activity_qyer"] inViewController:self];
    
//    // 首先判断服务器是否可以访问
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
//
//        
//        // 使用SLServiceTypeSinaWeibo来创建一个新浪微博view Controller
//        SLComposeViewController *socialVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
//        
//        // 写一个bolck，用于completionHandler的初始化
//        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result) {
//            [socialVC dismissViewControllerAnimated:YES completion:Nil];
//        };
//        // 初始化completionHandler，当post结束之后（无论是done还是cancel）该block都会被调用
//        socialVC.completionHandler = myBlock;
//        // 给view controller初始化默认的图片，url，文字信息
//        UIImage *image = [UIImage imageNamed:@"activity_qyer"];
//        
//        [socialVC setInitialText:kShareText];
//        [socialVC addImage:image];
//        [socialVC addURL:[NSURL URLWithString:kShareURL]];
//        
//        // 以模态的方式展现view controller
//        [self presentViewController:socialVC animated:YES completion:Nil];
//        
//    } else {
//        NSLog(@"Uninstall SINA WEIBO");
//    }
}

/**
 *  关闭当前视图
 */
- (void)closeHandler
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"footViewHidden" object:nil userInfo:@{@"hidden":@NO}];
    [self dismissViewControllerAnimated:YES completion:nil];
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
