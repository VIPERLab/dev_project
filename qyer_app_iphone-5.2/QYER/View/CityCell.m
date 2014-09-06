//
//  CityCell.m
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CityCell.h"
#import "UIImageView+WebCache.h"
#import "CityList.h"

@implementation CityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.backImage = [[[UIImageView alloc]initWithFrame:CGRectMake(7, 10, UIWidth-14, 78)] autorelease];
        self.backImage.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backImage];
        
        self.iconImage = [[[UIImageView alloc]initWithFrame:CGRectMake(3, 0, 100, 67)] autorelease];
        self.iconImage.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImage.clipsToBounds = YES;
        [self.backImage addSubview:self.iconImage];
        
        self.hotImage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 49, 20)] autorelease];
        self.hotImage.image = [UIImage imageNamed:@"city_hot.png"];
        [self.backImage addSubview:self.hotImage];
        
        self.titleLbl = [[[UILabel alloc]initWithFrame:CGRectMake(110, 0, 170, 18)] autorelease];
        self.titleLbl.font = [UIFont fontWithName:Default_Font size:15.0];//[UIFont systemFontOfSize:15.0];
        self.titleLbl.textColor = RGB(68, 68, 68);
        self.titleLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.titleLbl];
        
        if (!IS_IOS7) {
            self.titleLbl.frame = CGRectMake(110, 0, 170, 23);
        }
        
        self.willLbl = [[[UILabel alloc]initWithFrame:CGRectMake(110, 22, 180, 18)] autorelease];
        self.willLbl.font = [UIFont fontWithName:Default_Font size:12.0];//[UIFont systemFontOfSize:12.0];
        self.willLbl.textColor = RGB(188, 188, 188);
        self.willLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.willLbl];
        
        
        
        self.infoLbl = [[[UILabel alloc]initWithFrame:CGRectMake(110, 38, 190, 36)] autorelease];
        self.infoLbl.font = [UIFont fontWithName:Default_Font size:12.0];//[UIFont systemFontOfSize:12.0];
        self.infoLbl.numberOfLines = 2;
        self.infoLbl.backgroundColor = [UIColor clearColor];
        self.infoLbl.textColor = RGB(188, 188, 188);
        self.infoLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.infoLbl];
        
        
        
        
        
        UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 87, UIWidth-20, 0.5)];
        lineImageView.backgroundColor = RGB(205, 205, 205);
        [self addSubview:lineImageView];
        [lineImageView release];
        
        self.back_click_view = [[[UIView alloc]initWithFrame:CGRectMake(0, -2, UIWidth, 90)] autorelease];
        self.back_click_view.alpha = 0.1;
        self.back_click_view.backgroundColor = [UIColor blackColor];
        self.back_click_view.hidden = YES;
        [self addSubview:self.back_click_view];
    }
    return self;
}

//************ Insert By ZhangDong 2014.4.1 Start ***********
/**
 *  配置单元格
 *
 *  @param cityList 当前单元格数据
 */
- (void)configData:(CityList *)cityList
{
    [self.iconImage setImage:nil];
    [self.titleLbl setText:nil];
    [self.hotImage setImage:nil];
    [self.willLbl setText:nil];
    [self.infoLbl setText:nil];
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:cityList.str_photo] placeholderImage:[UIImage imageNamed:@"default_ls_back.png"]];
    self.titleLbl.text = cityList.str_catename;
    self.hotImage.alpha = [cityList.str_ishot integerValue];
    self.willLbl.text =  cityList.beenstr;
    
    NSLog(@"+++++++++++   %@    ++++++++++++++++",cityList.representative);
    
    if (cityList.representative.length>1){
        self.infoLbl.text = [NSString stringWithFormat:@"代表景点：%@", cityList.representative];
    }
}

//************ Insert By ZhangDong 2014.4.1 End ***********

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
