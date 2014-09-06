//
//  StartDateViewController.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-17.
//
//

#import "StartDateViewController.h"
#import "StartDateCell.h"
#import "QYSectionCategory.h"
#import "QYCommonToast.h"

@interface StartDateViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
StartDateCellDelegate
>

@property (nonatomic, retain) UITableView *mainTableView;
@property (nonatomic, retain) NSMutableArray *sectionCategoryArray;

@end

@implementation StartDateViewController

-(void)dealloc
{
    QY_VIEW_RELEASE(_mainTableView);
    QY_SAFE_RELEASE(_sectionCategoryArray);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(void)loadView
//{
//    [super loadView];
//    
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    
    _titleLabel.text = @"选择出发日期";
    
    //mainTableView
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-_headView.frame.size.height)];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainTableView];
    
    //header space
    UIView *spaceHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainTableView.frame.size.width, 10)];
    spaceHeaderView.backgroundColor = [UIColor clearColor];
    _mainTableView.tableHeaderView = spaceHeaderView;
    [spaceHeaderView release];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //请求折扣品类信息
    [self requestForSectionCategorys];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//请求折扣品类信息
- (void)requestForSectionCategorys
{
    [self.view makeToastActivity];
    [QYSectionCategory getSectionCategorysWithId:_produectId
                                         success:^(NSArray *data) {
                                             [self.view hideToastActivity];
                                             
                                             if([data isKindOfClass:[NSArray class]] && [data count] > 0)
                                             {
                                                 
                                                 self.sectionCategoryArray = [NSMutableArray arrayWithArray:data];
                                                 //刷新数据
                                                 [self reloadData];

                                                 
                                             }
                                             
                                         } failure:^(NSError *error) {
                                             [self.view hideToastActivity];
                                             
                                             [self.view hideToast];
                                             [self.view makeToast:[error localizedDescription] duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//Toast_Post_Order_Fail
                                             
                                         }];
}

//刷新数据
- (void)reloadData
{
    [_mainTableView reloadData];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sectionCategoryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *StartDateCellIdentifier = [NSString stringWithFormat:@"StartDateCellIdentifier%d",indexPath.row];
    StartDateCell *cell = [tableView dequeueReusableCellWithIdentifier:StartDateCellIdentifier];
    if (cell == nil) {
        cell = [[[StartDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StartDateCellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.sectionCategory = [_sectionCategoryArray objectAtIndex:indexPath.row];
    }
    cell.delegate = self;
    
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QYSectionCategory *sectionCategory = [_sectionCategoryArray objectAtIndex:indexPath.row];
    
    //计算本月有多少天
    NSInteger days = [QYSectionCategory daysFromMonth:[sectionCategory.cateMonth intValue] year:[sectionCategory.cateYear intValue]];
    
    //计算1号是星期几
    NSInteger dayOfWeek = [QYSectionCategory dayOfWeekFromMonth:[sectionCategory.cateMonth intValue] year:[sectionCategory.cateYear intValue]];
    //计算有多少行
    NSInteger dateRow = [QYSectionCategory dateRowsFromDays:days dayOfWeek:dayOfWeek];
    
    return dateRow*k_date_height+k_date_header_height+ 20;
}

#pragma mark - StartDateCellDelegate
- (void)StartDateCellCategoryButtonClickAction:(id)sender cell:(StartDateCell*)aCell dateCategory:(QYDateCategory*)aDateCategory
{
    
    if ([_delegate respondsToSelector:@selector(StartDateViewControllerCategoryButtonClickAction:viewController:dateCategory:)]) {
        [_delegate StartDateViewControllerCategoryButtonClickAction:sender viewController:self dateCategory:aDateCategory];
    }
    
    [self clickBackButton:nil];

}

@end
