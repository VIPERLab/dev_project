//
//  RemindCell.h
//  LastMinute
//
//  Created by lide on 13-9-25.
//
//

#import <UIKit/UIKit.h>
#import "Remind.h"

#define RemindCellHeight   150.0f-9

@interface RemindCell : UITableViewCell
{
    UIImageView     *_backgroundImageView;
    UIImageView     *_iconImageView;
    UILabel         *_titleLabel;
    UIImageView     *_lineImageView;
    UILabel         *_typeLabel;
    UILabel         *_timeLabel;
    UILabel         *_startPositionLabel;
    UILabel         *_locationLabel;
    
    Remind          *_remind;
}

@property (retain, nonatomic) Remind *remind;

@end
