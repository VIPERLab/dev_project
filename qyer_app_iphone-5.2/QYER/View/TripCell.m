//
//  TripCell.m
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "TripCell.h"

@implementation TripCell

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
        
        
        self.dayImage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 8, 28, 12)] autorelease];
        self.dayImage.image = [UIImage imageNamed:@"trip_tag.png"];
        [self.iconImage addSubview:self.dayImage];
        
        
        self.dayLbl = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 28, 12)] autorelease];
        self.dayLbl.backgroundColor = [UIColor clearColor];
        self.dayLbl.font = [UIFont boldSystemFontOfSize:9.0];
        self.dayLbl.text = @"7天";
        self.dayLbl.textColor = [UIColor whiteColor];
        self.dayLbl.textAlignment = NSTextAlignmentLeft;
        [self.dayImage addSubview:self.dayLbl];
        
        
        self.titleLbl = [[[UILabel alloc]initWithFrame:CGRectMake(120, 11, 170, 18)] autorelease];
        self.titleLbl.numberOfLines = 2;
        self.titleLbl.font = [UIFont boldSystemFontOfSize:15.0];
        self.titleLbl.text = @"泰国美食之旅";
        self.titleLbl.textColor = RGB(68, 68, 68);
        self.titleLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.titleLbl];
        
        self.contentLbl = [[[UILabel alloc]initWithFrame:CGRectMake(120, 34, 170, 36)] autorelease];
        self.contentLbl.font = [UIFont systemFontOfSize:12.0];
        self.contentLbl.text = @"曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷-曼谷";
        self.contentLbl.textColor = RGB(188, 188, 188);
        self.contentLbl.numberOfLines = 2;
        self.contentLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.contentLbl];
        
        self.nameTimeLbl = [[[UILabel alloc]initWithFrame:CGRectMake(120, 73, 170, 18)] autorelease];
        self.nameTimeLbl.font = [UIFont systemFontOfSize:14.0];
        self.nameTimeLbl.text = @"sut_lxm | 2014-01-31";
        self.nameTimeLbl.textColor = RGB(194, 194, 194);
        self.nameTimeLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.nameTimeLbl];

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
