//
//  PlaceTableViewCell.h
//  QYER
//
//  Created by Frank on 14-3-24.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PlaceTableViewCellType){
    PlaceTableViewCellTypeLeft,
    PlaceTableViewCellTypeHot,
    PlaceTableViewCellTypeOther
};

@protocol PlaceTableViewCellDelegate <NSObject>
- (void)imageViewBtnTouchUp:(NSInteger)index withType:(NSInteger)type;
@end

/**
 *	目的地视图里面表格使用的单元格
 */
@interface PlaceTableViewCell : UITableViewCell
{
    /**
     * 左侧顶部阴影图片
     */
    UIImageView *_leftTopShadow;
    
    /**
     * 右侧顶部阴影图片
     */
    UIImageView *_rightTopShadow;
    
    /**
     *  单元格类型
     */
    PlaceTableViewCellType _cellType;
}

/**
 *  初始化左侧表格视图
 *
 *  @param style           表格样式
 *  @param reuseIdentifier 复用的字符串标识
 *  @param frame           frame
 *
 *  @return 
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame;

/**
 *	@brief	左侧单元格的标签
 */
@property (nonatomic, retain) UILabel *label;

/**
 *	@brief	左侧单元格选中显示的图片
 */
@property (nonatomic, retain) UIImageView *selectImageView;

/**
 *	@brief	其他国家单元格的初始化方法
 *  @param  style               单元格样式
 *  @param  reuseIdentifier     创建单元格内存标记的字符串
 *	@return	id
 */
- (id)initWithOtherStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

/**
 *	@brief	热门国家单元格左侧
 */
@property (nonatomic, retain) UIButton *imageBtnLeft;
@property (nonatomic, retain) UILabel *labelLeftCount;
@property (nonatomic, retain) UILabel *labelLeftType;
@property (nonatomic, retain) UILabel *labelLeftCountry;
@property (nonatomic, retain) UILabel *labelLeftCountryEn;
/**
 *	@brief	热门国家单元格右侧
 */
@property (nonatomic, retain) UIButton *imageBtnRight;
@property (nonatomic, retain) UILabel *labelRightCount;
@property (nonatomic, retain) UILabel *labelRightType;
@property (nonatomic, retain) UILabel *labelRightCountry;
@property (nonatomic, retain) UILabel *labelRightCountryEn;

@property (nonatomic, assign) id<PlaceTableViewCellDelegate> delegate;
/**
 *	@brief	热门国家单元格初始化方法
 *  @param  style               单元格样式
 *  @param  reuseIdentifier     创建单元格内存标记的字符串
 *	@return	id
 */
- (id)initWithHotStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

/**
 *	@brief	设置单元格显示数据
 *  @param  delegate            委托的类
 *  @param  data                要显示的数据
 *  @param  indexPath           当前单元格的NSIndexPath
 */
- (void)showData:(NSArray *)data indexPath:(NSIndexPath *)indexPath;

@end


