//
//  HotelCell.m
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import "HotelCell.h"

@implementation HotelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        // Initialization code
        self.backImage = [[[UIImageView alloc]initWithFrame:CGRectMake(8, 0, UIWidth-16, 96)] autorelease];
        self.backImage.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.backImage];
        
        self.iconImage = [[[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 102, 80)] autorelease];
        self.iconImage.image = [UIImage imageNamed:@"lm_default.png"];
        [self.backImage addSubview:self.iconImage];
        
        self.titleLbl = [[[UILabel alloc]initWithFrame:CGRectMake(120, 11, 170, 18)] autorelease];
        self.titleLbl.font = [UIFont boldSystemFontOfSize:15.0];
        self.titleLbl.text = @"Malee Pattaya 3";
        self.titleLbl.textColor = RGB(68, 68, 68);
        self.titleLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.titleLbl];
        
        self.infoLbl = [[[UILabel alloc]initWithFrame:CGRectMake(120, 35, 180, 18)] autorelease];
        self.infoLbl.font = [UIFont boldSystemFontOfSize:12.0];
        self.infoLbl.text = @"四星级|靠近 圆明园我们的人会不会出现的法搜的水电费是的";
        self.infoLbl.textColor = RGB(188, 188, 188);
        self.infoLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.infoLbl];
        
        
        self.thbLbl = [[[UILabel alloc]initWithFrame:CGRectMake(120, 65, 30, 18)] autorelease];
        self.thbLbl.font = [UIFont systemFontOfSize:13.0];
        self.thbLbl.text = @"THB";
        self.thbLbl.textColor = RGB(68, 68, 68);
        self.thbLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.thbLbl];
        
        
        self.priceLbl = [[[UILabel alloc]initWithFrame:CGRectMake(150, 64, 100, 18)] autorelease];
        self.priceLbl.font = [UIFont systemFontOfSize:21.0];
        self.priceLbl.text = @"350";
        self.priceLbl.textColor = RGB(255, 109, 66);
        self.priceLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.priceLbl];
        
        UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(16, 95, UIWidth-32, 1)];
        lineImageView.backgroundColor = RGB(232, 232, 232);
        [self addSubview:lineImageView];
        [lineImageView release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
