//
//  KBAppDelegate.h
//  kwbook
//
//  Created by 单 永杰 on 13-11-27.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+PushAddButton.h"

#define ROOT_NAVI_CONTROLLER    [KBAppDelegate rootNavigationController]

@interface KBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(UINavigationController *)rootNavigationController;

@end
