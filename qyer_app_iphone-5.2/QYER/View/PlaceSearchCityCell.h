//
//  CityTableViewCell.h
//  QYER
//
//  Created by Frank on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum PlaceSearchType {
	PlaceSearchTypePOI = 1,
    PlaceSearchTypeCity,
    PlaceSearchTypeCountry
} PlaceSearchType;

@protocol PlaceSearchCityCellDelegate <NSObject>
- (void)didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
@end

@class PlaceSearchModel;
/**
 *	@brief	目的地搜索视图里面表格使用的单元格
 */
@interface PlaceSearchCityCell : UITableViewCell

/**
 *	@brief	底部阴影显示的图片
 */
@property (nonatomic, retain) UIImageView *bottomShadowImageView;

/**
 *	@brief	左侧图片
 */
@property (nonatomic, retain) UIImageView *imgView;

/**
 *	@brief	上标签
 */
@property (nonatomic, retain) UILabel *topLabel;

/**
 *	@brief	中间标签
 */
@property (nonatomic, retain) UILabel *centerLabel;

/**
 *	@brief	底部标签
 */
@property (nonatomic, retain) UILabel *bottomLabel;

/**
 *	@brief	右部标签
 */
@property (nonatomic, retain) UILabel *rightLabel;

/**
 *  当前行的indexPath
 */
@property (nonatomic, retain) NSIndexPath *indexPath;

/**
 *  委托的类
 */
@property (nonatomic, assign) id<PlaceSearchCityCellDelegate> delegate;
/**
 *  配置数据
 *
 *  @param model 当前行的model
 */
- (void)configData:(PlaceSearchModel*)model;
@end


