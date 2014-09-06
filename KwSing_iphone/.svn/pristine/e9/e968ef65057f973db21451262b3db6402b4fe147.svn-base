//
//  VidioCaptrueView.m
//  KwSing
//
//  Created by Qian Hu on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "VideoCaptrueView.h"


@implementation VideoCaptrueView
@synthesize avCaptureSession; 
@synthesize imgv;
@synthesize customLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        firstFrame= YES;
    }
    return self;
}


#pragma mark -  

#pragma mark VideoCapture  

- (AVCaptureDevice *)getFrontCamera  

{  
    //获取前置摄像头设备  
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];  
    
    for (AVCaptureDevice *device in cameras)  
        
    {  
        
        if (device.position == AVCaptureDevicePositionFront)  
            
            return device;  
        
    }  
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];  
}  

- (void)startVideoCapture  

{  
    //打开摄像设备，并开始捕抓图像  

    if(self->avCaptureDevice|| self->avCaptureSession)  
        
    {  
        //"Already capturing" 
        return;  
    }  
    
    
    
    if((self->avCaptureDevice = [self getFrontCamera]) == nil)  
        
    {  
       // "Failed to get valide capture device" 
        return;  
    }  
    
    
    
    NSError *error = nil;  
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self->avCaptureDevice error:&error];  
    
    if (!videoInput)  
        
    {  
        
        //[labelState setText:@"Failed to get video input"];  
        
        self->avCaptureDevice = nil;  
        
        return;  
        
    }  
    
    
    
    self->avCaptureSession = [[AVCaptureSession alloc] init];  
    
    self->avCaptureSession.sessionPreset = AVCaptureSessionPresetLow;  
    
    [self->avCaptureSession addInput:videoInput];  
    
    
    
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are   
    
    // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA.   
    
    // On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.  
    
    //  
    
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];  
    
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:  
                              
                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,  
                              
                              [NSNumber numberWithInt:240], (id)kCVPixelBufferWidthKey,  
                              
                              [NSNumber numberWithInt:320], (id)kCVPixelBufferHeightKey,  
                              
                              nil];  
    
    avCaptureVideoDataOutput.videoSettings = settings;  
    
    [settings release];  
    
    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, 50);  
    
    
    
    dispatch_queue_t queue = dispatch_queue_create("org.doubango.idoubs", NULL);  
    
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];  
    
    [self->avCaptureSession addOutput:avCaptureVideoDataOutput];  
    
    [avCaptureVideoDataOutput release];  
    
    dispatch_release(queue);  
    
    AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self->avCaptureSession];  
    
    previewLayer.frame = self.bounds;  
    
    previewLayer.videoGravity= AVLayerVideoGravityResizeAspectFill;  
    
    self->firstFrame= YES; 
    
    [[self layer] addSublayer: previewLayer];  
    
    
    [self->avCaptureSession startRunning];  
    
   // [labelState setText:@"Video capture started"];  
    
    
    
}  

- (void)stopVideoCapture:(id)arg  

{  
    
    //停止摄像头捕抓  
    
    if(self->avCaptureSession){  
        
        [self->avCaptureSession stopRunning];  
        
        self->avCaptureSession= nil;  
        
     //   [labelState setText:@"Video capture stopped"];  
        
    }  
    
    self->avCaptureDevice = nil;  
    
    //移除localView里面的内容  
    
    for(UIView *view in self.subviews) { 
        
        [view removeFromSuperview];  
        
    }  
    
}  

#pragma mark -  

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate  

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection   

{  
    
    //捕捉数据输出 要怎么处理虽你便   
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);  
    
    
    
    
    
    if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess)  
        
    {  
        
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(pixelBuffer);
        
        
        
        size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);  
        
        
        
        if(self->firstFrame)  
            
        {   
            
            if(1)  
                
            {  
                
                //第一次数据要求：宽高，类型  
                
                int width = CVPixelBufferGetWidth(pixelBuffer); 
                
                
                
                int height = CVPixelBufferGetHeight(pixelBuffer);  
                
                
                
                
                
                int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);  
                
                
                
                switch (pixelFormat) {  
                        
                    case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:  
                        
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_nv12; // iPhone 3GS or 4  
                        
                        NSLog(@"Capture pixel format=NV12");  
                        
                        break;  
                        
                    case kCVPixelFormatType_422YpCbCr8:  
                        
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_uyvy422; // iPhone 3  
                        
                        NSLog(@"Capture pixel format=UYUY422");  
                        
                        break;  
                        
                    default:  
                        
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_rgb32;  
                        
                        NSLog(@"Capture pixel format=RGB32");  
                        
                        break;  
                        
                }  
                
                
                
                self->firstFrame = NO;  
                
            }  
            
        }  
        
        
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);   
        
    }  
    
    
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];  
    
    
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);  
    
    
    
    
    
    CVPixelBufferLockBaseAddress(imageBuffer,0);   
    
    
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);   
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);   
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);   
    
    size_t height = CVPixelBufferGetHeight(imageBuffer);    
    
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    if (!colorSpace) 
        
    {
        
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        
        return ;
        
    }
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);  
    
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);   
    
    
    
    
    
    CGContextRelease(newContext);   
    
    //  另一种获得IMAGE方法
    
    // size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer); 
    
    //
    
    //    // Create a Quartz direct-access data provider that uses data we supply
    
    //    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, 
    
    //   NULL);
    
    //    // Create a bitmap image from data supplied by our data provider
    
    //    CGImageRef cgImage = 
    
    // CGImageCreate(width,
    
    //   height,
    
    //   8,
    
    //   32,
    
    //   bytesPerRow,
    
    //   colorSpace,
    
    //   kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
    
    //   provider,
    
    //   NULL,
    
    //   true,
    
    //   kCGRenderingIntentDefault);
    
    //    CGDataProviderRelease(provider);
    
    
    
    CGColorSpaceRelease(colorSpace);
    
    
    
    // Create and return an image object representing the specified Quartz image
    
    UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    
   
    //[self.imgv performSelectorOnMainThread:@selector(setImage:) withObject:imagewaitUntilDone:YES];  
    
    //    CGImageRelease(cgImage);
    
    
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    
    [self.customLayer performSelectorOnMainThread:@selector(setContents:) withObject: (id) newImage waitUntilDone:YES];  
    
    
    // UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];  
    
    
    CGImageRelease(newImage);  
    
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);  
    
    
    
    [pool drain];  
    
}  

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
