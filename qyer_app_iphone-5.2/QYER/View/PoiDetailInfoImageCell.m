//
//  PoiDetailInfoImageCell.m
//  QyGuide
//
//  Created by an qing on 13-2-21.
//
//

#import "PoiDetailInfoImageCell.h"


#define poiImageHeight          180 



@implementation PoiDetailInfoImageCell
@synthesize poiImageV = _poiImageV;


-(void)dealloc
{
    [_poiImageV removeFromSuperview];
    [_poiImageV release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _poiImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, poiImageHeight)];
        _poiImageV.backgroundColor = [UIColor clearColor];
        [self addSubview:_poiImageV];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
