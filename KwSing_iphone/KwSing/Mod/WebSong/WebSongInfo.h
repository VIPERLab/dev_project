//
//  WebSongInfo.h
//  KwSing
//
//  Created by 熊 改 on 14-1-20.
//  Copyright (c) 2014年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebSongInfo : NSObject
{
    NSString *_songId;
    NSString *_title;
    NSString *_time;
    NSString *_viewTimes;
    NSString *_comments;
    NSString *_flowers;
    NSString *_source;
}
@property (nonatomic , retain) NSString *songId;
@property (nonatomic , retain) NSString *title;
@property (nonatomic , retain) NSString *time;
@property (nonatomic , retain) NSString *viewTimes;
@property (nonatomic , retain) NSString *comments;
@property (nonatomic , retain) NSString *flowers;
@property (nonatomic , retain) NSString *source;
@end
