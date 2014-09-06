//
//  RemindLocationViewController.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-9-27.
//
//

#import "RemindLocationViewController.h"
#import "RemindTypeCell.h"
#import "RemindSearchCell.h"

#define kTableViewTag   17718
#define KSearchTableViewTag 87351

#define Height_Search_Default       460.0f

@interface RemindLocationViewController ()

@end

@implementation RemindLocationViewController

@synthesize countryArray = _countryArray;
@synthesize hotCountryArray = _hotCountryArray;
@synthesize delegate = _delegate;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [super dealloc];
}

#pragma mark - private

- (void)clickSearchCancelButton:(id)sender
{
    [_searchBar resignFirstResponder];
    [UIView animateWithDuration:0.18 animations:^{
        _searchBackView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _searchBackView.frame.size.height);
    }];
    
    _searchBar.frame = CGRectMake(0, 0, 320, 46);
    _searchCancelButton.hidden = YES;
}

#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _countryArray = [[NSMutableArray alloc] initWithCapacity:0];
        _hotCountryArray = [[NSMutableArray alloc] initWithCapacity:0];
        _searchArray = [[NSMutableArray alloc] initWithCapacity:0];
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
    
    _titleLabel.text = @"选择目的地";
    self.view.backgroundColor = [UIColor colorWithRed:232.0/255.0f green:242.0/255.0f blue:249.0/255.0f alpha:1.0];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height + 44, 320, self.view.frame.size.height - _headView.frame.size.height - 44) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tag = kTableViewTag;
    [self.view addSubview:_tableView];
    
    UIView *tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)] autorelease];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = tableHeaderView;
    
    _searchBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, 46)];
    _searchBackImageView.backgroundColor = [UIColor clearColor];
    _searchBackImageView.image = [UIImage imageNamed:@"myLastMin_bg_search.png"];
    _searchBackImageView.userInteractionEnabled = YES;
    [self.view addSubview:_searchBackImageView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索国家";
    _searchBar.backgroundImage = [UIImage imageNamed:@"myLastMin_bg_search.png"];
    [_searchBackImageView addSubview:_searchBar];
    
    _searchCancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _searchCancelButton.frame = CGRectMake(270, 8, 45, 30);
    _searchCancelButton.backgroundColor = [UIColor clearColor];
    [_searchCancelButton setTitleColor:[UIColor colorWithRed:50.0 / 255.0 green:50.0 / 255.0 blue:50.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [_searchCancelButton setTitle:@"取消" forState:UIControlStateNormal];
    _searchCancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_searchCancelButton setBackgroundImage:[UIImage imageNamed:@"myLastMin_bg_search_cancel.png"] forState:UIControlStateNormal];
    [_searchCancelButton addTarget:self action:@selector(clickSearchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [_searchBackImageView addSubview:_searchCancelButton];
    _searchCancelButton.hidden = YES;
    
    _searchBackView = [[UIView alloc] initWithFrame:_tableView.frame];
    _searchBackView.backgroundColor = [UIColor colorWithRed:50.0 / 255.0 green:50.0 / 255.0 blue:50.0 / 255.0 alpha:0.3];
    _searchBackView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _searchBackView.frame.size.height);
    [self.view addSubview:_searchBackView];
    
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _searchBackView.frame.size.width, _searchBackView.frame.size.height)];
    _searchTableView.tag = KSearchTableViewTag;
    _searchTableView.backgroundColor = [UIColor whiteColor];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    [_searchBackView addSubview:_searchTableView];
    _searchTableView.hidden = YES;
    
    //UIKeyboardWillShowNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //添加对键盘Frame的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard notification
-(void)keyboardWillShow:(NSNotification *)aNotification
{
    [self setTextViewFrameWithKeyboardNotification:aNotification];
    
    
}


-(void)keyboardWasChange:(NSNotification *)aNotification
{
    [self setTextViewFrameWithKeyboardNotification:aNotification];
    
}

//根据键盘的高度重新设置TextView的高度
- (void)setTextViewFrameWithKeyboardNotification:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float keyboardHeight = kbSize.height;

    CGRect searchFrame = _searchTableView.frame;
    searchFrame.size.height = Height_Search_Default-keyboardHeight;
    
    _searchTableView.frame = searchFrame;
    
    
    
    
//    _bgImageView.frame = CGRectMake(8, _adjustView.frame.size.height+13, 304, self.view.frame.size.height-(_adjustView.frame.size.height+13)-keyboardHeight-10);//145);
//    _textView.frame = _bgImageView.bounds;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == kTableViewTag)
    {
        return [_hotCountryArray count];
    }
    else
    {
        return [_searchArray count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView.tag == kTableViewTag)
    {
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(9, 0, 302, 25)] autorelease];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"myLastMin_bg_cell_remind_gray.png"];
        [view addSubview:imageView];
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(8, 0, 280, 25)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.textColor = [UIColor colorWithRed:50.0 / 255.0 green:50.0 / 255.0 blue:50.0 / 255.0 alpha:1.0];
        label.text = @"热门目的地";
        [imageView addSubview:label];
        
        return view;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView.tag == kTableViewTag)
    {
        return 25.0;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == kTableViewTag)
    {
        RemindTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindLocationViewControllerIdentifier"];
        if(cell == nil)
        {
            cell = [[[RemindTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RemindLocationViewControllerIdentifier"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.titleLabel.text = [[_hotCountryArray objectAtIndex:indexPath.row] objectForKey:@"country_name"];
        
        if(indexPath.row == [_hotCountryArray count] - 1)
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
    else
    {
        RemindSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindLocationViewControllerSearchIdentifier"];
        if(cell == nil)
        {
            cell = [[[RemindSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RemindLocationViewControllerSearchIdentifier"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = [[_searchArray objectAtIndex:indexPath.row] objectForKey:@"country_name"];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == kTableViewTag)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(remindLocationViewControllerDidSelectHotLocation:)])
        {
            [_delegate remindLocationViewControllerDidSelectHotLocation:[_hotCountryArray objectAtIndex:indexPath.row]];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if(_delegate && [_delegate respondsToSelector:@selector(remindLocationViewControllerDidSelectHotLocation:)])
        {
            [_delegate remindLocationViewControllerDidSelectHotLocation:[_searchArray objectAtIndex:indexPath.row]];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return nil;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _searchBar.frame = CGRectMake(0, 0, 270, 46);
    _searchCancelButton.hidden = NO;
    
    [UIView animateWithDuration:0.18 animations:^{
        _searchBackView.transform = CGAffineTransformIdentity;
    }];

    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchArray removeAllObjects];
    
    if(searchText && ![searchText isEqualToString:@""])
    {
        for(NSDictionary *dictionary in _countryArray)
        {
            NSArray *array = [dictionary objectForKey:@"country"];
            if([array isKindOfClass:[NSArray class]] && [array count] > 0)
            {
                for(NSDictionary *countryDictionary in array)
                {
                    NSString *countryName = [countryDictionary objectForKey:@"country_name"];
                    if([countryName rangeOfString:searchText].length > 0)
                    {
                        [_searchArray addObject:countryDictionary];
                    }
                }
            }
        }
    }
    
    //刷新搜索数据
    [self reloadSearchData];
    
}


//刷新搜索数据
- (void)reloadSearchData
{
    if([_searchArray count] > 0)
    {
        _searchTableView.hidden = NO;
    }
    else
    {
        _searchTableView.hidden = YES;
    }
    
    [_searchTableView reloadData];


}

@end
