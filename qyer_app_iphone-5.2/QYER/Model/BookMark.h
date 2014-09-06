//
//  BookMark.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-12.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookMark : NSObject <NSCoding>
{
    NSString        *_str_guideName;
    NSString        *_str_bookMarkTitle;
    NSString        *_str_bookMarkPageNumber;
    NSString        *_str_guideHtmlInfoPath;
}

@property(nonatomic, retain) NSString   *str_guideName;
@property(nonatomic, retain) NSString   *str_bookMarkTitle;
@property(nonatomic, retain) NSString   *str_bookMarkPageNumber;
@property(nonatomic, retain) NSString   *str_guideHtmlInfoPath;

@end
