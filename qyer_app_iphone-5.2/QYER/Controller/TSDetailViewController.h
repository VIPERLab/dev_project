//
//  TSDetailViewController.h
//  TravelSubject
//
//  Created by chenguanglin on 14-7-18.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"

@interface TSDetailViewController : QYBaseViewController
/**
 *  微锦囊的id
 */
@property (nonatomic, copy) NSString *ID;
/**
 *  页面的跳转来源
 */
@property (nonatomic, copy) NSString *source;

@end
