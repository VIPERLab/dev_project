//
//  FileSize.m
//  DownLoadZipFile_withPods
//
//  Created by an qing on 13-4-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "FileSize.h"
#import "FilePath.h"

@implementation FileSize


+(NSNumber*)getSizeOfFile:(NSString*)filePath
{
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        if (ui == FALSE) //如果不是目录
        {
            NSError *error = nil;
            NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
            
            if (error == nil)
            {
                unsigned long long fileSize = 0;
                fileSize =  [fileAttr fileSize];
                
                return [NSNumber numberWithUnsignedLongLong:fileSize];
            }
        }
    }
    return [NSNumber numberWithInt:0];
}

@end
