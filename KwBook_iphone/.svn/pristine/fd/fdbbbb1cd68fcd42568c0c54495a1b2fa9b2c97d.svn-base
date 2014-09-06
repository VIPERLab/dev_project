//
//  HttpRequestHelper.mm
//  KwSing
//
//  Created by 海平 翟 on 12-7-24.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "HttpRequestHelper.h"
#include "HttpRequest.h"
#include "KwTools.h"

@implementation KSHttpRequestHelper
@synthesize pRequest;
@synthesize strSaveFile;
@synthesize pNotify;
@synthesize idNotify;
@synthesize pNotifyThread;
@synthesize block_start;
@synthesize block_process;
@synthesize block_stop;
@synthesize bUpload;
@synthesize lContinueSize;
@synthesize cancled;
@synthesize http;
@synthesize finished;

- (void)dealloc
{
    [pNotifyThread release];
    [strSaveFile release];
    [http release];
    if(block_start)Block_release(block_start);
    if(block_process)Block_release(block_process);
    if(block_stop)Block_release(block_stop);
	[super dealloc];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (pNotifyThread && ![pNotifyThread isEqual:[NSThread currentThread]]) {
        [self performSelector:@selector(requestFinished_notify:) onThread:pNotifyThread withObject:request waitUntilDone:NO];
    } else {
        [self requestFinished_notify:request];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSLog(@"\nrequestFailed:%d",[request responseStatusCode]);
    NSError* err=[request error];
    if(err){
        //NSLog(@"requestFailed:%d\n%@\n%@\n",err.code,err.domain,err.userInfo);
    }
    if (pNotifyThread && ![pNotifyThread isEqual:[NSThread currentThread]]) {
        [self performSelector:@selector(requestFailed_notify:) onThread:pNotifyThread withObject:request waitUntilDone:NO];
    } else {
        [self requestFailed_notify:request];
    }
}

- (void)setProgress:(float)newProgress
{
    if (newProgress<=0) {
        return;
    }
    
    if (pNotifyThread && ![pNotifyThread isEqual:[NSThread currentThread]]) {
        [self performSelector:@selector(setProgress_notify:) onThread:pNotifyThread withObject:[NSNumber numberWithFloat:newProgress] waitUntilDone:NO];
    } else {
        [self setProgress_notify:[NSNumber numberWithFloat:newProgress]];
    }
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength
{
    if (newLength!=0) {
        lNeedDownloadTotalSize+=(long)newLength;
        if (!bUpload && !bStarted) {
            if (pNotifyThread && ![pNotifyThread isEqual:[NSThread currentThread]]) {
                [self performSelector:@selector(requestStarted_notify:) onThread:pNotifyThread withObject:request waitUntilDone:NO];
            } else {
                [self requestStarted_notify:request];
            }
            bStarted=TRUE;
        }
    }
}

- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength
{
    if (bUpload && !bStarted) {
        lUploadTotalSize=[request postLength];
        if (pNotifyThread && ![pNotifyThread isEqual:[NSThread currentThread]]) {
            [self performSelector:@selector(requestStarted_notify:) onThread:pNotifyThread withObject:request waitUntilDone:NO];
        } else {
            [self requestStarted_notify:request];
        }
        bStarted=TRUE;
    }
}

- (void)requestStarted_notify:(id)request
{
    if (self.cancled) {
        return;
    }
    ASIHTTPRequest* p=(ASIHTTPRequest*)request;
    if (pNotify) {
        if (bUpload) {
            pNotify->IHttpNotify_UploadStart(pRequest);
        }
        else {
            pNotify->IHttpNotify_DownStart(pRequest,[p contentLength]);
        }
    }
    if (idNotify) {
        if (bUpload && [idNotify respondsToSelector:@selector(IHttpNotify_UploadStart:)]) {
            [idNotify IHttpNotify_UploadStart:pRequest];
        }
        else if ([idNotify respondsToSelector:@selector(IHttpNotify_DownStart:totalsize:)]) {
            [idNotify IHttpNotify_DownStart:pRequest totalsize:[p contentLength]];
        }
    }
    if (block_start) {
        block_start(pRequest);
    }
}

- (void)requestFinished_notify:(id)request
{
    if (cancled) {
        return;
    }
    if ([http responseStatusCode]<300 && !bUpload && [strSaveFile length]>0) {
        [self writeToFile];
    }
    
    finished=YES;
    
    ASIHTTPRequest* p=(ASIHTTPRequest*)request;
    BOOL b=![p isCancelled] && ![p error] && ([request responseStatusCode]<300 || [request responseStatusCode]==416);
    if (pNotify) {
        pNotify->IHttpNotify_Stop(pRequest,b);
    }
    if (idNotify && [idNotify respondsToSelector:@selector(IHttpNotify_Stop:success:)]) {
        [idNotify IHttpNotify_Stop:pRequest success:b];
    }
    if (block_stop) {
        block_stop(pRequest,b);
    }
}

- (void)requestFailed_notify:(id)request
{
    if (cancled) {
        return;
    }
    finished=YES;
    
    if (pNotify) {
        pNotify->IHttpNotify_Stop(pRequest,FALSE);
    }
    if (idNotify && [idNotify respondsToSelector:@selector(IHttpNotify_Stop:success:)]) {
        [idNotify IHttpNotify_Stop:pRequest success:FALSE];
    }
    if (block_stop) {
        block_stop(pRequest,FALSE);
    }
}

- (void)setProgress_notify:(id)newProgress
{
    if (cancled || finished) {
        return;
    }
    NSNumber* p=(NSNumber*)newProgress;
    
    if ([p floatValue]<fLastNotifySize) {
        return;
    }
    fLastNotifySize=[p floatValue];
    
    if ([http responseStatusCode]<300 && !bUpload && [strSaveFile length]>0) {
        [self writeToFile];
    }

    __block long lTotalSize=bUpload?lUploadTotalSize:(lNeedDownloadTotalSize+lContinueSize);
    __block long lCurrentSize=bUpload?lTotalSize*[p floatValue]:([[http responseData] length]+lContinueSize);
    __block unsigned long ulSpeed=[ASIHTTPRequest averageBandwidthUsedPerSecond];
    
    if ([http responseStatusCode]==416) {
        lTotalSize=lCurrentSize=lContinueSize;
        ulSpeed=0;
    }
    if (pNotify) {
        pNotify->IHttpNotify_Process(pRequest, lTotalSize, lCurrentSize,ulSpeed);
    }
    if (idNotify && [idNotify respondsToSelector:@selector(IHttpNotify_Process:totalsize:currentsize:speed:)]) {
        [idNotify IHttpNotify_Process:pRequest totalsize:lTotalSize currentsize:lCurrentSize speed:ulSpeed];
    }
    if (block_process) {
        block_process(pRequest,lTotalSize,lCurrentSize,ulSpeed);
    }
}

- (void)writeToFile
{
    NSData* pData=[http responseData];
    long length=[pData length];
    if (length>lWriteSize) {
        FILE* f=fopen([strSaveFile UTF8String],"ab+");
        if (f) {
            fwrite((char*)[pData bytes]+lWriteSize, sizeof(char),length-lWriteSize,f);
            fflush(f);
            lWriteSize=length;
            fclose(f);
        }
    }
}

@end

