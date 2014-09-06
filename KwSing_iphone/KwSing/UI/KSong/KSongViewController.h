//
//  KSKSongViewController.h
//  KwSing
//
//  Created by Qian Hu on 12-8-9.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <string>
#include "AudioEffectType.h"
#include "KSWebView.h"

@interface KSKSongViewController : UIViewController<UIActionSheetDelegate>
-(void)SetRecordId:(std::string) rid Record:(bool)brecord Video:(bool)bvedio;
-(void)SetEmigrated: (bool)bEmigrated : (KSWebView*)emiWebView;
-(void)stopPlay;
@end
