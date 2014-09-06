//
//  KSongLyricView.h
//  KwSing
//
//  Created by Qian Hu on 12-7-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LyricInfo.h"
#import "MediaModelFactory.h"

@interface KSongLyricView : UIView
{
    NSTimer *timer;
    int uiCurSentenceID;
    bool bHighlightTopLine;

    CLyricInfo *m_pLyricInfo;
    CMediaInterface *m_pMediaInterface;
}
-(void) SetLyricInfo:(CLyricInfo*)plyricinfo;
-(void) SetMedia:(CMediaInterface*) mediaInterface;
-(void)StopRefresh;
@end
