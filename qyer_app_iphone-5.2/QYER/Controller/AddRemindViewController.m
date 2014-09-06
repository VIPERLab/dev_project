//
//  AddRemindViewController.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-9-25.
//
//

#import "AddRemindViewController.h"
#import "AddRemindCell.h"
#import "QYAPIClient.h"
#import "MobClick.h"
#import "Toast+UIView.h"

@interface AddRemindViewController ()

@end

@implementation AddRemindViewController

@synthesize type = _type;
@synthesize time = _time;
@synthesize startPosition = _startPosition;
@synthesize location = _location;

#pragma mark - private

- (void)clickConfirmButton:(id)sender
{
    if(_type == nil && _time == nil && _startPosition == nil && _location == nil)
    {
        
        [self.view hideToastActivity];
        [self.view makeToast:@"您必须设置其中任何一项" duration:1.2f position:@"center" isShadow:NO];
        
        return;
    }
    
    NSUInteger type = 0;
    NSString *times = @"";
    NSString *startPosition = @"";
    NSUInteger country = 0;
    
    if(_type != nil)
    {
        type = [[_type objectForKey:@"id"] intValue];
    }
    if(_time != nil)
    {
        times = [NSString stringWithFormat:@"%@", [_time objectForKey:@"times"]];
    }
    if (_startPosition != nil) {
        startPosition = [NSString stringWithFormat:@"%@", [_startPosition objectForKey:@"city"]];
    }
    if(_location != nil)
    {
        country = [[_location objectForKey:@"country_id"] intValue];
    }
    
    if(type == 0 && [times isEqualToString:@""] && [startPosition isEqualToString:@""] && country == 0)
    {
        
        [self.view hideToastActivity];
        [self.view makeToast:@"您必须设置其中任何一项" duration:1.2f position:@"center" isShadow:NO];
        
        return;
    }
    
    [self.view makeToastActivity];
    [[QYAPIClient sharedAPIClient] addLastMinuteRemindWithType:type
                                                         times:times
                                                 startPosition:startPosition
                                                     countryId:country
                                                       success:^(NSDictionary *dic) {
                                                           
                                                           [self.view hideToastActivity];
                                                           [self.view makeToast:@"提醒设置成功" duration:0 position:@"center" isShadow:NO];
                                                           
                                                           [self dismissViewControllerAnimated:YES completion:^{
                                                               [self.view hideToast];
                                                           }];
                                                           
                                                           
//                                                           MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                                                           hud.mode = MBProgressHUDModeText;
//                                                           hud.labelText = @"提醒设置成功";
//                                                           hud.yOffset -= 35;
//                                                           dispatch_time_t popTime;
//                                                           popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (TOAST_DURATION * NSEC_PER_SEC));
//                                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                                                               [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                                               [self dismissModalViewControllerAnimated:YES];
//                                                           });
                                                           
                                                           
                                                       }
                                                       failure:^{
//                                                           MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                                                           hud.mode = MBProgressHUDModeText;
//                                                           hud.labelText = [error localizedDescription];//@"网络错误";
//                                                           hud.yOffset -= 35;
//                                                           dispatch_time_t popTime;
//                                                           popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (TOAST_DURATION * NSEC_PER_SEC));
//                                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                                                               [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                                           });
                                                           
//                                                           [self.view hideToast];
//                                                           [self.view makeToast:[error localizedDescription] duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//Toast_Post_Order_Fail
                                                       }];
}

#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _typeArray = [[NSMutableArray alloc] initWithCapacity:0];
        _timeArray = [[NSMutableArray alloc] initWithCapacity:0];
        _startPositionArray = [[NSMutableArray alloc] initWithCapacity:0];
        _countryArray = [[NSMutableArray alloc] initWithCapacity:0];
        _hotCountryArray = [[NSMutableArray alloc] initWithCapacity:0];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _titleLabel.text = @"添加提醒";
    _backButton.hidden = YES;
    _closeButton.hidden = NO;
    
    self.view.backgroundColor = [UIColor colorWithRed:232.0/255.0f green:242.0/255.0f blue:249.0/255.0f alpha:1.0];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, self.view.frame.size.height - _headView.frame.size.height) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = tableHeaderView;
    [tableHeaderView release];
    
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    tableFooterView.backgroundColor = [UIColor clearColor];
    
    _confirmButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _confirmButton.frame = CGRectMake(39, 7, 241, 47);
    [_confirmButton setBackgroundImage:[UIImage imageNamed:@"myLastMin_btn_remind_confirm.png"] forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(clickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [tableFooterView addSubview:_confirmButton];

    _tableView.tableFooterView = tableFooterView;
    [tableFooterView release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([_typeArray count] == 0 || [_timeArray count] == 0 ||[_startPositionArray count] == 0 || [_countryArray count] == 0 || [_hotCountryArray count] == 0)
    {
        [self.view makeToastActivity];
        
        [[QYAPIClient sharedAPIClient] getCategoryTotalWithType:0
                                                        times:@""
                                                  continentId:0
                                                    countryId:0
                                                    departure:@""
                                                      success:^(NSDictionary *dic) {
                                                          
                                                          [self.view hideToastActivity];
                                                          
                                                          if(dic != nil)
                                                          {
                                                              
                                                              [_typeArray removeAllObjects];
                                                              [_typeArray addObjectsFromArray:[[dic objectForKey:@"data"] objectForKey:@"type"]];
                                                              [_timeArray removeAllObjects];
                                                              [_timeArray addObjectsFromArray:[[dic objectForKey:@"data"] objectForKey:@"times_drange"]];
                                                              [_startPositionArray removeAllObjects];
                                                              [_startPositionArray addObjectsFromArray:[[dic objectForKey:@"data"] objectForKey:@"departure"]];
                                                              [_countryArray removeAllObjects];
                                                              [_countryArray addObjectsFromArray:[[dic objectForKey:@"data"] objectForKey:@"poi"]];
                                                              
                                                          }
                                                      } failure:^ {
                                                          
                                                          [self.view hideToastActivity];
                                                          
                                                      }];
        
        [[QYAPIClient sharedAPIClient] getHotCountrySuccess:^(NSDictionary *dic) {
            
            [self.view hideToastActivity];
            
            if(dic != nil)
            {
                [_hotCountryArray removeAllObjects];
                [_hotCountryArray addObjectsFromArray:[[dic objectForKey:@"data"] objectForKey:@"country"]];
            }
        } failure:^{
            
            [self.view hideToastActivity];
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddRemindViewControllerIdentifier"];
    if(cell == nil)
    {
        cell = [[[AddRemindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddRemindViewControllerIdentifier"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.row)
    {
        case 0:
        {
            cell.titleLabel.text = @"折扣类型";
            if(_type != nil)
            {
                cell.typeLabel.text = [_type objectForKey:@"catename"];
            }
            else
            {
                cell.typeLabel.text = @"全部";
            }
        }
            break;
        case 1:
        {
            cell.titleLabel.text = @"旅行时间";
            if(_time != nil)
            {
                cell.typeLabel.text = [_time objectForKey:@"description"];
            }
            else
            {
                cell.typeLabel.text = @"全部";
            }
        }
            break;
        case 2:
        {
            cell.titleLabel.text = @"出发地";
            if(_startPosition)
            {
                cell.typeLabel.text = [_startPosition objectForKey:@"city_des"];
            }
            else
            {
                cell.typeLabel.text = @"全部";
            }
        }
            break;
        case 3:
        {
            cell.titleLabel.text = @"目的地";
            if(_location)
            {
                cell.typeLabel.text = [_location objectForKey:@"country_name"];
            }
            else
            {
                cell.typeLabel.text = @"全部";
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            AddRemindCell *cell = (AddRemindCell *)[tableView cellForRowAtIndexPath:indexPath];
            RemindTypeViewController *remindTypeVC = [[[RemindTypeViewController alloc] init] autorelease];
            remindTypeVC.typeArray = _typeArray;
            remindTypeVC.delegate = self;
            remindTypeVC.selectedName = cell.typeLabel.text;
            [self.navigationController pushViewController:remindTypeVC animated:YES];
        }
            break;
        case 1:
        {
            AddRemindCell *cell = (AddRemindCell *)[tableView cellForRowAtIndexPath:indexPath];
            RemindTimeViewController *remindTimeVC = [[[RemindTimeViewController alloc] init] autorelease];
            remindTimeVC.timeArray = _timeArray;
            remindTimeVC.delegate = self;
            remindTimeVC.selectedName = cell.typeLabel.text;
            [self.navigationController pushViewController:remindTimeVC animated:YES];
        }
            break;
        case 2:
        {
            AddRemindCell *cell = (AddRemindCell *)[tableView cellForRowAtIndexPath:indexPath];
            RemindStartPositionViewController *remindTimeVC = [[[RemindStartPositionViewController alloc] init] autorelease];
            remindTimeVC.startPositionArray = _startPositionArray;
            remindTimeVC.delegate = self;
            remindTimeVC.selectedName = cell.typeLabel.text;
            [self.navigationController pushViewController:remindTimeVC animated:YES];
        }
            break;
        case 3:
        {
            RemindLocationViewController *remindLocationVC = [[[RemindLocationViewController alloc] init] autorelease];
            remindLocationVC.countryArray = _countryArray;
            remindLocationVC.hotCountryArray = _hotCountryArray;
            remindLocationVC.delegate = self;
            [self.navigationController pushViewController:remindLocationVC animated:YES];
        }
            break;
        default:
            break;
    }
    
    return nil;
}

#pragma mark - RemindTypeViewControllerDelegate

- (void)remindTypeViewControllerDidSelectType:(NSDictionary *)type
{
    self.type = type;
    [_tableView reloadData];
}

#pragma mark - RemindTimeViewControllerDelegate

- (void)remindTimeViewControllerDidSelectTime:(NSDictionary *)time
{
    self.time = time;
    [_tableView reloadData];
}

#pragma mark - RemindStartPositionViewControllerDelegate

- (void)remindStartPositionViewControllerDidSelectStartPosition:(NSDictionary *)startPosition
{
    self.startPosition = startPosition;
    [_tableView reloadData];
}

#pragma mark - RemindLocationViewControllerDelegate

- (void)remindLocationViewControllerDidSelectHotLocation:(NSDictionary *)hotLocation
{
    self.location = hotLocation;
    [_tableView reloadData];
}

@end
