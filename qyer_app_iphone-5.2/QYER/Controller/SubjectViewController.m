//
//  SubjectViewController.m
//  LastMinute
//
//  Created by lide on 13-10-17.
//
//

#import "SubjectViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "MobClick.h"

@interface SubjectViewController ()

@end

@implementation SubjectViewController

@synthesize operation = _operation;
@synthesize lastMinuteArray = _lastMinuteArray;

-(void)dealloc
{
    QY_SAFE_RELEASE(_operationIds);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _lastMinuteArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
   
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(231, 242, 248);
    
    _titleLabel.text = @"专题";
    
    _gridView = [[SMGridView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, self.view.frame.size.height - _headView.frame.size.height)];
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.gridDelegate = self;
    _gridView.dataSource = self;
    _gridView.vertical = YES;
    _gridView.padding = 10.0f;
    [self.view addSubview:_gridView];
    
    CGSize size = CGSizeZero;
    
    if(ios7)
    {
        size = [[_operation operationContent] boundingRectWithSize:CGSizeMake(300, 400) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}  context:nil].size;
    }
    else
    {
        size = [[_operation operationContent] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 400) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    _gridHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 180 + size.height + 20)];
    _gridHeaderView.backgroundColor = [UIColor clearColor];
    
    _backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 180, 320,size.height + 20)];
    _backView.backgroundColor = [UIColor clearColor];
    _backView.image = [[UIImage imageNamed:@"wordBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [_gridHeaderView addSubview:_backView];
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
    _backgroundImageView.backgroundColor = [UIColor clearColor];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    [_backgroundImageView setImageWithURL:[NSURL URLWithString:[_operation operationBigPic]] placeholderImage:[UIImage imageNamed:@"default_co_back"]];
    [_gridHeaderView addSubview:_backgroundImageView];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _backgroundImageView.frame.origin.y + _backgroundImageView.frame.size.height + 10, 300, size.height)];
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textColor = [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0];
    _contentLabel.font = [UIFont fontWithName:Default_Font size:14.0];
    _contentLabel.text = _operation.operationContent;
    [_gridHeaderView addSubview:_contentLabel];
    
    if (!IS_IOS7) {
        
        CGRect rect = _contentLabel.frame;
        rect.size.height += 10;
        _contentLabel.frame = rect;
    }
    //    [_gridView reloadData];
    
    
    //判断_operationIds是否存在，是为了兼容老代码
    if (_operationIds&&[_operationIds count]>0) {
        //请求折扣列表数据
        [self requestForLastMinuteList];
        
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SMGridViewDataSource

- (BOOL)smGridViewShowLoader:(SMGridView *)gridView
{
    return NO;
}

- (int)numberOfSectionsInSMGridView:(SMGridView *)gridView
{
    return 1;
}

- (int)smGridView:(SMGridView *)gridView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (int)smGridView:(SMGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return [_lastMinuteArray count];
}

- (UIView *)smGridView:(SMGridView *)gridView viewForIndexPath:(NSIndexPath *)indexPath
{
    LastMinuteView *view = (LastMinuteView *)[gridView dequeReusableViewOfClass:[LastMinuteView class]];
    if (!view) {
        view = [[[LastMinuteView alloc] initWithFrame:CGRectMake(0, 0, 145, 170)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        view.delegate = self;
    }
    
    [view setLastMinute:[_lastMinuteArray objectAtIndex:indexPath.row]];
    
    return view;
}

- (CGSize)smGridView:(SMGridView *)gridView sizeForIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(145, 170);
}

- (UIView *)smGridView:(SMGridView *)gridView viewForHeaderInSection:(NSInteger)section {
    
    return _gridHeaderView;
}

- (CGSize)smGridView:(SMGridView *)gridView sizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    
    if(ios7)
    {
        size = [[_operation operationContent] boundingRectWithSize:CGSizeMake(300, 400) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}  context:nil].size;
    }
    else
    {
        size = [[_operation operationContent] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 400) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return CGSizeMake(320, 180 + size.height + 20);
}

#pragma mark - LastMinuteViewDelegate

- (void)lastMinuteViewDidTap:(LastMinute *)lastMinute
{
    
    NSDictionary * dictttt = (NSDictionary *)lastMinute;
    int dealID = [[dictttt objectForKey:@"id"] integerValue];
    
    //*********** Insert By ZhangDong 2014.4.8 Start ***********
//    LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//    lastDetailVC.dealID = dealID;
//    [self.navigationController pushViewController:lastDetailVC animated:YES];
//    [lastDetailVC release];
    
    //by jessica
    LastMinuteDetailViewControllerNew * lastDetailVC = [[LastMinuteDetailViewControllerNew alloc]init];
    lastDetailVC.lastMinuteId = dealID;
    lastDetailVC.source = NSStringFromClass([self class]);
    [self.navigationController pushViewController:lastDetailVC animated:YES];
    [lastDetailVC release];
    
    /*
//    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
//    CGContextRef contentRef = UIGraphicsGetCurrentContext();
//    [self.view.layer renderInContext:contentRef];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    LastMinuteDetailViewController *lastMinuteDetailVC = [[[LastMinuteDetailViewController alloc] init] autorelease];
    lastMinuteDetailVC.dealID = [lastMinute.str_id intValue];
//    [lastMinuteDetailVC setLastMinute:lastMinute];
//    [lastMinuteDetailVC setLastMinuteTitle:lastMinute.lastMinuteTitle];
//    [lastMinuteDetailVC setPopImage:image];
    
    [self.navigationController pushViewController:lastMinuteDetailVC animated:YES];
    
    */
    
}

//请求折扣详情数据
- (void)requestForLastMinuteList
{
    [self.view makeToastActivity];
    
    [LastMinuteDeal getLastMinuteWithIds:_operationIds success:^(NSArray *data) {
        
        [self.view hideToastActivity];
        [_lastMinuteArray addObjectsFromArray:data];
        NSLog(@" _lastMinuteArray is %@",_lastMinuteArray);
//        self.lastMinuteArray = [NSMutableArray arrayWithArray:data];
        [self reloadData];
        
    } failure:^{
        
        [self.view hideToastActivity];
        [self reloadData];
    }];
    
    /*
    [LastMinute getLastMinuteWithIds:_operationIds
                             success:^(NSArray *data) {
                                 
                                 [self.view hideToastActivity];
                                 
                                 self.lastMinuteArray = [NSMutableArray arrayWithArray:data];
                                 [self reloadData];
                                 
                                 
                             } failure:^(NSError *error) {
                                 
                                 [self.view hideToastActivity];
                                 [self reloadData];
                                 
                             }];
*/

}

//刷新数据
-(void)reloadData
{
    [_gridView reloadData];

}

@end
