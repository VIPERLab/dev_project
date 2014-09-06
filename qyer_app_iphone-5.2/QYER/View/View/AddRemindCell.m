//
//  AddRemindCell.m
//  LastMinute
//
//  Created by lide on 13-9-25.
//
//

#import "AddRemindCell.h"

@implementation AddRemindCell

@synthesize titleLabel = _titleLabel;
@synthesize typeLabel = _typeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 58)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
//        _backgroundImageView.image = [UIImage imageNamed:@"bg_remind.png"];
        _backgroundImageView.image = [[UIImage imageNamed:@"myLastMin_cell_only.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];
        [self.contentView addSubview:_backgroundImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, 150, 58)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:50.0 / 255.0 green:50.0 / 255.0 blue:50.0 / 255.0 alpha:1.0];
        _titleLabel.text = @"折扣类型";
        [_backgroundImageView addSubview:_titleLabel];
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 175, 58)];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.font = [UIFont systemFontOfSize:13.0f];
        _typeLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0 blue:119.0/255.0 alpha:1.0];
        _typeLabel.textAlignment = NSTextAlignmentRight;
        _typeLabel.text = @"机票";
        [_backgroundImageView addSubview:_typeLabel];
        
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 17, 24, 24)];
        _arrowImageView.backgroundColor = [UIColor clearColor];
        _arrowImageView.image = [UIImage imageNamed:@"myLastMin_arrow.png"];
        [_backgroundImageView addSubview:_arrowImageView];
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
//        _backgroundImageView.image = [UIImage imageNamed:@"bg_remind_highlight.png"];
        _backgroundImageView.image = [[UIImage imageNamed:@"myLastMin_cell_only_highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];
    }
    else
    {
//        _backgroundImageView.image = [UIImage imageNamed:@"bg_remind.png"];
        _backgroundImageView.image = [[UIImage imageNamed:@"myLastMin_cell_only.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];
    }
}

@end
