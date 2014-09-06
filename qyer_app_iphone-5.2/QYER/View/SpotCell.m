//
//  SpotCell.m
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import "SpotCell.h"
#import "UIImageView+WebCache.h"
@implementation SpotCell


-(void)dealloc
{
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.backImage = [[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, UIWidth-20, 67)] autorelease];
        self.backImage.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backImage];
        
        self.iconImage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 67)] autorelease];
        self.iconImage.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImage.clipsToBounds = YES;
        [self.backImage addSubview:self.iconImage];
        
        self.hotImage = [[[UIImageView alloc]initWithFrame:CGRectMake(-5, 5, 49, 20)] autorelease];
        self.hotImage.image = [UIImage imageNamed:@"city_hot"];
        [self.backImage addSubview:self.hotImage];
        
        self.titleLbl = [[[UILabel alloc]initWithFrame:CGRectMake(110, 0, 180, 18)] autorelease];
        self.titleLbl.font = [UIFont fontWithName:Default_Font size:15.0];
        self.titleLbl.textColor = RGB(68, 68, 68);
        self.titleLbl.backgroundColor = [UIColor clearColor];
        self.titleLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.titleLbl];
        
        
        self.label_distance = [[[UILabel alloc] initWithFrame:CGRectMake(310-50-10, self.titleLbl.frame.origin.y, 50, 18)] autorelease];
        self.label_distance.font = [UIFont systemFontOfSize:12];
        self.label_distance.backgroundColor = [UIColor clearColor];
        self.label_distance.textAlignment = NSTextAlignmentRight;
        self.label_distance.textColor = RGB(194, 194, 194);
        self.label_distance.adjustsFontSizeToFitWidth = YES;
        [self.backImage addSubview:self.label_distance];
        self.label_distance.alpha = 0;
        
        
        self.willLbl = [[[UILabel alloc]initWithFrame:CGRectMake(110, 24, 180, 18)] autorelease];
        self.willLbl.font = [UIFont fontWithName:Default_Font size:12.0];//[UIFont systemFontOfSize:12.0];
        //self.willLbl.text = @"83%的人会去,28989人去过";
        self.willLbl.textColor = RGB(194, 194, 194);
        self.willLbl.textAlignment = NSTextAlignmentLeft;
        self.willLbl.backgroundColor = [UIColor clearColor];
        [self.backImage addSubview:self.willLbl];
        
        self.rateView = [[[DYRateView alloc] initWithFrame:CGRectMake(110, 49, 67, 12)
                                                  fullStar:[UIImage imageNamed:@"spot_star1"]
                                                 emptyStar:[UIImage imageNamed:@"spot_star2"]] autorelease];
        self.rateView.backgroundColor = [UIColor clearColor];
        self.rateView.alignment = RateViewAlignmentLeft;
        self.rateView.rate = 0.5;
        [self.backImage addSubview:self.rateView];

        
        self.rateLbl = [[[UILabel alloc]initWithFrame:CGRectMake(190, 46, 100, 18)] autorelease];
        self.rateLbl.font = [UIFont fontWithName:Default_Font size:12.0];//[UIFont systemFontOfSize:12.0];
        self.rateLbl.backgroundColor = [UIColor clearColor];
        self.rateLbl.textColor = RGB(194, 194, 194);
        self.rateLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.rateLbl];
      
        if (!IS_IOS7) {
            self.titleLbl.frame = CGRectMake(110, 3, 180, 24);
            self.willLbl.frame = CGRectMake(110, 29, 180, 18);
            self.rateLbl.frame = CGRectMake(190, 50, 100, 18);
        }
        
        self.lineImageView = [[[UIImageView alloc]initWithFrame:CGRectMake(10, 87, UIWidth-20, 0.5)] autorelease];
        self.lineImageView.backgroundColor = RGB(205, 205, 205);
        [self addSubview:self.lineImageView];
        
        
        self.back_click_view = [[[UIView alloc]initWithFrame:CGRectMake(0, -2, UIWidth, 90)] autorelease];
        self.back_click_view.alpha = 0.1;
        self.back_click_view.backgroundColor = [UIColor blackColor];
        self.back_click_view.hidden = YES;
        [self addSubview:self.back_click_view];
    }
    return self;
}
-(void)setNearByPoi:(CityPoi *)data
{
    self.label_distance.alpha = 1;
    self.label_distance.text = data.str_distance;
    self.titleLbl.frame = CGRectMake(110, -4, 140, 25);
    self.rateLbl.frame = CGRectMake(200, 46, 100, 18);
    self.rateLbl.textAlignment = NSTextAlignmentRight;
    self.lineImageView.frame = CGRectMake(10, 87, UIWidth-10, 0.5);
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:data.str_albumCover] placeholderImage:[UIImage imageNamed:@"default_ls_back"]];
    
    //新加
    self.hotImage.alpha = [data.str_hotFlag intValue];
    
    
    self.titleLbl.text = data.str_poiChineseName;
    
    self.rateView.rate = [data.str_comprehensiveRating floatValue]/10;
    
    self.willLbl.text = data.str_wantGo;
    
    
    if ([data.str_comprehensiveEvaluation isEqual:[NSNull null]]||[data.str_comprehensiveEvaluation isKindOfClass:[NSNull class]] || [data.str_comprehensiveEvaluation isEqualToString:@"<null>"]) {
        
        self.rateLbl.text = @"";
    }else{
        self.rateLbl.text = [NSString stringWithFormat:@"综合评分:%@分",data.str_comprehensiveEvaluation];
    }
}
-(void)setCityPoi:(CityPoi *)data{
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:data.str_albumCover] placeholderImage:[UIImage imageNamed:@"default_ls_back"]];
    
    //新加
    self.hotImage.alpha = [data.str_hotFlag intValue];

    
    self.titleLbl.text = data.str_poiChineseName;
    
    self.rateView.rate = [data.str_comprehensiveRating floatValue]/10;
    
    self.willLbl.text = data.str_wantGo;
    

    if ([data.str_comprehensiveEvaluation isEqual:[NSNull null]]||[data.str_comprehensiveEvaluation isKindOfClass:[NSNull class]] || [data.str_comprehensiveEvaluation isEqualToString:@"<null>"]) {
        
        self.rateLbl.text = @"";
    }else{
        self.rateLbl.text = [NSString stringWithFormat:@"综合评分:%@分",data.str_comprehensiveEvaluation];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted == NO) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.back_click_view.hidden = YES;
            
        });
        
    }else{
        self.back_click_view.hidden = NO;
    }
    
    
}
@end
