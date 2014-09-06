//
//  SortStringWithChinese.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-25.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SortStringWithChinese : NSObject
{
    NSMutableArray *_array_stringsToSort;
}
-(NSMutableArray *)getSortArray;
-(id)initWithArray:(NSMutableArray*)_array;
@end
