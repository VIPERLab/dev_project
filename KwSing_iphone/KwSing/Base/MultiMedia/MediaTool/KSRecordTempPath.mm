//
//  KSRecordTempPath.m
//  KwSing
//
//  Created by 永杰 单 on 12-8-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSRecordTempPath.h"
#import "KwDir.h"
//#include <string>

@implementation KSRecordTempPath

+(std::string) getRecordTempPath{
    NSString* record_path = [KwTools::Dir::GetPath(KwTools::Dir::PATH_CASHE) stringByAppendingString:@"/RecordTempPath"];
    BOOL b_is_directory = NO;
    BOOL b_directory_exist = [[NSFileManager defaultManager] fileExistsAtPath:record_path isDirectory:&b_is_directory];
    if (!(b_directory_exist && b_is_directory)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:record_path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [record_path UTF8String];
}

+(std::string) getOrigionSongPath{
    NSString* record_path = [KwTools::Dir::GetPath(KwTools::Dir::PATH_CASHE) stringByAppendingString:@"OrigionSongPath"];
    BOOL b_is_directory = NO;
    BOOL b_directory_exist = [[NSFileManager defaultManager] fileExistsAtPath:record_path isDirectory:&b_is_directory];
    if (!(b_directory_exist && b_is_directory)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:record_path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [record_path UTF8String];
}

@end
