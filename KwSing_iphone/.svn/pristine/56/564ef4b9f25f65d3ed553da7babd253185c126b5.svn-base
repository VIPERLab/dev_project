//
//  VidioCaptrueView.h
//  KwSing
//
//  Created by Qian Hu on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreMedia/CoreMedia.h>
#import<AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

@interface VideoCaptrueView : UIView<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureDevice *avCaptureDevice; 
    BOOL firstFrame; //是否为第一帧  
    CALayer *customLayer;
    UIImageView *imgv;
}
@property (nonatomic, retain) AVCaptureSession *avCaptureSession;  
@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic, retain) UIImageView *imgv;
- (AVCaptureDevice *)getFrontCamera;  

- (void)startVideoCapture;  

- (void)stopVideoCapture:(id)arg;  
@end
