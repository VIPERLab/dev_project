//
//  bannerRootView.m
//  QYER
//
//  Created by chenguanglin on 14-7-11.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "bannerRootView.h"
#import "MayLikeBBSModel.h"
#import "MayLikeMyLastMinModel.h"
#import "MayLikePlaceModel.h"
#import "UIImageView+WebCache.h"

#define ImageWidth 240                  //图片的宽度
#define ImageMargin 10                  //图片间的间距


@interface bannerRootView()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *subTitleLable;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *backImage;
@property (nonatomic, strong) UILabel *titleName;
@property (nonatomic, strong) UILabel *subTitleName;

@property (nonatomic, strong) UIScrollView *mayLikeScrollView;


@property (nonatomic, assign) int scrollViewOffSet;
@property (nonatomic, assign) int lastScrollViewOffSet;
@property (nonatomic, assign) int pageCount;
@property (nonatomic, assign) int currentPage;

@end

@implementation bannerRootView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //大标题
        _titleLable = [[UILabel alloc] init];
        _titleLable.backgroundColor = [UIColor clearColor];
        _titleLable.textColor = [UIColor whiteColor];
        [self addSubview:_titleLable];
        //竖线
        _lineView = [[UIView alloc] init];
        [self addSubview:_lineView];
        //大副标题
        _subTitleLable = [[UILabel alloc] init];
        _subTitleLable.backgroundColor = [UIColor clearColor];
        [self addSubview:_subTitleLable];
        
        //图片的滚动View
        _mayLikeScrollView = [[UIScrollView alloc] init];
        _mayLikeScrollView.backgroundColor = [UIColor clearColor];
        _mayLikeScrollView.showsHorizontalScrollIndicator = NO;
        _mayLikeScrollView.delegate = self;
        _mayLikeScrollView.contentOffset = CGPointMake(-40, 0);
        _mayLikeScrollView.contentInset = UIEdgeInsetsMake(0, 40, 0, 0);
        [self addSubview:_mayLikeScrollView];
        
        self.currentPage = 0;
        self.lastScrollViewOffSet = -40;
        
    }
    return self;
}
/**
 *  目的地模型的set方法
 */
- (void)setMayLikePlaceModelArray:(NSArray *)mayLikePlaceModelArray
{
    CGFloat mayLikeSrollViewH = 155;
    
    _mayLikePlaceModelArray = mayLikePlaceModelArray;
    
    int imageCount = mayLikePlaceModelArray.count;
    _mayLikeScrollView.contentSize = CGSizeMake(ImageWidth * imageCount + (imageCount - 1) * ImageMargin + 40 , mayLikeSrollViewH);
    _mayLikeScrollView.backgroundColor = [UIColor clearColor];
    
    CGFloat mayLikeSrollViewX = 0;
    CGFloat mayLikeSrollViewY = 46;
    CGFloat mayLikeSrollViewW = [UIScreen mainScreen].bounds.size.width;
    
    for (int i = 0; i < imageCount; i++) {
        MayLikePlaceModel *placeMode = [[MayLikePlaceModel alloc] init];
        placeMode = mayLikePlaceModelArray[i];
        
        //背景图片
        UIImageView *backImage = [[UIImageView alloc] init];
        backImage.userInteractionEnabled = YES;
        backImage.backgroundColor = [UIColor whiteColor];
        [backImage setImageWithURL:[NSURL URLWithString:placeMode.photo] placeholderImage:[UIImage imageNamed:@"placeholderImage_微锦囊"]];
        backImage.layer.cornerRadius = 2.0;
        backImage.layer.masksToBounds = YES;
        backImage.contentMode = UIViewContentModeScaleAspectFill;
        backImage.clipsToBounds = YES;
        
        backImage.tag = i;
        UITapGestureRecognizer *placeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(placeTapAction:)];
        [backImage addGestureRecognizer:placeTap];
        
        CGFloat backImageW = 240;
        CGFloat backImageX = i * (backImageW + ImageMargin);
        CGFloat backImageY = 0;
        CGFloat backImageH = mayLikeSrollViewH;
        backImage.frame = CGRectMake(backImageX, backImageY, backImageW, backImageH);
        [_mayLikeScrollView addSubview:backImage];
        
        //阴影遮罩
        CGFloat shadeImageH = 90;
        UIImageView *shadeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, backImageH - shadeImageH, backImageW, shadeImageH)];
        shadeImage.backgroundColor = [UIColor clearColor];
        shadeImage.userInteractionEnabled = YES;
        shadeImage.image = [UIImage imageNamed:@"mayLike_shade"];
        [backImage addSubview:shadeImage];
        
        //英文名
        UIFont *placeNameFont = [UIFont systemFontOfSize:15];
        UILabel *placeName = [[UILabel alloc] init];
        placeName.backgroundColor = [UIColor clearColor];
        placeName.textColor = [UIColor whiteColor];
        placeName.text = placeMode.title;
        placeName.font = placeNameFont;
        CGSize placeNameENSize = [placeName.text sizeWithFont:placeNameFont constrainedToSize:CGSizeMake(238, 24) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat placeNameX = 10;
        CGFloat placeNameW = placeNameENSize.width;
        CGFloat placeNameH = placeNameENSize.height;
        CGFloat placeNameY = backImageH - 10 - placeNameH;
        placeName.frame = CGRectMake(placeNameX, placeNameY, placeNameW, placeNameH);
        placeName.shadowOffset = CGSizeMake(0, 1);
        [backImage addSubview:placeName];
        
    }
    
    _mayLikeScrollView.frame = CGRectMake(mayLikeSrollViewX, mayLikeSrollViewY, mayLikeSrollViewW, mayLikeSrollViewH);
}
/**
 *  游记模型的set方法
 */
- (void)setMayLikeBBSModelArray:(NSArray *)mayLikeBBSModelArray
{
    CGFloat mayLikeSrollViewH = 130;
    
    _mayLikeBBSModelArray = mayLikeBBSModelArray;
    
    int imageCount = mayLikeBBSModelArray.count;
    _mayLikeScrollView.contentSize = CGSizeMake(ImageWidth * imageCount + (imageCount - 1) * ImageMargin + 40 , mayLikeSrollViewH);
    _mayLikeScrollView.backgroundColor = [UIColor clearColor];
    
    CGFloat mayLikeSrollViewX = 0;
    CGFloat mayLikeSrollViewY = 46;
    CGFloat mayLikeSrollViewW = [UIScreen mainScreen].bounds.size.width;
    
    for (int i = 0; i < imageCount; i++) {
        MayLikeBBSModel *BBSMode = [[MayLikeBBSModel alloc] init];
        BBSMode = mayLikeBBSModelArray[i];
        
        //背景图片
        UIImageView *backImage = [[UIImageView alloc] init];
        backImage.userInteractionEnabled = YES;
        backImage.backgroundColor = [UIColor clearColor];
        [backImage setImageWithURL:[NSURL URLWithString:BBSMode.photo] placeholderImage:[UIImage imageNamed:@"placeholderImage_游记"]];
        backImage.layer.cornerRadius = 2.0;
        backImage.layer.masksToBounds = YES;
        backImage.contentMode = UIViewContentModeScaleAspectFill;
        backImage.clipsToBounds = YES;
        
        backImage.tag = i;
        UITapGestureRecognizer *tripTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tripTapAction:)];
        [backImage addGestureRecognizer:tripTap];
        
        
        CGFloat backImageW = 240;
        CGFloat backImageX = i * (backImageW + ImageMargin);
        CGFloat backImageY = 0;
        CGFloat backImageH = mayLikeSrollViewH;
        backImage.frame = CGRectMake(backImageX, backImageY, backImageW, backImageH);
        [_mayLikeScrollView addSubview:backImage];
        
        //阴影遮罩
        CGFloat shadeImageH = 90;
        UIImageView *shadeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, backImageH - shadeImageH, backImageW, shadeImageH)];
        shadeImage.backgroundColor = [UIColor clearColor];
        shadeImage.userInteractionEnabled = YES;
        shadeImage.image = [UIImage imageNamed:@"mayLike_shade"];
        [backImage addSubview:shadeImage];
        
        //游记名
        UIFont *BBSNameFont = [UIFont systemFontOfSize:15];
        UILabel *BBSName = [[UILabel alloc] init];
        BBSName.backgroundColor = [UIColor clearColor];
        BBSName.textColor = [UIColor whiteColor];
        BBSName.text = BBSMode.title;
        BBSName.font = BBSNameFont;
        CGSize placeNameENSize = [BBSName.text sizeWithFont:BBSNameFont constrainedToSize:CGSizeMake(238, 15) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat placeNameENX = 10;
        CGFloat placeNameENW = placeNameENSize.width;
        CGFloat placeNameENH = placeNameENSize.height;
        CGFloat placeNameENY = backImageH - 10 - placeNameENH;
        BBSName.frame = CGRectMake(placeNameENX, placeNameENY, placeNameENW, placeNameENH);
        BBSName.shadowOffset = CGSizeMake(0, 1);
        [backImage addSubview:BBSName];
        
    }
    
    _mayLikeScrollView.frame = CGRectMake(mayLikeSrollViewX, mayLikeSrollViewY, mayLikeSrollViewW, mayLikeSrollViewH);
}
/**
 *  折扣模型的set方法
 */
- (void)setMayLikeMyLastMinModelArray:(NSArray *)mayLikeMyLastMinModelArray
{
    _mayLikeMyLastMinModelArray = mayLikeMyLastMinModelArray;
    CGFloat mayLikeSrollViewH = 239;
    
    int imageCount = mayLikeMyLastMinModelArray.count;
    _mayLikeScrollView.contentSize = CGSizeMake(ImageWidth * imageCount + (imageCount - 1) * ImageMargin + 40 , mayLikeSrollViewH);
    _mayLikeScrollView.backgroundColor = [UIColor clearColor];
    
    CGFloat mayLikeSrollViewX = 0;
    CGFloat mayLikeSrollViewY = 46;
    CGFloat mayLikeSrollViewW = [UIScreen mainScreen].bounds.size.width;
    
    for (int i = 0; i < imageCount; i++) {
        MayLikeMyLastMinModel *myLastMinMode = [[MayLikeMyLastMinModel alloc] init];
        myLastMinMode = mayLikeMyLastMinModelArray[i];
        
        //整体的背景view
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor clearColor];
        CGFloat backViewW = 250;
        CGFloat backViewX = i * backViewW;
        CGFloat backViewY = 0;
        CGFloat backViewH = 239;
        backView.frame = CGRectMake(backViewX, backViewY, backViewW, backViewH);
        [_mayLikeScrollView addSubview:backView];
        
        //整体的View
        UIView *totalView = [[UIView alloc] init];
        totalView.backgroundColor = [UIColor whiteColor];
        totalView.layer.cornerRadius = 2.0;
        totalView.layer.masksToBounds = YES;
        totalView.clipsToBounds = YES;
        
        totalView.tag = i;
        UITapGestureRecognizer *discountTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(discountTapAction:)];
        [totalView addGestureRecognizer:discountTap];
        
        CGFloat totalViewW = 240;
        CGFloat totalViewX = 0;
        CGFloat totalViewY = 0;
        CGFloat totalViewH = 239;
        totalView.frame = CGRectMake(totalViewX, totalViewY, totalViewW, totalViewH);
        [backView addSubview:totalView];
        
        
        //上部图片
        UIImageView *topImageView = [[UIImageView alloc] init];
        topImageView.userInteractionEnabled = YES;
        topImageView.backgroundColor = [UIColor clearColor];
        [topImageView setImageWithURL:[NSURL URLWithString:myLastMinMode.photo] placeholderImage:[UIImage imageNamed:@"placeholderImage_折扣"]];
        topImageView.contentMode = UIViewContentModeScaleAspectFill;
        CGFloat topImageViewW = totalViewW;
        CGFloat topImageViewH = 166;
        topImageView.frame = CGRectMake(0, 0, topImageViewW, topImageViewH);
        [totalView addSubview:topImageView];
        
        //价格标签
        UIImageView *priceBackImage = [[UIImageView alloc] init];
        priceBackImage.backgroundColor = [UIColor clearColor];
        CGFloat priceBackImageW = 85;
        CGFloat priceBackImageH = 25;
        CGFloat priceBackImageX = topImageViewW - priceBackImageW + 5;
        CGFloat priceBackImageY = topImageViewH - 10 - priceBackImageH;
        priceBackImage.frame = CGRectMake(priceBackImageX, priceBackImageY, priceBackImageW, priceBackImageH);
        [backView addSubview:priceBackImage];
        
        UILabel *prefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 171, 30, 13)];
        prefixLabel.backgroundColor = [UIColor clearColor];
        prefixLabel.textColor = [UIColor whiteColor];
        prefixLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        [backView addSubview:prefixLabel];
        UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
        
        CGSize fontSize = [@"888" sizeWithFont:font forWidth:200 lineBreakMode:NSLineBreakByWordWrapping];
        UILabel *priceLabel = [[UILabel alloc] init];
        if(ios7)
        {
            priceLabel.frame = CGRectMake(8, 184 - fontSize.height, 100, fontSize.height);
        }
        else
        {
            priceLabel.frame = CGRectMake(8, 192 - fontSize.height, 100, fontSize.height);
        }
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.textColor = [UIColor whiteColor];
        priceLabel.font = font;
        priceLabel.text = @"4855";
        [backView addSubview:priceLabel];
        
        CGSize size = [@"4855" sizeWithFont:font forWidth:100 lineBreakMode:NSLineBreakByWordWrapping];
        UILabel *suffixLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabel.frame.origin.x + size.width, 171, 30, 13)];
        suffixLabel.backgroundColor = [UIColor clearColor];
        suffixLabel.textColor = [UIColor whiteColor];
        suffixLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        suffixLabel.text = @"元起";
        [backView addSubview:suffixLabel];
        
        NSString *string = myLastMinMode.price;
        if (![string isEqualToString:@""] && string.length >0) {
            
            [priceBackImage setHidden:NO];
            
            NSArray *array = [string componentsSeparatedByString:@"<em>"];
            
            if([array count] > 1)
            {
                //价格前的宽度
                float beforeSizeWidth = 0;
                
                if ([[array objectAtIndex:0]isKindOfClass:[NSString class]] && ![[array objectAtIndex:0]isEqualToString:@""]) {
                    beforeSizeWidth = [(NSString *)[array objectAtIndex:0] sizeWithFont:[UIFont boldSystemFontOfSize:11.0f] constrainedToSize:CGSizeMake(100, 15) lineBreakMode:NSLineBreakByWordWrapping].width + 3;
                }
                
                //价格的宽度
                NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];
                UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
                float priceSizeWidth = [(NSString *)[anotherArray objectAtIndex:0] sizeWithFont:font constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping].width;
                
                //后面的宽度
                float afterSizeWidth = 0;
                if([anotherArray count] > 1)
                {
                    afterSizeWidth = [(NSString *)[anotherArray objectAtIndex:1] sizeWithFont:[UIFont boldSystemFontOfSize:11.0f] constrainedToSize:CGSizeMake(100, 15) lineBreakMode:NSLineBreakByWordWrapping].width +3;
                }
                //全部价格的宽度
                float  totalPriceWidth = beforeSizeWidth + priceSizeWidth + afterSizeWidth;
                
                suffixLabel.frame = CGRectMake(topImageViewW - afterSizeWidth, topImageViewH - 10 - priceBackImageH + 5, afterSizeWidth, 13);
                if([anotherArray count] > 1){
                    suffixLabel.text = [anotherArray objectAtIndex:1];
                    
                }
                [suffixLabel setTextAlignment:NSTextAlignmentRight];
                
                priceLabel.frame = CGRectMake(topImageViewW - afterSizeWidth - priceSizeWidth, topImageViewH - 10 - priceBackImageH, priceSizeWidth, (ios7 ? 20 : 27));
                priceLabel.text = [anotherArray objectAtIndex:0];
                
                prefixLabel.frame = CGRectMake(topImageViewW - totalPriceWidth, topImageViewH - 10 - priceBackImageH + 3, beforeSizeWidth, 13);
                prefixLabel.text = [array objectAtIndex:0];
                [prefixLabel setTextAlignment:NSTextAlignmentLeft];
                
                UIImage * redCardImg = [UIImage imageNamed:@"label"];
                redCardImg = [redCardImg stretchableImageWithLeftCapWidth:10 topCapHeight:5];
                [priceBackImage setFrame:CGRectMake(topImageViewW - totalPriceWidth - 12 + 5, topImageViewH - 10 - priceBackImageH, totalPriceWidth+12, 25)];
                [priceBackImage setImage:redCardImg];
            }
            
            else
            {
                UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
                CGSize priceSize = [myLastMinMode.price sizeWithFont:font constrainedToSize:CGSizeMake(140, 17) lineBreakMode:NSLineBreakByWordWrapping];
                
                priceLabel.text = myLastMinMode.price;
                [priceLabel setFrame:CGRectMake(topImageViewW -priceSize.width, topImageViewH - 10 - priceBackImageH, priceSize.width + 2,(ios7 ? 17 : 24))];
                [priceLabel setTextAlignment:NSTextAlignmentRight];
                
                UIImage * redCardImg = [UIImage imageNamed:@"label"];
                redCardImg = [redCardImg stretchableImageWithLeftCapWidth:10 topCapHeight:5];
                [priceBackImage setFrame:CGRectMake(topImageViewW - priceSize.width + 1, topImageViewH - 10 - priceBackImageH, priceSize.width + 4, 25)];
                [priceBackImage setImage:redCardImg];
            }
        }
        
        else{
            
            [priceBackImage setHidden:YES];
        }
        
        //标题
        UIFont *myLastMinTitleFont = [UIFont systemFontOfSize:14];
        UILabel *myLastMinTitle = [[UILabel alloc] init];
        myLastMinTitle.backgroundColor = [UIColor clearColor];
        myLastMinTitle.text = myLastMinMode.title;
        myLastMinTitle.textColor = RGB(68, 68, 68);
        myLastMinTitle.numberOfLines = 2;
        myLastMinTitle.font = myLastMinTitleFont;
        CGSize myLastMinTitleSize = [myLastMinTitle.text sizeWithFont:myLastMinTitleFont constrainedToSize:CGSizeMake(240, 38) lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat myLastMinTitleW = myLastMinTitleSize.width;
        CGFloat myLastMinTitleH = myLastMinTitleSize.height;
        CGFloat myLastMinTitleX = 10;
        CGFloat myLastMinTitleY = topImageViewH + 5;
        
        myLastMinTitle.frame = CGRectMake(myLastMinTitleX, myLastMinTitleY, myLastMinTitleW, myLastMinTitleH);
        
        CGFloat lineSpace = 5;//行间距
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:myLastMinTitle.text];
        NSMutableParagraphStyle *paragraghStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraghStyle setLineSpacing:lineSpace];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraghStyle range:NSMakeRange(0, myLastMinTitle.text.length)];
        myLastMinTitle.attributedText = attributedString;
        
        [totalView addSubview:myLastMinTitle];
        [myLastMinTitle sizeToFit];
        
        //倒计时图标
        UIImageView *timeIcon = [[UIImageView alloc] init];
        timeIcon.image = [UIImage imageNamed:@"time"];
        timeIcon.backgroundColor = [UIColor clearColor];
        CGFloat timeIconW = 14;
        CGFloat timeIconH = 14;
        CGFloat timeIconX = 10;
        CGFloat timeIconY = totalViewH - 10 - timeIconH;
        timeIcon.frame = CGRectMake(timeIconX, timeIconY, timeIconW, timeIconH);
        [totalView addSubview:timeIcon];
        
        //过期时间
        UILabel *endTime = [[UILabel alloc] init];
        endTime.backgroundColor = [UIColor clearColor];
        endTime.text = myLastMinMode.expire_date;
        endTime.textColor = RGB(158, 163, 171);
        endTime.font = [UIFont systemFontOfSize:14];
        
        CGFloat endTimeX = timeIconX + timeIconW + 5;
        CGFloat endTimeY = timeIconY;
        CGFloat endTimeW = 240;
        CGFloat endTimeH = timeIconH;
        endTime.frame = CGRectMake(endTimeX, endTimeY, endTimeW, endTimeH);
        [totalView addSubview:endTime];
    }

    _mayLikeScrollView.frame = CGRectMake(mayLikeSrollViewX, mayLikeSrollViewY, mayLikeSrollViewW, mayLikeSrollViewH);
}

/**
 *  根据类型设置title以及frame
 *
 *  @param type banner的类型
 */
- (void)setType:(int)type
{
    switch (type) {
        case BannerTypePlace:
            _titleLable.text = @"私藏路线";
            _subTitleLable.text = @"你想走的，必定与众不同";
            _subTitleLable.textColor = RGB(9, 118, 112);
            _lineView.backgroundColor = RGB(9, 118, 112);
            self.backgroundColor = RGB(11, 185, 175);
            break;
        case BannerTypeBBS:
            _titleLable.text = @"心水游记";
            _subTitleLable.text = @"你喜欢的，必定独具匠心";
            _subTitleLable.textColor = RGB(24, 118, 154);
            _lineView.backgroundColor = RGB(24, 118, 154);
            self.backgroundColor = RGB(70, 173, 229);
            break;
        case BannerTypeMyLastMin:
            _titleLable.text = @"独享折扣";
            _subTitleLable.text = @"你选择的，必定独一无二";
            _subTitleLable.textColor = RGB(71, 140, 8);
            _lineView.backgroundColor = RGB(71, 140, 8);
            self.backgroundColor = RGB(114, 199, 96);
            break;
        default:
            break;
    }
    UIFont *titleFont = [UIFont systemFontOfSize:19];
    _titleLable.font = titleFont;
    CGSize titleSize = [_titleLable.text sizeWithFont:titleFont constrainedToSize:CGSizeMake(320, 18) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat titleLableX = 40;
    CGFloat titleLableY = 18;
    CGFloat titleLableW = titleSize.width;
    CGFloat titleLableH = titleSize.height;
    _titleLable.frame = CGRectMake(titleLableX, titleLableY, titleLableW, titleLableH);
    
    CGFloat lineViewX = titleLableX + titleLableW + 6;
    CGFloat lineViewY = 24;
    CGFloat lineViewW = 1;
    CGFloat lineViewH = 14;
    _lineView.frame = CGRectMake(lineViewX, lineViewY, lineViewW, lineViewH);
    
    UIFont *subTitleFont = [UIFont systemFontOfSize:12];
    CGSize subTitleSize = [_subTitleLable.text sizeWithFont:subTitleFont constrainedToSize:CGSizeMake(320, 14) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat subTitleLableX = lineViewX + lineViewW +6;
    CGFloat subTitleLableY = lineViewY ;
    CGFloat subTitleLableW = subTitleSize.width;
    CGFloat subTitleLableH = subTitleSize.height;
    _subTitleLable.font = subTitleFont;
    _subTitleLable.frame = CGRectMake(subTitleLableX, subTitleLableY, subTitleLableW, subTitleLableH);
}

- (void)discountTapAction:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(DiscountClick:)]) {
        
        [self.delegate DiscountClick:[_mayLikeMyLastMinModelArray[tap.view.tag] ID]];
    }
}

- (void)tripTapAction:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(tripClick:)]) {
        
        [self.delegate tripClick:[_mayLikeBBSModelArray[tap.view.tag] view_url]];
    }
}

- (void)placeTapAction:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(placeClick:)]) {
        
        [self.delegate placeClick:[_mayLikePlaceModelArray[tap.view.tag] ID]];
    }
}

#pragma mark -
#pragma mark -----UIScrollView的代理方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.pageCount = (scrollView.contentSize.width - 30) / 250 - 1;
    
    NSLog(@"%d",self.pageCount);
    
    if (decelerate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [scrollView setContentOffset:scrollView.contentOffset animated:YES];
            
            [self local];
        });
    }else{
        [self local];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _scrollViewOffSet = scrollView.contentOffset.x;
}
- (void)local
{
    int distance = _scrollViewOffSet - _lastScrollViewOffSet;
    if (distance > 20) {
        if (_currentPage < _pageCount) {
            _currentPage++;
        }
    }
    if (distance < -20){
        if (_currentPage > 0) {
            _currentPage--;
        }
    }
    
    int offSet = _currentPage * 250 - 40;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [_mayLikeScrollView setContentOffset:CGPointMake(offSet, 0)];
    [UIView commitAnimations];
    
    _lastScrollViewOffSet = _scrollViewOffSet;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
