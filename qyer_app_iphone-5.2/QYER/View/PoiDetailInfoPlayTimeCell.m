//
//  PoiDetailInfoPlayTimeCell.m
//  QyGuide
//
//  Created by an qing on 13-2-22.
//
//

#import "PoiDetailInfoPlayTimeCell.h"


#define  cellHeight             60
#define  playTimeLabelHeight    30




@implementation PoiDetailInfoPlayTimeCell
@synthesize playTimeLabel = _playTimeLabel;
@synthesize playTimeValueLabel = _playTimeValueLabel;
@synthesize commentNumLabel = _commentNumLabel;
@synthesize commentArrowImageV = _commentArrowImageV;


-(void)dealloc
{
    [_playTimeBackBgView release];
    [_playTimeLabel release];
    [_playTimeValueLabel release];
    [_commentBackBgView release];
    [_commentArrowImageV release];
    [_commentNumLabel release];
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        _playTimeBackBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160-1, cellHeight)];
        _playTimeBackBgView.backgroundColor = [UIColor blackColor];
        [self addSubview:_playTimeBackBgView];
        
        _playTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 160-1-10, playTimeLabelHeight)];
        _playTimeLabel.text = @"推荐游玩时间";
        _playTimeLabel.textColor = [UIColor grayColor];
        _playTimeLabel.textAlignment = NSTextAlignmentLeft;
        _playTimeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_playTimeLabel];
        
        _playTimeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, playTimeLabelHeight-10, 160-1-10, playTimeLabelHeight)];
        _playTimeValueLabel.textColor = [UIColor whiteColor];
        _playTimeValueLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_playTimeValueLabel];
        
        
        
        _commentBackBgView = [[UIView alloc] initWithFrame:CGRectMake(162, 0, 160-1, cellHeight)];
        _commentBackBgView.backgroundColor = [UIColor grayColor];
        [self addSubview:_commentBackBgView];
        _commentNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(160+1+10, playTimeLabelHeight-10, 160-1-10, playTimeLabelHeight)];
        _commentNumLabel.textColor = [UIColor whiteColor];
        _commentNumLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_commentNumLabel];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
