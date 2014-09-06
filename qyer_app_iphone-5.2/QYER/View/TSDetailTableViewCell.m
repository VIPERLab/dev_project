//
//  TSDetailTableViewCell.m
//  TravelSubject
//
//  Created by chenguanglin on 14-7-18.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import "TSDetailTableViewCell.h"
#import "TSDetailCellModel.h"
#import "TSDetailCellFrame.h"
#import "MYStarView.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@interface TSDetailTableViewCell()

@property (nonatomic, strong) UIButton *topImageView;

@property (nonatomic, strong) UILabel *countryNameLable;

@property (nonatomic, strong) UILabel *cityNameLable;

@property (nonatomic, strong) UILabel *titleLable;

@property (nonatomic, strong) MYStarView *starNumView;

@property (nonatomic, strong) UILabel *descriptionLable;

@property (nonatomic, strong) UIView *cellFootView;
@end

@implementation TSDetailTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell_TSDetail";
    TSDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[TSDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        //上部的分割线
        UIImageView *topLine = [[UIImageView alloc] init];
        topLine.image = [UIImage imageNamed:@"line1"];
        topLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
        [self.contentView addSubview:topLine];
        
        //上部图片
        _topImageView = [[UIButton alloc] init];
        _topImageView.backgroundColor = [UIColor clearColor];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topImageView.clipsToBounds = YES;
        CGFloat topImageX = 10;
        CGFloat topImageY = 10;
        CGFloat topImageW = self.contentView.bounds.size.width - topImageX * 2;
        CGFloat topImageH = 140;
        _topImageView.frame = CGRectMake(topImageX, topImageY, topImageW, topImageH);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [_topImageView addGestureRecognizer:tap];
        [self.contentView addSubview:_topImageView];
        
        
        //阴影
        CGFloat shadeImageH = 80;
        UIImageView *shadeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, topImageH - shadeImageH, topImageW, shadeImageH)];
        shadeImage.backgroundColor = [UIColor clearColor];
        shadeImage.image = [UIImage imageNamed:@"shade_微锦囊"];
        [_topImageView addSubview:shadeImage];
        //poi图标
        UIImageView *poiImageView = [[UIImageView alloc] init];
        poiImageView.backgroundColor = [UIColor clearColor];
        poiImageView.image = [UIImage imageNamed:@"poi_微锦囊"];
        CGFloat poiX = 2;
        CGFloat poiY = 95;
        CGFloat poiW = 24;
        CGFloat poiH = 24;
        poiImageView.frame = CGRectMake(poiX, poiY, poiW, poiH);
        [_topImageView addSubview:poiImageView];
        //箭头
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        arrowImageView.backgroundColor = [UIColor clearColor];
        arrowImageView.image = [UIImage imageNamed:@"arrow_微锦囊"];
        CGFloat arrowW = 24;
        CGFloat arrowH = 24;
        CGFloat arrowX = topImageW - arrowW;
        CGFloat arrowY = topImageH - 10 - arrowH;
        arrowImageView.frame = CGRectMake(arrowX, arrowY, arrowW, arrowH);
        [_topImageView addSubview:arrowImageView];
        //标题
        _titleLable = [[UILabel alloc] init];
        _titleLable.backgroundColor = [UIColor clearColor];
        
        _titleLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
        
        _titleLable.textColor = [UIColor whiteColor];
        CGFloat titleX = poiX + poiW;
        CGFloat titleY = poiY;
        CGFloat titleW = 220;
        CGFloat titleH = poiH;
        _titleLable.frame = CGRectMake(titleX, titleY, titleW, titleH);
        [_topImageView addSubview:_titleLable];
        //国家名
        _countryNameLable = [[UILabel alloc] init];
        _countryNameLable.backgroundColor = [UIColor clearColor];
        
        _countryNameLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
        
        _countryNameLable.textColor = [UIColor whiteColor];
        CGFloat countryX = 9;
        CGFloat countryY = poiY + poiH;
        CGFloat countryW = 35;
        CGFloat countryH = 15;
        _countryNameLable.frame = CGRectMake(countryX, countryY, countryW, countryH);
        [_topImageView addSubview:_countryNameLable];
        //城市名
        _cityNameLable = [[UILabel alloc] init];
        _cityNameLable.backgroundColor = [UIColor clearColor];
        
        _cityNameLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
        
        _cityNameLable.textColor = [UIColor whiteColor];
        CGFloat cityX = countryX + countryW;
        CGFloat cityY = countryY;
        CGFloat cityW = 100;
        CGFloat cityH = countryH;
        _cityNameLable.frame = CGRectMake(cityX, cityY, cityW, cityH);
        [_topImageView addSubview:_cityNameLable];
        
        //推荐星级
        UILabel *starTextLable = [[UILabel alloc] init];
        starTextLable.backgroundColor = [UIColor clearColor];
        starTextLable.text = @"推荐星级";
        starTextLable.textColor = RGB(158, 163, 171);
        starTextLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:9];
        CGFloat starLableX = topImageX;
        CGFloat starLableY = topImageY + topImageH + 10;
        CGFloat starLableW = 36;
        CGFloat starLableH = 9;
        starTextLable.frame = CGRectMake(starLableX, starLableY, starLableW, starLableH);
        [self.contentView addSubview:starTextLable];
        
        _starNumView = [[MYStarView alloc] init];
        _starNumView.backgroundColor = [UIColor clearColor];
        _starNumView.starCount = 3;
        CGFloat starViewX = starLableX + starLableW + 10;
        CGFloat starViewY = starLableY - 3;
        CGFloat starViewW = 100;
        CGFloat starViewH = 15;
        _starNumView.frame = CGRectMake(starViewX, starViewY, starViewW, starViewH);
        [self.contentView addSubview:_starNumView];
        //简介
        _descriptionLable = [[UILabel alloc] init];
        _descriptionLable.font = [UIFont systemFontOfSize:14];
        _descriptionLable.backgroundColor = [UIColor clearColor];
        _descriptionLable.numberOfLines = 0;
        _descriptionLable.textColor = RGB(110, 110, 110);
        [self.contentView addSubview:_descriptionLable];
        
        //底部分割view
        _cellFootView = [[UIView alloc] init];
        _cellFootView.backgroundColor = RGB(232, 242, 249);
        _cellFootView.frame = CGRectMake(0, 0, UIScreenWidth, 10);
        UIImageView *footLine = [[UIImageView alloc] init];
        footLine.image = [UIImage imageNamed:@"line1"];
        footLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
        [_cellFootView addSubview:footLine];
        
        [self.contentView addSubview:_cellFootView];
        
    }
    
    return self;
}


- (void)setTSDetailFrame:(TSDetailCellFrame *)TSDetailFrame
{
    _TSDetailFrame = TSDetailFrame;
    
    TSDetailCellModel *detailModel = TSDetailFrame.TSDetailModel;
    
    self.titleLable.text = detailModel.title;
    self.countryNameLable.text = [NSString stringWithFormat:@"%@,",detailModel.countryName];
    self.cityNameLable.text = detailModel.cityName;
    self.starNumView.starCount = detailModel.recommandstar;
    self.descriptionLable.text = detailModel.description;
    [self.topImageView setImageWithURL:[NSURL URLWithString:detailModel.photo] placeholderImage:[UIImage imageNamed:@"default_detail.png"]];
    self.topImageView.tag = [detailModel.ID integerValue];
    
    
    self.countryNameLable.frame = TSDetailFrame.countryNameF;
    self.cityNameLable.frame = TSDetailFrame.cityNameF;
    self.descriptionLable.frame = TSDetailFrame.descriptionF;
    self.cellFootView.frame = TSDetailFrame.cellFootF;

}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(poiClick:)]) {
        
        [self.delegate poiClick:tap.view.tag];
    }
}


@end
