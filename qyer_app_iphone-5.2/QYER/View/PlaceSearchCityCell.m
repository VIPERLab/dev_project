//
//  CityTableViewCell.m
//  QYER
//
//  Created by Frank on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PlaceSearchCityCell.h"
#import "QyYhConst.h"
#import "PlaceSearchModel.h"
#import "UIImageView+WebCache.h"

#define iOS7AdapLabelHeight(num) ((ios7) ? (num) : (num + 5))
#define labelY(num) ((ios7) ? (num) : (num + 2))
#define iOS7AdapLabelY(num) ((ios7) ? (num) : (num - 4))

@implementation PlaceSearchCityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
//        //背景图片
        UIButton *backImage = [UIButton buttonWithType:UIButtonTypeCustom];
        backImage.frame = CGRectMake(8, 0, UIWidth - 16, 76);
        [backImage setImage:[UIImage imageNamed:@"我的行程_list2"] forState:UIControlStateNormal];
        [backImage setImage:[UIImage imageNamed:@"search_cell_pressdown"] forState:UIControlStateHighlighted];
        [backImage addTarget:self action:@selector(backImageClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:backImage];
        
        //底部阴影图片
        CGFloat y = backImage.frame.origin.y + backImage.frame.size.height;
        UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, backImage.frame.size.width, 2)];
        shadowImageView.image = [UIImage imageNamed:@"首页_底部阴影.png"];
        self.bottomShadowImageView = shadowImageView;
        [backImage addSubview:shadowImageView];
        [shadowImageView release];
        
        //左侧图片
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 60, 60)];
        self.imgView = imgView;
        [backImage addSubview:imgView];
        
        //上标签
        CGFloat x = imgView.frame.origin.x + imgView.frame.size.width + 12;
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 10 , 200, iOS7AdapLabelHeight(20))];
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.font = [UIFont fontWithName:Default_Font size:15];
        topLabel.textAlignment = NSTextAlignmentLeft;
        topLabel.textColor = RGB(68, 68, 68);
        self.topLabel = topLabel;
        [backImage addSubview:topLabel];
        
        //中间标签
        CGFloat centerLabelY = topLabel.frame.origin.y + topLabel.frame.size.height + (ios7 ? 5 : 0);
        UILabel *centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, centerLabelY, 200, iOS7AdapLabelHeight(12))];
        centerLabel.backgroundColor = [UIColor clearColor];
        centerLabel.font = [UIFont fontWithName:Default_Font size:12];
        centerLabel.textAlignment = NSTextAlignmentLeft;
        centerLabel.textColor = RGB(188, 188, 188);
        self.centerLabel = centerLabel;
        [backImage addSubview:centerLabel];
        
        //下标签
        CGFloat bottomLabelY = centerLabel.frame.origin.y + centerLabel.frame.size.height + (ios7 ? 6 : 2);
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, bottomLabelY, 200, iOS7AdapLabelHeight(12))];
        bottomLabel.backgroundColor = [UIColor clearColor];
        bottomLabel.font = [UIFont fontWithName:Default_Font size:12];
        bottomLabel.textAlignment = NSTextAlignmentLeft;
        bottomLabel.textColor = RGB(188, 188, 188);
        self.bottomLabel = bottomLabel;
        [backImage addSubview:bottomLabel];
        
        //右标签
        CGFloat width = 60;
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - width - 25, centerLabel.frame.origin.y, width, iOS7AdapLabelHeight(12))];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.font = [UIFont fontWithName:Default_Font size:12];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.textColor = RGB(43, 171, 121);
        self.rightLabel = rightLabel;
        [backImage addSubview:rightLabel];

        [rightLabel release];
        [bottomLabel release];
        [centerLabel release];
        [topLabel release];
        [imgView release];
    }
    return self;
}

#pragma mark
#pragma mark Private

/**
 *  把model的数据，显示在cell中
 *
 *  @param model 当前行数据
 */
- (void)configData:(PlaceSearchModel *)model
{
    [self.imgView setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[UIImage imageNamed:@"place_search_default.png"]];
    self.topLabel.text = model.poiname ;
    self.centerLabel.text = [self centerLabelText:model];
    self.bottomLabel.text = model.beenstr;
    self.rightLabel.text = model.label;
}

/**
 *  根绝当前行的type，获取text
 *
 *  @param model 当前行数据
 *
 *  @return text
 */
- (NSString*)centerLabelText:(PlaceSearchModel*)model
{
    NSString *text = @"";
    switch ([model.type integerValue]) {
        case PlaceSearchTypePOI:
        {
            text = [NSString stringWithFormat:@"%@/%@", model.parentname, model.parent_parentname];
            break;
        }
        default:
        {
            text = model.parentname;
            break;
        }
    }
    return text;
}

/**
 *  背景图片点击触发的方法
 */
- (void)backImageClicked
{
    if ([self.delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
        [self.delegate didSelectRowAtIndexPath:self.indexPath];
    }
}

#pragma mark
#pragma mark Super

- (void)dealloc
{
    self.bottomShadowImageView = nil;
    self.imgView = nil;
    self.topLabel = nil;
    self.centerLabel = nil;
    self.bottomLabel = nil;
    self.rightLabel = nil;
    
    [super dealloc];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end
