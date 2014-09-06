//
//  AudioHelper.m
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-21.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "AudioHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import "MessageManager.h"
#import "IObserverApp.h"

@interface AudioHelper()
{
    BOOL bHasMicrophone;
    BOOL bHasHeadset;
}
@end

@implementation AudioHelper

+ (AudioHelper*) getInstance;
{
    static AudioHelper* pInstance(NULL);
    if (!pInstance) {
        pInstance=[[AudioHelper alloc] init];
        [pInstance initSession];
    }
    return pInstance;
}

- (BOOL)hasMicophone
{
    return [[AVAudioSession sharedInstance] inputIsAvailable];
}

- (BOOL)hasHeadset
{
//苹果也犯2，模拟器你没有这功能就返回没有嘛，竟然直接崩溃
#if TARGET_IPHONE_SIMULATOR
    return NO;
#endif
    CFStringRef route = nil;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
    } else {
        NSString* routeStr = (NSString*)route;
        /* "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound
            || headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}
 
void audioRouteChangeListenerCallback(void* inUserData
                                      ,AudioSessionPropertyID inPropertyID
                                      ,UInt32 inPropertyValueS
                                      ,const void* inPropertyValue)
{
    
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;

    CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
    CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
 
    AudioHelper *_self = (AudioHelper *) inUserData;
    if (_self->bHasHeadset!=[_self hasHeadset]) {
        _self->bHasHeadset=[_self hasHeadset];
        SYN_NOTIFY(OBSERVER_ID_APP,IObserverApp::HeadsetStatusChanged,_self->bHasHeadset);
    }
    if (_self->bHasMicrophone!=[_self hasMicophone]) {
        _self->bHasMicrophone=[_self hasMicophone];
        SYN_NOTIFY(OBSERVER_ID_APP,IObserverApp::MicrophoneStatusChanged,_self->bHasMicrophone);
    }
}

- (void)initSession {
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange
                                     ,audioRouteChangeListenerCallback
                                     ,self);
    [[AVAudioSession sharedInstance] setActive: YES error:NULL];
    bHasMicrophone=[self hasMicophone];
    bHasHeadset=[self hasHeadset];
}


@end
