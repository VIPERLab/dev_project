//
//  DownloadingCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-21.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "DownloadingCell.h"

@implementation DownloadingCell
@synthesize label_downloading = _label_downloading;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        UIImageView *imagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_download_runing.png"]];
        imagView.frame = CGRectMake(0, 0, 320, 38);
        [self addSubview:imagView];
        [imagView release];
        
        
        _label_downloading = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 320, 24)];
        _label_downloading.backgroundColor = [UIColor clearColor];
        _label_downloading.textAlignment = NSTextAlignmentCenter;
        _label_downloading.font = [UIFont systemFontOfSize:16.];
        [self addSubview:_label_downloading];
        
    }
    return self;
}

-(void)dealloc
{
    self.label_downloading = nil;
    [super dealloc];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted)
    {
        self.backgroundColor = [UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3];
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
