//
//  VersionUpdate.h
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-14.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionUpdate : NSObject

+(BOOL)isUpdateFilePath;
+(id)sharedVersionUpdate;
+(void)updateFileSystem;
+(void)fixBugAppearWhenVersion5;
+(void)fixBugAppearWhenVersion5WithGuideName:(NSString *)guidename;

@end
