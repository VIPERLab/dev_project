//
//  CCActiotSheet.h
//  QYER
//
//  Created by 张伊辉 on 14-5-7.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QyYhConst.h"
#import "QYBaseViewController.h"



@protocol CCActiotSheetDelegate;
@interface CCActiotSheet : UIView
@property (nonatomic, assign) id<CCActiotSheetDelegate>delegate;
- (id)initWithTitle:(NSString *)title andDelegate:(id)delegate andArrayData:(NSArray *)array;
- (void)show;
@end



@protocol CCActiotSheetDelegate <NSObject>
- (void)ccActionSheet:(CCActiotSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
