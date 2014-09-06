//
//  KSAudioFormatConvertInterface.m
//  KwSing
//
//  Created by 永杰 单 on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSAudioFormatConvertInterface.h"
#import <CoreFoundation/CFString.h>
#import "AudioFormatConvert.h"

extern void ThreadStateInitalize();
extern void ThreadStateBeginInterruption();
extern void ThreadStateEndInterruption();

@implementation KSAudioFormatConvertInterface

- (void) convertThreadFun:(id)in_para{
    if (noErr == CAudioFormatConvert::ConvertFormatToPCM(in_para)) {
        m_bIsConvertFinish = YES;
        m_ConvertStatus = CONVERT_SUCESS;
    } else {
        m_bIsConvertFinish = YES;
        m_ConvertStatus = CONVERT_ERR;
    }
}

- (void) audioFileFormatConvert:(id)in_para{
    ThreadStateInitalize();
    [NSThread detachNewThreadSelector:@selector(convertThreadFun:) toTarget:self withObject:in_para];
}

- (BOOL) isConvertFinish{
    return m_bIsConvertFinish;
}

- (enum ConvertStatus) getConvertStatus{
    return m_ConvertStatus;
}

@end
