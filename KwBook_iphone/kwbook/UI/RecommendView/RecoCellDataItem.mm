//
//  RecoCellDataItem.m
//  kwbook
//
//  Created by 熊 改 on 13-12-2.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import "RecoCellDataItem.h"

@implementation RecoCellDataItem
-(NSString*)description
{
    return [NSString stringWithFormat:@"RecoDataItem.Id:%@,name:%@,musicCount:%@,image:%@,listenCount:%@",self.bookId,
            self.artistName,self.musicCount,self.imageURL,self.listenCount];
}
@end
