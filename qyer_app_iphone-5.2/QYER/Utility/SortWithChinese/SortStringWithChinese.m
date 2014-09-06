//
//  SortStringWithChinese.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-25.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "SortStringWithChinese.h"
#import "ChineseString.h"
#import "pinyin.h"



@implementation SortStringWithChinese

-(id)initWithArray:(NSMutableArray *)_array
{
    self = [super init];
    if (self)
    {
        //Step1:初始化
        _array_stringsToSort = [[NSMutableArray alloc] initWithArray:_array];
    }
    return self;
}

-(NSMutableArray*)getSortArray
{
    //Step2:获取字符串中文字的拼音首字母并与字符串共同存放
    NSMutableArray *chineseStringsArray = [NSMutableArray array];
    
    for(int i = 0; i < [_array_stringsToSort count]; i++)
    {
        ChineseString *chineseString = [[[ChineseString alloc] init] autorelease];
        
        chineseString.string = [NSString stringWithString:[_array_stringsToSort objectAtIndex:i]];
        if(chineseString.string == nil)
        {
            chineseString.string = @"";
        }
        
        if(![chineseString.string isEqualToString:@""])
        {
            NSString *pinYinResult = [NSString string];
            for(int j = 0; j < chineseString.string.length; j++)
            {
                NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
                
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            chineseString.pinYin = pinYinResult;
        }
        else
        {
            chineseString.pinYin = @"";
        }
        [chineseStringsArray addObject:chineseString];
    }
    
    //Step3:按照拼音首字母对这些Strings进行排序
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    // Step4:如果有需要，再把排序好的内容从ChineseString类中提取出来
    NSMutableArray *result=[NSMutableArray array];
    for(int i=0;i<[chineseStringsArray count];i++){
        [result addObject:((ChineseString*)[chineseStringsArray objectAtIndex:i]).string];
    }
    
    return result;
}

@end

