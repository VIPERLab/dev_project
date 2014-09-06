//
//  BookMarkData.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-12.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "BookMarkData.h"
#import "FilePath.h"
#import "CacheData.h"


@implementation BookMarkData


-(void)dealloc
{
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- 单例
static BookMarkData *sharedBookMarkData = nil;
+(id)sharedBookMarkData
{
    if (!sharedBookMarkData)
    {
        sharedBookMarkData = [[self alloc] init];
    }
    return sharedBookMarkData;
}



-(void)addBookmark:(BookMark *)bookmark
{
    if(!bookmark)
    {
        return;
    }
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[BookMarkData sharedBookMarkData] getBookmarkList]];
    if([dic objectForKey:bookmark.str_guideName])
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[dic objectForKey:bookmark.str_guideName]];
        [array addObject:bookmark];
        [dic setObject:array forKey:bookmark.str_guideName];
        [array release];
    }
    else
    {
        NSMutableArray *array_new = [[NSMutableArray alloc] init];
        [array_new addObject:bookmark];
        [dic setObject:array_new forKey:bookmark.str_guideName];
        [array_new release];
    }
    NSLog(@"  BookmarkData: %@",dic);
    [self saveBookmarkData:dic];
    [dic release];
    
    
    
//    [sharedBookMarkData.array_bookMark addObject:bookmark];
//    NSString *plistPath = [[FilePath getBookMarkPath] retain];
//    [CacheData cacheData:sharedBookMarkData.array_bookMark toFilePath:plistPath];
//    [plistPath release];
}

-(void)removeBookmark:(BookMark *)bookmark
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[BookMarkData sharedBookMarkData] getBookmarkList]];
    NSLog(@"  删除之前的书签 : %@",dic);
    NSLog(@"  删除的Bookmark - title : %@",bookmark.str_bookMarkTitle);
    if([dic objectForKey:bookmark.str_guideName])
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[dic objectForKey:bookmark.str_guideName]];
        for(BookMark *bm in array)
        {
            NSLog(@" str_guideName     : %@",bm.str_guideName);
            NSLog(@" str_bookMarkTitle : %@",bm.str_bookMarkTitle);
            if(bm.str_bookMarkTitle && bookmark.str_bookMarkTitle && [bm.str_bookMarkTitle isEqualToString:bookmark.str_bookMarkTitle])
            {
                NSLog(@" ok  删除 bookmark.str_bookMarkTitle");
                [array removeObject:bm];
                break;
            }
        }
        if(array.count > 0)
        {
            [dic setObject:array forKey:bookmark.str_guideName];
        }
        else
        {
            [dic removeObjectForKey:bookmark.str_guideName];
        }
        [self saveBookmarkData:dic];
        [array release];
    }
    NSLog(@"  删除后的书签 : %@",dic);
    
    
    
    NSString *plistPath = [[FilePath getBookMarkPath] retain];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [data writeToFile:plistPath atomically:NO];
    [plistPath release];
    [dic release];
    
    
    
    
//    for(BookMark *boo_mark in sharedBookMarkData.array_bookMark)
//    {
//        if([boo_mark.str_bookMarkTitle isEqualToString:bookmark.str_bookMarkTitle])
//        {
//            [sharedBookMarkData.array_bookMark removeObject:boo_mark];
//            break;
//        }
//    }
//    
//    NSString *plistPath = [[FilePath getBookMarkPath] retain];
//    [CacheData cacheData:sharedBookMarkData.array_bookMark toFilePath:plistPath];
//    [plistPath release];
}

-(void)removeBookmarkByGuideName:(NSString *)guideName
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[BookMarkData sharedBookMarkData] getBookmarkList]];
    [dic removeObjectForKey:guideName];
    [self saveBookmarkData:dic];
    [dic release];
    
    
    
//    for(BookMark *boo_mark in sharedBookMarkData.array_bookMark)
//    {
//        if([boo_mark.str_guideName isEqualToString:guideName])
//        {
//            [sharedBookMarkData.array_bookMark removeObject:boo_mark];
//            break;
//        }
//    }
//    
//    NSString *plistPath = [[FilePath getBookMarkPath] retain];
//    [CacheData cacheData:sharedBookMarkData.array_bookMark toFilePath:plistPath];
//    [plistPath release];
}

-(NSDictionary *)getBookmarkList
{
    NSString *plistPath = [[FilePath getBookMarkPath] retain];
    NSDictionary *dic = [CacheData getCachedBookmarkFromFilePath:plistPath];
    NSLog(@" dic===dic : %@",dic);
    
    [plistPath release];
    return dic;
}

-(void)saveBookmarkData:(NSDictionary *)dic
{
    NSString *plistPath = [[FilePath getBookMarkPath] retain];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [data writeToFile:plistPath atomically:NO];
    [plistPath release];
}

@end
