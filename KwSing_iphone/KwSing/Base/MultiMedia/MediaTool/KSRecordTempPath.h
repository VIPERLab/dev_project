//
//  KSRecordTempPath.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <string>

@interface KSRecordTempPath : NSObject

+(std::string) getRecordTempPath;
+(std::string) getOrigionSongPath;

@end
