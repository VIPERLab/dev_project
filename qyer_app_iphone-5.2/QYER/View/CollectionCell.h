//
//  CollectionCell.h
//  LastMinute
//
//  Created by lide on 13-8-12.
//
//

#import <UIKit/UIKit.h>
#import "LastMinute.h"


#define CollectionCellHeight   66.0f  

@interface CollectionCell : UITableViewCell
{
    UIImageView     *_backgroundImageView;
    UILabel         *_titleLabel;
    UILabel         *_prefixLabel;
    UILabel         *_priceLabel;
    UILabel         *_suffixLabel;
    UIImageView     *_iconTime;
    UILabel         *_timeLabel;
    UIImageView     *_arrowImageView;
    
    LastMinute      *_lastMinute;
}

@property (retain, nonatomic) LastMinute *lastMinute;

@end
