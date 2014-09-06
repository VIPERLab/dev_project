//
//  CollectionCell.m
//  LastMinute
//
//  Created by lide on 13-8-12.
//
//

#import "CollectionCell.h"

@implementation CollectionCell

@synthesize lastMinute = _lastMinute;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 66)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
//        _backgroundImageView.image = [[UIImage imageNamed:@"x_cell_only.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];//[[UIImage imageNamed:@"bg_collect_cell.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:30];
        [self.contentView addSubview:_backgroundImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 13, 260, 18)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _titleLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0f];
//        _titleLabel.text = @"雅高集团亚太区酒店限时抢购亚太区酒店...";//TEST
        [self.contentView addSubview:_titleLabel];
        
        _prefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 43, 20, 13)];
        _prefixLabel.backgroundColor = [UIColor clearColor];
        _prefixLabel.textColor = [UIColor colorWithRed:158.0 / 255.0 green:163.0 / 255.0 blue:171.0 / 255.0 alpha:1.0];
        _prefixLabel.font = [UIFont systemFontOfSize:11.0f];
        [self.contentView addSubview:_prefixLabel];
        
        UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
        if(font == nil)
        {
            font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15.0];
        }
        
        CGSize fontSize = [@"888" sizeWithFont:font forWidth:200 lineBreakMode:NSLineBreakByWordWrapping];
        
        if(ios7)
        {
            _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 56 - fontSize.height, 20, fontSize.height)];
        }
        else
        {
            _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 63 - fontSize.height, 20, fontSize.height)];
        }
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor colorWithRed:249.0/255.0f green:115.0/255.0f blue:115.0/255.0f alpha:1.0f];//[UIColor colorWithRed:242.0 / 255.0 green:100.0 / 255.0 blue:38.0 / 255.0 alpha:1.0];
        
        _priceLabel.font = font;
//        _priceLabel.text = @"1300";//Test
        [self.contentView addSubview:_priceLabel];
        
        _suffixLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 43, 20, 13)];
        _suffixLabel.backgroundColor = [UIColor clearColor];
        _suffixLabel.textColor = [UIColor colorWithRed:158.0 / 255.0 green:163.0 / 255.0 blue:171.0 / 255.0 alpha:1.0];
        _suffixLabel.font = [UIFont systemFontOfSize:11.0f];
//        _suffixLabel.text = @"元起";//Test
        [self.contentView addSubview:_suffixLabel];
        
        _iconTime = [[UIImageView alloc] initWithFrame:CGRectMake(187, 41+2, 13, 13)];
        _iconTime.backgroundColor = [UIColor clearColor];
        _iconTime.image = [UIImage imageNamed:@"myLastMin_time_icon.png"];
        [_backgroundImageView addSubview:_iconTime];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(192+9, 43, 80, 13)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor colorWithRed:158.0 / 255.0 green:163.0 / 255.0 blue:171.0 / 255.0 alpha:1.0];
        _timeLabel.font = [UIFont systemFontOfSize:11.0f];
        _timeLabel.textAlignment = NSTextAlignmentRight;
//        _timeLabel.text = @"3天8小时过期";//Test
        [_backgroundImageView addSubview:_timeLabel];
        
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320-24, 21, 24, 24)];
        _arrowImageView.backgroundColor = [UIColor clearColor];
        _arrowImageView.image = [UIImage imageNamed:@"myLastMin_arrow.png"];//arrow.png
        [self.contentView addSubview:_arrowImageView];
        
        //分割线
        UIImageView *seperateLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, CollectionCellHeight-1, 320-10, 1)];
        seperateLine.image = [[UIImage imageNamed:@"myLastMin_horizontal_line.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        [self.contentView addSubview:seperateLine];
        [seperateLine release];
    }
    return self;
}

- (void)setLastMinute:(LastMinute *)lastMinute
{
    if(_lastMinute)
    {
        QY_SAFE_RELEASE(_lastMinute);
    }
    
    _lastMinute = [lastMinute retain];
    
    _titleLabel.text = lastMinute.str_title;
    
    NSString *string = _lastMinute.str_price;
    
    NSArray *array = [string componentsSeparatedByString:@"<em>"];
    
    if([array count] > 1)
    {
        CGFloat offsetX = 0;
        CGSize prefixSize = [(NSString *)[array objectAtIndex:0] sizeWithFont:[UIFont systemFontOfSize:11.0f] constrainedToSize:CGSizeMake(200, 200) lineBreakMode:NSLineBreakByWordWrapping];
        _prefixLabel.frame = CGRectMake(19, 43, prefixSize.width, 13);
        _prefixLabel.text = [array objectAtIndex:0];
        offsetX += prefixSize.width + _prefixLabel.frame.origin.x;
        
        NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];
        
        UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
        if(font == nil)
        {
            font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15.0];
        }
        
        CGSize priceSize = [(NSString *)[anotherArray objectAtIndex:0] sizeWithFont:font constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByWordWrapping];
        _priceLabel.frame = CGRectMake(offsetX, _priceLabel.frame.origin.y, priceSize.width, _priceLabel.frame.size.height);
        _priceLabel.text = [anotherArray objectAtIndex:0];
        offsetX += priceSize.width;
        
        if([anotherArray count] > 1)
        {
            CGSize suffixSize = [(NSString *)[anotherArray objectAtIndex:1] sizeWithFont:[UIFont systemFontOfSize:11.0f] constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByWordWrapping];
            _suffixLabel.frame = CGRectMake(offsetX, 43, suffixSize.width, 13);
            _suffixLabel.text = [anotherArray objectAtIndex:1];
        }
    }
    else
    {
        _priceLabel.text = _lastMinute.str_price;
        CGSize priceSize = [_priceLabel.text sizeWithFont:_priceLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _priceLabel.frame.size.height) lineBreakMode:_priceLabel.lineBreakMode];
        CGRect frame = _priceLabel.frame;
        frame.size.width = priceSize.width;
        _priceLabel.frame = frame;
    }
    
    _timeLabel.text = lastMinute.str_end_date;
    
    CGSize timeSize = [_timeLabel.text sizeWithFont:[UIFont systemFontOfSize:11.0f] forWidth:200 lineBreakMode:NSLineBreakByWordWrapping];
    _timeLabel.frame = CGRectMake(_timeLabel.frame.origin.x - timeSize.width + _timeLabel.frame.size.width, _timeLabel.frame.origin.y, timeSize.width, _timeLabel.frame.size.height);
    _iconTime.frame = CGRectMake(_timeLabel.frame.origin.x - _iconTime.frame.size.width + 5 - 9, _iconTime.frame.origin.y, _iconTime.frame.size.width, _iconTime.frame.size.height);
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
        _backgroundImageView.image = [[UIImage imageNamed:@"x_cell_only_highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];
    }
    else
    {
        _backgroundImageView.image = [[UIImage imageNamed:@"x_cell_only.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    
    [super willTransitionToState:state];
    
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        
        for (UIView *subview in self.subviews) {
            
            if(ios7)
            {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl_Legacy"]) {
                    
                    subview.hidden = YES;
                    subview.alpha = 0.0;
                }
            }
            else
            {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                    
                    subview.hidden = YES;
                    subview.alpha = 0.0;
                }
            }
        }
    }
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    
    [super didTransitionToState:state];
    
    if (state == UITableViewCellStateShowingDeleteConfirmationMask || state == UITableViewCellStateDefaultMask) {
        for (UIView *subview in self.subviews) {
            
            if(ios7)
            {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl_Legacy"]) {
                    
                    UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
                    CGRect f = deleteButtonView.frame;
                    f.origin.x -= 14;
                    f.origin.y -= 6;
                    deleteButtonView.frame = f;
                    
                    subview.hidden = NO;
                    
                    [UIView beginAnimations:@"anim" context:nil];
                    subview.alpha = 1.0;
                    [UIView commitAnimations];
                }
            }
            else
            {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                    
                    UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
                    CGRect f = deleteButtonView.frame;
                    f.origin.x -= 14;
                    f.origin.y -= 6;
                    deleteButtonView.frame = f;
                    
                    subview.hidden = NO;
                    
                    [UIView beginAnimations:@"anim" context:nil];
                    subview.alpha = 1.0;
                    [UIView commitAnimations];
                }
            }
        }
    }
}

@end
