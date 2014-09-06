//
//  KSAdjustSoundView.h
//  KwSing
//
//  Created by 单 永杰 on 12-12-12.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioEffectType.h"
#import "KSUIControlShowDelegate.h"
#include "MediaRecord.h"

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

@interface KSAdjustSoundView : UIView <IObserverApp> {
    int m_nAccompanyVolume;
    int m_nSingVolume;
    int m_nEchoType;
    CMediaRecord* m_pMediaRecord;
    id<KSUIControlShowDelegate> delegate;
}

@property (nonatomic) int accompanyVolume;
@property (nonatomic) int singVolume;
@property (nonatomic) int echoType;
@property (nonatomic)CMediaRecord* mediaRecord;
@property (nonatomic, retain) id<KSUIControlShowDelegate> delegate;

-(id)initWithFrame:(CGRect)frame Media:(CMediaRecord*)p_media;
-(void)IObserverApp_HeadsetStatusChanged:(BOOL)bHasHeadset;

@end
