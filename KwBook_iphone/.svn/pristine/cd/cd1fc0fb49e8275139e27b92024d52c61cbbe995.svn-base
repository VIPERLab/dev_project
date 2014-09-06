//
//  KBAudioStateNotify.m
//  kwbook
//
//  Created by 单 永杰 on 13-12-26.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import "KBAudioStateNotify.h"
#import "MessageManager.h"
#import "AudioPlayerManager.h"
#include "RecentBookList.h"
#include "CollectBookList.h"
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <AudioToolbox/AudioToolbox.h>

static KBAudioStateNotify* sharedInstance = nil;

@interface KBAudioStateNotify ()

@property (nonatomic, strong)NSMutableDictionary* playbackInfo;

@end

@implementation KBAudioStateNotify

+(KBAudioStateNotify*)sharedInstance{
    @synchronized(self){
        if (nil == sharedInstance) {
            sharedInstance = [[KBAudioStateNotify alloc] init];
        }
    }
    
    return sharedInstance;
}

-(id)init{
    self = [super init];
    _playbackInfo = [[NSMutableDictionary alloc] init];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(notifyState) userInfo:nil repeats:YES];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(notifyLockScreenInfo) userInfo:nil repeats:YES];
    }
    
    return  self;
}

-(void)notifyState{
    if (E_AUDIO_PLAY_PLAYING == CAudioPlayerManager::getInstance()->getCurPlayState()) {
        float f_cur_time = CAudioPlayerManager::getInstance()->currentTime();
        CPlayBookList::getInstance()->setCurPos(f_cur_time * 1000);
        CPlayBookList::getInstance()->SavePlaylist();
        
        CChapterInfo* chapter_info = CPlayBookList::getInstance()->getCurChapter();
        
        if (chapter_info) {
            CRecentBookInfo* recent_book_info = CRecentBookList::GetInstance()->GetCurBook([[NSString stringWithUTF8String:chapter_info->m_strBookId.c_str()] intValue]);
            if (recent_book_info) {
                recent_book_info->m_unIndex = CPlayBookList::getInstance()->getCurPlayIndex();
                recent_book_info->m_unPosMilSec = f_cur_time * 1000;
                
                CRecentBookList::GetInstance()->SaveAllBooks();
            }
            
            CCollectBookInfo* collect_book = CCollectBookList::GetInstance()->GetCurBook([[NSString stringWithUTF8String:chapter_info->m_strBookId.c_str()] intValue]);
            if (collect_book) {
                collect_book->m_unIndex = CPlayBookList::getInstance()->getCurPlayIndex();
                collect_book->m_unPosMilSec = f_cur_time * 1000;
                
                CCollectBookList::GetInstance()->SaveAllBooks();
            }
            
            CPlayBookList::getInstance()->setCurPos(f_cur_time * 1000);
        }
        
        SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlaylistStatusChanged);
    }
}

- (void)notifyLockScreenInfo{
    AudioPlayState cur_play_state = CAudioPlayerManager::getInstance()->getCurPlayState();
    if (E_AUDIO_PLAY_PLAYING == cur_play_state) {
        CChapterInfo* cur_chapter = CPlayBookList::getInstance()->getCurChapter();
        if (cur_chapter) {
            if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
                [_playbackInfo setObject:[NSString stringWithUTF8String:cur_chapter->m_strName.c_str()] forKey:MPMediaItemPropertyTitle];
                [_playbackInfo setObject:[NSString stringWithUTF8String:cur_chapter->m_strArtist.c_str()] forKey:MPMediaItemPropertyArtist];
                [_playbackInfo setObject:[NSNumber numberWithInt:CAudioPlayerManager::getInstance()->duration()] forKey:MPMediaItemPropertyPlaybackDuration];
                [_playbackInfo setObject:[NSNumber numberWithInt:CAudioPlayerManager::getInstance()->currentTime()] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
                
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:_playbackInfo];
            }
        }
    }
}


@end
