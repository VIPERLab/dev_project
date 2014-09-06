//
//  BookMarkData.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-12.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookMark.h"

@interface BookMarkData : NSObject

+(id)sharedBookMarkData;

-(void)addBookmark:(BookMark *)bookmark;
-(void)removeBookmark:(BookMark *)bookmark;
-(void)removeBookmarkByGuideName:(NSString *)guideName;
-(NSDictionary *)getBookmarkList;

@end
