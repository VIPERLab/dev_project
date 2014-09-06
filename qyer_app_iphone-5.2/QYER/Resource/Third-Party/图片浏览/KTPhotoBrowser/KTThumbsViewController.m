//
//  KTThumbsViewController.m
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "KTThumbsViewController.h"
#import "KTThumbsView.h"
#import "KTThumbView.h"
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "GetPoiPhotoImages.h"



#define heightForRow                80
#define serverImageSize             80


#define chineseTitleLabelX          50
#define chineseTitleLabelY          5
#define chineseTitleLabelWidth      220
#define chineseTitleLabelHeight     20

#define englishTitleLabelX          50
#define englishTitleLabelY          23
#define englishTitleLabelWidth      220
#define englishTitleLabelHeight     20

#define poiImageHeight              180
#define poiCommentHeight            50


#define chineseTitleTypeSize        16
#define englishTitleTypeSize        14






@interface KTThumbsViewController (Private)
@end


@implementation KTThumbsViewController

@synthesize dataSource = dataSource_;
@synthesize navigationTitle = _navigationTitle;
@synthesize poiId;
@synthesize max_id = _max_id;
@synthesize typeImage = _typeImage;





- (void)dealloc
{
    
    [_headView release];
    [_chineseTitleLabel release];
    [_englishTitleLabel release];
    [_backButton release];
    [_navigationTitle release];
    [_chineseTitle release];
    [_englishTitle release];
    [_typeImage release];
    [_myTableView release];
    
    [_poiPhotoDataArray removeAllObjects];
    [_poiPhotoDataArray release];
    [_poiAllPhotoDataArray removeAllObjects];
    [_poiAllPhotoDataArray release];
    [_poiImagesMaxidArray removeAllObjects];
    [_poiImagesMaxidArray release];
    
    [images_ release];
    [allImages_ release];
    
    [_getPoiImages release];
    [_getAllPoiImages release];
    
    [scrollView_ release], scrollView_ = nil;
    
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    // The first time the view appears, store away the current translucency so we can reset on pop.
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    if (!viewDidAppearOnce_)
    {
        viewDidAppearOnce_ = YES;
        navbarWasTranslucent_ = [navbar isTranslucent];
    }
    // Then ensure translucency to match the look of Apple's Photos app.
    [navbar setTranslucent:YES];
    
    [super viewWillAppear:animated];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(poiImagePositionDidChanged:) name:@"poiImagePositionDidChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(poiImagePosition:) name:@"poiImagePosition" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Restore old translucency when we pop this controller.
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    [navbar setTranslucent:navbarWasTranslucent_];
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)loadView
{
    // Make sure to set wantsFullScreenLayout or the photo
    // will not display behind the status bar.
    
    
    [self initScrollView];
    [self getPoiImagesFromServer];
    
    [self getAllPoiImagesFromServer];
}
-(void)initImageView
{
    //    images_ = [[SDWebImageDataSource alloc] init];
    //    [self setDataSource:images_];
    
    images_ = [[SDWebImageDataSource alloc] initWithImages:_poiPhotoDataArray];
    [self setDataSource:images_];
}

#pragma mark -
#pragma mark --- setNavigationgbarInfo
-(void)setNavigationgbarInfo:(NSDictionary *)dic
{
    _chineseTitle = [[dic objectForKey:@"_chineseTitle"] retain];
    _englishTitle = [[dic objectForKey:@"_englishTitle"] retain];
    _typeImage = [[dic objectForKey:@"_typeImage"] retain];
    
    [self setTitleView];
}
-(void)setTitleView
{
    if(_chineseTitle && _chineseTitle.length > 0 && _englishTitle && _englishTitle.length > 0)
    {
        [self setTitleViewWithAll];
    }
    else if(!_englishTitle || _englishTitle.length < 1)
    {
        [self setTitleViewWithImageAndChinese];
    }
    else
    {
        [self setTitleViewWithImageAndEnglish];
    }
}
-(void)setTitleViewWithImageAndChinese
{
    _chineseTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(chineseTitleLabelX, chineseTitleLabelY+8, chineseTitleLabelWidth, chineseTitleLabelHeight)];
    _chineseTitleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _chineseTitleLabel.backgroundColor = [UIColor clearColor];
    _chineseTitleLabel.text = _chineseTitle;
    _chineseTitleLabel.textAlignment = NSTextAlignmentCenter;
    _chineseTitleLabel.textColor = [UIColor whiteColor];
    _chineseTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleTypeSize];
    _chineseTitleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    _chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_chineseTitleLabel];
    
}
-(void)setTitleViewWithImageAndEnglish
{
    _chineseTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(chineseTitleLabelX, chineseTitleLabelY+8, chineseTitleLabelWidth, chineseTitleLabelHeight)];
    _chineseTitleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _chineseTitleLabel.backgroundColor = [UIColor clearColor];
    _chineseTitleLabel.text = _englishTitle;
    _chineseTitleLabel.textAlignment = NSTextAlignmentCenter;
    _chineseTitleLabel.textColor = [UIColor whiteColor];
    _chineseTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleTypeSize];
    _chineseTitleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    _chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_chineseTitleLabel];
}
-(void)setTitleViewWithAll
{
    _chineseTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(chineseTitleLabelX, chineseTitleLabelY, chineseTitleLabelWidth, chineseTitleLabelHeight)];
    _chineseTitleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 1);
    _chineseTitleLabel.backgroundColor = [UIColor clearColor];
    _chineseTitleLabel.text = _chineseTitle;
    _chineseTitleLabel.textAlignment = NSTextAlignmentCenter;
    _chineseTitleLabel.textColor = [UIColor whiteColor];
    _chineseTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleTypeSize];
    _chineseTitleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_chineseTitleLabel];
    [_chineseTitleLabel sizeToFit];
    
    
    
    
    
    CGRect frame = _chineseTitleLabel.frame;
    frame.origin.x = (int)frame.origin.x;
    frame.origin.y = (int)frame.origin.y;
    _chineseTitleLabel.frame = frame;
    
    
    
    
    
    _englishTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(englishTitleLabelX, englishTitleLabelY, englishTitleLabelWidth, englishTitleLabelHeight)];
    _englishTitleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _englishTitleLabel.backgroundColor = [UIColor clearColor];
    _englishTitleLabel.text = _englishTitle;
    _englishTitleLabel.textAlignment = NSTextAlignmentCenter;
    _englishTitleLabel.textColor = [UIColor whiteColor];
    _englishTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:englishTitleTypeSize];
    _englishTitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    _englishTitleLabel.shadowOffset = CGSizeMake(0, -1);
    [_headView addSubview:_englishTitleLabel];
    
    
    
    if(showImageViewOnNavigationbar)
    {
        UIImageView *imageV;
        if(_chineseTitleLabel.frame.origin.x - chineseTitleLabelX <= 0)
        {
            imageV = [[UIImageView alloc] initWithFrame:CGRectMake(chineseTitleLabelX +5, _chineseTitleLabel.frame.origin.y+_chineseTitleLabel.frame.size.height/2.-11, 18, 18)];
            
            CGRect frame = _chineseTitleLabel.frame;
            frame.origin.x = imageV.frame.origin.x +11+18;
            frame.size.width = chineseTitleLabelWidth-5-18-11;
            _chineseTitleLabel.frame = frame;
        }
        else
        {
            CGRect frame = _chineseTitleLabel.frame;
            frame.origin.x = frame.origin.x +11;
            _chineseTitleLabel.frame = frame;
            
            
            imageV = [[UIImageView alloc] initWithFrame:CGRectMake(_chineseTitleLabel.frame.origin.x-25, _chineseTitleLabel.frame.origin.y+_chineseTitleLabel.frame.size.height/2.-11, 18, 18)];
        }
        imageV.backgroundColor = [UIColor clearColor];
        imageV.image = self.typeImage;
        [_headView addSubview:imageV];
    }
}


#pragma mark -
#pragma mark --- initScrollView
-(void)initScrollView
{
    [self setWantsFullScreenLayout:YES];
    
    KTThumbsView *scrollView = [[KTThumbsView alloc] initWithFrame:CGRectZero];
    [scrollView setDataSource:self];
    [scrollView setController:self];
    [scrollView setScrollsToTop:YES];
    [scrollView setScrollEnabled:YES];
    [scrollView setAlwaysBounceVertical:YES];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    
    if ([dataSource_ respondsToSelector:@selector(thumbsHaveBorder)]) {
        [scrollView setThumbsHaveBorder:[dataSource_ thumbsHaveBorder]];
    }
    
    if ([dataSource_ respondsToSelector:@selector(thumbSize)]) {
        [scrollView setThumbSize:[dataSource_ thumbSize]];
    }
    
    if ([dataSource_ respondsToSelector:@selector(thumbsPerRow)]) {
        [scrollView setThumbsPerRow:[dataSource_ thumbsPerRow]];
    }
    
    
    // Set main view to the scroll view.
    //[self setView:scrollView];
    
    //UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    UIView *rootView = [[UIView alloc] init];
    rootView.backgroundColor = [UIColor clearColor];
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.userInteractionEnabled = YES;
    [rootView addSubview:_headView];
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, 3, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    scrollView.frame=CGRectMake(0, 20+42, [[UIScreen mainScreen ]bounds].size.width , [[UIScreen mainScreen ]bounds].size.height-20-42);
    [rootView addSubview:scrollView];
    [self setView:rootView];
    [rootView release];
    
    
    
    // Retain a reference to the scroll view.
    scrollView_ = scrollView;
    [scrollView_ retain];
    
    //*** anqing set delegate
    scrollView_.delegate = self;
    
    // Release the local scroll view reference.
    [scrollView release];
}


#pragma mark -
#pragma mark --- KTThumbsViewDataSource
- (NSInteger)thumbsViewNumberOfThumbs:(KTThumbsView *)thumbsView
{
    NSInteger count = [dataSource_ numberOfPhotos];
    return count;
}


#pragma mark -
#pragma mark --- Thumbs delegate
- (void)willLoadThumbs {
    // Do nothing by default.
}

- (void)didLoadThumbs {
    // Do nothing by default.
    
}

- (void)reloadThumbs {
    [self willLoadThumbs];
    
    [scrollView_ reloadData];
    [self didLoadThumbs];
}

- (void)setDataSource:(id <KTPhotoBrowserDataSource>)newDataSource
{
    dataSource_ = newDataSource;
    [self reloadThumbs];
}

- (void)didSelectThumbAtIndex:(NSUInteger)index
{
    [self setDataSource_anqing:allImages_];
    
    KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc]
                                                  initWithDataSource:allDataSource_
                                                  andStartWithPhotoAtIndex:index];
    
    [[self navigationController] pushViewController:newController animated:YES];
    [newController release];
}
- (KTThumbView *)thumbsView:(KTThumbsView *)thumbsView thumbForIndex:(NSInteger)index
{
    KTThumbView *thumbView = [thumbsView dequeueReusableThumbView];
    if (!thumbView)
    {
        thumbView = [[[KTThumbView alloc] initWithFrame:CGRectZero] autorelease];
        [thumbView setController:self];
    }
    
    // Set thumbnail image.
    if ([dataSource_ respondsToSelector:@selector(thumbImageAtIndex:thumbView:)] == NO)
    {
        // Set thumbnail image synchronously.
        UIImage *thumbImage = [dataSource_ thumbImageAtIndex:index];
        [thumbView setThumbImage:thumbImage];
    }
    else
    {
        // Set thumbnail image asynchronously.
        [dataSource_ thumbImageAtIndex:index thumbView:thumbView];
    }
    
    return thumbView;
}


#pragma mark -
#pragma mark --- getPoiImagesFromServer
-(void)getPoiImagesFromServer
{
    if(!_getPoiImages)
    {
        _getPoiImages = [[GetPoiPhotoImages alloc] init];
    }
    [_getPoiImages getPoiPhotoImagesByClientid:ClientId_QY andClientSecrect:ClientSecret_QY andPoiId:self.poiId andMax_id:self.max_id finished:^{
        
        MYLog(@"getPoiImagesFromServer 成功!!!");
        
        downloadNewDataFlag = 0;
        
        if(!_poiPhotoDataArray)
        {
            _poiPhotoDataArray = [[NSMutableArray alloc] init];
        }
        [_poiPhotoDataArray addObjectsFromArray:_getPoiImages.dataArray];
        GetPoiPhotoImages *getPoiImagesdata = (GetPoiPhotoImages *)[_getPoiImages.dataArray lastObject];
        self.max_id = [getPoiImagesdata.imageIdStr intValue]-1;
        
        
        
        //判断是否已经下载完所有的数据
        if([_getPoiImages.dataArray count] < getImageNumberOneTime)
        {
            isDownloadAllData = 1;
        }
        else
        {
            isDownloadAllData = 0;
        }
        
        [self performSelector:@selector(initImageView) withObject:nil afterDelay:0];
        
    } failed:^{
        downloadNewDataFlag = 0;
    }];
}

-(void)getAllPoiImagesFromServer
{
    if(!_getAllPoiImages)
    {
        _getAllPoiImages = [[GetPoiPhotoImages alloc] init];
    }
    [_getAllPoiImages getAllPoiPhotoImagesByClientid:ClientId_QY andClientSecrect:ClientSecret_QY andPoiId:self.poiId andMax_id:0 finished:^{
        
        MYLog(@"getAllPoiImagesFromServer 成功!!!");
        
        if(!_poiAllPhotoDataArray)
        {
            _poiAllPhotoDataArray = [[NSMutableArray alloc] init];
        }
        [_poiAllPhotoDataArray removeAllObjects];
        [_poiAllPhotoDataArray addObjectsFromArray:_getAllPoiImages.allDataArray];
        
        
        if(!_poiImagesMaxidArray)
        {
            _poiImagesMaxidArray = [[NSMutableArray alloc] init];
        }
        [_poiImagesMaxidArray removeAllObjects];
        [_poiImagesMaxidArray addObjectsFromArray:_getAllPoiImages.allMaxIdArray];
        
        
        [self performSelector:@selector(initAllImageView) withObject:nil afterDelay:0];
        
    } failed:^{
        
    }];
}



#pragma mark -
#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(isDownloadAllData == 0 && downloadNewDataFlag == 0 && scrollView_.contentOffset.y+scrollView_.frame.size.height - scrollView_.contentSize.height >= 30)
    {
        MYLog(@"再去网上加载数据 ^ ^ ");
        
        downloadNewDataFlag = 1;
        [self appendNewImagesFromServer];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}
-(void)appendNewImagesFromServer
{
    
    CGSize size = scrollView_.contentSize;
    size.height += 60;
    scrollView_.contentSize = size;
    [scrollView_ setContentOffset:CGPointMake(0, scrollView_.contentOffset.y+30)];
    
    
    
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    activityView.frame = CGRectMake(150, size.height-15, 20, 20);
    [scrollView_ addSubview:activityView];
    [activityView startAnimating];
    activityView.backgroundColor = [UIColor redColor];
    
    [self performSelector:@selector(getPoiImagesFromServer) withObject:nil afterDelay:0.2];
}


#pragma mark -
#pragma mark --- poiImagePositionDidChanged
- (void)poiImagePositionDidChanged:(NSNotification*)notification
{
    NSInteger line = [notification.object intValue]/poiImageNumberOfOneLine; //第几行
    float offsetY = line * poiImageViewHeight+(320.0-poiImageViewHeight*poiImageNumberOfOneLine)/(poiImageNumberOfOneLine+1);
    if(line == 0 || scrollView_.contentSize.height-scrollView_.frame.size.height <= 0)
    {
        return;
    }
    else if(offsetY+scrollView_.frame.size.height < scrollView_.contentSize.height)
    {
        [scrollView_ setContentOffset:CGPointMake(0, offsetY)];
    }
    else
    {
        [scrollView_ setContentOffset:CGPointMake(0, scrollView_.contentSize.height-scrollView_.frame.size.height)];
    }
}

#pragma mark -
#pragma mark --- poiImagePosition
- (void)poiImagePosition:(NSNotification*)notification
{
    imagePosition = [notification.object intValue];
    
    if([_poiAllPhotoDataArray count] <= 20)
    {
        return;
    }
    else if(imagePosition*20 > [_poiPhotoDataArray count])
    {
        [self reInitImageView];
    }
}



#pragma mark -
#pragma mark --- setDataSource_anqing ******************************
-(void)initAllImageView
{
    allImages_ = [[SDWebImageDataSource alloc] initWithImages:_poiAllPhotoDataArray];
}
- (void)setDataSource_anqing:(id <KTPhotoBrowserDataSource>)newDataSource
{
    allDataSource_ = newDataSource;
}

-(void)reInitImageView
{
    [_poiPhotoDataArray removeAllObjects];
    for(int i = 0; i < imagePosition*20;i++)
    {
        if(imagePosition*20 > [_poiAllPhotoDataArray count])
        {
            break;
        }
        else
        {
            [_poiPhotoDataArray addObject:[_poiAllPhotoDataArray objectAtIndex:i]];
        }
    }
    
    if(imagePosition < [_poiImagesMaxidArray count])
    {
        self.max_id = [[_poiImagesMaxidArray objectAtIndex:imagePosition] intValue];
    }
    else
    {
        self.max_id = [[_poiImagesMaxidArray lastObject] intValue];
    }
    
    images_ = [[SDWebImageDataSource alloc] initWithImages:_poiPhotoDataArray];
    [self setDataSource:images_];
}



#pragma mark -
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
{
    downloadNewDataFlag = 0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getPoiImagesFromServer) object:nil];
    
    if(_getPoiImages)
    {
        [_getPoiImages cancle];
    }
    
    if(_getAllPoiImages)
    {
        [_getAllPoiImages cancle];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    
    [_poiPhotoDataArray removeAllObjects];
    [_poiPhotoDataArray release];
    [_poiAllPhotoDataArray removeAllObjects];
    [_poiAllPhotoDataArray release];
	
	// Release any cached data, images, etc that aren't in use.
}


#pragma mark -
#pragma mark --- viewDidUnload
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
