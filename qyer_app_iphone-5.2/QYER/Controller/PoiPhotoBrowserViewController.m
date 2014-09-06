//
//  PoiPhotoBrowserViewController.m
//  QyGuide
//
//  Created by an qing on 13-2-19.
//
//

#import "PoiPhotoBrowserViewController.h"
#import "GetPoiPhotoImages.h"
#import "UIImageView+WebCache.h"
#import "PoiImageCell.h"
#import "MobClick.h"
#import <QuartzCore/QuartzCore.h>
#import "ChangeTableviewContentInset.h"




///////
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
///////

#import "Toast+UIView.h"






#define heightForRow                80

#define chineseTitleLabelX          40
#define chineseTitleLabelY          (ios7 ? 21 : 5)
#define chineseTitleLabelWidth      240
#define chineseTitleLabelHeight     24

#define englishTitleLabelX          40
#define englishTitleLabelY          (ios7 ? 40 : 24)
#define englishTitleLabelWidth      240
#define englishTitleLabelHeight     18

#define poiImageHeight              180
#define poiCommentHeight            50


#define chineseTitleTypeSize        16
#define englishTitleTypeSize        14


#define TESTFLAG    0






@interface PoiPhotoBrowserViewController ()

@end






@implementation PoiPhotoBrowserViewController
@synthesize navigationTitle = _navigationTitle;
@synthesize poiId;
@synthesize max_id = _max_id;
@synthesize typeImage = _typeImage;
@synthesize dic_navation = _dic_navation;


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
    QY_VIEW_RELEASE(_footView);
    QY_SAFE_RELEASE(_navigationTitle);
    QY_SAFE_RELEASE(_chineseTitle);
    QY_SAFE_RELEASE(_englishTitle);
    QY_VIEW_RELEASE(_chineseTitleLabel);
    QY_VIEW_RELEASE(_englishTitleLabel);
    QY_SAFE_RELEASE(_typeImage);
    QY_VIEW_RELEASE(_backButton);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_myTableView);
    
    QY_MUTABLERECEPTACLE_RELEASE(_poiAllPhotoDataArray);
    QY_MUTABLERECEPTACLE_RELEASE(_poiImagesMaxidArray);
    QY_MUTABLERECEPTACLE_RELEASE(_poiPhotoDataArray);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.strType = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(poiImagePosition:) name:@"poiImagePosition" object:nil];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    NSLog(@"  viewDidAppear ---  PoiPhotoBrowserViewController");
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    pageSize = 200;
    page = 1;
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    [self setRootView];
    [self setNavigationBar];
    [self initTableView];
    [self setNavigationgbarInfo:self.dic_navation];
    [self getAllPoiImagesFromServer];
 
    [self.view makeToastActivity];
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
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 44+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, 2, 40, 40);
    if(ios7)
    {
        _backButton.frame = CGRectMake(0, 2+20, 40, 40);
    }
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
}

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
    //_chineseTitleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
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
    //_chineseTitleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
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
    //_chineseTitleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_chineseTitleLabel];
    //[_chineseTitleLabel sizeToFit];
    
    
    
    
    
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
    //_englishTitleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_englishTitleLabel.shadowOffset = CGSizeMake(0, 1);
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


-(void)initTableView
{
    if(ios7)
    {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    }
    else
    {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([[UIScreen mainScreen] bounds].size.height-20))];
    }
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.separatorColor = [UIColor clearColor];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    
    
    [self setTableViewFooterView];
    
    
    [ChangeTableviewContentInset changeWithTableView:_myTableView];
    [self.view addSubview:_myTableView];
    [self.view bringSubviewToFront:_headView];
}
-(void)getPoiImagesFromAllImagesArray
{
    downloadNewDataFlag = 0;
    
    //_myTableView.tableFooterView = nil;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
    view.backgroundColor = [UIColor clearColor];
    _myTableView.tableFooterView = view;
    [view release];
    
    
    if(!_poiPhotoDataArray)
    {
        _poiPhotoDataArray = [[NSMutableArray alloc] init];
    }
    
    
    NSInteger number = 0;
    NSInteger position = count;
    for(int i = position; i < position+getImageNumberOneTime ; i++)
    {
        if(i < [_poiAllPhotoDataArray count])
        {
            [_poiPhotoDataArray addObject:[_poiAllPhotoDataArray objectAtIndex:i]];
            number++;
            count++;
        }
        else
        {
            break;
        }
    }
    
    //判断是否已经下载完所有的数据
    if(number < getImageNumberOneTime)
    {
        isDownloadAllData = 1;
    }
    else
    {
        isDownloadAllData = 0;
    }
    
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    [_myTableView reloadData];
    
}

//    -(void)getPoiImagesFromServer
//    {
//    GetPoiPhotoImages *getPoiImages = [[GetPoiPhotoImages alloc] init];
//
//    [getPoiImages getPoiPhotoImagesByClientid:kClientId andClientSecrect:kClientSecret andPoiId:self.poiId andMax_id:self.max_id finished:^{
//        
//        MYLog(@"getPoiImagesFromServer 成功!!!");
//        
//        downloadNewDataFlag = 0;
//        
//        if(!_poiPhotoDataArray)
//        {
//            _poiPhotoDataArray = [[NSMutableArray alloc] init];
//        }
//        [_poiPhotoDataArray addObjectsFromArray:getPoiImages.dataArray];
//        GetPoiPhotoImages *getPoiImagesdata = (GetPoiPhotoImages *)[getPoiImages.dataArray lastObject];
//        self.max_id = [getPoiImagesdata.imageIdStr intValue]-1;
//        
//        
//        
//        _myTableView.tableFooterView = nil;
//        
//        //判断是否已经下载完所有的数据
//        if([getPoiImages.dataArray count] < getImageNumberOneTime)
//        {
//            isDownloadAllData = 1;
//        }
//        else
//        {
//            isDownloadAllData = 0;
//        }
//        
//        _myTableView.delegate = self;
//        _myTableView.dataSource = self;
//        [_myTableView reloadData];
//        
//    } failed:^{
//        downloadNewDataFlag = 0;
//        
//        isDownloadAllData = 1;
//        _myTableView.tableFooterView = nil;
//        
//        if(_activityView && [_activityView isAnimating])
//        {
//            [_activityView stopAnimating];
//        }
//        if(_footView && [_footView viewWithTag:1])
//        {
//            [(UILabel*)[_footView viewWithTag:1] setText:@"加载更多"];
//            CGRect frame = [_footView viewWithTag:1].frame;
//            frame.origin.x = 110;
//            [_footView viewWithTag:1].frame = frame;
//        }
//        
//    }];
//    [getPoiImages release];
//}


#pragma mark -
#pragma mark --- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_poiPhotoDataArray || [_poiPhotoDataArray count] == 0)
    {
        return 0;
    }
    else if([_poiPhotoDataArray count] <= poiImageNumberOfOneLine)
    {
        return 1;
    }
    else if([_poiPhotoDataArray count]%poiImageNumberOfOneLine == 0)
    {
        return [_poiPhotoDataArray count]/poiImageNumberOfOneLine;
    }
    else
    {
        return [_poiPhotoDataArray count]/poiImageNumberOfOneLine+1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return heightForRow;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poiimageViewCellIdentifier"];
    if(cell == nil)
    {
        cell = [[[PoiImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"poiimageViewCellIdentifier"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    [self initPoiImages:cell andIndexPath:indexPath];
    
    return cell;
}
-(void)initPoiImages:(PoiImageCell*)cell andIndexPath:(NSIndexPath *)indexPath
{
    cell.imageView1.image = nil;
    cell.imageView2.image = nil;
    cell.imageView3.image = nil;
    cell.imageView4.image = nil;
    cell.control1.position = @"-1";
    cell.control2.position = @"-1";
    cell.control3.position = @"-1";
    cell.control4.position = @"-1";
    cell.control1.hasBackGroundColorflag = 0;
    cell.control2.hasBackGroundColorflag = 0;
    cell.control3.hasBackGroundColorflag = 0;
    cell.control4.hasBackGroundColorflag = 0;
    cell.imageView1.alpha = 0;
    cell.imageView2.alpha = 0;
    cell.imageView3.alpha = 0;
    cell.imageView4.alpha = 0;
    
    
    if(indexPath.row*poiImageNumberOfOneLine >= [_poiPhotoDataArray count])
    {
        [cell.imageView1.layer setBorderWidth:0.];
        [cell.imageView1.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control1.hasBackGroundColorflag = 1;
        [cell.imageView2.layer setBorderWidth:0.];
        [cell.imageView2.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control2.hasBackGroundColorflag = 1;
        [cell.imageView3.layer setBorderWidth:0.];
        [cell.imageView3.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control3.hasBackGroundColorflag = 1;
        [cell.imageView4.layer setBorderWidth:0.];
        [cell.imageView4.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control4.hasBackGroundColorflag = 1;
        return;
    }
    NSString *picurl1 = [NSString stringWithFormat:@"%@",[[_poiPhotoDataArray objectAtIndex:0+indexPath.row*poiImageNumberOfOneLine] picUrl_small]];
//    NSString *str =[NSString stringWithFormat:@"%@@2x",@"默认图片小"];
//    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    UIImage *image = [UIImage imageNamed:@"poi_list_pic"];
    [cell.imageView1 setImageWithURL:[NSURL URLWithString:picurl1] placeholderImage:image success:^(UIImage *image){} failure:^(NSError *error){}];
    cell.control1.position = [NSString stringWithFormat:@"%d",indexPath.row*poiImageNumberOfOneLine];
    //cell.ll.text = [NSString stringWithFormat:@"%d = 第%d行",indexPath.row*poiImageNumberOfOneLine+1,indexPath.row*poiImageNumberOfOneLine/4];
    cell.imageView1.alpha = 1;
    
    
    
    if(1+indexPath.row*poiImageNumberOfOneLine >= [_poiPhotoDataArray count])
    {
        [cell.imageView2.layer setBorderWidth:0.];
        [cell.imageView2.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control2.hasBackGroundColorflag = 1;
        [cell.imageView3.layer setBorderWidth:0.];
        [cell.imageView3.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control3.hasBackGroundColorflag = 1;
        [cell.imageView4.layer setBorderWidth:0.];
        [cell.imageView4.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control4.hasBackGroundColorflag = 1;
        return;
    }
    NSString *picurl2 = [NSString stringWithFormat:@"%@",[[_poiPhotoDataArray objectAtIndex:1+indexPath.row*poiImageNumberOfOneLine] picUrl_small]];
    [cell.imageView2 setImageWithURL:[NSURL URLWithString:picurl2] placeholderImage:image success:^(UIImage *image){} failure:^(NSError *error){}];
    cell.control2.position = [NSString stringWithFormat:@"%d",1+indexPath.row*poiImageNumberOfOneLine];
    cell.imageView2.alpha = 1;
    
    
    
    if(2+indexPath.row*poiImageNumberOfOneLine >= [_poiPhotoDataArray count])
    {
        [cell.imageView3.layer setBorderWidth:0.];
        [cell.imageView3.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control3.hasBackGroundColorflag = 1;
        [cell.imageView4.layer setBorderWidth:0.];
        [cell.imageView4.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control4.hasBackGroundColorflag = 1;
        return;
    }
    NSString *picurl3 = [NSString stringWithFormat:@"%@",[[_poiPhotoDataArray objectAtIndex:2+indexPath.row*poiImageNumberOfOneLine] picUrl_small]];
    [cell.imageView3 setImageWithURL:[NSURL URLWithString:picurl3] placeholderImage:image success:^(UIImage *image){} failure:^(NSError *error){}];
    cell.control3.position = [NSString stringWithFormat:@"%d",2+indexPath.row*poiImageNumberOfOneLine];
    cell.imageView3.alpha = 1;
    
    
    if(3+indexPath.row*poiImageNumberOfOneLine >= [_poiPhotoDataArray count])
    {
        [cell.imageView4.layer setBorderWidth:0.];
        [cell.imageView4.layer setBorderColor:[UIColor clearColor].CGColor];
        cell.control4.hasBackGroundColorflag = 1;
        return;
    }
    NSString *picurl4 = [NSString stringWithFormat:@"%@",[[_poiPhotoDataArray objectAtIndex:3+indexPath.row*poiImageNumberOfOneLine] picUrl_small]];
    [cell.imageView4 setImageWithURL:[NSURL URLWithString:picurl4] placeholderImage:image success:^(UIImage *image){} failure:^(NSError *error){}];
    cell.control4.position = [NSString stringWithFormat:@"%d",3+indexPath.row*poiImageNumberOfOneLine];
    cell.imageView4.alpha = 1;
}


#pragma mark -
#pragma mark --- UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark -
#pragma mark --- PoiImageCellDelegate
-(void)PoiImageCellDidSelected:(MyPoiImageViewControl *)control
{
    MYLog(@"查看POI图片 ^^^ ");
    
    
    if([control.position intValue] >= _poiAllPhotoDataArray.count)
    {
        return;
    }
    
    if(_flag_unavailable)
    {
        return;
    }
    _flag_unavailable = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.3];
    
    
    [self setDataSource_anqing:allImages_];
    KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc]
                                                  initWithDataSource:allDataSource_
                                                  andStartWithPhotoAtIndex:[control.position intValue]];
    [[self navigationController] pushViewController:newController animated:YES];
    [newController setImageArray:_poiAllPhotoDataArray];
    [newController release];
}
-(void)changeFlag
{
    _flag_unavailable = NO;
}




#pragma mark -
#pragma mark --- setDataSource_anqing  ******************************
-(void)getAllPoiImagesFromServer
{
    if(!_getAllPoiImages)
    {
        _getAllPoiImages = [[GetPoiPhotoImages alloc] init];
    }
    
    
    [_getAllPoiImages getAllPoiPhotoImagesByClientid:ClientId_QY andClientSecrect:ClientSecret_QY  type:self.strType andPoiId:self.poiId pageSize:pageSize page:page finished:^{
        
        MYLog(@"getAllPoiImagesFromServer 成功!!! max_id = %d",self.max_id);
        
        if(!_poiAllPhotoDataArray)
        {
            _poiAllPhotoDataArray = [[NSMutableArray alloc] init];
        }
        [_poiAllPhotoDataArray addObjectsFromArray:_getAllPoiImages.allDataArray];
        
        
        if([_getAllPoiImages.allDataArray count] == 200)
        {
            page++;
            if (page<5) {
                
                [self getAllPoiImagesFromServer];

            }else{
                
                [self performSelector:@selector(initAllImageView) withObject:nil afterDelay:0];
                [self performSelector:@selector(getPoiImagesFromAllImagesArray) withObject:nil afterDelay:0];
            }
            //self.max_id = [[[_getAllPoiImages.allDataArray lastObject] imageIdStr] intValue]-1;
            
        }
        else
        {
            [self performSelector:@selector(initAllImageView) withObject:nil afterDelay:0];
            [self performSelector:@selector(getPoiImagesFromAllImagesArray) withObject:nil afterDelay:0];
        }
        
        [self.view hideToastActivity];
    } failed:^{
        [self.view hideToastActivity];

    }];
}
-(void)initAllImageView
{
    allImages_ = [[SDWebImageDataSource alloc] initWithImages:_poiAllPhotoDataArray];
}
- (void)setDataSource_anqing:(id <KTPhotoBrowserDataSource>)newDataSource
{
    allDataSource_ = newDataSource;
}









#pragma mark -
#pragma mark --- UIScrollViewDelegate
-(void)setTableViewFooterView
{
    if(!_footView)
    {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    }
    _footView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(110+16, 5, 100, 27)];
    label.tag = 1;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"加载更多";
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:15.];
    label.textAlignment = NSTextAlignmentCenter;
    if(!_activityView)
    {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    _activityView.backgroundColor = [UIColor clearColor];
    _activityView.center = CGPointMake(label.frame.origin.x, 16.5);
    [_footView addSubview:_activityView];
    [_footView addSubview:label];
    _activityView.alpha = 0;
    [label release];
}











#pragma mark -
#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(isDownloadAllData == 0 && downloadNewDataFlag == 0 && _myTableView.contentOffset.y+_myTableView.frame.size.height - _myTableView.contentSize.height >= 30)
    {
        //NSLog(@"再去网上加载数据 ^ ^ ");
        downloadNewDataFlag = 1;
        
        if(_activityView)
        {
            _activityView.alpha = 1;
            [_activityView startAnimating];
        }
        _myTableView.tableFooterView = _footView;
        
        
        [self performSelector:@selector(appendImagesData) withObject:nil afterDelay:0.1];
    }
}
-(void)appendImagesData
{
    //[self getPoiImagesFromServer];
    [self getPoiImagesFromAllImagesArray];
}



#pragma mark -
#pragma mark --- poiImagePosition -这里要做两件事:(1)是否需要加载新数据;(2)是否要设置offset
- (void)poiImagePosition:(NSNotification*)notification
{
    imagePosition = [notification.object intValue];
    if([_poiAllPhotoDataArray count] <= getImageNumberOneTime)
    {
        return;
    }
    else if(imagePosition*getImageNumberOneTime > [_poiPhotoDataArray count])
    {
        [self getMoreImages];
    }
    
    
    
    NSDictionary *dic = notification.userInfo;
    [self poiImagePosition_changed:[[dic objectForKey:@"poiimagecurrentIndex"] intValue]];
    
}
-(void)getMoreImages
{
    MYLog(@"count -- 0 -- %d",count);
    
    for(int i = count; i < count+(imagePosition-count/20)*getImageNumberOneTime; i++)
    {
        if(i < [_poiAllPhotoDataArray count])
        {
            [_poiPhotoDataArray addObject:[_poiAllPhotoDataArray objectAtIndex:i]];
            count++;
        }
        else
        {
            break;
        }
    }
    MYLog(@"count -- 1 -- %d",count);
    
    if(count%getImageNumberOneTime != 0)
    {
        isDownloadAllData = 1;
    }
    
    
    [_myTableView reloadData];
    
}

#pragma mark -
#pragma mark --- poiImagePosition_changed
-(void)poiImagePosition_changed:(NSInteger)position
{
    NSInteger line = position/poiImageNumberOfOneLine; //第几行
    float offsetY = line * poiImageViewHeight+(320.0-poiImageViewHeight*poiImageNumberOfOneLine)/(poiImageNumberOfOneLine+1);
    MYLog(@"line ------ %d",line);
    MYLog(@"offsetY --- %f",offsetY);
    
    
    if(line == 0 || _myTableView.contentSize.height-_myTableView.frame.size.height <= 0)
    {
        [_myTableView setContentOffset:CGPointMake(0, 0)];
        return;
    }
    else if(offsetY+_myTableView.frame.size.height <= _myTableView.contentSize.height)
    {
        [_myTableView setContentOffset:CGPointMake(0, offsetY)];
    }
    else
    {
        MYLog(@" else  else  else  else ");
        [_myTableView setContentOffset:CGPointMake(0, _myTableView.contentSize.height-_myTableView.frame.size.height)];
    }
}


#pragma mark -
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
{
    downloadNewDataFlag = 0;
    
    
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
    if(_poiPhotoDataArray)
    {
        [_poiPhotoDataArray removeAllObjects];
        [_poiPhotoDataArray release];
        _poiPhotoDataArray = nil;
    }
    if(_myTableView)
    {
        [_myTableView removeFromSuperview];
        [_myTableView release];
        _myTableView = nil;
    }
    
    self.view = nil;
}

@end
