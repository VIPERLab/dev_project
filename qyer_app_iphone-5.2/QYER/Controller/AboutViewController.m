//
//  AboutViewController.m
//  QyGuide
//
//  Created by lide on 12-11-3.
//
//

#import "AboutViewController.h"
#import "MobClick.h"
#import "Toast+UIView.h"
#import "ShowAppVersionInfo.h"
#import "QYToolObject.h"


@interface AboutViewController ()

@end




@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_backButton);
    QY_VIEW_RELEASE(_briefImageView);
    QY_VIEW_RELEASE(_siteButton);
    QY_VIEW_RELEASE(_logoImageView);
    QY_VIEW_RELEASE(_versionImageView);
    QY_VIEW_RELEASE(_titleLabel);
    
    QY_SAFE_RELEASE(appNewInfo);
    QY_SAFE_RELEASE(path);
    
    [super dealloc];
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"关于穷游页"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(openUrlInAppFlag == 1)
    {
        [self performSelector:@selector(releaseWebVC) withObject:nil afterDelay:1];
    }
    
    [self.view hideToast];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick endLogPageView:@"关于穷游页"];
}




- (void)loadView
{
    [super loadView];
    
    
    
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image =[UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
    
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 46+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 160, 30)];
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(80, 6+20, 160, 30);
    }
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"关于穷游";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    [_headView addSubview:_titleLabel];
    
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, 3, 40, 40);
    if(ios7)
    {
        _backButton.frame = CGRectMake(0, 3+20, 40, 40);
    }
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    
    
    _briefImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 50, 304, 238)];
    if(ios7)
    {
        _briefImageView.frame = CGRectMake(8, 50+20, 304, 238);
    }
    _briefImageView.image = [UIImage imageNamed:@"bg_more_brief.png"];
    [self.view addSubview:_briefImageView];
    
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(187, 295, 125, 38)];
    if(ios7)
    {
        _logoImageView.frame = CGRectMake(187, 295+20, 125, 38);
    }
    _logoImageView.image = [UIImage imageNamed:@"bg_more_logo.png"];
    [self.view addSubview:_logoImageView];
    
    
    
    
    float positionY = [self.view bounds].size.height - 86-10;
    if(!ios7)
    {
        positionY = [self.view bounds].size.height - 86-30;
    }
    UIButton *button_update = [UIButton buttonWithType:UIButtonTypeCustom];
    button_update.frame = CGRectMake((320-560/2)/2., positionY, 560/2, 72/2);
    button_update.backgroundColor = [UIColor clearColor];
    [button_update setBackgroundImage:[UIImage imageNamed:@"检查新版本@2x.png"] forState:UIControlStateNormal];
    [button_update addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_update];
    
    
    
    
    
    
    
    
    
    
    //    _versionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, self.view.frame.size.height - 55, 180, 49)];
    //    _versionImageView.image = [UIImage imageNamed:@"bg_more_version.png"];
    //    [self.view addSubview:_versionImageView];
    
    positionY = [self.view bounds].size.height - 50;
    if(!ios7)
    {
        positionY = [self.view bounds].size.height - 70;
    }
    //[ShowAppVersionInfo showInView:self.view withFrame:CGRectMake(60, positionY, 200, 50)];
    [ShowAppVersionInfo showInView:self.view atPositionY:positionY];
    
    
    
    
    
    _siteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _siteButton.backgroundColor = [UIColor clearColor];
    _siteButton.frame = CGRectMake(0, _briefImageView.frame.origin.y+_briefImageView.frame.size.height, 120, 30);
    _siteButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    [_siteButton setTitle:@"www.qyer.com" forState:UIControlStateNormal];
    [_siteButton setTitleColor:[UIColor colorWithRed:105/255. green:153/255. blue:154/255. alpha:1] forState:UIControlStateNormal];
    [_siteButton addTarget:self action:@selector(clickSiteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_siteButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
}


-(void)update:(id)sender
{
    //[MobClick setDelegate:self];
    
    [self.view hideToast];
    [self.view makeToast:@"正在检查..." duration:0 position:@"center" isShadow:NO];
    
    [MobClick checkUpdateWithDelegate:self selector:@selector(appUpdate:)];
}

-(void)appUpdate:(NSDictionary *)appUpdateInfo
{
    appNewInfo = [[appUpdateInfo valueForKey:@"update_log"] retain];
    path = [[appUpdateInfo objectForKey:@"path"] retain];
    //NSLog(@"path:%@",path);
    NSString *isUpdate = [[appUpdateInfo valueForKey:@"update"] retain];
    
    updateFlag = 0;
    if([isUpdate isEqualToString:@"YES"])
    {
        updateFlag = 1;
        [self performSelectorOnMainThread:@selector(showUpdateAlert) withObject:nil waitUntilDone:YES];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(makeToast) withObject:nil waitUntilDone:YES];
    }
    [isUpdate release];
}

-(void)makeToast
{
    [self.view hideToast];
    [self.view makeToast:@"当前已是最新版本" duration:1 position:@"center" isShadow:NO];
}

-(void)showUpdateAlert
{
    [self.view hideToast];
    
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"发现最新版本"
                          message:appNewInfo
                          delegate:self
                          cancelButtonTitle:@"忽略本次提醒"
                          otherButtonTitles:@"立即更新",nil];
    alert.delegate = self;
    [alert show];
    [alert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        return;
    }
    else
    {
        if(updateFlag == 1)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d&at=10l6dK",APPSTOREAPPLICATIONID]];
            if(ios7)
            {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d?at=10l6dK",APPSTOREAPPLICATIONID]];
            }
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}


- (void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSiteButton:(id)sender
{
    if(openUrlInAppFlag == 1)
    {
        return;
    }
    
    
    webVC = [[WebViewViewController alloc] init] ;
    [webVC setStartURL:@"http://www.qyer.com"];
    [self presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:nil];
}





#pragma mark -
#pragma mark --- releaseWebVC 
-(void)releaseWebVC
{
    if(webVC && webVC.retainCount > 0)
    {
        [webVC.view removeFromSuperview];
        [webVC release];
    }
    openUrlInAppFlag = 0;   //当_webVC释放后再置为0
}


#pragma mark -
#pragma mark --- webview - delegate
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.labelText = @"Loading...";
//}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
