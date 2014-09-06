//
//  TravelSubjectTableViewCell.m
//  QYER
//
//  Created by chenguanglin on 14-7-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "TravelSubjectTableViewCell.h"
#import "TravelSubjectModel.h"
#import "UIImage+resize.h"
#import "UIImageView+WebCache.h"

@interface TravelSubjectTableViewCell()


@property (nonatomic, strong) UIImageView *userIconView;

@property (nonatomic, strong) UIImageView *topImageView;

@property (nonatomic, strong) UILabel *titleLable;

@property (nonatomic, strong) UILabel *userNameLable;

@property (nonatomic, strong) UILabel *detailLable;

@property (nonatomic, strong) UIButton *placeNumButton;

@end

@implementation TravelSubjectTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell_TravelSubjectList";
    TravelSubjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[TravelSubjectTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        //初始化cell页面
        [self setupCellView];
        
    }
    return self;
}
/**
 *  初始化cell页面
 */
- (void)setupCellView
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //图片
    _topImageView = [[UIImageView alloc] init];
    _topImageView.userInteractionEnabled = YES;
    CGFloat topImageViewW = self.contentView.bounds.size.width;
    CGFloat topImageViewH = 160;
    _topImageView.frame = CGRectMake(0, 0, topImageViewW, topImageViewH);
    _topImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_topImageView];
    
    //阴影
    CGFloat shadeImageH = 80;
    UIImageView *shadeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, topImageViewH - shadeImageH, topImageViewW, shadeImageH)];
    shadeImage.backgroundColor = [UIColor clearColor];
    shadeImage.userInteractionEnabled = YES;
    shadeImage.image = [UIImage imageNamed:@"shade_微锦囊"];
    [_topImageView addSubview:shadeImage];
    
    //旅行地数量
    CGFloat placeW = 80;
    CGFloat placeH = 20;
    CGFloat placeX = topImageViewW - 10 - placeW;
    CGFloat placeY = 10;
    _placeNumButton = [[UIButton alloc] init];
    _placeNumButton.userInteractionEnabled = NO;
    _placeNumButton.frame = CGRectMake(placeX, placeY, placeW, placeH);
    _placeNumButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_placeNumButton setBackgroundImage:[UIImage resizedImageWithName:@"bg_旅行地"] forState:UIControlStateNormal];
    [_topImageView addSubview:_placeNumButton];
    
    //用户头像
    _userIconView = [[UIImageView alloc] init];
    _userIconView.backgroundColor = [UIColor clearColor];
    
    CGFloat userIconW = 40;
    CGFloat userIconH = 40;
    CGFloat userIconX = 10;
    CGFloat userIconY = topImageViewH - 10 - userIconH;
    _userIconView.frame = CGRectMake(userIconX, userIconY, userIconW, userIconH);
    _userIconView.layer.cornerRadius = userIconW / 2;
    _userIconView.layer.masksToBounds = YES;
    _userIconView.clipsToBounds = YES;
    [_topImageView addSubview:_userIconView];
    
    //标题
    _titleLable = [[UILabel alloc] init];
    CGFloat titleX = userIconX + userIconW + 10;
    CGFloat titleY = userIconY;
    CGFloat titleW = topImageViewW - titleX - 2;
    CGFloat titleH = 17;
    _titleLable.frame = CGRectMake(titleX, titleY, titleW, titleH);
    _titleLable.font = [UIFont systemFontOfSize:17];
    _titleLable.textColor = [UIColor whiteColor];
    _titleLable.shadowOffset = CGSizeMake(0, 1);
    _titleLable.backgroundColor = [UIColor clearColor];
    [_topImageView addSubview:_titleLable];
    
    //用户名
    _userNameLable = [[UILabel alloc] init];
    CGFloat userNameX = titleX;
    CGFloat userNameY = titleY + titleH + 10;
    CGFloat userNameW = titleW;
    CGFloat userNameH = 13;
    _userNameLable.frame = CGRectMake(userNameX, userNameY, userNameW, userNameH);
    _userNameLable.font = [UIFont systemFontOfSize:12];
    _userNameLable.backgroundColor = [UIColor clearColor];
    _userNameLable.textColor = [UIColor whiteColor];
    _userNameLable.shadowOffset = CGSizeMake(0, 1);
    [_topImageView addSubview:_userNameLable];
    
    //简介
    _detailLable = [[UILabel alloc] init];
    _detailLable.textColor = RGB(68, 68, 68);
    _detailLable.font = [UIFont systemFontOfSize:14];
    _detailLable.numberOfLines = 3;
    [self.contentView addSubview:_detailLable];
    
    //分割线
    UIImageView *line = [[UIImageView alloc] init];
    line.image = [UIImage imageNamed:@"line1"];
    line.frame = CGRectMake(0, 248, topImageViewW, 1);
    [self.contentView addSubview:line];
}
/**
 *  数据模型的set方法
 */
- (void)setTSModel:(TravelSubjectModel *)TSModel
{
    _TSModel = TSModel;
    
    _titleLable.text = TSModel.title;
    _userNameLable.text = TSModel.userName;
    [_userIconView setImageWithURL:[NSURL URLWithString:TSModel.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    [_topImageView setImageWithURL:[NSURL URLWithString:TSModel.photo]];
    
    NSString *placeNumString = [NSString stringWithFormat:@"%@个旅行地",TSModel.count];
    [_placeNumButton setTitle:placeNumString forState:UIControlStateNormal];
    CGSize placeSize = [placeNumString sizeWithFont:_placeNumButton.titleLabel.font constrainedToSize:CGSizeMake(100, 10) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat placeW = placeSize.width + 20;
    CGFloat placeX = self.topImageView.bounds.size.width - 10 - placeW;
    CGFloat placeY = 10;
    _placeNumButton.frame = CGRectMake(placeX, placeY, placeSize.width + 20, placeSize.height);
    
    self.detailLable.text = TSModel.description;
    CGSize detailSize = [TSModel.description sizeWithFont:_detailLable.font constrainedToSize:CGSizeMake(300, 80) lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat detailX = _userIconView.frame.origin.x;
    CGFloat detailY = _topImageView.bounds.size.height + 14;
    CGFloat detailW = detailSize.width;
    CGFloat detailH = detailSize.height;
    _detailLable.frame = CGRectMake(detailX, detailY, detailW, detailH);
    CGFloat lineSpace = 5;//行间距
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:TSModel.description];
    NSMutableParagraphStyle *paragraghStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraghStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraghStyle range:NSMakeRange(0, TSModel.description.length)];
    _detailLable.attributedText = attributedString;
    _detailLable.lineBreakMode = NSLineBreakByTruncatingTail;
    [_detailLable sizeToFit];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
