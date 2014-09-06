//
//  FilePath.m
//  DownLoadZipFile_withPods
//
//  Created by an qing on 13-4-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "FilePath.h"
#import <sys/xattr.h>

@implementation FilePath


-(void)dealloc
{
    sharedFilePath = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- 单例
static FilePath *sharedFilePath = nil;
+(id)sharedFilePath
{
    if (!sharedFilePath)
    {
        //NSLog(@"新申请FilePath");
        sharedFilePath = [[self alloc] init];
    }
    return sharedFilePath;
}


#pragma mark -
#pragma mark --- 对沙盒里的某给定路径添加不进行'iTunes/iCloud备份'属性。
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.1)
    {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success)
        {
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    else
    {
        const char *filePath = [[URL path] fileSystemRepresentation];
        const char *attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}



#pragma mark -
#pragma mark --- 创建文件存储名称和存储的路径
-(BOOL)createFilePath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager ];
    
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[pathURL path],path];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        return 1;
    }
    else
    {
        //NSLog(@"文件目录已存在");
        return 2;
    }
    return -1;
}



#pragma mark -
#pragma mark --- getFilePath
-(NSString *)getSrcPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    return [pathURL path];
}
-(NSString *)getFilePath:(NSString *)pathname
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self getSrcPath],pathname];
    
    BOOL ui;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        return filePath;
    }
    else
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        return filePath;
    }
}
-(NSString *)getMenuFilePath:(NSString *)pathname
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self getSrcPath],pathname];
    
    BOOL ui;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        return filePath;
    }
    else
    {
        return nil;
    }
}
-(NSString *)getTmpZipFilePath:(NSString *)filename
{
    NSString *tmpZipfilePath = [NSString stringWithFormat:@"%@/%@",[self getFilePath:@"file_tmp"],filename];
    
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpZipfilePath isDirectory:&ui])
    {
        return tmpZipfilePath;
    }
    else
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpZipfilePath withIntermediateDirectories:YES attributes:nil error:nil];
        return tmpZipfilePath;
    }
}
-(NSString *)getZipFilePath
{
    NSString *zipfilePath = [self getFilePath:@"file"];
    
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipfilePath isDirectory:&ui])
    {
        return zipfilePath;
    }
    else
    {
        return nil;
    }
}


#pragma mark -
#pragma mark --- getBookMarkPath
+(NSString *)getBookMarkPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/bookmark",[pathURL path]];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *plistPath = [NSString stringWithFormat:@"%@/bookmark.plist",filePath];
    
    return plistPath;
}


#pragma mark -
#pragma mark --- getQYMoreAppPath
+(NSString *)getQYMoreAppPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/QYMoreApp",[pathURL path]];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *plistPath = [NSString stringWithFormat:@"%@/moreapp.plist",filePath];
    
    return plistPath;
}

//********** Insert By ZhangDong 2014.3.31 Start **********
#pragma mark -
#pragma mark --- getAllPlacePath
+ (NSString *)fileFullPathWithPath:(NSString*)pathName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [pathURL path], pathName];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@.plist",filePath, pathName];
    
    return plistPath;
}
//********** Insert By ZhangDong 2014.3.31 End **********

#pragma mark -
#pragma mark --- getQYMoreAppPath
+(NSString *)getQYGuideCategoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/QYGuideCategory",[pathURL path]];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *plistPath = [NSString stringWithFormat:@"%@/category.plist",filePath];
    
    return plistPath;
}


#pragma mark -
#pragma mark --- 获取用户行程的缓存地址
+(NSString *)getUserItineraryPathWithUserId:(NSString *)userid
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/UserItinerary/%@",[pathURL path],userid];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *plistPath = [NSString stringWithFormat:@"%@/UserItinerary.plist",filePath];
    
    return plistPath;
}



#pragma mark -
#pragma mark --- getGuideHtmlPathByGuideName
+(NSString *)getGuideHtmlPathByGuideName:(NSString *)guidename
{
    NSString *file_path = [[FilePath sharedFilePath] getFilePath:@"file"];
    NSString *guideHtml_path = [NSString stringWithFormat:@"%@/%@_html",file_path,guidename];
    return guideHtml_path;
}
+(NSString *)getGuideZipPathByGuideName:(NSString *)guidename
{
    NSString *file_path = [[FilePath sharedFilePath] getFilePath:@"file"];
    NSString *guideZip_path = [NSString stringWithFormat:@"%@/%@.zip",file_path,guidename];
    return guideZip_path;
}



#pragma mark -
#pragma mark --- 更新锦囊之前,将原有已下载的锦囊移动到另外一个目录下 [若更新失败则再挪回去]
+(void)moveDownloadedGuideToAnotherPathWithGuideName:(NSString *)guide_name
{
    NSString *file_path = [self getGuideHtmlPathByGuideName:guide_name];
    NSString *file_path_tmp = [NSString stringWithFormat:@"%@/%@_html",[[FilePath sharedFilePath] getFilePath:@"file_tmp_redownload"],guide_name];
    NSString *file_path_zip = [self getGuideZipPathByGuideName:guide_name];
    NSString *file_path_zip_tmp = [NSString stringWithFormat:@"%@/%@.zip",[[FilePath sharedFilePath] getFilePath:@"file_tmp_redownload"],guide_name];
    if([[NSFileManager defaultManager] fileExistsAtPath:file_path])
    {
        if(![[NSFileManager defaultManager] moveItemAtPath:file_path toPath:file_path_tmp error:nil])
        {
            NSLog(@" 移动'%@'文件失败 ",[NSString stringWithFormat:@"/%@_html",guide_name]);
        }
    }
    else if([[NSFileManager defaultManager] fileExistsAtPath:file_path_zip])
    {
        if(![[NSFileManager defaultManager] moveItemAtPath:file_path_zip toPath:file_path_zip_tmp error:nil])
        {
            NSLog(@" 移动'%@'文件失败 ",[NSString stringWithFormat:@"/%@.zip",guide_name]);
        }
    }
}
+(void)removeGuideToDownloadPathWithGuideName:(NSString *)guide_name
{
    NSString *file_path = [self getGuideHtmlPathByGuideName:guide_name];
    NSString *file_path_tmp = [NSString stringWithFormat:@"%@/%@_html",[[FilePath sharedFilePath] getFilePath:@"file_tmp_redownload"],guide_name];
    NSString *file_path_zip = [self getGuideZipPathByGuideName:guide_name];
    NSString *file_path_zip_tmp = [NSString stringWithFormat:@"%@/%@.zip",[[FilePath sharedFilePath] getFilePath:@"file_tmp_redownload"],guide_name];
    if([[NSFileManager defaultManager] fileExistsAtPath:file_path_tmp])
    {
        if(![[NSFileManager defaultManager] moveItemAtPath:file_path_tmp toPath:file_path error:nil])
        {
            NSLog(@" 移动'%@'文件到下载目录失败 ",[NSString stringWithFormat:@"/%@_html",guide_name]);
        }
    }
    
    else if([[NSFileManager defaultManager] fileExistsAtPath:file_path_zip_tmp])
    {
        if(![[NSFileManager defaultManager] moveItemAtPath:file_path_zip_tmp toPath:file_path_zip error:nil])
        {
            NSLog(@" 移动'%@'文件失败 ",[NSString stringWithFormat:@"/%@.zip",guide_name]);
        }
    }
}
+(BOOL)isExitGuideWithGuideName:(NSString *)guide_name
{
    NSString *file_path_tmp = [NSString stringWithFormat:@"%@/%@_html",[[FilePath sharedFilePath] getFilePath:@"file_tmp_redownload"],guide_name];
    NSString *file_path_zip_tmp = [NSString stringWithFormat:@"%@/%@.zip",[[FilePath sharedFilePath] getFilePath:@"file_tmp_redownload"],guide_name];
    BOOL ui;
    if([[NSFileManager defaultManager] fileExistsAtPath:file_path_tmp isDirectory:&ui])
    {
        return YES;
    }
    else if([[NSFileManager defaultManager] fileExistsAtPath:file_path_zip_tmp isDirectory:&ui])
    {
        return YES;
    }
    
    return NO;
}
+(void)deleteGuideWithGuideName:(NSString *)guide_name
{
    NSString *file_path_tmp = [NSString stringWithFormat:@"%@/%@_html",[[FilePath sharedFilePath] getFilePath:@"file_tmp_redownload"],guide_name];
    NSString *file_path_zip_tmp = [NSString stringWithFormat:@"%@/%@.zip",[[FilePath sharedFilePath] getFilePath:@"file_tmp_redownload"],guide_name];
    if([[NSFileManager defaultManager] fileExistsAtPath:file_path_tmp])
    {
        if(![[NSFileManager defaultManager] removeItemAtPath:file_path_tmp error:nil])
        {
            NSLog(@" 删除'%@'文件失败 ",[NSString stringWithFormat:@"/%@_html",guide_name]);
        }
    }
    else if([[NSFileManager defaultManager] fileExistsAtPath:file_path_zip_tmp])
    {
        if(![[NSFileManager defaultManager] removeItemAtPath:file_path_zip_tmp error:nil])
        {
            NSLog(@" 删除'%@'文件失败 ",[NSString stringWithFormat:@"/%@.zip",guide_name]);
        }
    }
}


@end


