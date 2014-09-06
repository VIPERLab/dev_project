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

@property (nonatomic, strong) UIView *back_click_view;

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
    
    //总的View
    UIView *totalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 249)];
    totalView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:totalView];
    
    
    //图片
    _topImageView = [[UIImageView alloc] init];
    _topImageView.userInteractionEnabled = YES;
    CGFloat topImageViewW = self.contentView.bounds.size.width;
    CGFloat topImageViewH = 160;
    _topImageView.frame = CGRectMake(0, 0, topImageViewW, topImageViewH);
    _topImageView.backgroundColor = [UIColor clearColor];
    _topImageView.contentMode = UIViewContentModeScaleAspectFill;
    _topImageView.clipsToBounds = YES;
    [totalView addSubview:_topImageView];
    
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
    _placeNumButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    [_placeNumButton setBackgroundImage:[UIImage resizedImageWithName:@"bg_旅行地"] forState:UIControlStateNormal];
    [_topImageView addSubview:_placeNumButton];
    
    //用户头像
    CGFloat userIconBackgroundW = 40;
    CGFloat userIconBackgroundH = 40;
    CGFloat userIconBackgroundX = 10;
    CGFloat userIconBackgroundY = topImageViewH - 10 - userIconBackgroundH;
    UIView *userImageBackground = [[UIView alloc] init];
    userImageBackground.frame = CGRectMake(userIconBackgroundX, userIconBackgroundY, userIconBackgroundW, userIconBackgroundH);
    userImageBackground.backgroundColor = [UIColor whiteColor];
    
    userImageBackground.layer.cornerRadius = userIconBackgroundW / 2;
    userImageBackground.layer.masksToBounds = YES;
    userImageBackground.clipsToBounds = YES;
    [_topImageView addSubview:userImageBackground];
    
    _userIconView = [[UIImageView alloc] init];
    _userIconView.backgroundColor = [UIColor clearColor];
    
    CGFloat userIconW = 38;
    CGFloat userIconH = 38;
    CGFloat userIconX = 1;
    CGFloat userIconY = 1;
    _userIconView.frame = CGRectMake(userIconX, userIconY, userIconW, userIconH);
    _userIconView.layer.cornerRadius = userIconW / 2;
    _userIconView.layer.masksToBounds = YES;
    _userIconView.clipsToBounds = YES;
    [userImageBackground addSubview:_userIconView];
    
    //标题
    _titleLable = [[UILabel alloc] init];
    CGFloat titleX = userIconBackgroundX + userIconW + 10;
    CGFloat titleY = userIconBackgroundY + 2;
    CGFloat titleW = topImageViewW - titleX - 2;
    CGFloat titleH = 17;
    _titleLable.frame = CGRectMake(titleX, titleY, titleW, titleH);
    _titleLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:17];
    _titleLable.textColor = [UIColor whiteColor];
    _titleLable.shadowOffset = CGSizeMake(0, 1);
    _titleLable.backgroundColor = [UIColor clearColor];
    [_topImageView addSubview:_titleLable];
    
    //用户名
    _userNameLable = [[UILabel alloc] init];
    CGFloat userNameX = titleX;
    CGFloat userNameY = titleY + titleH + 8;
    CGFloat userNameW = titleW;
    CGFloat userNameH = 13;
    _userNameLable.frame = CGRectMake(userNameX, userNameY, userNameW, userNameH);
    _userNameLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    _userNameLable.backgroundColor = [UIColor clearColor];
    _userNameLable.textColor = [UIColor whiteColor];
    _userNameLable.shadowOffset = CGSizeMake(0, 1);
    [_topImageView addSubview:_userNameLable];
    
    //简介
    _detailLable = [[UILabel alloc] init];
    _detailLable.textColor = RGB(68, 68, 68);
    _detailLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    _detailLable.numberOfLines = 3;
    [totalView addSubview:_detailLable];
    
    //底部的分割栏
    UIView *cellFootView = [[UIView alloc] init];
    cellFootView.backgroundColor = RGB(232, 242, 249);
    cellFootView.frame = CGRectMake(0, 239, UIScreenWidth, 10);
    UIImageView *footLine = [[UIImageView alloc] init];
    footLine.image = [UIImage imageNamed:@"line1"];
    footLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
    [cellFootView addSubview:footLine];
    [self.contentView addSubview:cellFootView];
    //高亮状态的遮罩
    _back_click_view = [[UIView alloc]initWithFrame:totalView.bounds];
    _back_click_view.backgroundColor = [UIColor blackColor];
    _back_click_view.alpha = 0.3;
    _back_click_view.hidden = YES;
    [totalView addSubview:_back_click_view];
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
    CGSize detailSize = [TSModel.description sizeWithFont:_detailLable.font constrainedToSize:CGSizeMake(300, 70) lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat detailX = 10;
    CGFloat detailY = _topImageView.bounds.size.height + 9;
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
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    if (highlighted == NO) {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _back_click_view.hidden = YES;

        });

    }else{
        _back_click_view.hidden = NO;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
