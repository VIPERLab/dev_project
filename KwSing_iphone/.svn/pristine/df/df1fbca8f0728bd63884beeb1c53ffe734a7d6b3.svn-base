//
//  KSNetSongDelegate.h
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__KSMusicLibDelegate__
#define __KwSing__KSMusicLibDelegate__

#import <Foundation/Foundation.h>
#import "KSWebView.h"
#import "IObserverApp.h"
#include "SongInfo.h"

@interface KSMusicLibDelegate : NSObject<IObserverApp>
{
    NSMutableArray *arrSearchHistory;
}
- (id)init;
- (void)dealloc;

-(void)IObserverApp_EnterBackground;
-(void)IObserverApp_EnterForeground;

- (void)LoadSearchHistory;
- (void)InsertSearchKey:(id)key;
- (id)GetSearchHistory;
-(void)ClearSearchHistroy;
-(void)DeleteSearchHistroy:(id)key;

-(void)KSong :(CSongInfoBase*)songInfo;
@end


#endif