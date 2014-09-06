//
//  PlaceTableViewCell.m
//  QYER
//
//  Created by Frank on 14-3-24.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PlaceTableViewCell.h"
#import "QyYhConst.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "CountryList.h"
#import "QAControl.h"
#import "UIButton+WebCache.h"

#define iOS7AdapLabelHeight(num) ((ios7) ? (num) : (num + 10))
#define iOS7AdapLabelY(num) ((ios7) ? (num) : (num + 3))
#define iOS7AdapLabelTypeY(num) ((ios7) ? (num) : (num - 2))

typedef enum MathNumberCount {
	MathNumberCountOne,
    MathNumberCountTwo,
    MathNumberCountThree,
    MathNumberCountFour
} MathNumberCount;

@implementation PlaceTableViewCell

#pragma mark
#pragma mark Init
/**
 *	@brief	左侧表格单元格的初始化方法
 *  @param  style               单元格样式
 *  @param  reuseIdentifier     创建单元格内存标记的字符串
 *	@return	id
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundColor = [UIColor clearColor];
        _cellType = PlaceTableViewCellTypeLeft;
        
		//单元格底部的线
		UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 49, 57, 1)];
		bottomImageView.image = [UIImage imageNamed:@"place_separator_line"];
        bottomImageView.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:bottomImageView];
		[bottomImageView release];

		//单元格右侧的线
		UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 0, 1, 54)];
		rightImageView.image = [UIImage imageNamed:@"place_line"];
		[self.contentView addSubview:rightImageView];
		[rightImageView release];

		//当单元格被选中时，右侧的“缺口”
		UIImageView *selImageView = [[UIImageView alloc] initWithFrame:CGRectMake(62, 15, 9, 17)];
		selImageView.alpha = 0;
		selImageView.image = [UIImage imageNamed:@"place_arrow"];
		self.selectImageView = selImageView;
		[self.contentView addSubview:selImageView];
		[selImageView release];

		//单元格的文本标签
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, iOS7AdapLabelY(frame.origin.y), frame.size.width, frame.size.height - 5)];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = RGB(130, 153, 165);
        label.font = [UIFont fontWithName:Default_Font size:15];
		self.label = label;
		[self.contentView addSubview:label];
		[label release];
	}
	return self;
}

/**
 *	@brief	其他国家单元格的初始化方法
 *  @param  style               单元格样式
 *  @param  reuseIdentifier     创建单元格内存标记的字符串
 *	@return	id
 */
- (id)initWithOtherStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundColor = [UIColor clearColor];
        _cellType = PlaceTableViewCellTypeOther;
        
		//背景图片
		UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 3, 230, 39)];
		bgView.backgroundColor = RGB(245, 245, 245);
        bgView.tag = 3001;
		[self.contentView addSubview:bgView];

		//标签
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, iOS7AdapLabelY(0), 230, 39)];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont fontWithName:Default_Font size:15];
		label.textAlignment = NSTextAlignmentLeft;
		label.textColor = RGB(68, 68, 68);
		self.label = label;
		[bgView addSubview:label];
        
		[label release];
		[bgView release];
	}
	return self;
}

/**
 *	@brief	热门国家单元格的初始化方法
 *  @param  style               单元格样式
 *  @param  reuseIdentifier     创建单元格内存标记的字符串
 *	@return	id
 */
- (id)initWithHotStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundColor = [UIColor clearColor];
        _cellType = PlaceTableViewCellTypeHot;
        
		//左侧显示的控件
        UIButton *leftImageBtn = [self createButton:CGRectMake(10, 0, 110, 165)];
        [self.contentView addSubview:leftImageBtn];
        self.imageBtnLeft = leftImageBtn;

		UIView *leftShadowView = [[self createView:CGRectMake(0, 107, leftImageBtn.frame.size.width, 58)] retain];
        leftShadowView.tag = 1000;
		[leftImageBtn addSubview:leftShadowView];

		_leftTopShadow = [[self createShadowView:CGRectMake(48, 10, 52, 38)] retain];
		[leftImageBtn addSubview:_leftTopShadow];
        
        UIImageView *leftPOIImageView = [self createPOIImageView:CGRectMake(0, 4, 18, 18)];
        [_leftTopShadow addSubview:leftPOIImageView];

		UILabel *leftLabelCount = [[self createLabel:CGRectMake(68, 14, 26, 18)] retain];
		leftLabelCount.backgroundColor = [UIColor clearColor];
        leftLabelCount.textAlignment = NSTextAlignmentRight;
		self.labelLeftCount = leftLabelCount;
		[leftImageBtn addSubview:leftLabelCount];

		UILabel *leftLabelType = [[self createLabel:CGRectMake(56, iOS7AdapLabelTypeY(34), 36, iOS7AdapLabelHeight(9))] retain];
		leftLabelType.font = [UIFont fontWithName:Default_Font size:9];
		leftLabelType.backgroundColor = [UIColor clearColor];
        leftLabelType.textAlignment = NSTextAlignmentRight;
		self.labelLeftType = leftLabelType;
		[leftImageBtn addSubview:leftLabelType];

		UILabel *leftLabelCountry = [[self createLabel:CGRectMake(10, 115, 95, iOS7AdapLabelHeight(18))] retain];
        leftLabelCountry.backgroundColor = [UIColor clearColor];
        leftLabelCountry.font = [UIFont fontWithName:Default_Font size:18];
		self.labelLeftCountry = leftLabelCountry;
		[leftImageBtn addSubview:leftLabelCountry];

		UILabel *leftLabelEn = [[self createLabel:CGRectMake(10, 138, 98, 20)] retain];
        leftLabelEn.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
		self.labelLeftCountryEn = leftLabelEn;
		[leftImageBtn addSubview:leftLabelEn];
        
        
        
		//右侧显示的控件
		CGFloat x = leftImageBtn.frame.origin.x + leftImageBtn.frame.size.width + 10;
		UIButton *rightImageBtn = [self createButton:CGRectMake(x, 0, 110, 165)];
		self.imageBtnRight = rightImageBtn;
		[self.contentView addSubview:rightImageBtn];

		UIView *rightShadowView = [[self createView:CGRectMake(0, 107, rightImageBtn.frame.size.width, 58)] retain];
        rightImageBtn.tag = 2001;
		[rightImageBtn addSubview:rightShadowView];
        
        _rightTopShadow = [[self createShadowView:CGRectMake(48, 10, 52, 38)] retain];
		[rightImageBtn addSubview:_rightTopShadow];

        UIImageView *rightPOIImageView = [self createPOIImageView:CGRectMake(0, 4, 18, 18)];
        [_rightTopShadow addSubview:rightPOIImageView];

		UILabel *rightLabelCount = [[self createLabel:CGRectMake(68, 14, 26, 18)] retain];
		rightLabelCount.backgroundColor = [UIColor clearColor];
        rightLabelCount.textAlignment = NSTextAlignmentRight;
		self.labelRightCount = rightLabelCount;
		[rightImageBtn addSubview:rightLabelCount];

		UILabel *rightLabelType = [[self createLabel:CGRectMake(56, iOS7AdapLabelTypeY(34), 36, iOS7AdapLabelHeight(9))] retain];
		rightLabelType.font = [UIFont fontWithName:Default_Font size:9];
		rightLabelType.backgroundColor = [UIColor clearColor];
        rightLabelType.textAlignment = NSTextAlignmentRight;
		self.labelRightType = rightLabelType;
		[rightImageBtn addSubview:rightLabelType];
        
        UILabel *rightLabelCountry = [[self createLabel:CGRectMake(10, 115, 95, iOS7AdapLabelHeight(18))] retain];
        rightLabelCountry.font = [UIFont fontWithName:Default_Font size:18];
		self.labelRightCountry = rightLabelCountry;
		[rightImageBtn addSubview:rightLabelCountry];
        
		UILabel *rightLabelEn = [[self createLabel:CGRectMake(10, 138, 98, 20)] retain];
        rightLabelEn.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
		self.labelRightCountryEn = rightLabelEn;
		[rightImageBtn addSubview:rightLabelEn];

		[leftLabelCount release];
		[leftLabelType release];
		[leftLabelEn release];
		[leftLabelCountry release];
		[leftShadowView release];

		[rightLabelCount release];
		[rightLabelType release];
		[rightLabelEn release];
		[rightLabelCountry release];
		[rightShadowView release];
	}
	return self;
}

#pragma mark
#pragma mark Public
/**
 *	@brief	设置单元格显示数据
 *  @param  delegate            委托的类
 *  @param  data                要显示的数据
 *  @param  indexPath           当前单元格的NSIndexPath
 */
- (void)showData:(NSArray *)data indexPath:(NSIndexPath *)indexPath {
    //左侧的数据
	if (indexPath.row * 2 < [data count]) {
		CountryList *leftCountry = data[indexPath.row * 2];
        
        //计算当前POI或者城市个数的位数
        MathNumberCount count = [self numberCount:leftCountry.count];
        
        //通过位数控制阴影图片，标签的坐标和宽度
        CGFloat shadowImageX = [self topShadowImageX:count];
        CGFloat shadowImageWidth = [self topShadowImageWidth:count];
        CGFloat shadowLabelX = [self topShadowLabelX:count];
        CGFloat shadowLabelWidth = [self topShadowLabelWidth:count];
        
        _leftTopShadow.frame = CGRectMake(shadowImageX, 10, shadowImageWidth, 38);
        self.labelLeftCount.frame = CGRectMake(shadowLabelX, 14, shadowLabelWidth, 18);
        self.labelLeftType.frame = CGRectMake(shadowImageX + 4, self.labelLeftType.frame.origin.y, shadowImageWidth - 12, self.labelLeftType.frame.size.height);
        
        self.labelLeftCount.text = [NSString stringWithFormat:@"%d", leftCountry.count];
        self.labelLeftType.text = leftCountry.label;
        self.labelLeftCountry.text = leftCountry.str_catename;
		self.labelLeftCountryEn.text = leftCountry.str_catename_en;
        
        NSString *leftImgUrl = leftCountry.str_photo;
        //如果tag>2000，那么是热门城市，否则是热门国家
        self.imageBtnLeft.tag = indexPath.section * 1000 + 1000 + indexPath.row * 2;
        
        [self.imageBtnLeft setImageWithURL:[NSURL URLWithString:leftImgUrl] placeholderImage:[UIImage imageNamed:@"place_defaultPNG.png"]];
        
        [self.imageBtnLeft addTarget:self action:@selector(tapImageViewHandler:) forControlEvents:UIControlEventTouchUpInside];
        
	}
    

    //右侧的数据
    if ((indexPath.row * 2 + 1) < [data count]) {
		CountryList *rightCountry = data[indexPath.row * 2 + 1];
        
        //计算当前POI或者城市个数的位数
        MathNumberCount count = [self numberCount:rightCountry.count];
        
        //通过位数控制阴影图片，标签的坐标和宽度
        CGFloat shadowImageX = [self topShadowImageX:count];
        CGFloat shadowImageWidth = [self topShadowImageWidth:count];
        CGFloat shadowLabelX = [self topShadowLabelX:count];
        CGFloat shadowLabelWidth = [self topShadowLabelWidth:count];
        
        _rightTopShadow.frame = CGRectMake(shadowImageX, 10, shadowImageWidth, 38);
        self.labelRightCount.frame = CGRectMake(shadowLabelX, 14, shadowLabelWidth, 18);
        self.labelRightType.frame = CGRectMake(shadowImageX + 4, self.labelRightType.frame.origin.y, shadowImageWidth - 12, self.labelRightType.frame.size.height);
        
		self.labelRightCount.text = [NSString stringWithFormat:@"%d", rightCountry.count];
		self.labelRightType.text = rightCountry.label;
		self.labelRightCountry.text = rightCountry.str_catename;
		self.labelRightCountryEn.text = rightCountry.str_catename_en;
        
		NSString *rightImgUrl = rightCountry.str_photo;
        //如果tag>2000，那么是热门城市，否则是热门国家
		self.imageBtnRight.tag = indexPath.section * 1000 + 1000 + indexPath.row * 2 + 1;
		[self.imageBtnRight setImageWithURL:[NSURL URLWithString:rightImgUrl] placeholderImage:[UIImage imageNamed:@"place_defaultPNG.png"]];
        
        [self.imageBtnRight addTarget:self action:@selector(tapImageViewHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        self.imageBtnRight.hidden = NO;
        _rightTopShadow.hidden = NO;
        UIView *view = [self.contentView viewWithTag:2001];
        view.hidden = NO;
    }else{
        //如果右侧没有数据，清空
        [self clearRightCell];
    }
}

#pragma mark
#pragma mark Private

/**
 *	@brief	创建标签
 *  @param  frame      标签的frame
 *  @return UILabel
 */
- (UILabel *)createLabel:(CGRect)frame {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	label.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
	label.shadowOffset = CGSizeMake(0, 1);
	return [label autorelease];
}

/**
 *	@brief	创建图片视图
 *  @param  frame      图片视图的frame
 *  @return UIImageView
 */
- (UIButton *)createButton:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.userInteractionEnabled = YES;
    button.layer.cornerRadius = 2;
    button.layer.masksToBounds = YES;
	return button;
}

/**
 *	@brief	创建阴影图片视图
 *  @param  frame      阴影图片视图的frame
 *  @return UIImageView
 */
- (UIImageView *)createShadowView:(CGRect)frame {
	UIImageView *imageView = [self createBaseImageView:frame image:[UIImage imageNamed:@"place_poi_bg"]];
	return imageView;
}

/**
 *  创建POI图片视图
 *
 *  @param frame
 *
 *  @return
 */
- (UIImageView*)createPOIImageView:(CGRect)frame
{
    UIImageView *imageView = [self createBaseImageView:frame image:[UIImage imageNamed:@"place_poi"]];
    return imageView;
}

/**
 *  根据frame创建一个UIImageView
 *
 *  @param frame frame
 *
 *  @return UIImageView
 */
- (UIImageView*)createBaseImageView:(CGRect)frame image:(UIImage*)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    if (image) {
        imageView.image = image;
    }
	imageView.backgroundColor = [UIColor clearColor];
	return [imageView autorelease];
}

/**
 *	@brief	创建阴影视图
 *  @param  frame      阴影视图的frame
 *  @return UIView
 */
- (UIView *)createView:(CGRect)frame {
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.backgroundColor = [UIColor blackColor];
	view.alpha = 0.4;
    view.userInteractionEnabled = NO;
	return [view autorelease];
}

/**
 *  计算数字的位数
 *
 *  @param number 需要计算的数字
 *
 *  @return 数字位数
 */
- (MathNumberCount)numberCount:(NSInteger)number
{
    MathNumberCount count = MathNumberCountOne;
    if (number > 9 && number <= 99) {
        count = MathNumberCountTwo;
    }else if (number > 99 && number <= 999){
        count = MathNumberCountThree;
    }else if (number > 999 && number <= 9999){
        count = MathNumberCountFour;
    }
    return count;
}

/**
 *  根据数字位数计算头部阴影图片的X
 *
 *  @param count 数字位数
 *
 *  @return X
 */
- (CGFloat)topShadowImageX:(MathNumberCount)count
{
    CGFloat width = 0;
    switch (count) {
        case MathNumberCountOne:
        {
            width = 60;
            break;
        }
        case MathNumberCountTwo:
        {
            width = 52;
            break;
        }
        case MathNumberCountThree:
        {
            width = 42;
            break;
        }
        case MathNumberCountFour:
        {
            width = 32;
            break;
        }
    }
    return width;
}

/**
 *  根据数字位数计算头部阴影的宽度
 *
 *  @param count 数字位数
 *
 *  @return 宽度
 */
- (CGFloat)topShadowImageWidth:(MathNumberCount)count
{
    CGFloat width = 0;
    switch (count) {
        case MathNumberCountOne:
        {
            width = 40;
            break;
        }
        case MathNumberCountTwo:
        {
            width = 48;
            break;
        }
        case MathNumberCountThree:
        {
            width = 58;
            break;
        }
        case MathNumberCountFour:
        {
            width = 68;
            break;
        }
    }
    return width;
}

/**
 *  根据数字位数计算头部阴影标签的X
 *
 *  @param count 数字位数
 *
 *  @return X
 */
- (CGFloat)topShadowLabelX:(MathNumberCount)count
{
    CGFloat width = 0;
    switch (count) {
        case MathNumberCountOne:
        {
            width = 79;
            break;
        }
        case MathNumberCountTwo:
        {
            width = 68;
            break;
        }
        case MathNumberCountThree:
        {
            width = 57;
            break;
        }
        case MathNumberCountFour:
        {
            width = 46;
            break;
        }
    }
    return width;
}


/**
 *  根据数字位数计算头部阴影标签的宽度
 *
 *  @param count 数字位数
 *
 *  @return 宽度
 */
- (CGFloat)topShadowLabelWidth:(MathNumberCount)count
{
    CGFloat width = 0;
    switch (count) {
        case MathNumberCountOne:
        {
            width = 15;
            break;
        }
        case MathNumberCountTwo:
        {
            width = 26;
            break;
        }
        case MathNumberCountThree:
        {
            width = 37;
            break;
        }
        case MathNumberCountFour:
        {
            width = 48;
            break;
        }
    }
    return width;
}

/**
 *  清空右侧表格
 */
- (void)clearRightCell
{
    self.labelRightCount.text = @"";
    self.labelRightType.text = @"";
    self.labelRightCountry.text = @"";
    self.labelRightCountryEn.text = @"";
    self.imageBtnRight.hidden = YES;
    _rightTopShadow.hidden = YES;
    UIView *view = [self.contentView viewWithTag:2001];
    view.hidden = YES;
}

/**
 *  触摸图片触发的方法
 *
 *  @param button
 */
- (void)tapImageViewHandler:(UIButton *)button {
    NSInteger tag = button.tag;
    int type = ((tag < 2000) ? 1 : 2);
    NSInteger index = tag % 1000;
    
    if ([self.delegate respondsToSelector:@selector(imageViewBtnTouchUp:withType:)]) {
        [self.delegate imageViewBtnTouchUp:index withType:type];
    }
}


#pragma mark
#pragma mark Super

- (void)dealloc {
    self.label = nil;
    self.selectImageView = nil;
    
    self.labelLeftCount = nil;
    self.labelLeftCountry = nil;
    self.labelLeftCountryEn = nil;
    self.labelLeftType = nil;
    self.imageBtnLeft = nil;
    
    self.labelRightCount = nil;
    self.labelRightCountry = nil;
    self.labelRightCountryEn = nil;
    self.labelRightType = nil;
    self.imageBtnRight = nil;
    
    [_leftTopShadow release];
    _leftTopShadow = nil;
    
    [_rightTopShadow release];
    _rightTopShadow = nil;
    
	[super dealloc];
}

- (void)awakeFromNib {
	// Initialization code
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        switch (_cellType) {
            case PlaceTableViewCellTypeOther:
            {
                UIView *view = [self.contentView viewWithTag:3001];
                view.backgroundColor = RGB(222, 222, 222);
                break;
            }
            default:
                break;
        }
    }else{
        switch (_cellType) {
            case PlaceTableViewCellTypeOther:
            {
                UIView *view = [self.contentView viewWithTag:3001];
                view.backgroundColor = RGB(245, 245, 245);
                break;
            }
            default:
                break;
        }
    }
}

@end
