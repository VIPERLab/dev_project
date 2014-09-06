//
//  PlayMusicLyricView.h
//  KwSing
//
//  Created by Qian Hu on 12-8-10.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "playPicturesView.h"
#import "LyricInfo.h"
#import "MediaModelFactory.h"

@interface PlayMusicLyricView : UIView
{
    NSTimer *timer;
    int nCurSentenceID;
    
    CLyricInfo *m_pLyricInfo;
    CMediaInterface *m_pMediaInterface;
    bool m_bFail;
}
-(void) SetLyricInfo:(CLyricInfo*)plyricinfo;
-(void) SetMedia:(CMediaInterface*) mediaInterface;
-(void)StopRefresh;
@end
