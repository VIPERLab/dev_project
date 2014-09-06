//
//  QYMapViewController.m
//  QyGuide
//
//  Created by an qing on 13-3-12.
//
//

#import "QYMapViewController.h"
#import "MyPoitAnnotation.h"
#import "MyCallOutAnnotationView.h"
#import "MyPopAnnotation.h"
#import "MyLocationAnnotation.h"
#import "PoiDetailViewController.h"
#import "GetInfo.h"
#import "CheckNetStatus.h"
#import "Toast+UIView.h"
#import "GetPoiListFromGuide.h"
#import "MobClick.h"
#import <CoreLocation/CLHeading.h>
#import <QuartzCore/QuartzCore.h>
#import "math.h"

#import "QYMapViewController.h"

#import "OSMTileOverlay.h"
#import "CustomOverlayView.h"
#import "AppDelegate.h"
#import "GetPoiDetailInfo.h"
#import "UIImageView+WebCache.h"



#define toRad(X) (X*M_PI/180.0)



#define popViewOffsetX      0
#define popViewOffsetY      -62   //大头针和popview之间的偏移量
#define showMyLocationTime  20    //定位超时时间

#define test_flag           0     //测试map的某些功能 [仅测试时使用]




@interface QYMapViewController ()

@end





@implementation QYMapViewController
@synthesize delegate;
@synthesize pressAnnotation;
@synthesize showPopViewFlag = _showPopViewFlag;
@synthesize isFromReadVCAndOnlyOnePoint = _isFromReadVCAndOnlyOnePoint;
@synthesize locationManager = _locationManager;
@synthesize fromPoidetailVC = _fromPoidetailVC;

@synthesize currentHeading;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        
        [self setRootView];
        [self setNavigationBar];
        
        
    }
    return self;
}


-(void)dealloc
{
    _myMapView.delegate = nil;
    
    [_array_mapViewHeader removeAllObjects];
    [_array_mapViewHeader release];
    
    [_dataDic removeAllObjects];
    [_dataDic release];
    
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_myMapView);
    QY_VIEW_RELEASE(_activityView);
    QY_VIEW_RELEASE(_myPositionView);
    
    QY_SAFE_RELEASE(_tap);
    QY_SAFE_RELEASE(_poilistInfoDic);
    QY_SAFE_RELEASE(_poilistInfoDataArray);
    QY_SAFE_RELEASE(_pinArray);
    QY_SAFE_RELEASE(_calloutAnnotation_autoShow);
    QY_SAFE_RELEASE(_chineseName);
    QY_SAFE_RELEASE(_englishName);
    
    [_minePoint release];
    
    if (overlayView)
    {
        [overlayView release];
        overlayView = nil;
    }
    
    [_locationManager stopUpdatingHeading];
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    [_locationManager release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    if (ios7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    
    
    if(_isShowPoiFlag == 0)
    {
        _isShowPoiFlag = 1;
        [self showAllPoi];
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setmapview_delegatenil) name:@"setmapviewdelegatenil" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setmapview_delegate) name:@"setmapviewdelegate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:@"stop" object:nil];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"frommapvc"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    _myMapView.delegate = self;
    if(_locationManager)
    {
        _locationManager.delegate = self;
    }
}
-(void)setmapview_delegatenil
{
    if(_locationManager)
    {
        [_locationManager stopUpdatingHeading];
        [_locationManager stopUpdatingLocation];
        
        _locationManager.delegate = nil;
        _myMapView.delegate = nil;
    }
}
-(void)setmapview_delegate
{
    if(_locationManager)
    {
        _locationManager.delegate = self;
        _myMapView.delegate = self;
        
        [_locationManager startUpdatingHeading];
        
        if(_isShowCurrentLocation == 1)
        {
            [_locationManager startUpdatingLocation];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view hideToast];
    
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkActivityViewState) object:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setDrawRectReturn" object:nil];
    
    _myMapView.delegate = nil;
    if(_locationManager)
    {
        _locationManager.delegate = nil;
        [_locationManager stopUpdatingHeading];
        [_locationManager stopUpdatingLocation];
    }
    
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
    _headView.image = [UIImage imageNamed:@"home_head.png"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
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
-(void)setNavigationTitle:(NSString*)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 3, 220, 40)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(50, 3+20, 220, 40);
    }
    titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = [NSString stringWithFormat:@"%@地图",title];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [_headView addSubview:titleLabel];
    [titleLabel release];
}


#pragma mark -
#pragma mark --- initMapView
-(void)initMapView
{
    if(!_myMapView)
    {
        if(iPhone5)
        {
            if(ios7)
            {
                _myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, [[UIScreen mainScreen] bounds].size.height-(_headView.frame.size.height))];
                _myMapView.rotateEnabled = NO;
            }
            else
            {
                _myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, [[UIScreen mainScreen] bounds].size.height-20-(_headView.frame.size.height)+18)];
            }
            
            
            
//            if(!ios7)
//            {
//                //google_logoView:
//                UIImageView *google_logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _myMapView.frame.size.height-50/2-20, 160/2, 50/2)];
//                UIImage *logoImage =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"谷歌logo@2x" ofType:@"png"]];
//                google_logoView.image = logoImage;
//                google_logoView.backgroundColor = [UIColor clearColor];
//                [_myMapView addSubview:google_logoView];
//                [google_logoView release];
//            }
        }
        else
        {
            NSString *deviceSystemVersion = [[UIDevice currentDevice] systemVersion];
            if([deviceSystemVersion floatValue] - 6. < 0)
            {
                _myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, 460-(_headView.frame.size.height))];
            }
            else
            {
                _myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, 480-(_headView.frame.size.height))]; //处理高德地图上的默认文字
            }
        }
    }
    [_myMapView setDelegate:self];
    [_myMapView setMapType:0]; //类型:MKMapTypeStandard=0,MKMapTypeSatellite,MKMapTypeHybrid
    [self.view addSubview:_myMapView];
    [self.view bringSubviewToFront:_imageView_mapViewHeader];
    [self.view bringSubviewToFront:_headView];
    
    
    
    
    //设定一些属性值
    //////_myMapView.showsUserLocation = YES;  //***会在自己的位置处显示一个绿色的小点!
    _myMapView.scrollEnabled = YES;
    _myMapView.zoomEnabled = YES;
    
    
    
    
    // ----- Add our overlay layer to the map
    NSString *deviceSystemVersion = [[UIDevice currentDevice] systemVersion];
    if([deviceSystemVersion intValue] >= 6)
    {
        OSMTileOverlay *overlay = [[[OSMTileOverlay alloc] init] autorelease];
        
        [_myMapView addOverlay:overlay];
    }
    
    
    
    
    //定位按钮:
    _locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if(_flag_pointOnly == 0)
    {
        _imageView_mapViewHeader.alpha = 1;
        _locateButton.frame = CGRectMake(320-44-5+9, _myMapView.frame.origin.y+7 + 46, 35, 35);
    }
    else
    {
        _imageView_mapViewHeader.alpha = 0;
        _locateButton.frame = CGRectMake(320-44-5+9, _myMapView.frame.origin.y+7, 35, 35);
    }
    _locateButton.backgroundColor = [UIColor clearColor];
    [_locateButton addTarget:self action:@selector(showMyLocation) forControlEvents:UIControlEventTouchUpInside];
    //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"手动地图icon@2x" ofType:@"png"]];
    UIImage *image = [UIImage imageNamed:@"手动地图icon"];
    [_locateButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.view addSubview:_locateButton];
    
}




#pragma mark -
#pragma mark --- initMapViewHeader
-(void)initMapViewHeader
{
    if(!_imageView_mapViewHeader)
    {
        _imageView_mapViewHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 46, 320, 46)];
    }
    if(ios7)
    {
        _imageView_mapViewHeader.frame = CGRectMake(0, 46+20, 320, 46);
    }
    _imageView_mapViewHeader.backgroundColor = [UIColor clearColor];
    //_imageView_mapViewHeader.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"背景@2x" ofType:@"png"]];
    _imageView_mapViewHeader.image = [UIImage imageNamed:@"背景"];
    _imageView_mapViewHeader.userInteractionEnabled = YES;
    [self.view addSubview:_imageView_mapViewHeader];
    [self.view bringSubviewToFront:_headView];
    
    [self initArray_mapViewHeader];
    [self initPoiStytleViewWithArray:_array_mapViewHeader inView:_imageView_mapViewHeader];
    
}
-(void)initArray_mapViewHeader
{
    if(!_array_mapViewHeader)
    {
        _array_mapViewHeader = [[NSMutableArray alloc] init];
    }
    [_array_mapViewHeader removeAllObjects];
    
    if(!_array_mapViewHeader_unselect)
    {
        _array_mapViewHeader_unselect = [[NSMutableArray alloc] init];
    }
    [_array_mapViewHeader_unselect removeAllObjects];
    
    [_array_mapViewHeader addObject:@"style_全部@2x"];
    [_array_mapViewHeader addObject:@"style_景点@2x"];
    [_array_mapViewHeader addObject:@"style_餐饮@2x"];
    [_array_mapViewHeader addObject:@"style_购物@2x"];
    [_array_mapViewHeader addObject:@"style_体验@2x"];
    [_array_mapViewHeader addObject:@"style_交通@2x"];
    
    [_array_mapViewHeader addObject:@"style_全部_pressed@2x"];
    [_array_mapViewHeader addObject:@"style_景点_pressed@2x"];
    [_array_mapViewHeader addObject:@"style_餐饮_pressed@2x"];
    [_array_mapViewHeader addObject:@"style_购物_pressed@2x"];
    [_array_mapViewHeader addObject:@"style_体验_pressed@2x"];
    [_array_mapViewHeader addObject:@"style_交通_pressed@2x"];
    
    [_array_mapViewHeader_unselect addObject:@"style_unselect_全部@2x"];
    [_array_mapViewHeader_unselect addObject:@"style_unselect_景点@2x"];
    [_array_mapViewHeader_unselect addObject:@"style_unselect_餐饮@2x"];
    [_array_mapViewHeader_unselect addObject:@"style_unselect_购物@2x"];
    [_array_mapViewHeader_unselect addObject:@"style_unselect_体验@2x"];
    [_array_mapViewHeader_unselect addObject:@"style_unselect_交通@2x"];
}
-(void)initPoiStytleViewWithArray:(NSArray *)array inView:(UIImageView *)view
{
    for(int i = 0; i < array.count/2; i++)
    {
        NSString *name_icon = [array objectAtIndex:i];
        NSString *name_icon_select = [array objectAtIndex:(i+6)];
        NSInteger positionX = (12 + 80/2.)*i + 11;
        
        UIButton *button_poiStytle = [UIButton buttonWithType:UIButtonTypeCustom];
        button_poiStytle.frame = CGRectMake(positionX, 3, 40, 40);
        button_poiStytle.tag = i+10;
        button_poiStytle.backgroundColor = [UIColor clearColor];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name_icon ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",name_icon]];
        [button_poiStytle setBackgroundImage:image forState:UIControlStateNormal];
        //image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name_icon_select ofType:@"png"]];
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",name_icon_select]];
        [button_poiStytle setBackgroundImage:image forState:UIControlStateHighlighted];
        [button_poiStytle addTarget:self action:@selector(select_style:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button_poiStytle];
    }
}
-(void)select_style:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag)
    {
        case 10:
        {
            //NSLog(@"全部");
            
            [self screenOutPoiByStytle:@"0"];
            [self updatePoiStyleButtonImageByTag:10];
        }
            break;
        case 11:
        {
            //NSLog(@"景点");
            
            [self screenOutPoiByStytle:@"32"];
            [self updatePoiStyleButtonImageByTag:11];
        }
            break;
        case 12:
        {
            //NSLog(@"餐饮");
            
            [self screenOutPoiByStytle:@"78"];
            [self updatePoiStyleButtonImageByTag:12];
        }
            break;
        case 13:
        {
            //NSLog(@"购物");
            
            [self screenOutPoiByStytle:@"147"];
            [self updatePoiStyleButtonImageByTag:13];
        }
            break;
        case 14:
        {
            //NSLog(@"体验");
            
            [self screenOutPoiByStytle:@"148"];
            [self updatePoiStyleButtonImageByTag:14];
        }
            break;
        case 15:
        {
            //NSLog(@"交通");
            
            [self screenOutPoiByStytle:@"77"];
            [self updatePoiStyleButtonImageByTag:15];
        }
            break;
            
        default:
            break;
    }
}
-(void)screenOutPoiByStytle:(NSString *)cate_id
{
    switch ([cate_id intValue])
    {
        case 0:
        {
            if(_pinArray)
            {
                [_myMapView removeAnnotations:_pinArray];
                [_pinArray removeAllObjects];
            }
            if(_pinArray_copy && _pinArray_copy.count > 0)
            {
                [_pinArray addObjectsFromArray:_pinArray_copy];
                
                if(_isShowCurrentLocation == 1)
                {
                    if(_minePoint)
                    {
                        [_pinArray addObject:_minePoint];
                    }
                }
                
                [_myMapView addAnnotations:_pinArray];
            }
        }
            break;
        default:
        {
            [self screenOutWithCateId:cate_id];
        }
            break;
    }
}
-(void)updatePoiStyleButtonImageByTag:(NSInteger)tag
{
    switch (tag)
    {
        case 10:
        {
            [self resetButtonImage:1];
        }
            break;
        default:
        {
            [self resetButtonImage:0];
            [self selectButtonWithTag:tag];
        }
            break;
    }
}
-(void)screenOutWithCateId:(NSString *)cate_id
{
    if(_pinArray)
    {
        [_myMapView removeAnnotations:_pinArray];
        [_pinArray removeAllObjects];
    }
    
    for(MyPoitAnnotation *point in _pinArray_copy)
    {
        if([point.cateIdStr isEqualToString:cate_id])
        {
            [_pinArray addObject:point];
        }
    }
    
    if(_isShowCurrentLocation == 1)
    {
        if(_minePoint)
        {
            [_pinArray addObject:_minePoint];
        }
    }
    
    
    
    if(_pinArray && _pinArray.count > 0)
    {
        [_myMapView addAnnotations:_pinArray];
    }
}
-(void)resetButtonImage:(BOOL)flag  //flag=1表示全选;flag=0表示全不选
{
    for(int i = 0; i < _array_mapViewHeader.count/2; i++)
    {
        NSString *name_icon = @"";
        if(flag == 1)
        {
            name_icon = [_array_mapViewHeader objectAtIndex:i];
        }
        else
        {
            name_icon = [_array_mapViewHeader_unselect objectAtIndex:i];
        }
        
        UIButton *button_poiStytle = (UIButton *)[_imageView_mapViewHeader viewWithTag:(i+10)];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name_icon ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",name_icon]];
        [button_poiStytle setBackgroundImage:image forState:UIControlStateNormal];
    }
}
-(void)selectButtonWithTag:(NSInteger)tag
{
    NSString *name_icon = [_array_mapViewHeader objectAtIndex:tag-10];
    UIButton *button_poiStytle = (UIButton *)[_imageView_mapViewHeader viewWithTag:tag];
    //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name_icon ofType:@"png"]];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",name_icon]];
    [button_poiStytle setBackgroundImage:image forState:UIControlStateNormal];
}



#pragma mark -
#pragma mark --- map Delegate [Google layer 需要]
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSString *deviceSystemVersion = [[UIDevice currentDevice] systemVersion];
    if([deviceSystemVersion intValue] >= 6)
    {
        overlayView = [[CustomOverlayView alloc] initWithOverlay:overlay];
        return overlayView;
    }
    
    return nil;
}




#pragma mark -
#pragma mark --- 显示所有点的位置
- (void)recenterMap
{
    if(_myMapView)
    {
        NSArray *coordinates = [_myMapView valueForKeyPath:@"annotations.coordinate"];
        
        
        CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
        CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
        for(NSValue *value in coordinates)
        {
            CLLocationCoordinate2D coord = {0.0f, 0.0f};
            [value getValue:&coord];
            if(coord.longitude > maxCoord.longitude) {
                maxCoord.longitude = coord.longitude;
            }
            if(coord.latitude > maxCoord.latitude) {
                maxCoord.latitude = coord.latitude;
            }
            if(coord.longitude < minCoord.longitude) {
                minCoord.longitude = coord.longitude;
            }
            if(coord.latitude < minCoord.latitude) {
                minCoord.latitude = coord.latitude;
            }
        }
        
        MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
        region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.;
        region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.;
        if(iPhone5)
        {
            region.span.longitudeDelta = (maxCoord.longitude - minCoord.longitude)*[[UIScreen mainScreen] bounds].size.height/460.;
            region.span.latitudeDelta = (maxCoord.latitude - minCoord.latitude)*[[UIScreen mainScreen] bounds].size.height/460.;
        }
        else
        {
            region.span.longitudeDelta = (maxCoord.longitude - minCoord.longitude);
            region.span.latitudeDelta = (maxCoord.latitude - minCoord.latitude);
        }
        
        if((self.showPopViewFlag == 1 && _isShowCurrentLocation == 0) || self.isFromReadVCAndOnlyOnePoint == 1)
        {
            region.span.longitudeDelta = 0.016;
            region.span.latitudeDelta = 0.016;
        }
        
        [_myMapView setRegion:region animated:YES];
    }
}

-(void)setRegion
{
    MKCoordinateRegion region = _myMapView.region;
    region.span.longitudeDelta = 0.016;
    region.span.latitudeDelta = 0.016;
    [_myMapView setRegion:region animated:NO];
}


#pragma mark -
#pragma mark --- showAllPoi
-(void)showAllPoi
{
    [self initMapViewHeader];
    [self initMapView];
    
    
    if(_pinArray.count > 0)
    {
        [_myMapView addAnnotations:_pinArray];
    }
    
    
    //*** 此方法一定要写到addAnnotations方法后面 !!!!!!
    [self recenterMap];
    
    
    
    if(self.showPopViewFlag == 1 || self.isFromReadVCAndOnlyOnePoint == 1)
    {
        [self performSelector:@selector(autoShowPopView) withObject:nil afterDelay:0.2];
    }
    self.isFromReadVCAndOnlyOnePoint = 0;
    
    
    
    
    [self customInitialize];
    [self adjustImageViewDirection];
    
}
-(void)initPinarrayWithDic:(NSDictionary *)dic
{
    _flag_pointOnly = 1;
    
    if(!_pinArray)
    {
        _pinArray = [[NSMutableArray alloc] init];
    }
    [_pinArray removeAllObjects];
    
    _poilistInfoDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
    CLLocationCoordinate2D theCenterofmine;
    theCenterofmine.latitude = [[dic objectForKey:@"lat"] floatValue];
    theCenterofmine.longitude = [[dic objectForKey:@"lng"] floatValue];
    MyPoitAnnotation *point = [[MyPoitAnnotation alloc] initWithCoords:theCenterofmine];
    point.poiId = [[dic objectForKey:@"poiId"] intValue];
    point.lat = [[dic objectForKey:@"lat"] floatValue];
    point.lng = [[dic objectForKey:@"lng"] floatValue];
    point.title = [dic objectForKey:@"_chineseTitle"];
    point.subtitle = [dic objectForKey:@"_englishTitle"];
    point.cateIdStr = [dic objectForKey:@"cateid"];
    point.type = [dic objectForKey:@"cateid"];
    point.image = [self setImageByCateid:[[dic objectForKey:@"cateid"] intValue]]; //大头针图片
    [_pinArray addObject:point];
    [point release];
    
    
    if(_pinArray_copy)
    {
        [_pinArray_copy removeAllObjects];
        [_pinArray_copy release];
    }
    _pinArray_copy = [[NSMutableArray alloc] initWithArray:_pinArray copyItems:YES];
    
    
}
-(void)initPinarray:(NSArray *)array
{
    _flag_pointOnly = 0;
    
    
    if(array && [array count] > 0)
    {
        if(!_pinArray)
        {
            _pinArray = [[NSMutableArray alloc] init];
        }
        [_pinArray removeAllObjects];
        
        if(!_poilistInfoDataArray)
        {
            _poilistInfoDataArray = [[NSMutableArray alloc] init];
        }
        [_poilistInfoDataArray removeAllObjects];
        [_poilistInfoDataArray addObjectsFromArray:array];
        
        if(_poilistInfoDataArray && [_poilistInfoDataArray count] > 0)
        {
            [self setPoilistInfoData];
        }
    }
    
}
-(void)setPoilistInfoData
{
    for(int i = 0;i < [_poilistInfoDataArray count];i++)
    {
        GetPoiListFromGuide *poilistInfo = (GetPoiListFromGuide *)[_poilistInfoDataArray objectAtIndex:i];
        
        CLLocationCoordinate2D theCenterofmine;
        theCenterofmine.latitude = poilistInfo.lat;
        theCenterofmine.longitude = poilistInfo.lng;
        MyPoitAnnotation *point = [[MyPoitAnnotation alloc] initWithCoords:theCenterofmine];
        point.lat = poilistInfo.lat;
        point.lng = poilistInfo.lng;
        point.poiId = poilistInfo.poiId;
        point.title = poilistInfo.chineseName;
        point.subtitle = poilistInfo.englishName;
        point.cateIdStr = [NSString stringWithFormat:@"%d",poilistInfo.cateId];
        point.type = [NSString stringWithFormat:@"%d",poilistInfo.cateId];
        point.image = [self setImageByCateid:poilistInfo.cateId];  //大头针图片
        [_pinArray addObject:point];
        [point release];
        
    }
    
    if(_pinArray_copy)
    {
        [_pinArray_copy removeAllObjects];
        [_pinArray_copy release];
    }
    _pinArray_copy = [[NSMutableArray alloc] initWithArray:_pinArray copyItems:YES];
    
}
-(UIImage *)setImageByCateid:(NSInteger)cate_id
{
    if(cate_id == 32) //景点
    {
//        NSString *str =[NSString stringWithFormat:@"%@@2x",@"目的地"];
//        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        
        UIImage *image = [UIImage imageNamed:@"目的地"];
        return image;
    }
    else if(cate_id == 77) //交通
    {
//        NSString *str =[NSString stringWithFormat:@"%@@2x",@"交通"];
//        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        
        UIImage *image = [UIImage imageNamed:@"交通"];
        return image;
    }
    else if(cate_id == 78) //餐饮
    {
//        NSString *str =[NSString stringWithFormat:@"%@@2x",@"餐饮"];
//        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        
        UIImage *image = [UIImage imageNamed:@"餐饮"];
        return image;
    }
    else if(cate_id == 147) //购物
    {
//        NSString *str =[NSString stringWithFormat:@"%@@2x",@"购物"];
//        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        
        UIImage *image = [UIImage imageNamed:@"购物"];
        return image;
    }
    else if(cate_id == 148) //活动
    {
//        NSString *str =[NSString stringWithFormat:@"%@@2x",@"体验"];
//        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"体验"];
        return image;
    }
    else if(cate_id == 149) //住宿
    {
//        NSString *str =[NSString stringWithFormat:@"%@@2x",@"酒店"];
//        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"酒店"];
        return image;
    }
    //else if(cate_id == 150) //实用信息
    //{
    //    return nil;
    //}
    //else if(cate_id == 151) //路线
    //{
    //    return nil;
    //}
    else
    {
//        NSString *str =[NSString stringWithFormat:@"%@@2x",@"其他"];
//        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"其他"];
        return image;
    }
    
    return nil;
}


#pragma mark -
#pragma mark --- 添加大头针,每在MapView中加入一个Annotation,就会调用此方法
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MyPoitAnnotation class]])
    {
        //MYLog(@"添加大头针");
        MyPoitAnnotation *point = (MyPoitAnnotation *)annotation;
        
        
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:point.type];
        if (!pinView)
        {
            // If an existing pin view was not available, create one
            pinView = [[[MKAnnotationView alloc] initWithAnnotation:point
                                                    reuseIdentifier:point.type] autorelease];
        }
        pinView.canShowCallout = NO;
        pinView.image = point.image;
        
        return pinView;
    }
    else if([annotation isKindOfClass:[MyPopAnnotation class]])
    {
        //MYLog(@"显示大头针的popView");
        //NSLog(@"annotation == %@",annotation);
        //MyPopAnnotation *point = (MyPopAnnotation *)annotation;
        
        //MyCallOutAnnotationView *callOutView = (MyCallOutAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutView"];
        //if (!callOutView)
        //{
        // If an existing pin view was not available, create one
        MyCallOutAnnotationView *callOutView = [[[MyCallOutAnnotationView alloc] initWithAnnotation:_calloutAnnotation reuseIdentifier:@"CalloutView"] autorelease];
        //}
        callOutView.canShowCallout = NO;
        callOutView.delegate = self;
        callOutView.centerOffset = CGPointMake(popViewOffsetX,popViewOffsetY);
        callOutView.contentView.backgroundColor = [UIColor clearColor];
        callOutView.contentView.image = [UIImage imageNamed:@"Iconx@2x.png"];
        callOutView.title = ((MyPopAnnotation *)annotation).title;
        callOutView.subtitle = ((MyPopAnnotation *)annotation).subtitle;
        callOutView.cateIdStr = ((MyPopAnnotation *)annotation).cateIdStr;
        callOutView.lat = ((MyPopAnnotation *)annotation).lat;
        callOutView.lng = ((MyPopAnnotation *)annotation).lng;
        callOutView.poiId = ((MyPopAnnotation *)annotation).poiId;
        
        
        if([_poilistInfoDic objectForKey:@"poiId"])
        {
            [self getPoiDetailInfoDataFromServerWithPoiId:[[_poilistInfoDic objectForKey:@"poiId"] intValue] inView:callOutView];
        }
        else
        {
            [self getPoiDetailInfoDataFromServerWithPoiId:((MyPopAnnotation *)annotation).poiId inView:callOutView];
        }
        
        
        
        //给PopView添加动画
        callOutView.alpha = 0;
        [self addAnimationForPopView:callOutView];
        
        
        callOutView.tag = 100;
        
        return callOutView;
    }
    else if(_isShowCurrentLocation == 1 || [annotation isKindOfClass:[MyPoitAnnotation class]]) //定位的图片
    {
        //NSLog(@"  ^^^ 定位的图片 -- 1");
        
        
        
        
        _myPositionView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"myPosition"];
        if (!_myPositionView)
        {
            // If an existing pin view was not available, create one
            _myPositionView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myPosition"];
        }
        
        
        _myPositionView.transform = headingRotation_copy;
        
        _myPositionView.canShowCallout = NO;
        //UIImage *image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"我得位置@2x" ofType:@"png"]];
        UIImage *image =  [UIImage imageNamed:@"我得位置"];
        _myPositionView.image = image;
        
        [self updateButtonImage:1];
        
        
        _isShowCurrentLocation = 1;
        //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkActivityViewState) object:nil];
        
        return _myPositionView;
    }
    
	return nil;
    
}


#pragma mark -
#pragma mark --- MapViewControllerDidSelectDelegate
-(void)popViewDidSelectedWithType:(NSString*)type andTitle:(NSString*)title andSubtitle:(NSString*)subtitle andLat:(float)lat andLng:(float)lng andPoiId:(NSInteger)poi_id
{
    if(![_chineseName isEqualToString:title])
    {
        [_chineseName release];
        _chineseName = [title retain];
    }
    if(![_englishName isEqualToString:subtitle])
    {
        [_englishName release];
        _englishName = [subtitle retain];
    }
    _lat = lat;
    _lng = lng;
    _poiId = poi_id;
    
    
    if([type isEqualToString:@"systemmap"])
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"导航功能需跳转系统地图\n确定打开？"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"确定",nil];
        [alertView show];
        [alertView release];
    }
    else if([type isEqualToString:@"poidetailinfo"])
    {
        [self readPoiDetailInfo];
    }
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex])
    {
        return;
    }
    else
    {
        if(alertView.tag == 121)
        {
            [_activityView stopAnimating];
            [self updateButtonImage:1];
        }
        else
        {
            [self turnToSystemMap];
        }
    }
}
-(void)turnToSystemMap
{
    NSString *version = [[GetInfo getDeviceInfoSystemVersion] retain];
    if([version floatValue] - 6. < 0)
    {
        [version release];
        
        //***(1).通过坐标跳转到google地图
        float latitudeTurnTo = _lat;
        float longitudeTurnTo = _lng;
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f",latitudeTurnTo,longitudeTurnTo];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else
    {
        [version release];
        
        CLLocationCoordinate2D location;
        location.latitude = _lat;
        location.longitude = _lng;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
        MKMapItem *item = [[[MKMapItem alloc] initWithPlacemark:placemark] autorelease];
        if(_chineseName && _chineseName.length > 0)
        {
            [item setName:_chineseName];
        }
        else
        {
            [item setName:_englishName];
        }
        //[item setPhoneNumber:@"+86 15501197655"];
        //[item setUrl:[NSURL URLWithString:@"http://www.m.qyer.com"]];
        NSDictionary *mapLaunchOptions = [NSDictionary dictionaryWithObjectsAndKeys:@"title",@"title", nil];
        [item openInMapsWithLaunchOptions:mapLaunchOptions];
        
        [placemark release];
    }
    
    MYLog(@"已跳转 +++++ ");
}
-(void)readPoiDetailInfo
{
    
    if(self.fromPoidetailVC == 1)
    {
        return;
    }
    
    
    PoiDetailViewController *poiDetailVC = [[PoiDetailViewController alloc] init];
    poiDetailVC.poiId = _poiId;
    if(_flag_getDataSuccess == 1)
    {
        poiDetailVC.dataDic = _dataDic;
    }
    [self.navigationController pushViewController:poiDetailVC animated:YES];
    [poiDetailVC release];
    
}




#pragma mark -
#pragma mark --- 点击大头针时的动作
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(NA, 4_0)
{
    if ([view.annotation isKindOfClass:[MyPoitAnnotation class]])
    {
        //NSLog(@"点击大头针 ");
        
        
        NSString *version = [[GetInfo getDeviceInfoSystemVersion] retain];
        if([version floatValue] - 6. < 0)
        {
            if(_calloutAnnotation_autoShow)
            {
                [_myMapView removeAnnotation:_calloutAnnotation_autoShow];
            }
        }
        [version release];
        
        
        
        if (_calloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude &&
            _calloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude)
        {
            //NSLog(@"点击大头针时在这里返回了 ~~~");
            return;
        }
        if (_calloutAnnotation)
        {
            //NSLog(@"删除_calloutAnnotation ");
            [mapView removeAnnotation:_calloutAnnotation];
            [_calloutAnnotation release];
            _calloutAnnotation = nil;
        }
        
        
        isShowPopView = 1;
        tapWeidu = view.annotation.coordinate.latitude;
        tapJingdu = view.annotation.coordinate.longitude;
        
        
        CLLocationCoordinate2D theCenterofmine;
        theCenterofmine.latitude = tapWeidu;
        theCenterofmine.longitude = tapJingdu;
        
        
        
        _calloutAnnotation = [[MyPopAnnotation alloc] initWithLatitude:tapWeidu andLongitude:tapJingdu];
        _calloutAnnotation.title = ((MyPoitAnnotation*)view.annotation).title;
        _calloutAnnotation.subtitle = ((MyPoitAnnotation*)view.annotation).subtitle;
        _calloutAnnotation.cateIdStr = ((MyPoitAnnotation*)view.annotation).cateIdStr;
        _calloutAnnotation.poiId = ((MyPoitAnnotation *)view.annotation).poiId;
        _calloutAnnotation.lat = tapWeidu;
        _calloutAnnotation.lng = tapJingdu;
        
        
        //poiallmapClickicon
        [MobClick event:@"poiallmapClickicon" label:[NSString stringWithFormat:@"%@",_calloutAnnotation.cateIdStr]];
        
        
        
        
        [_myMapView addAnnotation:_calloutAnnotation];
        [mapView setCenterCoordinate:_calloutAnnotation.coordinate animated:YES];
        
	}
    else
    {
        [self doSomething];
    }
}
-(void)doSomething
{
    //NSLog(@" doSomething  here ~~~ ");
    
    [self performSelector:@selector(removePopView:) withObject:_myMapView afterDelay:0.0];
}



#pragma mark -
#pragma mark --- 点击地图上其他得位置时去除popView
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSString *deviceSystemVersion = [[UIDevice currentDevice] systemVersion];
    
    if([deviceSystemVersion floatValue] - 6.0 >= 0)
    {
        if (_calloutAnnotation && (view.annotation != _calloutAnnotation))
        {
            isShowPopView = 0;
            
            [_myMapView removeAnnotation:_calloutAnnotation];
            [_calloutAnnotation release];
            _calloutAnnotation = nil;
        }
    }
}


#pragma mark -
#pragma mark --- removePopView
-(void)removePopView:(MKMapView *)mapView
{
    if(_calloutAnnotation)
    {
        [mapView removeAnnotation:_calloutAnnotation];
        [_calloutAnnotation release];
        _calloutAnnotation = nil;
        isShowPopView = 0;
    }
}


#pragma mark -
#pragma mark --- showMyLocation 定位
-(void)showMyLocation
{
    if(_isShowCurrentLocation == 1)
    {
        [self recenterMap];
    }
    else
    {
        //[self performSelector:@selector(checkActivityViewState) withObject:nil afterDelay:showMyLocationTime];
        
        
        [MobClick event:@"poimapClickPosition"];
        
        
        
        if([CheckNetStatus checkMyNetStatus] <= 0)
        {
            [self.view hideToast];
            [self.view makeToast:@"您当前网络状况不好，暂时获取不到当前位置请检查后重试。" duration:1.5 position:@"center" isShadow:NO];
        }
        else
        {
            [self performSelector:@selector(updateButtonImage:) withObject:0 afterDelay:0];
            
            //_isShowCurrentLocation = 1;
            //[_myMapView setShowsUserLocation:YES];
            
            
            [self setupLocationManager];
        }
    }
}
-(void)checkActivityViewState
{
    if(_activityView && [_activityView isAnimating] && _isShowCurrentLocation == 0)
    {
        [_activityView stopAnimating];
        [self updateButtonImage:1];
        
        [self.view hideToast];
        [self.view makeToast:@"定位失败，请稍后重试。" duration:1. position:@"center" isShadow:NO];
        
        
        if(_locationManager)
        {
            [_locationManager stopUpdatingHeading];
            [_locationManager stopUpdatingLocation];
        }
    }
}
-(void)updateButtonImage:(BOOL)flag
{
    if(flag == 0)
    {
        UIImage *image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"手动地图icon_bg@2x" ofType:@"png"]];
        [_locateButton setBackgroundImage:image forState:UIControlStateNormal];
        if(!_activityView)
        {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }
        _activityView.backgroundColor = [UIColor clearColor];
        _activityView.center = _locateButton.center;
        [_activityView startAnimating];
        [self.view addSubview:_activityView];
    }
    else
    {
        UIImage *image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"手动地图icon@2x" ofType:@"png"]];
        if(_locateButton)
        {
            [_locateButton setBackgroundImage:image forState:UIControlStateNormal];
        }
        if(_activityView)
        {
            [_activityView stopAnimating];
        }
    }
}



#pragma mark -
#pragma mark --- autoShowPopView
-(void)autoShowPopView
{
    _calloutAnnotation_autoShow = [[MyPopAnnotation alloc] initWithLatitude:[[_poilistInfoDic objectForKey:@"lat"] floatValue] andLongitude:[[_poilistInfoDic objectForKey:@"lng"] floatValue]];
    _calloutAnnotation_autoShow.title = [_poilistInfoDic objectForKey:@"_chineseTitle"];
    _calloutAnnotation_autoShow.subtitle = [_poilistInfoDic objectForKey:@"_englishTitle"];
    _calloutAnnotation_autoShow.cateIdStr = [_poilistInfoDic objectForKey:@"cateid"];
    _calloutAnnotation_autoShow.lat = [[_poilistInfoDic objectForKey:@"lat"] floatValue];
    _calloutAnnotation_autoShow.lng = [[_poilistInfoDic objectForKey:@"lng"] floatValue];
    _calloutAnnotation_autoShow.poiId = [[_poilistInfoDic objectForKey:@"poiId"] intValue];
    
    
    isShowPopView = 1;
    [_myMapView addAnnotation:_calloutAnnotation_autoShow];
    [_myMapView setCenterCoordinate:_calloutAnnotation_autoShow.coordinate animated:YES];
    
    
    NSString *version = [[GetInfo getDeviceInfoSystemVersion] retain];
    if([version floatValue] - 6. >= 0)
    {
        if(_tap)
        {
            [_myMapView removeAnnotation:_calloutAnnotation_autoShow];
            [_tap removeTarget:self action:@selector(tap:)];
        }
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_myMapView addGestureRecognizer:_tap];
    }
    
    [version release];
}
- (void)tap:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        isShowPopView = 0;
        [_myMapView removeAnnotation:_calloutAnnotation_autoShow];
        [_tap removeTarget:self action:@selector(tap:)];
    }
}



#pragma mark -
#pragma mark --- 这个方法在Map移动后执行(拖拽/放大/缩小/双击).
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    if(_locationManager && falseFlag == 1)
    {
        [_locationManager startUpdatingHeading];
        [_locationManager startUpdatingLocation];
    }
}


#pragma mark -
#pragma mark --- 动态显示手机的方向
- (void)customInitialize
{
    currentHeading = 0.0;
}
-(void)adjustImageViewDirection
{
    [self startLocationHeadingEvents];
    [self updateHeadingDisplays];
}
- (void)startLocationHeadingEvents
{
    if (_locationManager == nil)
    {
        //CLLocationManager *theManager = [[[CLLocationManager alloc] init] autorelease];
        
        // Retain the object in a property.
        //self.locationManager = theManager;
        //self.locationManager.delegate = self;
        
        _locationManager =  [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable])
    {
        _locationManager.headingFilter = kCLHeadingFilterNone;
        [_locationManager startUpdatingHeading];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    self.currentHeading = theHeading;
    
    [self updateHeadingDisplays];
}

- (void)updateHeadingDisplays
{
    // Animate Compass
    [UIView     animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGAffineTransform headingRotation;
                             headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, toRad(currentHeading));
                             _myPositionView.transform = headingRotation;
                         }
                         completion:^(BOOL finished) {
                             CGAffineTransform headingRotation;
                             headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, toRad(currentHeading));
                             headingRotation_copy = headingRotation;
                         }];
}



#pragma mark -
#pragma mark --- 给PopView添加动画
-(void)addAnimationForPopView:(MyCallOutAnnotationView *)callOutView
{
    [UIView animateWithDuration:0.1 animations:^{
        callOutView.alpha = 1;
    } completion:^(BOOL finished){
        
    }];
    
    
//    CGFloat scale = 0.001;
//    callOutView.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale forView:callOutView], [self yTransformForScale:scale forView:callOutView]);
//    
//    [UIView animateWithDuration:0.03 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        CGFloat scale1 = 1.2f;
//        callOutView.transform = CGAffineTransformMake(scale1, 0.0f, 0.0f, scale1, [self xTransformForScale:scale1 forView:callOutView], [self yTransformForScale:scale1 forView:callOutView]);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.03 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            CGFloat scale2 = 0.90;
//            callOutView.transform = CGAffineTransformMake(scale2, 0.0f, 0.0f, scale2, [self xTransformForScale:scale2 forView:callOutView], [self yTransformForScale:scale2 forView:callOutView]);
//        } completion:^(BOOL finished1) {
//            [UIView animateWithDuration:0.03 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                CGFloat scale3 = 1;
//                callOutView.transform = CGAffineTransformMake(scale3, 0.0f, 0.0f, scale3, [self xTransformForScale:scale3 forView:callOutView], [self yTransformForScale:scale3 forView:callOutView]);
//            } completion:nil];
//        }];
//    }];
}
- (CGFloat)relativeParentXPosition:(MyCallOutAnnotationView *)callOutView
{
    return callOutView.frame.size.width/2.;
}
- (CGFloat)xTransformForScale:(CGFloat)scale forView:(MyCallOutAnnotationView *)callOutView
{
    CGFloat xDistanceFromCenterToParent = callOutView.frame.size.width/2. - [self relativeParentXPosition:callOutView];
    CGFloat transformX = (xDistanceFromCenterToParent * scale) - xDistanceFromCenterToParent;
    return transformX;
}
- (CGFloat)yTransformForScale:(CGFloat)scale forView:(MyCallOutAnnotationView *)callOutView
{
    CGFloat yDistanceFromCenterToParent = callOutView.frame.size.height / 2.0f;
    CGFloat transformY = yDistanceFromCenterToParent - yDistanceFromCenterToParent * scale;
    return transformY;
}


#pragma mark -
#pragma mark --- setupLocationManager  *** 定位 ***
-(void)setupLocationManager
{
    _didUpdateToLocation = 0;
    
    if(_locationManager == nil)
    {
        _locationManager =  [[CLLocationManager alloc] init];
    }
    
    
    if ([CLLocationManager authorizationStatus] == 0 || [CLLocationManager authorizationStatus] == 1 || [CLLocationManager authorizationStatus] == 3) //授权状态:1-允许;2-拒绝;3-拒绝后又从设置里打开.
    {
        _isShowCurrentLocation = 1;
        
        //MYLog(@"Starting CLLocationManager");
        _locationManager.delegate = self;
        //_locationManager.distanceFilter = 10; //距离筛选器,当位置移动大于10米时才去调用‘didUpdateToLocation’更新位置坐标
        _locationManager.distanceFilter = kCLDistanceFilterNone; //不设置距离过滤，即随时更新地理位置
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest; //精确度级别(使用当前可用精确度最高的方法)
        [_locationManager startUpdatingLocation]; //启动位置管理器
        
    }
    else if([CLLocationManager authorizationStatus] == 2)
    {
        [self.view hideToast];
        [self.view makeToast:@"需要您在系统设置界面\n授权打开定位服务" duration:1.5 position:@"center" isShadow:NO];
        
        
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    MYLog(@" --------- didUpdateToLocation ");
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
    {
        falseFlag = 0;
        
        if(_myMapView)
        {
            
            CLLocationCoordinate2D theCenterofmine;
            theCenterofmine = newLocation.coordinate;
            if(!_minePoint)
            {
                _minePoint = [[MyLocationAnnotation alloc] initWithCoords:theCenterofmine];
            }
            else
            {
                [_myMapView removeAnnotation:_minePoint];
                [_pinArray removeObject:_minePoint];
            }
            _minePoint.coordinate = theCenterofmine;
            [_myMapView addAnnotation:_minePoint];
            [_pinArray addObject:_minePoint];
            
            
            if(_isRecenter == 0)
            {
                _isRecenter = 1;
                [self recenterMap];
                //MYLog(@" --- recenterMap --- ");
            }
        }
    }
    else
    {
        MYLog(@" App -- is  backgrounded.");
    }
    
}


//***定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //MYLog(@"error ====== %@",[error localizedDescription]);
    
    falseFlag = 1;
    
    
    if(_minePoint)
    {
        //[_myMapView removeAnnotation:_minePoint];
        //[_pinArray removeObject:_minePoint];
        
        if(_myPositionView)
        {
            _myPositionView.transform = headingRotation_copy;
        }
    }
//    [_locationManager stopUpdatingLocation];
    
    
    
    
    [self updateButtonImage:1];
    _isShowCurrentLocation = 0;
    
}
-(void)stop
{
    [_activityView stopAnimating];
    [_activityView removeFromSuperview];
    [self updateButtonImage:1];
}

#pragma mark -
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
{
    _showPopViewFlag = 0;
    _isShowPoiFlag   = 0;
    _showPopViewFlag = 0;
    _isShowCurrentLocation = 0;
    _isFromReadVCAndOnlyOnePoint = 0;
    _isRecenter = 0;
    _didUpdateToLocation = 0;
    _isrejectiveUseLocation = 0;
    falseFlag = 0;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [_pinArray removeAllObjects];
    
    
    if(_locationManager)
    {
        _locationManager.delegate = nil;
        [_locationManager stopUpdatingLocation];
        [_locationManager stopUpdatingHeading];
    }
}



#pragma mark -
#pragma mark --- getPoiDetailInfoDataFromServer  以供大头针的popview使用
-(void)getPoiDetailInfoDataFromServerWithPoiId:(NSInteger)poiId inView:(MyCallOutAnnotationView *)callOutView
{
    _flag_getDataSuccess = 0;
    GetPoiDetailInfo *_getPoiDetailInfo_fromServer = [[GetPoiDetailInfo alloc] init];
    
    [_getPoiDetailInfo_fromServer getPoiDetailInfoByClientid:ClientId_QY andClientSecrect:ClientSecret_QY poiId:poiId finished:^(NSDictionary *dic){
        MYLog(@"获取PoiDetailInfo数据成功 ~~~ ");
        
        _flag_getDataSuccess = 1;
        if(_dataDic && _dataDic.retainCount > 0)
        {
            [_dataDic removeAllObjects];
            [_dataDic release];
            _dataDic = nil;
        }
        _dataDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
        
        MYLog(@" resetPopView  resetPopView  ");
        [self resetPopView:callOutView];
    } failed:^{
        MYLog(@"获取PoiDetailInfo数据失败 !!! ");
    }];
    
    [_getPoiDetailInfo_fromServer release];
}
-(void)resetPopView:(MyCallOutAnnotationView *)callOutView
{
    NSRange range = [[_dataDic objectForKey:@"photo"] rangeOfString:@"670"];
    NSString *picurl = nil;
    if(range.location < [[_dataDic objectForKey:@"photo"] length])
    {
        picurl = [[_dataDic objectForKey:@"photo"] substringToIndex:range.location];
        picurl = [NSString stringWithFormat:@"%@120",picurl];
    }
    
    if(callOutView)
    {
        //NSLog(@" callOutView : %@",callOutView);
        
        //callOutView.imageView_poi.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"108*108@2x" ofType:@"png"]];
        callOutView.imageView_poi.image = [UIImage imageNamed:@"108*108@2x.png"];
        if(picurl)
        {
            [callOutView.imageView_poi setImageWithURL:[NSURL URLWithString:picurl] placeholderImage:[UIImage imageNamed:@"108*108@2x.png"]];
        }
        [callOutView initStartViewWithGrade:[[_dataDic objectForKey:@"grade"] intValue]];
    }
}


-(void)setFromReadVC
{
    self.isFromReadVCAndOnlyOnePoint = 1;
}

@end


