//
//  TravelSubjectTableViewCell.h
//  QYER
//
//  Created by chenguanglin on 14-7-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TravelSubjectModel;
@interface TravelSubjectTableViewCell : UITableViewCell

@property (nonatomic, strong) TravelSubjectModel *TSModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
