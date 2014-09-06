//
//  AddGuideCommentCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-24.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "AddGuideCommentCell.h"

@implementation AddGuideCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, 320-8*2, 45)];
        _backView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backView];
        
        
        UIImageView *addCommentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        addCommentImageView.backgroundColor = [UIColor clearColor];
        [addCommentImageView setImage:[UIImage imageNamed:@"btn_addcomments.png"]];
        [self addSubview:addCommentImageView];
        [addCommentImageView release];
        
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
        _backView.backgroundColor = [UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3];
    }
    else
    {
        [self performSelector:@selector(setBackgroundColor) withObject:[UIColor clearColor] afterDelay:0.1];
    }
}
-(void)setBackgroundColor
{
    _backView.backgroundColor = [UIColor clearColor];
}

@end
