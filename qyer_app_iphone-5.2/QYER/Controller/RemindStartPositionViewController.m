//
//  RemindTimeViewController.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-9-27.
//
//

#import "RemindStartPositionViewController.h"
#import "RemindTypeCell.h"

@interface RemindStartPositionViewController ()

@end

@implementation RemindStartPositionViewController

@synthesize startPositionArray = _startPositionArray;
@synthesize delegate = _delegate;
@synthesize selectedName = _selectedName;

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _startPositionArray = [[NSMutableArray alloc] initWithCapacity:0];
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
    
    _titleLabel.text = @"选择出发地";
    self.view.backgroundColor = [UIColor colorWithRed:232.0/255.0f green:242.0/255.0f blue:249.0/255.0f alpha:1.0];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, self.view.frame.size.height - _headView.frame.size.height) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIView *tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)] autorelease];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = tableHeaderView;
    
    UIView *tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)] autorelease];
    tableFooterView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = tableFooterView;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_startPositionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RemindTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindTimeViewControllerIdentifier"];
    if(cell == nil)
    {
        cell = [[[RemindTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RemindTimeViewControllerIdentifier"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.titleLabel.text = [[_startPositionArray objectAtIndex:indexPath.row] objectForKey:@"city_des"];
    
    if([cell.titleLabel.text isEqualToString:_selectedName])
    {
        cell.checkImageView.hidden = NO;
    }
    else
    {
        cell.checkImageView.hidden = YES;
    }
    
    if(indexPath.row == [_startPositionArray count] - 1)
    {
        cell.lineImageView.hidden = YES;
        cell.shadowImageView.hidden = NO;
    }
    else
    {
        cell.lineImageView.hidden = NO;
        cell.shadowImageView.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_delegate && [_delegate respondsToSelector:@selector(remindTimeViewControllerDidSelectTime:)])
    {
        [_delegate remindStartPositionViewControllerDidSelectStartPosition:[_startPositionArray objectAtIndex:indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    return nil;
}

@end
