//
//  KSMySongsViewController.h
//  KwSing
//
//  Created by 改 熊 on 12-8-16.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "KSViewController.h"

@interface KSMySongsViewController :KSViewController

-(bool)hasSongs;
@end
#pragma mark
#pragma mark MyModalAlertView
@interface MyModalAlertView : UIAlertView
-(int)showModal;
@end

