//
//  PlaceViewController.h
//  QYER
//
//  Created by 我去 on 14-3-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
#import "PlaceTableViewCell.h"

@class Continent;

/**
 *	@brief	目的地
 */
@interface PlaceViewController : QYBaseViewController <UITableViewDataSource, UITableViewDelegate, PlaceTableViewCellDelegate>
{
	/**
     *  左侧表格选中的次数
     */
	NSInteger _selectLeftTableViewTimes;

	/**
     *  是否选中左侧表格第一行
     */
	BOOL _isSelectFirstRowLeftTableView;
    
    /**
     *  是否是南极洲
     */
    BOOL _isAntarctica;

	/**
     *  右侧表格
     */
	UITableView *_tableView;

	/**
     *  数据源
     */
	NSArray *_cellArray;

	/**
     *  左侧表格选中的数据
     */
	Continent *_selectedContinent;

	/**
     *  热门国家数组
     */
	NSArray *_countryListHot;

	/**
     *  其他国家数组
     */
	NSArray *_countryListOther;
    
    /**
     *  选中的IndexPath
     */
    NSIndexPath *_selectedIndexPath;
    
    /**
     *  判断是否已经触摸单元格的图片，用来排除两个图片同时触摸导致的BUG
     */
    BOOL _isTapedImage;
    
    /**
     *  国家章节的显示内容
     */
    NSString *_sectionNameCountry;
    
    /**
     *  城市章节的显示内容
     */
    NSString *_sectionNameCity;
    
    /**
     *  其他章节的显示名称
     */
    NSString *_sectionNameOther;
    
    /**
     *  其他国家的排序显示提示文字
     */
    NSString *_otherCountrySectionTipText;
    
    BOOL _isReload;

}
@property (nonatomic, retain) UIViewController *currentVC;

@end
