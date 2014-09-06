//
//  DataManager.m
//  Travel Gather
//
//  Created by lide on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
//#import "CaptureCollectionItem.h"
#define FileName_WebCache                             @"WebCache"

@implementation DataManager

#pragma mark - public

- (BOOL)webFileExistsFromCache:(NSString*)path
{
    NSString *diskCachePath = [self pathForWebCacheDirectory];
    NSString *myPath = [diskCachePath stringByAppendingPathComponent:path];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:myPath];


}

//缓存WebView
- (void)archiveWebData:(NSData *)data IntoCache:(NSString *)path
{
    NSString *diskCachePath = [self pathForWebCacheDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //如果WebCache文件夹不存在，则创建该文件夹
    if (![fileManager fileExistsAtPath:diskCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];

    }
    
    NSString *myPath = [diskCachePath stringByAppendingPathComponent:path];
    if (![fileManager fileExistsAtPath:myPath]) {
        [fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
        [fileManager createFileAtPath:myPath contents:nil attributes:nil];
    }
    
    if (![data writeToFile:myPath atomically:YES]) {
        
    }
    
    
    
}

- (NSData *)unarchiveWebDataFromCache:(NSString *)path
{
    NSString *diskCachePath = [self pathForWebCacheDirectory];
    NSString *myPath = [diskCachePath stringByAppendingPathComponent:path];
    NSData *fData = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:myPath]) {
        fData = [NSData dataWithContentsOfFile:myPath];
    }
    
    return fData;

}

-(void)archiveDict:(NSDictionary *)dict IntoCache:(NSString *)path{
    
    NSString *diskCachePath = [self pathForWebCacheDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //如果WebCache文件夹不存在，则创建该文件夹
    if (![fileManager fileExistsAtPath:diskCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
        
    }
    
    NSString *myPath = [diskCachePath stringByAppendingPathComponent:path];
    if (![fileManager fileExistsAtPath:myPath]) {
        [fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
        [fileManager createFileAtPath:myPath contents:nil attributes:nil];
    }
    
    if (![dict writeToFile:myPath atomically:YES]) {
        
    }
    

}
-(NSDictionary *)unarchiveWebDictFromCache:(NSString *)path{
    
    NSString *diskCachePath = [self pathForWebCacheDirectory];
    NSString *myPath = [diskCachePath stringByAppendingPathComponent:path];
    NSDictionary *fDict = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:myPath]) {
        fDict = [NSDictionary dictionaryWithContentsOfFile:myPath];
    }
    return fDict;
}

//cache 文件夹下的 WebCache文件夹
- (NSString*)pathForWebCacheDirectory
{
    return [[self pathForCacheDirectory] stringByAppendingPathComponent:FileName_WebCache];
}

//cache 文件夹
- (NSString*)pathForCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}



//- (void)archiveDataArray:(NSArray *)array IntoCache:(NSString *)path
//{
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
//    [self archiveData:data IntoCache:path];
//    
//}

- (void)archiveData:(NSData *)data IntoCache:(NSString *)path
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [[myPathList  objectAtIndex:0] stringByAppendingPathComponent:path];
    //    NSError *err        = nil;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:myPath]){
        //
        NSFileManager *fileManager = [NSFileManager defaultManager ]; // [[NSFileManager new] autorelease]; // File manager instance
        //
        [fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
        [[NSFileManager defaultManager] createFileAtPath:myPath contents:nil attributes:nil];
    }
    
    if(![data writeToFile:myPath atomically:YES])
    {
        
    }


}

//- (NSArray *)unarchiveDataArrayFromCache:(NSString *)path
//{
//    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *myPath    = [myPathList  objectAtIndex:0];
//    NSData *fData       = nil;
//    
//    myPath = [myPath stringByAppendingPathComponent:path];
//    if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
//    {
//        fData = [NSData dataWithContentsOfFile:myPath];
//    }
//
//    if (fData == nil ) {
//        return nil;
//    }
//    return [NSKeyedUnarchiver unarchiveObjectWithData:fData];
//}


- (NSData *)unarchiveDataFromCache:(NSString *)path
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    NSData *fData       = nil;
    
    myPath = [myPath stringByAppendingPathComponent:path];
    if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        fData = [NSData dataWithContentsOfFile:myPath];
    }

    return fData;


}

//+ (id)sharedManager
//{
//    static id sharedManager = nil;
//    if (!sharedManager) {
//        sharedManager = [[self alloc] init];
//    }
//    
//    return sharedManager;
//}

static id dataManager = nil;
+ (id)sharedManager
{
    
    @synchronized(dataManager){
        if(dataManager == nil)
        {
            dataManager = [[self alloc] init];
        }
    }
    
    return dataManager;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        
    }
    
    return self;
}

@end
