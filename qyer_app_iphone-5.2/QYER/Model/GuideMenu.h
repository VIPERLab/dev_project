//
//  GuideMenu.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-10.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideMenu : NSObject <NSCoding>
{
    NSString *_str_pageNumber;
    NSString *_title_menu;
    NSString *_str_titleHeight;
}

@property(nonatomic,retain) NSString *str_pageNumber;
@property(nonatomic,retain) NSString *title_menu;
@property(nonatomic,retain) NSString *str_titleHeight;

@end
