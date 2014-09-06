//
//  RemindTypeCell.m
//  LastMinute
//
//  Created by lide on 13-10-11.
//
//

#import "RemindTypeCell.h"

@implementation RemindTypeCell

@synthesize titleLabel = _titleLabel;
@synthesize checkImageView = _checkImageView;
@synthesize lineImageView = _lineImageView;
@synthesize shadowImageView = _shadowImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 0, 302, 44)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.image = [UIImage imageNamed:@"myLastMin_bg_cell_remind.png"];
        [self.contentView addSubview:_backgroundImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 269, 24)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _titleLabel.textColor = [UIColor colorWithRed:50.0 / 255.0 green:50.0 / 255.0 blue:50.0 / 255.0 alpha:1.0];
        [_backgroundImageView addSubview:_titleLabel];
        
        _checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(265, 12, 20, 20)];
        _checkImageView.backgroundColor = [UIColor clearColor];
        _checkImageView.image = [UIImage imageNamed:@"category_selected.png"];
        [_backgroundImageView addSubview:_checkImageView];
        _checkImageView.hidden = YES;
        
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 43, 275, 1)];
        _lineImageView.backgroundColor = [UIColor clearColor];
        _lineImageView.image = [[UIImage imageNamed:@"myLastMin_horizontal_line.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];//[UIImage imageNamed:@"line_cell_remind.png"];
        [_backgroundImageView addSubview:_lineImageView];
        
        _shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 302, 2)];
        _shadowImageView.backgroundColor = [UIColor clearColor];
        _shadowImageView.image = [UIImage imageNamed:@"shadow_cell_remind.png"];
        [_backgroundImageView addSubview:_shadowImageView];
        _shadowImageView.hidden = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted)
    {
        _backgroundImageView.image = [UIImage imageNamed:@"myLastMin_bg_cell_remind_highlight.png"];
    }
    else
    {
        _backgroundImageView.image = [UIImage imageNamed:@"myLastMin_bg_cell_remind.png"];
    }
}

@end
