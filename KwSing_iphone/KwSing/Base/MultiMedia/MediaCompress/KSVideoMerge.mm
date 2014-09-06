//
//  KSVideoMerge.m
//  KwSing
//
//  Created by 永杰 单 on 12-8-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSVideoMerge.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>
#import "MessageManager.h"
#import "IMediaSaveProcessObserver.h"

@implementation KSVideoMerge

static BOOL s_b_merge_success = YES;

+(BOOL)mergeAVFile:(NSString *)str_audio_path videoFilePath:(NSString *)str_video_path mergeFilePath:(NSString*)str_merge_path beginSaveTime:(unsigned long) n_begin_time{
    
    s_b_merge_success = YES;
    
    AVURLAsset* asset_audio = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:str_audio_path] options:nil];
    AVURLAsset* asset_video = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:str_video_path] options:nil];
   
    AVMutableComposition* mix_composition = [AVMutableComposition composition];
    AVMutableCompositionTrack* composition_comment_track = [mix_composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [composition_comment_track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset_audio.duration)  ofTrack:[[asset_audio tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack* composition_video_track = [mix_composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [composition_video_track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset_audio.duration) ofTrack:[[asset_video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    composition_video_track.preferredTransform = CGAffineTransformMakeRotation(M_PI_2);
    AVAssetExportSession* asset_export = [[AVAssetExportSession alloc] initWithAsset:mix_composition presetName:AVAssetExportPresetPassthrough];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:str_merge_path]) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:str_merge_path] error:nil];
    }

    asset_export.outputFileType = AVFileTypeMPEG4;
    asset_export.outputURL = [NSURL fileURLWithPath:str_merge_path];
    asset_export.shouldOptimizeForNetworkUse = YES;
    [asset_export exportAsynchronouslyWithCompletionHandler:^(void){
        if (AVAssetExportSessionStatusCompleted != asset_export.status) {
            [asset_audio release];
            [asset_video release];
            [asset_export release];
            
            unsigned long n_save_time = time(NULL) - n_begin_time;
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_FAIL, n_save_time * 1000);
        }else{
            [asset_audio release];
            [asset_video release];
            [asset_export release];
            
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, 1.0);
            unsigned long n_save_time = time(NULL) - n_begin_time;
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_SUCCESS, n_save_time * 1000);
        }
    }];
    return s_b_merge_success;
}

@end
