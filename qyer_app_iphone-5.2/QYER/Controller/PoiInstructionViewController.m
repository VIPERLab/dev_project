//
//  PoiInstructionViewController.m
//  QyGuide
//
//  Created by an qing on 13-3-5.
//
//


#import "PoiInstructionViewController.h"
#import <QuartzCore/QuartzCore.h>



#define     chineseTitleLabelX          50
#define     chineseTitleLabelY          (ios7 ? (5+20) : 5)
#define     chineseTitleLabelWidth      220
#define     chineseTitleLabelHeight     20
#define     englishTitleLabelX          50
#define     englishTitleLabelY          (ios7 ? (23+20) : 23)
#define     englishTitleLabelWidth      220
#define     englishTitleLabelHeight     20
#define     titleLabelHeight            30
#define     titleLabelPositionY         8
#define     chineseTitleTypeSize        16
#define     englishTitleTypeSize        14

#define     positionY_backbutton        (ios7 ? (3+20) : 3)
#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_scrollview        (ios7 ? (44+20) : 44)





@interface PoiInstructionViewController ()

@end





@implementation PoiInstructionViewController
@synthesize navigationTitle;
@synthesize instruction = _instruction;
@synthesize typeImage = _typeImage;
@synthesize chineseTitle = _chineseTitle;
@synthesize englishTitle = _englishTitle;

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
    QY_SAFE_RELEASE(_chineseTitle);
    QY_SAFE_RELEASE(_englishTitle);
    QY_SAFE_RELEASE(_instruction);
    
    QY_VIEW_RELEASE(_chineseTitleLabel);
    QY_VIEW_RELEASE(_englishTitleLabel);
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_scrollView);
    QY_VIEW_RELEASE(_instructionWebView);
    
    
    [super dealloc];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

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
    [self setScrollView];
    [self setContentView];
}
-(void)setRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image =[UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head.png"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    [self setTitleView];
}
-(void)setTitleView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 6, 250, 36)];
    if(ios7)
    {
        label.frame = CGRectMake(35, 4+20, 250, 30);
    }
    label.backgroundColor = [UIColor clearColor];
    label.adjustsFontSizeToFitWidth = YES;
    if(self.chineseTitle && self.chineseTitle.length > 0)
    {
        label.text = [NSString stringWithFormat:@"%@简介",self.chineseTitle];
    }
    else if(self.englishTitle && self.englishTitle.length > 0)
    {
        label.text = [NSString stringWithFormat:@"%@简介",self.englishTitle];
    }
    else
    {
        label.text = @"简介";
    }
    label.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //label.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:label];
    [label release];
}
-(void)setScrollView
{
    if(ios7)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, positionY_scrollview, 320, [[UIScreen mainScreen] bounds].size.height - positionY_scrollview)];
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, positionY_scrollview, 320, ([[UIScreen mainScreen] bounds].size.height-20) - positionY_scrollview)];
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    _scrollView.scrollEnabled = YES;
    _scrollView.alwaysBounceVertical = YES;
    CGRect frame = [[UIScreen mainScreen] bounds];
    if(ios7)
    {
        float height_top = 46+20;
        _scrollView.frame = frame;
        _scrollView.contentInset = UIEdgeInsetsMake(height_top, 0, 0, 0);
        _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(height_top, 0, 0, 0);
        _scrollView.contentOffset = CGPointMake(0, -height_top);
    }
    else
    {
        float height_top = 46;
        float height_frame = frame.size.height;
        height_frame = height_frame-20;
        frame.size.height = height_frame;
        _scrollView.frame = frame;
        _scrollView.contentInset = UIEdgeInsetsMake(height_top, 0, 0, 0);
        _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(height_top, 0, 0, 0);
        _scrollView.contentOffset = CGPointMake(0, -height_top);
    }
    [self.view insertSubview:_scrollView belowSubview:_headView];
}


-(void)setContentView
{
    float height = [self countContentLabelHeightByString:self.instruction andLength:302-18];
    UIView *view_background = [[UIView alloc] initWithFrame:CGRectMake(9, titleLabelPositionY, 302, height+9)];
    if(ios7)
    {
        view_background.frame = CGRectMake(9, titleLabelPositionY, 302, height+9*2);
    }
    view_background.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *label_content = [[UILabel alloc] initWithFrame:CGRectMake(9, 9, 302-18, height)];
    label_content.text = self.instruction;
    label_content.textColor = [UIColor colorWithRed:86/255. green:86/255. blue:86/255. alpha:1];
    label_content.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
    label_content.backgroundColor = [UIColor clearColor];
    label_content.numberOfLines = 0;
    [view_background.layer setBorderColor:[UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8].CGColor];
    [view_background.layer setBorderWidth:1];
    
    [_scrollView addSubview:view_background];
    [view_background addSubview:label_content];
    [_scrollView setContentSize:CGSizeMake(320, view_background.frame.size.height + 9*2)];
    
    
    [label_content release];
    [view_background release];
    
}


#pragma mark -
#pragma mark ---  UIWebView - delegate 加载完后获取webView的高度
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = _instructionWebView.frame;
    if([[[UIDevice currentDevice] systemVersion] doubleValue] < 5.0)
    {
        frame.size.height = [((UIScrollView *)[[_instructionWebView subviews] objectAtIndex:0]) contentSize].height;
    }
    else
    {
        frame.size.height = _instructionWebView.scrollView.contentSize.height;
    }
    _instructionWebView.alpha = 1;
    _instructionWebView.frame = frame;
    
    [_scrollView setContentSize:CGSizeMake(320, titleLabelHeight+titleLabelPositionY+frame.size.height+5)];
    
    [self initborderLine];
}
-(void)initborderLine
{
    [_instructionWebView.layer setBorderColor:[UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8].CGColor];
    [_instructionWebView.layer setBorderWidth:1];
}


#pragma mark -
#pragma mark --- 计算String所占的高度
-(float)countContentLabelHeightByString:(NSString*)content andLength:(float)length
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W3" size:13.0f] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    
    return sizeToFit.height;
}


#pragma mark -
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
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

