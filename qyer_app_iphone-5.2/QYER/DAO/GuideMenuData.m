//
//  GuideMenuData.m
//  QYGuide
//
//  Created by 我去 on 14-2-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GuideMenuData.h"
#import "FilePath.h"
#import "NSString+SBJSON.h"
#import "GuideMenu.h"
#import "GetWidthOrHeight.h"


@implementation GuideMenuData

+(NSArray *)getMenuJsonWithGuideName:(NSString *)guideName
{
    NSMutableArray *array_catalog = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[FilePath sharedFilePath] getMenuFilePath:[NSString stringWithFormat:@"file/%@_html/menu.json",guideName]];
    BOOL ui;
    if(!filePath || ![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        MYLog(@"没有'menu.json'文件");
        [array_catalog release];
        return [NSArray array];
    }
    else
    {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        NSData *cacheData = [fileHandle readDataToEndOfFile];
        NSString *cacheString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSArray *menu_srcDataArray = [cacheString JSONValue];
        if(menu_srcDataArray && [menu_srcDataArray isKindOfClass:[NSArray class]])
        {
            [array_catalog addObjectsFromArray:menu_srcDataArray];
        }
        else
        {
            [cacheString release];
            return [array_catalog autorelease];
        }
        [cacheString release];
    }
    
    [self initGuideMenuData:array_catalog];
    return [array_catalog autorelease];
}
+(void)initGuideMenuData:(NSMutableArray *)array_catelog
{
    if(!array_catelog || ![array_catelog isKindOfClass:[NSArray class]] || ([array_catelog isKindOfClass:[NSArray class]] && array_catelog.count == 0))
    {
        return;
    }
    
    
    NSMutableArray *array_tmp = [[NSMutableArray alloc] initWithArray:array_catelog copyItems:YES];
    [array_catelog removeAllObjects];
    for(int position = 0; position < array_tmp.count; position++)
    {
        GuideMenu *menu = [[GuideMenu alloc] init];
        NSDictionary *dic = [array_tmp objectAtIndex:position];
        
        
        //pageNumber:
        if(dic && ![dic isKindOfClass:[NSNull class]] && [dic isKindOfClass:[NSDictionary class]] && [dic objectForKey:@"file"])
        {
            NSRange range = [[dic objectForKey:@"file"] rangeOfString:@"."];
            if(range.location != NSNotFound && (range.location < [[dic objectForKey:@"file"] length]))
            {
                NSString *str_number = [[dic objectForKey:@"file"] substringToIndex:range.location];
                menu.str_pageNumber = str_number;
            }
            else
            {
                menu.str_pageNumber = @"  ";
            }
        }
        else
        {
            menu.str_pageNumber = @"  ";
        }
        
        
        //menuTitle:
        NSString *title = @" ";
        if(dic && ![dic isKindOfClass:[NSNull class]] && [dic isKindOfClass:[NSDictionary class]] && [dic objectForKey:@"title"])
        {
            title = [dic objectForKey:@"title"];
        }
        menu.title_menu = title;
        
        
        //titleHeight:
        float height = [GetWidthOrHeight getHeightWithContent:title andFontName:fontName_CatalogCell andFontSize:fontSize_CatalogCell andFixedWidth:fixedWidth_CatalogCell andMinHeight:minHeight_CatalogCell];
        menu.str_titleHeight = [NSString stringWithFormat:@"%f",height];
        [array_catelog addObject:menu];
        [menu release];
    }
    [array_tmp release];
}


@end
