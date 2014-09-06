//
//  RemindTypeCell.h
//  LastMinute
//
//  Created by lide on 13-10-11.
//
//

#import <UIKit/UIKit.h>

@interface RemindTypeCell : UITableViewCell
{
    UIImageView         *_backgroundImageView;
    UILabel             *_titleLabel;
    UIImageView         *_checkImageView;
    UIImageView         *_lineImageView;
    UIImageView         *_shadowImageView;
}

@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIImageView *checkImageView;
@property (retain, nonatomic) UIImageView *lineImageView;
@property (retain, nonatomic) UIImageView *shadowImageView;

@end
