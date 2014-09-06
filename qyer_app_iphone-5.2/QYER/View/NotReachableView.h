//
//  NotReachableView.h
//  QYER
//
//  Created by Frank on 14-4-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotReachableViewDelegate <NSObject>
- (void)touchesView;
@end

@interface NotReachableView : UIView

@property (nonatomic, assign) id<NotReachableViewDelegate> delegate;
@end

