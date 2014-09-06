//
//  QyerAppNotificationTableViewCell.m
//  QYER
//
//  Created by Qyer on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QyerAppNotificationTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UserInfo.h"
#import "UserInfoData.h"
#import "QyYhConst.h"
#define image_origin_x 8
#define image_origin_y 12
#define image_width    98/2
#define label__origin_y    15
#define label_width    230
#define label_height    15

@implementation QyerAppNotificationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        backview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        backview.backgroundColor=[UIColor whiteColor];
        
        [self.contentView addSubview:backview];
        
        
        _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(image_origin_x,image_origin_y,image_width,image_width)];
        
        _userIconView.layer.cornerRadius = 25.0f;
        _userIconView.layer.masksToBounds = YES;
        _userIconView.image=[UIImage imageNamed:@"famale"];
        [self addSubview:_userIconView];
        
        
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(image_origin_x+image_width+10,label__origin_y,label_width,label_height)];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.font = [UIFont systemFontOfSize:13.0];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0  blue:68.0/255.0  alpha:1.0];
        _messageLabel.shadowColor = [UIColor whiteColor];
        _messageLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:_messageLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_messageLabel.frame.origin.x,_messageLabel.frame.origin.y+_messageLabel.frame.size.height,label_width,label_height)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12.0];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.textColor = [UIColor colorWithRed:158.0/255.0 green:163.0/255.0  blue:171.0/255.0  alpha:1.0];
        [self addSubview:_timeLabel];
        
        lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 63.5, self.frame.size.width-10, 0.5)];
        lineImageView.backgroundColor = RGB(224, 224, 224);
        [self addSubview:lineImageView];
        [lineImageView release];
    }
    return self;
}

- (void)updateWithGuide:(QyerAppNotification *)_notifition{
    
    if (_notifition) {
        
        
        
        float height = [QyerAppNotificationTableViewCell calculateLabelHeightWithString:_notifition.message];
        CGRect backrect = backview.frame;
        backrect.size.height = height;
        backview.frame = backrect;
        
        CGRect lineFrame = lineImageView.frame;
        lineFrame.origin.y = height + 49.5;
        lineImageView.frame = lineFrame;
        
        //        _userNameLabel.text = _comment.userName;
        
        NSDate *lastUpdate = [NSDate dateWithTimeIntervalSince1970:[_notifition.publish_time floatValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *formattedDateString = [dateFormatter stringFromDate:lastUpdate];
        _timeLabel.text = formattedDateString;
        
        [dateFormatter release];
        
        
        NSString *strMessage = [_notifition.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        CGRect rect = _messageLabel.frame;
        rect.size.height = height;
        
        _messageLabel.frame = rect;
        _messageLabel.text = strMessage;
        
        
        
       CGRect rectTime = _timeLabel.frame;
        rectTime.origin.y = rect.origin.y + rect.size.height + 10;
         _timeLabel.frame = rectTime;
        
        [_userIconView setImageWithURL:[NSURL URLWithString:_notifition.object_photo]];
        
        
        
    }
    
    
    
}




+(CGFloat)calculateLabelHeightWithString:(NSString  *)string{
    CGSize size = CGSizeZero;
    if (string&&string.length!=0) {
        size = [string sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(label_width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    CGFloat contantLabelHeight = MAX(size.height, 20);//最小为20
    
    
    return contantLabelHeight;
}

+(CGFloat)calculateCellHeightByNotifition:(QyerAppNotification  *)_notifition{
    
    
    CGFloat height=[QyerAppNotificationTableViewCell calculateLabelHeightWithString:_notifition.message];
    
    return MAX(128/2, height+50);
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
