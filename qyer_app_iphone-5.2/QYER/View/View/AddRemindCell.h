//
//  AddRemindCell.h
//  LastMinute
//
//  Created by lide on 13-9-25.
//
//

#import <UIKit/UIKit.h>

@interface AddRemindCell : UITableViewCell
{
    UIImageView     *_backgroundImageView;
    UILabel         *_titleLabel;
    UILabel         *_typeLabel;
    UIImageView     *_arrowImageView;
}

@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UILabel *typeLabel;

@end
