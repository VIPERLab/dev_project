//
//  main.m
//  kwbook
//
//  Created by 单 永杰 on 13-11-27.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KBAppDelegate.h"
#include "CAppInit.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        CAppInit::GetInstance()->OnAppStart();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([KBAppDelegate class]));
    }
}
