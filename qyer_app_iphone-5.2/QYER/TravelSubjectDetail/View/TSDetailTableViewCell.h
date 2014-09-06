//
//  TSDetailTableViewCell.h
//  TravelSubject
//
//  Created by chenguanglin on 14-7-18.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TSDetailCellFrame;
@interface TSDetailTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) TSDetailCellFrame *TSDetailFrame;
@end
