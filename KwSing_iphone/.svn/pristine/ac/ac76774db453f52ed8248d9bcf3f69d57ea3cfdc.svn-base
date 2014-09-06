//
//  HttpRequestHelper.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-24.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_HttpRequestHelper_h
#define KwSing_HttpRequestHelper_h

#include "ASIHTTP/ASIHTTPRequestDelegate.h"
#include "ASIHTTP/ASIProgressDelegate.h"
#include "IHttpNotify.h"

class CHttpRequest;
@class ASIHTTPRequest;

typedef void(^BLOCK_START)(CHttpRequest*);
typedef void(^BLOCK_PROCESS)(CHttpRequest*,unsigned,unsigned,unsigned);
typedef void(^BLOCK_STOP)(CHttpRequest*,BOOL);

@interface KSHttpRequestHelper:NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>
{
    unsigned lUploadTotalSize;
    unsigned lNeedDownloadTotalSize;
    BOOL bStarted;
    unsigned lWriteSize;
    float fLastNotifySize;
}
@property (nonatomic,assign) CHttpRequest* pRequest;
@property (nonatomic,copy) NSString* strSaveFile;
@property (nonatomic,assign) IHttpRequestNotify* pNotify;
@property (nonatomic,assign) id<IHttpRequestNotify> idNotify; 
@property (nonatomic,retain) NSThread* pNotifyThread;

@property (nonatomic,assign) __block BLOCK_START block_start;
@property (nonatomic,assign) __block BLOCK_PROCESS block_process;
@property (nonatomic,assign) __block BLOCK_STOP block_stop;

@property (nonatomic,assign) BOOL bUpload;
@property (nonatomic,assign) unsigned lContinueSize;

@property (assign) BOOL cancled;
@property (assign) BOOL finished;
@property (nonatomic,retain) ASIHTTPRequest* http;


- (void)dealloc;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

- (void)setProgress:(float)newProgress;
- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength;
- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength;

- (void)requestStarted_notify:(id)request;
- (void)requestFinished_notify:(id)request;
- (void)requestFailed_notify:(id)request;
- (void)setProgress_notify:(id)newProgress;

- (void)writeToFile;
@end


#endif
