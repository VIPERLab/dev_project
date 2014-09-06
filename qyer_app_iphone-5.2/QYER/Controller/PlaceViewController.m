//
//  PlaceViewController.m
//  QYER
//
//  Created by 我去 on 14-3-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PlaceViewController.h"
#import "CountryViewController.h"
#import "SearchViewController.h"
#import "PlaceTableViewCell.h"
#import "AllPlaceData.h"
#import "Continent.h"
#import "CountryList.h"
#import "Toast+UIView.h"
#import "ChangeTableviewContentInset.h"
#import "ActivityViewController.h"

#define     height_titlelabel           (ios7 ? (30) : 34)


#define     left_tableView_tag 1001
#define     left_tableView_count 7
#define     left_tableView_selected_indexPath   [NSIndexPath indexPathForRow:0 inSection:0]
#define     left_tableView_cell_imageView_tag   1001
#define     left_tableView_cell_rect            CGRectMake(0, 0, 71, 54)


#define     tableView_tag 1002

#define     positionY_button_search         (ios7 ? 20 : 0)


#define iOS7AdapLabelHeight(num) ((ios7) ? (num) : (num + 7))



@interface PlaceViewController ()

@end



@implementation PlaceViewController
@synthesize currentVC;

#pragma mark
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
	// 设置表格视图
	[self setTableView];
    
    // 设置导航条
    [self setNavigation];
    
    // 查询数据
	[self queryData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc {
	QY_VIEW_RELEASE(_tableView);
	QY_VIEW_RELEASE(_headView);

	QY_SAFE_RELEASE(_cellArray);
	QY_SAFE_RELEASE(_selectedContinent);
	QY_SAFE_RELEASE(_countryListHot);
	QY_SAFE_RELEASE(_countryListOther);
    QY_SAFE_RELEASE(_selectedIndexPath);
    
	[super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"目的地"];
    _isTapedImage = NO;
    
    if (_isReload) {
        _isReload = NO;
        
        [self queryData];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"目的地"];
    _isTapedImage = NO;
}

#pragma mark
#pragma mark Private

/**
 *	@brief	设置导航条
 */
- (void)setNavigation {
    
//	_titleLabel.text = @"目的地";
    
    _titleLabel.text = @"";
    
    UIImageView *titleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 10, 80, 24)];
    if(ios7)
    {
        titleImgView.frame = CGRectMake(120, 10+20, 80, 24);
    }
    titleImgView.backgroundColor = [UIColor clearColor];
    [titleImgView setImage:[UIImage imageNamed:@"navigation_place"]];
    [_headView addSubview:titleImgView];
    [titleImgView release];
    
    _backButton.hidden = YES;
    [_rightButton setBackgroundImage:[UIImage imageNamed:@"btn_search"] forState:UIControlStateNormal];
}

/**
 *  @brief 选中左侧表格第一行(当季热门)
 */
- (void)selectFirstRowCellLeftTableView {
	//初始化左侧表格选中次数
	_selectLeftTableViewTimes = 0;
	//选中左侧表格第一行
	_isSelectFirstRowLeftTableView = YES;


	UITableView *tableView = (UITableView *)[self.view viewWithTag:left_tableView_tag];

	[self tableView:tableView didSelectRowAtIndexPath:left_tableView_selected_indexPath];
}

/**
 *  @brief 设置左右两侧表格
 */
- (void)setTableView {
	CGFloat height = self.view.bounds.size.height - RootViewControllerFootViewHeight;

	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 71, iOS7Adap(height))];
	tableView.tag = left_tableView_tag;
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.rowHeight = 54;
    tableView.showsVerticalScrollIndicator = NO;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.backgroundColor = RGB(232, 242, 249);
//    tableView.scrollEnabled = (UIHeight == 480);
	[self.view addSubview:tableView];
    
    //左侧表格下拉时候，头部右侧的竖线
    UIImageView *rightLineImageViewTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"place_line"]];
    rightLineImageViewTop.hidden = YES;
    rightLineImageViewTop.frame = CGRectMake(70, -300, 1, 300);
    rightLineImageViewTop.tag = 999;
    [tableView addSubview:rightLineImageViewTop];
    [rightLineImageViewTop release];
    
    //左侧表格下拉时候，底部右侧的竖线
    UIImageView *rightLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"place_line"]];
    rightLineImageView.frame = CGRectMake(70, 300, 1, 54);
    rightLineImageView.tag = 1000;
    rightLineImageView.hidden = YES;
    [tableView addSubview:rightLineImageView];
    [rightLineImageView release];

	CGFloat width = self.view.bounds.size.width - tableView.frame.size.width;
    
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	_tableView.tag = tableView_tag;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(iOS7Adap(64), 0, (ios7 ? 0 : 20), 0);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(iOS7Adap(64), 0, 0, 0);

    [ChangeTableviewContentInset changeTableView:tableView withOffSet:0];
    
    [self.view addSubview:_tableView];
	[tableView release];
    
    [self.view bringSubviewToFront:(UIView*)_headView];
}



/**
 *  @brief 设置章节显示内容
 *  @param section 当前章节索引
 */
- (NSString *)sectionText:(NSInteger)section {
	NSString *text = @"";
	if (section == 0) {
		text = _sectionNameCountry;
	}
	else {
		if (_isSelectFirstRowLeftTableView) {
			text = _sectionNameCity;
		}
		else {
			text = _sectionNameOther;
		}
	}

	return text;
}

/**
 *	@brief	查询数据
 */
- (void)queryData {
    [self.view performSelector:@selector(makeToastActivity) withObject:nil afterDelay:0];
   
	[AllPlaceData getAllPlaceListSuccess: ^(NSArray *countries) {
        //移除没有网络的视图
        [super setNotReachableView:NO];
        
	    _cellArray = [countries retain];

	    UITableView *tableView = (UITableView *)[self.view viewWithTag:left_tableView_tag];
	    [tableView reloadData];
        
        //默认选中左侧表格第一行(当季热门)
        [self selectFirstRowCellLeftTableView];
        
        [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
        
    } failed:^(enum QYRequestFailedType type) {
        MYLog(@"AllPlaceData getAllPlaceList Eroor");
        
        if (type == QYRequestFailedTypeNotReachable) {
            [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
            //加入没有网络的视图
            [super setNotReachableView:YES];
        }else if (type == QYRequestFailedTypeTimeout){
            [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
            [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
            //如果请求超时，那么下次进入视图，需要重新请求
            _isReload = YES;
        }
    }];
}

/**
 *  触摸图片触发的方法
 *
 *  @param index 当前图片的索引
 *  @param type  数据类型，1：国家 2：城市
 */
- (void)imageViewBtnTouchUp:(NSInteger)index withType:(NSInteger)type {
    if (_isTapedImage) {
        return;
    }
    _isTapedImage = YES;
    
    CountryList *item = nil;
    if (type == 1) {
        if (index < [_countryListHot count]) {
            item = _countryListHot[index];
        }
    }else{
        if (index < [_countryListOther count]) {
            item = _countryListOther[index];
        }
    }
    [self toNextViewController:item];
}

/**
 *  跳转到下一个视图
 *
 *  @param item 当前国家对象
 */
- (void)toNextViewController:(CountryList*)model
{
    CountryViewController *counVc = [[CountryViewController alloc]init];
    counVc.type = model.flag;
    counVc.key = model.str_id;
	[self.currentVC.navigationController pushViewController:counVc animated:YES];
	[counVc release];
}

/**
 *  @brief 触摸按钮触发的方法
 *  @param sender
 */
- (void)clickRightButton:(id)sender {
	SearchViewController *searchVC = [[SearchViewController alloc] init];
	searchVC.isFromPlace = YES;
	UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
	[searchVC release];
	navVC.navigationBarHidden = YES;
    
	[self presentViewController:navVC animated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"footViewHidden" object:nil userInfo:@{@"hidden":@YES}];
    }];
	[navVC release];
}

#pragma mark
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView.tag == left_tableView_tag || _isAntarctica) {
		return 1;
	}
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView.tag == left_tableView_tag) {
        if (_cellArray) {
            UIImageView *rightLineImageView = (UIImageView*)[tableView viewWithTag:1000];
            UIImageView *rightLineImageViewTop = (UIImageView*)[tableView viewWithTag:999];
            rightLineImageView.hidden = NO;
            rightLineImageViewTop.hidden = NO;
            if (rightLineImageView.frame.origin.y == 300) {
                rightLineImageView.frame = CGRectMake(tableView.frame.origin.x + tableView.frame.size.width - 1, [_cellArray count] * 54, 1, 180);
            }
        }
		return [_cellArray count];
	}
	if (section == 0) {
        return ceil([_countryListHot count] / 2.0);
	}
	return (_isSelectFirstRowLeftTableView ? ceil([_countryListOther count] / 2.0) : [_countryListOther count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//配置左侧表格单元格的内容显示
	if (tableView.tag == left_tableView_tag) {
		static NSString *cellString = @"leftCell";
		PlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];

		if (!cell) {
			cell = [[[PlaceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString frame:left_tableView_cell_rect] autorelease];
		}
        
        if ([_cellArray count] > indexPath.row) {
            Continent *continent = _cellArray[indexPath.row];
            cell.label.text = continent.catename;
        }
		
        //选中的行，字体加粗，显示选中图片
        if (_selectedIndexPath.row == indexPath.row) {
            cell.selectImageView.alpha = 1;
        }else{
            cell.selectImageView.alpha = 0;
        }
		return cell;
	}

	//配置右侧表格第二个章节的内容显示（其他国家）
	if (indexPath.section == 1 && !_isSelectFirstRowLeftTableView) {
		static NSString *cellString = @"cell";
		PlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
		if (!cell) {
			cell = [[[PlaceTableViewCell alloc] initWithOtherStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
		}

        if ([_countryListOther count] > indexPath.row) {
            CountryList *country = _countryListOther[indexPath.row];
            cell.label.text = country.str_catename;
        }
		return cell;
	}
	else {
		//配置右侧表格单元格的显示（每个单元格2个UIImageView的格式）
		static NSString *cellString = @"twoImageViewCell";
		PlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];

		if (!cell) {
			cell = [[[PlaceTableViewCell alloc] initWithHotStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
            cell.delegate = self;
		}
        
        if (indexPath.section == 0) {
            [cell showData:_countryListHot indexPath:indexPath];
        }else{
            [cell showData:_countryListOther indexPath:indexPath];
        }
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView.tag == left_tableView_tag) {
        
        _selectedIndexPath = [indexPath retain];
        
        //是否选择南极洲
        _isAntarctica = (indexPath.row == 7);
        
        //当是南极洲的时候，右侧表格只有一个section
        if (_isAntarctica) {
            _tableView.frame = CGRectMake(_tableView.frame.origin.x, 7, _tableView.frame.size.width, _tableView.frame.size.height - 7);
        }else{
            CGFloat width = self.view.bounds.size.width - tableView.frame.size.width;
            CGFloat height = self.view.bounds.size.height - RootViewControllerFootViewHeight;
            _tableView.frame = CGRectMake(tableView.frame.size.width, 0, width, height);
        }
        
		_selectLeftTableViewTimes++;
		//如果默认选中了左侧表格第一行，那么取消选中状态
		if (_selectLeftTableViewTimes == 2) {
			[self tableView:tableView didDeselectRowAtIndexPath:left_tableView_selected_indexPath];
		}
        
		//判断是否选中左侧表格第一行
		_isSelectFirstRowLeftTableView = (indexPath.row == 0);
        
        //设置章节显示内容
        _sectionNameCountry = @"热门国家";
        _sectionNameCity = @"热门城市";
        _sectionNameOther = @"其他国家";
        _otherCountrySectionTipText = @"按首字母拼音排列";

		_selectedContinent = [_cellArray[indexPath.row] retain];
		_countryListHot = [_selectedContinent.hotcountrylist retain];
		_countryListOther = [_selectedContinent.countrylist retain];
		[_tableView reloadData];
        
        if ([_countryListHot count] > 0) {
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        }

		PlaceTableViewCell *cell = (PlaceTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		cell.label.textColor = RGB(22, 22, 22);
		cell.selectImageView.alpha = 1;
        cell.label.font = [UIFont fontWithName:Default_Font size:15];
        
	}else{
        //如果左侧表格选中的不是第一行，并且右侧表格是第二个章节的时候（其他国家），跳转到国家的视图
        if (!_isSelectFirstRowLeftTableView && indexPath.section == 1) {
            CountryList *item = _countryListOther[indexPath.row];
            [self toNextViewController:item];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView.tag == left_tableView_tag) {
		//脱选状态恢复字体颜色，恢复默认状态图片
		PlaceTableViewCell *cell = (PlaceTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		cell.label.textColor = RGB(130, 153, 165);
		cell.selectImageView.alpha = 0;
        cell.label.font = [UIFont fontWithName:Default_Font size:15];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (tableView.tag != left_tableView_tag && !_isAntarctica) {
		UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 28)] autorelease];
        header.alpha = 0.96;
		header.backgroundColor = [UIColor whiteColor];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 70, iOS7AdapLabelHeight(14))];
		label.text = [self sectionText:section];
		label.font = [UIFont fontWithName:Default_Font size:14];
		label.textAlignment = NSTextAlignmentLeft;
		label.textColor = RGB(130, 153, 165);
		label.backgroundColor = [UIColor clearColor];
		[header addSubview:label];
		[label release];
        
        if (section == 1 && !_isSelectFirstRowLeftTableView) {
            UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 8, 100, iOS7AdapLabelHeight(14))];
            rightLabel.text = _otherCountrySectionTipText;
            rightLabel.textAlignment = NSTextAlignmentRight;
            rightLabel.textColor = RGB(188, 188, 188);
            rightLabel.backgroundColor = [UIColor clearColor];
            rightLabel.font = [UIFont fontWithName:Default_Font size:12];
            [header addSubview:rightLabel];
            [rightLabel release];
        }
        
		return header;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (tableView.tag == left_tableView_tag || _isAntarctica) ? 0 : 28;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//默认左侧表格高度的高度是54
	CGFloat height = 54;

	if (tableView.tag != left_tableView_tag) {
		//右侧表格第一个章节和“热门城市”的高度是90
		if (indexPath.section == 0 || _isSelectFirstRowLeftTableView) {
			height = 175;
		}
		else if (indexPath.section == 1) {  //其他国家
            if ([_countryListOther count] - 1 == indexPath.row) {
                height = 46; //最后一行，距离屏幕底部的留白
            }else{
                height = 42;
            }
		}
	}
	return height;
}


#pragma mark
#pragma mark NotReachableViewDelegate

- (void)touchesView
{
    [super touchesView];
    
    [self queryData];
}
@end
