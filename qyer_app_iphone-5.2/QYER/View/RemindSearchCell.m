//
//  RemindSearchCell.m
//  LastMinute
//
//  Created by lide on 13-10-15.
//
//

#import "RemindSearchCell.h"

@implementation RemindSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_backgroundImageView];
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
        _backgroundImageView.image = [UIImage imageNamed:@"cell_remind_search.png"];
    }
    else
    {
        _backgroundImageView.image = nil;
    }
}

@end
