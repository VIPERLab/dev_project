//
//  GuideHtml.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideHtml.h"
#import "FilePath.h"

@implementation GuideHtml

+(void)getGuideHtmlToArray:(NSMutableArray *)array withGuideName:(NSString *)str_guideName
{
    //取得一个目录下的所有文件名:
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html",str_guideName]];
    //NSArray *files = [fm subpathsAtPath:filePath];
    //NSArray *files = [fm subpathsOfDirectoryAtPath:filePath error:nil];
    NSArray *files = [fm contentsOfDirectoryAtPath:filePath error:nil];
    for(NSString *str in files)
    {
        if([str rangeOfString:@".html"].location != NSNotFound)
        {
            [array removeObject:str];
            [array addObject:str];
        }
    }
    
    NSArray *sortedArray = [array sortedArrayUsingComparator: ^(id obj1, id obj2)
                            {
                                if ([obj1 integerValue] > [obj2 integerValue])
                                {
                                    return (NSComparisonResult)NSOrderedDescending;
                                }
                                if ([obj1 integerValue] < [obj2 integerValue])
                                {
                                    return (NSComparisonResult)NSOrderedAscending;
                                }
                                return (NSComparisonResult)NSOrderedSame;
                            }];
    
    [array removeAllObjects];
    [array addObjectsFromArray:sortedArray];
}

@end
