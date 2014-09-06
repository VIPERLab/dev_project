//
//  KSVideoRecord.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
//
//#ifndef KwSing_IObserverApp_h
//#include "IObserverApp.h"
//#endif

@interface KSVideoRecord : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{
    AVCaptureSession* m_pCaptureSession;
    AVAssetWriter* m_pVideoWriter;
    AVAssetWriterInput* m_pVideoWriterInput;
    AVAssetWriterInputPixelBufferAdaptor* m_pVideoInputAdapter;
    
    AVCaptureVideoDataOutput* m_pVideoOutput;
    AVCaptureVideoPreviewLayer* preview_layer;
    
    NSString* m_strVideoPath;
    NSString* m_strTempVideoPath;
    
    BOOL m_bPaused;
}

- (AVCaptureDevice*) getFrontCamera;
- (bool) initVideoCapture : (UIView*) p_view VideoFilePath:(NSString*)str_video_file_path;
- (bool) startVideoCapture;
- (void) pauseVideoCapture;
- (void) continueVideoCapture;
- (void) stopVideoCapture;

@end
