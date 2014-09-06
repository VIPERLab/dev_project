//
//  OceaniaCell.m
//  QYER
//
//  Created by 我去 on 14-3-27.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "OceaniaCell.h"



#define     OceaniaCell_height     108/2
#define     OceaniaCell_width      142/2


@implementation OceaniaCell
@synthesize label_name = _label_name;
@synthesize imageView_right = _imageView_right;
@synthesize imageView_select = _imageView_select;


-(void)dealloc
{
    self.label_name = nil;
    self.imageView_right = nil;
    self.imageView_select = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        _label_name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, OceaniaCell_width, OceaniaCell_height)];
        _label_name.backgroundColor = [UIColor clearColor];
        _label_name.textAlignment = NSTextAlignmentCenter;
        _label_name.textColor = [UIColor colorWithRed:130/255. green:153/255. blue:165/255. alpha:1];
        _label_name.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _label_name.numberOfLines = 2;
        [self addSubview:_label_name];
        
        
        
        
        
        //单元格底部的线
        UIImageView *_imageView_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(7, OceaniaCell_height-1, OceaniaCell_width-7*2, 1)];
        _imageView_bottom.backgroundColor = [UIColor clearColor];
        _imageView_bottom.image = [UIImage imageNamed:@"cut_off_rule"];
        [self addSubview:_imageView_bottom];
        [_imageView_bottom release];
        
        
        //单元格右侧的线
        _imageView_right = [[UIImageView alloc] initWithFrame:CGRectMake(70, 0, 1, 54)];
        _imageView_right.image = [UIImage imageNamed:@"place_line"];
        [self addSubview:_imageView_right];
        
        
        //当单元格被选中时，右侧的“缺口”
        _imageView_select = [[UIImageView alloc] initWithFrame:CGRectMake(62, 19, 9, 17)];
        _imageView_select.hidden = YES;
        _imageView_select.image = [UIImage imageNamed:@"place_arrow"];
        [self addSubview:_imageView_select];
        
        
    }
    return self;
}

-(void)setSelectedState
{
    _label_name.textColor = [UIColor colorWithRed:22/255. green:22/255. blue:22/255. alpha:1];
}
-(void)setReselectedState
{
    _label_name.textColor = [UIColor colorWithRed:130/255. green:153/255. blue:165/255. alpha:1];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
