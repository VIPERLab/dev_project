//
//  CachePoiData.m
//  QyGuide
//
//  Created by an qing on 13-3-8.
//
//

#import "CachePoiData.h"
#import <sys/xattr.h>



@implementation CachePoiData


static id sharedCachePoiData = nil;


#pragma mark -
#pragma mark --- 单例
+(id)sharedCachePoiData
{
    if (!sharedCachePoiData)
    {
        sharedCachePoiData = [[self alloc] init];
    }
    
    return sharedCachePoiData;
}

#pragma mark -
#pragma mark --- 缓存数据 ^ ^ ^ ^ ^ ^
-(void)cachePoiData:(NSDictionary*)dic withPoiId:(NSInteger)poiid
{
    NSString *Path =[[self getCachePath] retain];
    NSString *destplist = [NSString stringWithFormat:@"%@/%d.plist",Path,poiid];
    
    
    //这样直接写不行:
    //[dic writeToFile:destplist atomically:YES];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [data writeToFile:destplist atomically:NO];
    
    [Path release];
}
//返回缓存路径
-(NSString*)getCachePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager ];
    
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    
    NSString *plistPath = [NSString stringWithFormat:@"%@/poidetailinfo_Cache",[pathURL path]];
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
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.1)
    {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success)
        {
            //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
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
+(BOOL)isFileExistByPoiId:(NSInteger)poiId
{
    NSString *Path =[[CachePoiData sharedCachePoiData] getCachePath];
    NSString *destplist = [NSString stringWithFormat:@"%@/%d.plist",Path,poiId];
    
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
-(NSDictionary *)getCachePoiDataWithPoiId:(NSInteger)poiid
{
    NSString *Path =[[self getCachePath] retain];
    NSString *destplist = [NSString stringWithFormat:@"%@/%d.plist",Path,poiid];
    
    NSData *data = [NSData dataWithContentsOfFile:destplist];
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [Path release];
    return dic;
}

@end

