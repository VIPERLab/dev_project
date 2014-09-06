//
//  ImageBrowserViewController.m
//  QyGuide
//
//  Created by lide on 12-11-5.
//
//

#import "ImageBrowserViewController.h"




@interface ImageBrowserViewController ()

@end





@implementation ImageBrowserViewController
@synthesize imagePath = _imagePath;

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
    QY_VIEW_RELEASE(_closeButton);
    QY_VIEW_RELEASE(_scrollView);
    _imageView.image = nil;
    QY_VIEW_RELEASE(_imageView);
    QY_SAFE_RELEASE(_imagePath);
    
    [activityIndicatorView release];
    
    [super dealloc];
}


- (void)loadView
{
    [super loadView];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [_scrollView addGestureRecognizer:doubleTapRecognizer];
    [doubleTapRecognizer release];
    
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [_scrollView addGestureRecognizer:twoFingerTapRecognizer];
    [twoFingerTapRecognizer release];
    
    
    if(ios7)
    {
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44+20)];
    }
    else
    {
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    }
    //    _headView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    _headView.backgroundColor = [UIColor clearColor];
    //_headView.image = [UIImage imageNamed:@"bg_image_browser.png"];
    _headView.backgroundColor = [UIColor colorWithRed:20/255 green:20/255 blue:20/255 alpha:0.75];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    //    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
    //    line.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    //    [_headView addSubview:line];
    
    _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    if(ios7)
    {
        _closeButton.frame = CGRectMake(4, 2+20, 40, 40);
    }
    else
    {
        _closeButton.frame = CGRectMake(4, 2, 40, 40);
    }
    [_closeButton setBackgroundColor:[UIColor clearColor]];
    //    [_closeButton setTitle:@"C" forState:UIControlStateNormal];
    //    [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_closeButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    
    [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_closeButton];
    
    //    _imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
    //    _imageView.image = [UIImage imageWithContentsOfFile:_imagePath];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [_scrollView addGestureRecognizer:tap];
    [tap requireGestureRecognizerToFail:doubleTapRecognizer];
    [tap release];
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundImageView.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:_backgroundImageView atIndex:0];
    
    
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = CGPointMake(150, 235);
    if (iPhone5) {
        activityIndicatorView.center = CGPointMake(150, 235+40);
    }
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
    if(!image)
    {
        [self clickCloseButton:nil];
        return;
    }
    _imageView = [[UIImageView alloc] initWithImage:image];
    
    if(_imageView.image.size.width / _imageView.image.size.height > 320 / _scrollView.frame.size.height)
    {
        _scrollView.contentSize = CGSizeMake(_imageView.image.size.width / _imageView.image.size.height * _scrollView.frame.size.height, _scrollView.frame.size.height);
    }
    else
    {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _imageView.image.size.height / _imageView.image.size.width * _scrollView.frame.size.width);
    }
    
    _imageView.frame = CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height);
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_scrollView addSubview:_imageView];
    
    _scrollView.minimumZoomScale = MIN(_scrollView.frame.size.width / _scrollView.contentSize.width, _scrollView.frame.size.height / _scrollView.contentSize.height);
    _scrollView.maximumZoomScale = _imageView.image.size.width / 320;
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
    
    [activityIndicatorView stopAnimating];
}



- (void)centerScrollViewContents
{
    CGSize boundsSize = _scrollView.bounds.size;
    CGRect contentsFrame = _imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    _imageView.frame = contentsFrame;
}

- (void)clickCloseButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissModalViewControllerAnimated:YES];
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    // 1
    CGPoint pointInView = [recognizer locationInView:_imageView];
    
    // 2
    CGFloat newZoomScale;// = _scrollView.zoomScale * 1.5f;
    //    newZoomScale = MIN(newZoomScale, _scrollView.maximumZoomScale);
    
    if(_scrollView.zoomScale == _scrollView.maximumZoomScale)
    {
        newZoomScale = _scrollView.minimumZoomScale;
    }
    else
    {
        newZoomScale = _scrollView.maximumZoomScale;
    }
    
    // 3
    CGSize scrollViewSize = _scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [_scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer
{
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = _scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, _scrollView.minimumZoomScale);
    [_scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)tap:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        _headView.hidden = !_headView.hidden;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

@end
