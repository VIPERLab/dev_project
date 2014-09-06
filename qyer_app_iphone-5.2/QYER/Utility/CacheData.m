//
//  CacheData.m
//  QyGuide
//
//  Created by an qing on 13-3-8.
//
//

#import "CacheData.h"
#import <sys/xattr.h>


#define  NAME_Cache_allGuide        @"QY_allguidedata"
#define  NAME_Cache_downloadGuide   @"QY_downloadguidedata"
#define  NAME_Cache_guideInfo       @"QY_guideDetailInfo"




@implementation CacheData



#pragma mark -
#pragma mark --- 单例
static id sharedCacheData = nil;
+(id)sharedCacheData
{
    if (!sharedCacheData)
    {
        sharedCacheData = [[self alloc] init];
    }
    
    return sharedCacheData;
}

#pragma mark -
#pragma mark --- 缓存数据 ^ ^ ^ ^ ^ ^
-(void)cacheData:(NSArray*)array
{
    NSString *Path = [[self getCachePath] retain];
    NSString *destplist = [NSString stringWithFormat:@"%@/%@.plist",Path,NAME_Cache_allGuide];
    
    
    //这样直接写不行:
    //[dic writeToFile:destplist atomically:YES];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [data writeToFile:destplist atomically:NO];
    
    [Path release];
}
//返回缓存路径
-(NSString*)getCachePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager ];
    
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    
    NSString *plistPath = [NSString stringWithFormat:@"%@/QY_allguide_Cache",[pathURL path]];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return plistPath;
}

#pragma mark -
#pragma mark --- 对沙盒里的某给定路径添加不进行'iTunes/iCloud备份'属性。
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version floatValue] - 5.1 >= 0)
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
        const char* filePath = [[URL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}
+(BOOL)class_addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version floatValue] - 5.1 >= 0)
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
        const char* filePath = [[URL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}


#pragma mark -
#pragma mark --- 缓存数据是否存在 ^ ^ ^ ^ ^ ^
+(BOOL)isFileExist
{
    NSString *Path =[[CacheData sharedCacheData] getCachePath];
    NSString *destplist = [NSString stringWithFormat:@"%@/%@.plist",Path,NAME_Cache_allGuide];
    
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:destplist isDirectory:&ui])
    {
        return 0;
    }
    else
    {
        return 1;
    }
    return 0;
}


#pragma mark -
#pragma mark --- 读取缓存数据 ^ ^ ^ ^ ^ ^
-(NSArray *)getCacheData
{
    NSString *Path =[[self getCachePath] retain];
    NSString *destplist = [NSString stringWithFormat:@"%@/%@.plist",Path,NAME_Cache_allGuide];
    
    NSData *data = [NSData dataWithContentsOfFile:destplist];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [Path release];
    return array;
}



#pragma mark -
#pragma mark --- 通过文件路径来存储或读取数据:
+(void)cacheData:(NSArray *)array toFilePath:(NSString *)filePath
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [data writeToFile:filePath atomically:NO];
}
+(NSArray *)getCacheDataFromFilePath:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return array;
}

//*** 书签:
+(NSDictionary *)getCachedBookmarkFromFilePath:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@" dic---dic : %@",dic);
    
    return dic;
}



#pragma mark -
#pragma mark --- 获取已下载的锦囊:
+(NSArray *)getDownloadedGuideCache
{
    NSURL *pathURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self class_addSkipBackupAttributeToItemAtURL:pathURL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@.plist",[pathURL path],NAME_Cache_downloadGuide];
    
    NSData *data = [NSData dataWithContentsOfFile:plistPath];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return array;
}
+(void)cacheDownloadedGuideData:(NSArray *)array
{
    if(!array)
    {
        return;
    }
    
    NSURL *pathURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self class_addSkipBackupAttributeToItemAtURL:pathURL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@.plist",[pathURL path],NAME_Cache_downloadGuide];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [data writeToFile:plistPath atomically:NO];
}


//*** 缓存锦囊详情页的信息:
+(void)cacheGuideDetailInfoData:(NSDictionary *)dic
{
    NSString *path =[[[CacheData sharedCacheData] getCachePath] retain];
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@.plist",path,NAME_Cache_guideInfo];
    [path release];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [data writeToFile:plistPath atomically:NO];
}

//*** 获取已缓存的锦囊详情页的信息:
+(NSDictionary *)getCachedGuideDetailInfoData
{
    NSString *path =[[[CacheData sharedCacheData] getCachePath] retain];
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@.plist",path,NAME_Cache_guideInfo];
    [path release];
    NSData *data = [NSData dataWithContentsOfFile:plistPath];
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return dic;
}


@end

