//
//  QuestionsViewController.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-8-27.
//
//

#import "QuestionsViewController.h"
#import "MobClick.h"



@interface QuestionsViewController ()

@end



@implementation QuestionsViewController

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
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_scrollView);
    
    [super dealloc];
}




#pragma mark -
#pragma mark --- view - Appear & Disappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"常见问题"];
    
    [self setHomeView];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick beginLogPageView:@"常见问题"];
}



#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    [self setRootView];
    [self setNavigationBar];
    
}

-(void)setRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 46+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 11, 160, 30)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(80, 6+20, 160, 30);
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"常见问题";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
    [_headView addSubview:titleLabel];
    [titleLabel release];
    
    
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
    
}
-(void)setHomeView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, 460-45)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.alwaysBounceVertical = YES;
    if(iPhone5)
    {
        _scrollView.frame = CGRectMake(0, 45, 320, 460+88-45);
    }
    if(ios7)
    {
        _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, 45+20, 320, _scrollView.frame.size.height);
    }
    [self.view addSubview:_scrollView];
    
    
    UIImage *image = [UIImage imageNamed:@"常见问题"];
    UIImageView *imageView_question = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 4420/2)];
    imageView_question.image = image;
    imageView_question.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:imageView_question];
    [_scrollView setContentSize:CGSizeMake(320, 4420/2)];
    [imageView_question release];
}



#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
