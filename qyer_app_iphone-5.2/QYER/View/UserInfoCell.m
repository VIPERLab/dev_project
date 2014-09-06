//
//  UserInfoCell.m
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserInfoCell.h"

#define positionY (ios7 ? 10 : 13)


@implementation UserInfoCell
@synthesize label_title = _label_title;
@synthesize imageView_arrow = _imageView_arrow;


-(void)dealloc
{
    QY_VIEW_RELEASE(_label_title);
    QY_VIEW_RELEASE(_imageView_arrow);
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor whiteColor];
        
        _label_title = [[UILabel alloc] initWithFrame:CGRectMake(10, positionY, 200, 24)];
        _label_title.backgroundColor = [UIColor clearColor];
        _label_title.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        //_label_title.font = [UIFont systemFontOfSize:15];
        _label_title.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        [self addSubview:_label_title];
        
        
        _imageView_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(320-48/2-8, 10, 48/2, 48/2)];
        _imageView_arrow.backgroundColor = [UIColor clearColor];
        _imageView_arrow.image = [UIImage imageNamed:@"arrow"];
        [self addSubview:_imageView_arrow];
        
        
        UIImageView *imageView_bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 43.5, 310, 1)];
        imageView_bottomLine.backgroundColor = [UIColor clearColor];
        imageView_bottomLine.image = [UIImage imageNamed:@"分割线_"];
        [self addSubview:imageView_bottomLine];
        [imageView_bottomLine release];
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted)
    {
        self.backgroundColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.3];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
