//
//  CategoryRefreshView.m
//  LastMinute
//
//  Created by lide on 13-7-1.
//
//

#import "CategoryRefreshView.h"
#import "QyYhConst.h"

#define kTableViewTag           10086
#define kCountryTableViewTag    10087

@implementation CategoryRefreshView

@synthesize categoryArray = _categoryArray;
@synthesize selectedName = _selectedName;

@synthesize delegate = _delegate;
@synthesize type = _type;
@synthesize selectIndex = _selectIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _categoryArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backgroundImageView.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
//        _backgroundImageView.image = [[UIImage imageNamed:@"bg_category.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        [self addSubview:_backgroundImageView];
        
        _shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height, 320, 3)];
        _shadowImageView.backgroundColor = [UIColor clearColor];
        _shadowImageView.image = [UIImage imageNamed:@"shadow_category_bottom.png"];
        [self addSubview:_shadowImageView];
        
        _countryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _countryTableView.backgroundColor = [UIColor colorWithRed:229.0 / 255.0 green:229.0 / 255.0 blue:229.0 / 255.0 alpha:1.0];
        _countryTableView.scrollsToTop = NO;
        _countryTableView.delegate = self;
        _countryTableView.dataSource = self;
        _countryTableView.separatorColor = [UIColor clearColor];
        [_countryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _countryTableView.tag = kCountryTableViewTag;
        _countryTableView.hidden = YES;
        [self addSubview:_countryTableView];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.scrollsToTop = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tag = kTableViewTag;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:_tableView];
        
        _activiayIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activiayIndicator.frame = CGRectMake(15, (self.frame.size.height - _activiayIndicator.frame.size.height) / 2, _activiayIndicator.frame.size.width, _activiayIndicator.frame.size.height);
        [self addSubview:_activiayIndicator];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(27 + _activiayIndicator.frame.size.width, 10, 200, 20)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor colorWithRed:150.0 / 255.0 green:150.0 / 255.0 blue:150.0 / 255.0 alpha:1.0];
        _label.font = [UIFont systemFontOfSize:14.0f];
        _label.text = @"正在加载...";
        
        //************ Mod BugNo.176 By ZhangDong 2014.4.3 Start ***********
        _label.hidden = YES;
        //************ Mod BugNo.176 By ZhangDong 2014.4.3 End ***********
        [self addSubview:_label];
    }
    return self;
}

- (void)dealloc
{
    QY_VIEW_RELEASE(_backgroundImageView);
    QY_VIEW_RELEASE(_activiayIndicator);
    QY_VIEW_RELEASE(_label);
    QY_VIEW_RELEASE(_shadowImageView);
    QY_VIEW_RELEASE(_tableView);
    QY_SAFE_RELEASE(_categoryArray);
    QY_VIEW_RELEASE(_countryTableView);
    
    _delegate = nil;
    
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)show
{
    [_activiayIndicator startAnimating];
    
    _activiayIndicator.hidden = NO;
    _label.hidden = NO;
    _countryTableView.hidden = YES;
    
    self.frame = CGRectMake(0, self.frame.origin.y, 320, 40);
    _backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _shadowImageView.frame = CGRectMake(0, self.frame.size.height, 320, 3);
    
    [_categoryArray removeAllObjects];
    [_tableView reloadData];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 40);
    }];
}

- (void)hide
{
    [_categoryArray removeAllObjects];
    [_tableView reloadData];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.frame = CGRectMake(0, self.frame.origin.y, 320, 40);
        _backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _countryTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _countryTableView.hidden = YES;
        _shadowImageView.frame = CGRectMake(0, self.frame.size.height, 320, 3);
        
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _activiayIndicator.hidden = NO;
        //************ Mod BUG No.176 By ZhangDong 2014.4.3 Start ***********
        _label.hidden = YES;
        //************ Mod BUG No.176 By ZhangDong 2014.4.3 End ***********
        [_activiayIndicator stopAnimating];
    }];
}

- (void)setCategoryArray:(NSMutableArray *)categoryArray
{
    [_categoryArray removeAllObjects];
    [_categoryArray addObjectsFromArray:categoryArray];
    
    if(_type == CategoryPOI)
    {
        for(NSUInteger i = 0; i < [categoryArray count]; i++)
        {
            NSDictionary *dictionary = [categoryArray objectAtIndex:i];
            NSArray *array = [dictionary objectForKey:@"country"];
            BOOL found = NO;
            for(NSDictionary *dictionary in array)
            {
                if([_selectedName isEqualToString:[dictionary objectForKey:@"country_name"]])
                {
                    _selectIndex = i;
                    found = YES;
                    break;
                }
            }
            
            if(found)
            {
                break;
            }
        }
    }
    
    if([categoryArray count] != 0)
    {
        _activiayIndicator.hidden = YES;
        _label.hidden = YES;
        _countryTableView.hidden = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            if([categoryArray count] > 8)
            {
                self.frame = CGRectMake(0, self.frame.origin.y, 320, 40 * 8);
            }
            else
            {
                if(_type == CategoryPOI)
                {
                    self.frame = CGRectMake(0, self.frame.origin.y, 320, 40 * 8);
                }
                else
                {
                    self.frame = CGRectMake(0, self.frame.origin.y, 320, 40 * [categoryArray count]);
                }
            }
            _backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            _tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            
            _shadowImageView.frame = CGRectMake(0, self.frame.size.height, 320, 3);
        } completion:^(BOOL finished) {
            if(_type == CategoryPOI)
            {
                _tableView.frame = CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height);
                _countryTableView.frame = CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height);
                _countryTableView.hidden = NO;
            }
            else
            {
                _tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                _countryTableView.hidden = YES;
            }
        }];
    }
    else
    {
        _activiayIndicator.hidden = NO;
        _label.hidden = NO;
        
        self.frame = CGRectMake(0, self.frame.origin.y, 320, 40);
        _backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        if(_type == CategoryPOI)
        {
            _tableView.frame = CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height);
            _countryTableView.frame = CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height);
            _countryTableView.hidden = NO;
        }
        else
        {
            _tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            _countryTableView.hidden = YES;
        }
        _shadowImageView.frame = CGRectMake(0, self.frame.size.height, 320, 3);
    }
    
    [_tableView reloadData];
    [_countryTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == kTableViewTag)
    {
        return [_categoryArray count];
    }
    else
    {
        if(_type == CategoryPOI)
        {
            if([_categoryArray count] > _selectIndex)
            {
                return [[[_categoryArray objectAtIndex:_selectIndex] objectForKey:@"country"] count];
            }
            else
            {
                return 0;
            }
        }
        else
        {
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //************ Mod By ZhangDong 2014.4.8 Start ***********
    return 35;
    //************ Mod By ZhangDong 2014.4.8 End ***********
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == kTableViewTag)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryIdentifier"];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CategoryIdentifier"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 20, 0);
            //************ Mod By ZhangDong 2014.4.8 Start ***********
            cell.textLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
            cell.textLabel.shadowOffset = CGSizeMake(0, 1);
            
            UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 34, cell.frame.size.width, 1)];
            bottomImageView.image = [UIImage imageNamed:@"lastminute_separator_left_line"];
            [cell.contentView addSubview:bottomImageView];
            [bottomImageView release];
            //************ Mod By ZhangDong 2014.4.8 Start ***********
        }
        
        //************ Mod By ZhangDong 2014.4.8 Start ***********
        cell.backgroundColor =  RGB(242, 245, 246);
        //************ Mod By ZhangDong 2014.4.8 Start ***********
        
//        [cell.accessoryView setBackgroundColor:[UIColor clearColor]];
        
        switch (_type)
        {
            case CategoryLastMinute:
            {
                cell.contentView.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
                cell.textLabel.text = [[_categoryArray objectAtIndex:indexPath.row] objectForKey:@"catename"];
            }
                break;
            case CategoryTime:
            {
                cell.contentView.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
                cell.textLabel.text = [[_categoryArray objectAtIndex:indexPath.row] objectForKey:@"description"];
            }
                break;
            case CategoryDeparture:
            {
                cell.contentView.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
                cell.textLabel.text = [[_categoryArray objectAtIndex:indexPath.row] objectForKey:@"city_des"];
            }
                break;
            case CategoryPOI:
            {
                cell.textLabel.text = [[_categoryArray objectAtIndex:indexPath.row] objectForKey:@"continent_name"];
                if(indexPath.row == _selectIndex)
                {
                    cell.contentView.backgroundColor = [UIColor colorWithRed:229.0 / 255.0 green:229.0 / 255.0 blue:229.0 / 255.0 alpha:1.0];
                }
                else
                {
                    cell.contentView.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
                }
            }
                break;
            default:
                break;
        }
                
        
        if (_type != CategoryPOI) {
            
            if([cell.textLabel.text isEqualToString:_selectedName])
            {
                UIImageView * accessImgVIew = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"category_selected.png"]]autorelease];
                [accessImgVIew setFrame:CGRectMake(10, 10, 20, 20)];
                [accessImgVIew setBackgroundColor:[UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0]];
                
//                UIView * viewwww = [[[UIView alloc]init]autorelease];
//                [viewwww setBackgroundColor:[UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0]];
//                [viewwww setBackgroundColor:[UIColor orangeColor]];
//                [viewwww setFrame:CGRectMake(cell.contentView.frame.size.width, 0,100, cell.contentView.frame.size.height)];
//                [viewwww addSubview:accessImgVIew];
                
                cell.accessoryView = accessImgVIew;
                [cell setBackgroundColor:[UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0]];
            }
            
            else
            {
                cell.accessoryView = nil;
            }
            
        }
        //********* Mod Bug No.178 By ZhangDong 2014.4.4 Start *********
        else
        {
            cell.accessoryView = nil;
        }
        //********* Mod Bug No.178 By ZhangDong 2014.4.4 End *********
        
//        if([cell.textLabel.text isEqualToString:_selectedName])
//        {
//            UIImageView * accessImgVIew = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"category_selected.png"]]autorelease];
//            [accessImgVIew setFrame:CGRectMake(30, 10, 20, 20)];
//            [accessImgVIew setBackgroundColor:[UIColor clearColor]];
//            
//            UIView * viewwww = [[[UIView alloc]init]autorelease];
//            [viewwww setBackgroundColor:[UIColor blueColor]];
//            [viewwww setFrame:CGRectMake(10, 0, 60, 40)];
//            [viewwww addSubview:accessImgVIew];
//            
//            cell.accessoryView = viewwww;
//        }
//        else
//        {
//            cell.accessoryView = nil;
//        }
        
        return cell;
    }
    
    
    
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCountryIdentifier"];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CategoryCountryIdentifier"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 20, 0);
            
            //************ Mod By ZhangDong 2014.4.8 Start ***********
            cell.backgroundColor = RGB(229, 229, 229);
            
            UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 34, cell.frame.size.width, 1)];
            bottomImageView.image = [UIImage imageNamed:@"lastminute_separator_right_line"];
            [cell.contentView addSubview:bottomImageView];
            [bottomImageView release];
            //************ Mod By ZhangDong 2014.4.8 Start ***********
        }
        
        switch (_type)
        {
            case CategoryLastMinute:
            {
                
            }
                break;
            case CategoryTime:
            {
                
            }
                break;
            case CategoryDeparture:
            {
            
            }
                break;
            case CategoryPOI:
            {
                if([_categoryArray count] > _selectIndex)
                {
                    cell.textLabel.text = [[[[_categoryArray objectAtIndex:_selectIndex] objectForKey:@"country"] objectAtIndex:indexPath.row] objectForKey:@"country_name"];
                }
            }
                break;
            default:
                break;
        }
        
        if([cell.textLabel.text isEqualToString:_selectedName])
        {
            //************ Mod By ZhangDong 2014.4.9 Start ***********
            UIImageView * accessImgVIew = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"category_selected.png"]]autorelease];
//            [accessImgVIew setFrame:CGRectMake(30, 10, 20, 20)];
            [accessImgVIew setBackgroundColor:[UIColor clearColor]];
            
//            UIView * viewwww = [[[UIView alloc]init]autorelease];
//            [viewwww setBackgroundColor:[UIColor clearColor]];
//            [viewwww setFrame:CGRectMake(10, 0, 60, 40)];
//            [viewwww addSubview:accessImgVIew];
            
            cell.accessoryView = accessImgVIew;
            //************ Mod By ZhangDong 2014.4.9 End ***********
        }
        else
        {
            cell.accessoryView = nil;
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == kTableViewTag)
    {
        if(_type == CategoryPOI)
        {
            _selectIndex = indexPath.row;
            [_tableView reloadData];
            [_countryTableView reloadData];
        }
        else
        {
            if(_delegate && [_delegate respondsToSelector:@selector(categoryRefreshViewDidSelectWithDictionary:)])
            {
                [_delegate categoryRefreshViewDidSelectWithDictionary:[_categoryArray objectAtIndex:indexPath.row]];
            }
        }
    }
    else
    {
        if(_delegate && [_delegate respondsToSelector:@selector(categoryRefreshViewDidSelectWithDictionary:withIndex:)])
        {
            if([_categoryArray count] > _selectIndex)
            {
                [_delegate categoryRefreshViewDidSelectWithDictionary:[_categoryArray objectAtIndex:_selectIndex] withIndex:indexPath];
            }
        }
    }
    
    return nil;
}

@end
