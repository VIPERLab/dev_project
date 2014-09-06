//
//  KSLineLyricView.h
//  KwSing
//
//  Created by 单 永杰 on 13-5-9.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LyricInfo.h"
#import "MediaModelFactory.h"

@interface KSLineLyricView : UIView{
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
