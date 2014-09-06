//
//  QyerAppNotificationTableViewCell.h
//  QYER
//
//  Created by Qyer on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QyerAppNotification.h"
@interface QyerAppNotificationTableViewCell : UITableViewCell{
    UILabel *_timeLabel;
    UILabel *_messageLabel;
    
    UIImageView *_userIconView;
    UIView *_iconBackView;
    
    UIView* backview;
    
    /**
     *  分割线
     */
    UIImageView *lineImageView;
}
- (void)updateWithGuide:(QyerAppNotification *)_notifition;

+(CGFloat)calculateLabelHeightWithString:(NSString  *)string;
+(CGFloat)calculateCellHeightByNotifition:(QyerAppNotification  *)_notifition;
@end
