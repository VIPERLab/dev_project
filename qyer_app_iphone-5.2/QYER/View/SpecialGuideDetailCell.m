//
//  GuideDetailCell.m
//  QyGuide
//
//  Created by an qing on 12-12-31.
//
//

#import "SpecialGuideDetailCell.h"




@implementation SpecialGuideDetailCell
@synthesize titleDetailLabel = _titleDetailLabel;
@synthesize contentLabel = _contentLabel;
@synthesize backGroundView;




-(void)dealloc
{
    [_titleDetailLabel removeFromSuperview];
    [_titleDetailLabel release];
    [_contentLabel removeFromSuperview];
    [_contentLabel release];
    [backGroundView removeFromSuperview];
    [backGroundView release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        backGroundView = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_SpecialGuideDetailCell, 0, 320-2*positionX_SpecialGuideDetailCell, 2)];
        backGroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:backGroundView];
        
        
        _titleDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(SpecialGuideDetailCell_titleDetailLabel_positionX+positionX_content_SpecialGuideDetailCell, SpecialGuideDetailCell_titleDetailLabel_positionY, SpecialGuideDetailCell_titleDetailLabel_sizeW-positionX_content_SpecialGuideDetailCell*2, SpecialGuideDetailCell_titleDetailLabel_height)];
        _titleDetailLabel.textColor = [UIColor blackColor];
        _titleDetailLabel.font = [UIFont systemFontOfSize:16];
        if(ios7)
        {
            _titleDetailLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:16];
        }
        _titleDetailLabel.backgroundColor = [UIColor clearColor];
        _titleDetailLabel.shadowColor = [UIColor whiteColor];
        _titleDetailLabel.shadowOffset = CGSizeMake(0, -0.2);
        [self addSubview:_titleDetailLabel];
        
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(SpecialGuideDetailCell_titleDetailLabel_positionX+positionX_content_SpecialGuideDetailCell, _titleDetailLabel.frame.size.height+_titleDetailLabel.frame.origin.y + SpecialGuideDetailCell_contentLabel_positionInterval, SpecialGuideDetailCell_contentLabel_sizeW, 10)];
        _contentLabel.numberOfLines = 0;
        _contentLabel.backgroundColor = [UIColor clearColor];
        if(ios7)
        {
            _contentLabel.font  = [UIFont systemFontOfSize:SpecialGuideDetailCell_titleDetailLabel_font];
        }
        else
        {
            _contentLabel.font  = [UIFont fontWithName:@"HiraKakuProN-W3" size:SpecialGuideDetailCell_titleDetailLabel_font];
        }
        _contentLabel.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1];
        _titleDetailLabel.shadowColor = [UIColor whiteColor];
        _titleDetailLabel.shadowOffset = CGSizeMake(0, -0.2);
        [self addSubview:_contentLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
