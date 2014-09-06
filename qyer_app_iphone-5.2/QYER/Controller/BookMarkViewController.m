//
//  BookMarkViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-6.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "BookMarkViewController.h"
#import "BookMark.h"
#import "BookMarkData.h"
#import "CatalogCell.h"
#import "ReadViewController.h"
#import "QYGuideData.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"
#import "ChangeTableviewContentInset.h"
#import "Toast+UIView.h"
#import "MobClick.h"
#import "VersionUpdate.h"



#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (4+20) : 4)
#define     height_titleLabel           (ios7 ? 30 : 34)
#define     positionY_backbutton        (ios7 ? (3+20) : 3)
#define     positionY_tableView         (ios7 ? (44+20) : 44)
#define     positionY_headLabel         (ios7 ? 10 : 14)



@interface BookMarkViewController ()

@end



@implementation BookMarkViewController
@synthesize currentVC = _currentVC;
@synthesize flag_navigation;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hotdot_phone:) name:@"hotdot_phone" object:nil];
        
    }
    return self;
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableview_BookMarkVC);
    QY_VIEW_RELEASE(_imageView_default);
    QY_MUTABLERECEPTACLE_RELEASE(_array_guideName);
    QY_MUTABLERECEPTACLE_RELEASE(_dic_bookMark);
    
    QY_SAFE_RELEASE(_currentVC);
    
    [super dealloc];
}





#pragma mark -
#pragma mark --- 热点 或 打电话
-(void)hotdot_phone:(NSNotification *)noatification
{
    NSDictionary *info = noatification.userInfo;
    if([[info objectForKey:@"type"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:1];
    }
    else if([[info objectForKey:@"type"] isEqualToString:@"0"])
    {
        [self resetRootViewWIthType:0];
    }
}

-(void)resetRootViewWIthType:(BOOL)flag
{
    if(!flag)
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height;
        self.view.frame = newFrame;
        
        
        newFrame = _tableview_BookMarkVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableview_BookMarkVC.frame = newFrame;
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableview_BookMarkVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableview_BookMarkVC.frame = newFrame;
        
    }
}




#pragma mark -
#pragma mark --- viewDidAppear  &  viewDidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
    
    
    
    [MobClick beginLogPageView:@"锦囊书签页"];
    
    
    [self initBookMarkData];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick endLogPageView:@"锦囊书签页"];
}
-(void)initBookMarkData
{
    NSDictionary *dic = [[BookMarkData sharedBookMarkData] getBookmarkList];
    NSLog(@" BookmarkList : %@",dic);
    if(!_array_guideName)
    {
        _array_guideName = [[NSMutableArray alloc] init];
    }
    [_array_guideName removeAllObjects];
    [_array_guideName addObjectsFromArray:[dic allKeys]];
    
    for(int i = 0; i < _array_guideName.count;i++)
    {
        NSLog(@" 书签 : %@",[_array_guideName objectAtIndex:i]);
        [VersionUpdate fixBugAppearWhenVersion5WithGuideName:[_array_guideName objectAtIndex:i]];
    }
    [_array_guideName removeAllObjects];
    dic = [[BookMarkData sharedBookMarkData] getBookmarkList];
    [_array_guideName addObjectsFromArray:[dic allKeys]];
    
    
    
    
    if(_dic_bookMark)
    {
        [_dic_bookMark removeAllObjects];
        [_dic_bookMark release];
    }
    _dic_bookMark = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
    
    for(NSString *guideName in _array_guideName)
    {
        NSMutableArray *array_tmp = [[NSMutableArray alloc] init];
        NSArray *array = [dic objectForKey:guideName];
        for(BookMark *bookMark in array)
        {
            BOOL flag = NO;
            for(BookMark *bookMark_tmp in array_tmp)
            {
                if([bookMark_tmp.str_bookMarkTitle isEqualToString:bookMark.str_bookMarkTitle])
                {
                    flag = YES;
                    break;
                }
            }
            if(!flag)
            {
                [array_tmp addObject:bookMark];
            }
        }
        [_dic_bookMark setObject:array_tmp forKey:guideName];
        [array_tmp release];
    }
    
    
    
    if(_array_guideName.count > 0)
    {
        [self initBookMarkTableView];
    }
    else
    {
        [self initDefaultImageView];
    }
}



#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initRootView];
    if(!self.flag_navigation)
    {
        [self setNavigationBar];
    }
}
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(184/2, positionY_titlelabel, 136, height_titleLabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"我的书签";
    //_titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    [_titleLabel release];
    
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
}
-(void)initDefaultImageView
{
    if(_tableview_BookMarkVC)
    {
        [_tableview_BookMarkVC removeFromSuperview];
    }
    
    if(!_imageView_default)
    {
        _imageView_default = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-150)/2., 320, 150)];
        _imageView_default.backgroundColor = [UIColor clearColor];
        _imageView_default.image = [UIImage imageNamed:@"bg_empty_bookmark"];
    }
    [self.view addSubview:_imageView_default];
}
-(void)initBookMarkTableView
{
    if(_imageView_default)
    {
        [_imageView_default removeFromSuperview];
    }
    
    if(!_tableview_BookMarkVC)
    {
        _tableview_BookMarkVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height) style:UITableViewStylePlain];
        _tableview_BookMarkVC.backgroundColor = [UIColor clearColor];
        _tableview_BookMarkVC.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview_BookMarkVC.separatorColor = [UIColor clearColor];
    }
//    if(ios7)
//    {
//        if(!_tableview_BookMarkVC)
//        {
//            _tableview_BookMarkVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height) style:UITableViewStylePlain];
//            _tableview_BookMarkVC.backgroundColor = [UIColor clearColor];
//            _tableview_BookMarkVC.separatorStyle = UITableViewCellSeparatorStyleNone;
//            _tableview_BookMarkVC.separatorColor = [UIColor clearColor];
//        }
//    }
//    else
//    {
//        if(!_tableview_BookMarkVC)
//        {
//            _tableview_BookMarkVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([self.view bounds].size.height-20)) style:UITableViewStylePlain];
//            _tableview_BookMarkVC.backgroundColor = [UIColor clearColor];
//            _tableview_BookMarkVC.separatorStyle = UITableViewCellSeparatorStyleNone;
//            _tableview_BookMarkVC.separatorColor = [UIColor clearColor];
//        }
//    }
    _tableview_BookMarkVC.delegate = self;
    _tableview_BookMarkVC.dataSource = self;
    [_tableview_BookMarkVC reloadData];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    footView.backgroundColor = [UIColor clearColor];
    _tableview_BookMarkVC.tableFooterView = footView;
    [footView release];
    
    if(!self.flag_navigation)
    {
        [ChangeTableviewContentInset changeTableView:_tableview_BookMarkVC withOffSet:0];
    }
    else
    {
        [ChangeTableviewContentInset changeTableView:_tableview_BookMarkVC withOffSet:height_offset_tableView];
    }
    [self.view addSubview:_tableview_BookMarkVC];
    [self.view bringSubviewToFront:_headView];
}


#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_array_guideName count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dic_bookMark objectForKey:[_array_guideName objectAtIndex:section]] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [_dic_bookMark objectForKey:[_array_guideName objectAtIndex:indexPath.section]];
    BookMark *bookMark = [array objectAtIndex:indexPath.row];
    NSString *bookMarkTitle = bookMark.str_bookMarkTitle;
    float height = [CatalogCell cellHeightWithContent:bookMarkTitle andLength:240];
    if(indexPath.row+1 == array.count)
    {
        return height+2;
    }
    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *customView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    customView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    //customView.image = [UIImage imageNamed:@"qyer_background"];
    //customView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"qyer_background" ofType:@"png"]];
    
    
    
    UIImageView *imgView_bookmark = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 40, 40)];
    imgView_bookmark.backgroundColor = [UIColor clearColor];
    imgView_bookmark.image = [UIImage imageNamed:@"btn_reader_bookmark_click"];
    [customView addSubview:imgView_bookmark];
    [imgView_bookmark release];
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView_bookmark.frame.origin.x+imgView_bookmark.frame.size.width-5, positionY_headLabel, 260, 20)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = [_array_guideName objectAtIndex:section];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    [customView addSubview:headerLabel];
    [headerLabel release];
    
    
    return [customView autorelease];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CatalogCell"];
    if(cell == nil)
    {
        cell = [[[CatalogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CatalogCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell initBookMarkCatelogWithArray:[_dic_bookMark objectForKey:[_array_guideName objectAtIndex:indexPath.section]] atPosition:indexPath.row];
    
    return cell;
}


#pragma mark -
#pragma mark --- UITableView - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@" indexPath.section         : %d",indexPath.section);
    NSLog(@" indexPath.row             : %d",indexPath.row);
    NSLog(@" array_guideName.count     : %d",_array_guideName.count);
    
    
    NSMutableArray *catlogArray = (NSMutableArray *)[GuideMenuData getMenuJsonWithGuideName:[_array_guideName objectAtIndex:indexPath.section]];
    if(catlogArray && [catlogArray isKindOfClass:[NSArray class]] && catlogArray.count > 0)
    {
        ReadViewController *readVC = [[ReadViewController alloc] init];
        readVC.flag_pushFromBookMark = 1;
        readVC.str_guideName = [_array_guideName objectAtIndex:indexPath.section];
        //readVC.guide = [QYGuideData getGuideByNameInBookMarkVC:[_array_guideName objectAtIndex:indexPath.section]];
        readVC.guide = [QYGuideData getGuideByName:[_array_guideName objectAtIndex:indexPath.section]];
        readVC.array_catalog = catlogArray;
        readVC.selectIndex = [[[[_dic_bookMark objectForKey:[_array_guideName objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] str_bookMarkPageNumber] intValue];
        if(self.currentVC)
        {
            [self.currentVC.navigationController pushViewController:readVC animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:readVC animated:YES];
        }
        [readVC release];
    }
    else
    {
        NSLog(@" 文件已损坏 ~~~ ");
        
        
        [self.view makeToast:@"文件已损坏,请重新下载" duration:1 position:@"center" isShadow:NO];
        
        
        //*** 删除本本锦囊里已保存的书签:
        NSInteger position_scetion = indexPath.section;
        NSInteger position_row = indexPath.row;
        NSString *guideName = [_array_guideName objectAtIndex:indexPath.section];
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[_dic_bookMark objectForKey:guideName]];
        BookMark *bookMark = [array objectAtIndex:position_row];
        [[BookMarkData sharedBookMarkData] removeBookmark:bookMark];
        
        
        
        
        //删除相关书签:
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[BookMarkData sharedBookMarkData] getBookmarkList]];
        [dic removeObjectForKey:guideName];
        NSString *plistPath = [[FilePath getBookMarkPath] retain];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [data writeToFile:plistPath atomically:NO];
        [plistPath release];
        [dic removeAllObjects];
        [dic release];
        
        
        
        
        //*** 从数组中删除: [ 先从数组中删除再刷新tableView ]
        [array removeObjectAtIndex:position_row];
        if(array.count > 0)
        {
            [_dic_bookMark setObject:array forKey:guideName];
            
            //*** tableView删除cell:
            [_tableview_BookMarkVC deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:position_row inSection:position_scetion]] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else
        {
            [_dic_bookMark removeObjectForKey:guideName];
            [_array_guideName removeObject:guideName];
            
            //*** tableView删除section:
            [_tableview_BookMarkVC deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
        }
        [array release];
        
        
        
        
        //*** 刷新tableView数据:
        if(_dic_bookMark.count == 0)
        {
            [self performSelector:@selector(initDefaultImageView) withObject:nil afterDelay:0.2];
        }
    }
}


#pragma mark -
#pragma mark --- doBack
-(void)doBack
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- UITableView - 删除cell操作
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        NSInteger position_scetion = indexPath.section;
        NSInteger position_row = indexPath.row;
        NSString *guideName = [_array_guideName objectAtIndex:indexPath.section];
        
        
        //*** 删除本本锦囊里已保存的书签:
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[_dic_bookMark objectForKey:guideName]];
        BookMark *bookMark = [array objectAtIndex:position_row];
        [[BookMarkData sharedBookMarkData] removeBookmark:bookMark];
        
        
        
        
        //*** 从数组中删除: [ 先从数组中删除再刷新tableView ]
        [array removeObjectAtIndex:position_row];
        if(array.count > 0)
        {
            [_dic_bookMark setObject:array forKey:guideName];
            
            //*** tableView删除cell:
            [_tableview_BookMarkVC deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:position_row inSection:position_scetion]] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else
        {
            [_dic_bookMark removeObjectForKey:guideName];
            [_array_guideName removeObject:guideName];
            
            //*** tableView删除section:
            [_tableview_BookMarkVC deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
        }
        [array release];
        
        
        
        
        //*** 刷新tableView数据:
        if(_dic_bookMark.count == 0)
        {
            [self performSelector:@selector(initDefaultImageView) withObject:nil afterDelay:0.2];
        }
        
    }
    else
    {
        return;
    }
}





#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
