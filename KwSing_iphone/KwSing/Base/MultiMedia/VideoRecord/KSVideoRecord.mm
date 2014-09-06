//
//  KSVideoRecord.m
//  KwSing
//
//  Created by 永杰 单 on 12-8-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSVideoRecord.h"
#import "KSRecordTempPath.h"
#import <CoreVideo/CVPixelBuffer.h>
#import <CoreMedia/CMSampleBuffer.h>
#include <string>

void AppendVideo(NSString* str_video, NSString* str_video_append){
    NSFileManager* file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:str_video_append]) {
        NSString* str_combine_video_path = [NSString stringWithUTF8String:([KSRecordTempPath getRecordTempPath] + "/Combined.mp4").c_str()];
        
        AVURLAsset* asset_video_url = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:str_video] options:nil];
        AVURLAsset* asset_temp_url = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:str_video_append] options:nil];
        
        AVMutableComposition* video_composition = [AVMutableComposition composition];
        AVMutableCompositionTrack* composition_video_track = [video_composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        AVAssetTrack* asset_record = [[asset_video_url tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVAssetTrack* asset_temp = [[asset_temp_url tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [composition_video_track setPreferredTransform:asset_record.preferredTransform];
        
        [composition_video_track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset_video_url.duration) ofTrack:asset_record atTime:kCMTimeZero error:0];
        [composition_video_track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset_video_url.duration) ofTrack:asset_temp atTime:asset_video_url.duration error:0];
        
        AVAssetExportSession* asset_export = [[AVAssetExportSession alloc] initWithAsset:video_composition presetName:AVAssetExportPresetPassthrough];
        
        if ([file_manager fileExistsAtPath:str_combine_video_path]) {
            [file_manager removeItemAtURL:[NSURL fileURLWithPath:str_combine_video_path] error:nil];
        }
        
        asset_export.outputFileType = AVFileTypeMPEG4;
        asset_export.outputURL = [NSURL fileURLWithPath:str_combine_video_path];
        asset_export.shouldOptimizeForNetworkUse = YES;
        [asset_export exportAsynchronouslyWithCompletionHandler:^(void){
            [asset_video_url release];
            [asset_temp_url release];
            [asset_export release];
            
            if ([file_manager fileExistsAtPath:str_video_append]) {
                [file_manager removeItemAtURL:[NSURL fileURLWithPath:str_video_append] error:nil];
            }
            if ([file_manager fileExistsAtPath:str_video]) {
                [file_manager removeItemAtURL:[NSURL fileURLWithPath:str_video] error:nil];
            }
            if ([file_manager fileExistsAtPath:str_combine_video_path]) {
                [file_manager moveItemAtPath:str_combine_video_path toPath:str_video error:nil];
            }
        }];
    }
}

@implementation KSVideoRecord

- (AVCaptureDevice*) getFrontCamera{
    NSArray* arry_cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice* device in arry_cameras) {
        if (AVCaptureDevicePositionFront == device.position) {
            return device;
        }
    }
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (bool) initVideoCapture:(UIView *)p_view VideoFilePath:(NSString*)str_video_file_path{
    m_pCaptureSession = [[AVCaptureSession alloc] init];
    [m_pCaptureSession beginConfiguration];
//    [m_pCaptureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    NSError* error = nil;
    unlink([str_video_file_path UTF8String]);
    m_pVideoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:str_video_file_path] fileType:AVFileTypeMPEG4 error:&error];
    m_strVideoPath = [[NSString alloc] initWithString:str_video_file_path];
    
    m_strTempVideoPath = [[NSString alloc] initWithUTF8String:([KSRecordTempPath getRecordTempPath] + "/temp.mp4").c_str()];//[NSString stringWithUTF8String:([KSRecordTempPath getRecordTempPath] + "/temp.mp4").c_str()];
    
    NSParameterAssert(m_pVideoWriter);
    
    NSDictionary* video_compression_setting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:300 * 1024.0], AVVideoAverageBitRateKey, nil];
    NSDictionary* video_setting = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, [NSNumber numberWithInt:320], AVVideoWidthKey, [NSNumber numberWithInt:240], AVVideoHeightKey, video_compression_setting, AVVideoCompressionPropertiesKey, nil];
    m_pVideoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:video_setting];
    NSParameterAssert(m_pVideoWriterInput);
    
    m_pVideoWriterInput.expectsMediaDataInRealTime = YES;
    m_pVideoWriterInput.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    NSDictionary* buffer_attribute = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, [NSNumber numberWithInt:320] ,(id)kCVPixelBufferWidthKey, [NSNumber numberWithInt:240] ,(id)kCVPixelBufferHeightKey, nil];
    m_pVideoInputAdapter = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:m_pVideoWriterInput sourcePixelBufferAttributes:buffer_attribute];
    NSParameterAssert(m_pVideoWriterInput);
    NSParameterAssert([m_pVideoWriter canAddInput:m_pVideoWriterInput]);
    
    [m_pVideoWriter addInput:m_pVideoWriterInput];
    
    AVCaptureDevice* video_device = [self getFrontCamera];
    AVCaptureDeviceInput* video_device_input = [AVCaptureDeviceInput deviceInputWithDevice:video_device error:&error];
    assert(video_device_input);
    
    m_pVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [m_pVideoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [m_pVideoOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] ,(id)kCVPixelBufferPixelFormatTypeKey, nil]];
    [m_pVideoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [m_pCaptureSession addInput:video_device_input];
    [m_pCaptureSession addOutput:m_pVideoOutput];
    [m_pCaptureSession commitConfiguration];
    
    preview_layer = [AVCaptureVideoPreviewLayer layerWithSession:m_pCaptureSession];
    preview_layer.frame = p_view.layer.frame;
//    NSLog(@"width = %f, height = %f", p_view.layer.frame.size.width, p_view.layer.frame.size.height);
    preview_layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [p_view.layer addSublayer:preview_layer];
    
    m_bPaused = NO;
    
    return true;
}

- (bool) startVideoCapture{
    //    if (m_pVideoCaptureDevice || m_pVideoCaptureSession) {
    //        return;
    //    }
    
    [m_pCaptureSession startRunning];
    
    return true;
}

- (void) stopVideoCapture{
    [preview_layer removeFromSuperlayer];
    
    if (m_pCaptureSession) {
        [m_pCaptureSession stopRunning];
    }
    [self performSelectorInBackground:@selector(stopAssetWriting) withObject:nil];
}

- (void)stopAssetWriting{
    if (m_pVideoWriter) {
        [m_pVideoWriter finishWriting];
    }
    AppendVideo(m_strVideoPath, m_strTempVideoPath);
    [m_pVideoWriter release];
    m_pVideoWriter = nil;
}

- (void)dealloc{
    [m_pCaptureSession removeOutput:m_pVideoOutput];
    
    [m_pCaptureSession release];
    m_pCaptureSession = nil;
    
//    if (m_pVideoWriterInput) {
//        [m_pVideoWriterInput release];
//        m_pVideoWriterInput = nil;
//    }
    
    if (m_pVideoWriter) {
        [m_pVideoWriter release];
        m_pVideoWriter = nil;
    }
    
    if (m_pVideoOutput) {
        [m_pVideoOutput release];
        m_pVideoOutput = nil;
    }
    
    [m_strVideoPath release];
    m_strVideoPath = nil;
    
    [m_strTempVideoPath release];
    m_strTempVideoPath = nil;
    
    [super dealloc];
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (m_bPaused) {
        return;
    }
 
    CMTime last_sample_time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (AVAssetWriterStatusWriting != m_pVideoWriter.status) {
        [m_pVideoWriter startWriting];
        [m_pVideoWriter startSessionAtSourceTime:last_sample_time];
    }
        
    if (captureOutput == m_pVideoOutput) {
        if ([m_pVideoWriterInput isReadyForMoreMediaData]) {
            [m_pVideoWriterInput appendSampleBuffer:sampleBuffer];
        }
    }
}

- (void) pauseVideoCapture{
    if (m_pCaptureSession) {
        [m_pCaptureSession stopRunning];
    }
    
    [self performSelectorInBackground:@selector(stopAssetWriting) withObject:nil];
    
    m_bPaused = YES;
}

- (void)continueVideoCapture{
    
    m_pVideoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:m_strTempVideoPath] fileType:AVFileTypeMPEG4 error:nil];
    
    NSParameterAssert(m_pVideoWriter);
    NSDictionary* video_compression_setting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:300 * 1024.0], AVVideoAverageBitRateKey, nil];
    NSDictionary* video_setting = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, [NSNumber numberWithInt:320], AVVideoWidthKey, [NSNumber numberWithInt:320], AVVideoHeightKey, video_compression_setting, AVVideoCompressionPropertiesKey, nil];
    m_pVideoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:video_setting];
    NSParameterAssert(m_pVideoWriterInput);
    
    m_pVideoWriterInput.expectsMediaDataInRealTime = YES;
//    m_pVideoWriterInput.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    NSDictionary* buffer_attribute = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    m_pVideoInputAdapter = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:m_pVideoWriterInput sourcePixelBufferAttributes:buffer_attribute];
    NSParameterAssert(m_pVideoWriterInput);
    NSParameterAssert([m_pVideoWriter canAddInput:m_pVideoWriterInput]);
    
//    [m_pVideoWriter addInput:m_pVideoWriterInput];
//    NSParameterAssert([m_pVideoWriter canAddInput:m_pVideoWriterInput]);
    [m_pVideoWriter addInput:m_pVideoWriterInput];
    
    [m_pCaptureSession startRunning];
    m_bPaused = NO;
}

@end
