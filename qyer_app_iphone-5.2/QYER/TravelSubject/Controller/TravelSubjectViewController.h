//
//  TravelSubjectViewController.h
//  QYER
//
//  Created by chenguanglin on 14-7-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
#import "LoadMoreView.h"

@interface TravelSubjectViewController : QYBaseViewController
/**
 *  类型
 */
@property (nonatomic, copy) NSString *type;
/**
 *  ID
 */
@property (nonatomic, copy) NSString *ID;

@end
