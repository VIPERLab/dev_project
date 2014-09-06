//
//  CategoryCell.m
//  QYER
//
//  Created by 我去 on 14-3-26.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CategoryCell.h"



@implementation CategoryCell
@synthesize imageView_backGround = _imageView_backGround;
@synthesize label_name = _label_name;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageView_backGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
        _imageView_backGround.backgroundColor = [UIColor redColor];
        [self addSubview:_imageView_backGround];
        
        
        _label_name = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
        _label_name.backgroundColor = [UIColor blueColor];
        [self addSubview:_label_name];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
