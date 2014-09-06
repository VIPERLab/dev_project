//
//  RemindCell.m
//  LastMinute
//
//  Created by lide on 13-9-25.
//
//

#import "RemindCell.h"

@implementation RemindCell

@synthesize remind = _remind;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 141)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.image = [[UIImage imageNamed:@"myLastMin_cell_only.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];//.image = [[UIImage imageNamed:@"bg_remind.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:20];
        [self.contentView addSubview:_backgroundImageView];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 6, 24, 24)];//CGRectMake(22, 9, 20, 20)
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.image = [UIImage imageNamed:@"myLastMin_icon_remind.png"];
        [self.contentView addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, 7, 200, 24)];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:47.0 / 255.0 green:56.0 / 255.0 blue:67.0 / 255.0 alpha:1.0];
        _titleLabel.text = @"提醒";
        [self.contentView addSubview:_titleLabel];
        
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 35, 302, 1)];
        _lineImageView.backgroundColor = [UIColor clearColor];
        _lineImageView.image = [[UIImage imageNamed:@"myLastMin_horizontal_line.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
//[UIImage imageNamed:@"line_remind.png"];
        [self.contentView addSubview:_lineImageView];
        
        //类型
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 45, 276, 15)];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.font = [UIFont systemFontOfSize:14.0f];
        _typeLabel.textColor = [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0];
        _typeLabel.text = @"类   型：机票";//Test
        [self.contentView addSubview:_typeLabel];
        
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 69, 276, 15)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:14.0f];
        _timeLabel.textColor = [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0];
        _timeLabel.text = @"时   间：2013年8月~2013年10月";//Test
        [self.contentView addSubview:_timeLabel];
        
        //出发地
        _startPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(22-2, 93, 276, 15)];
        _startPositionLabel.backgroundColor = [UIColor clearColor];
        _startPositionLabel.font = [UIFont systemFontOfSize:14.0f];
        _startPositionLabel.textColor = [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0];
        _startPositionLabel.text = @"出发地：泰国";//Test
        [self.contentView addSubview:_startPositionLabel];
        
        //目的地
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(22-2, 117, 276, 15)];
        _locationLabel.backgroundColor = [UIColor clearColor];
        _locationLabel.font = [UIFont systemFontOfSize:14.0f];
        _locationLabel.textColor = [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0];
        _locationLabel.text = @"目的地：泰国";//Test
        [self.contentView addSubview:_locationLabel];
    }
    return self;
}

- (void)setRemind:(Remind *)remind
{
    if(_remind != nil)
    {
        QY_SAFE_RELEASE(_remind);
    }
    
    _remind = [remind retain];
    
    _typeLabel.text = [NSString stringWithFormat:@"类   型：%@", [remind remindType]];
    _timeLabel.text = [NSString stringWithFormat:@"时   间：%@", [remind remindDate]];
    _startPositionLabel.text = [NSString stringWithFormat:@"出发地：%@", [remind remindStartPositon]];
    _locationLabel.text = [NSString stringWithFormat:@"目的地：%@", [remind remindCountry]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
