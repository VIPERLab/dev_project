//
//  IHttpNotify.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IHttpNotify_h
#define KwSing_IHttpNotify_h

#import <string>

class CHttpRequest;

@protocol IHttpRequestNotify <NSObject>
@optional
-(void)IHttpNotify_DownStart:(CHttpRequest*)pRequest totalsize:(long)lTotalSize;

-(void)IHttpNotify_UploadStart:(CHttpRequest*)pRequest;

-(void)IHttpNotify_Process:(CHttpRequest*)pRequest totalsize:(long)lTotalSize currentsize:(long)lCurrentSize speed:(long)lSpeed;

-(void)IHttpNotify_Stop:(CHttpRequest*)pRequest success:(BOOL)bSuccess;
@end

class IHttpRequestNotify
{
public:
    virtual void IHttpNotify_DownStart(CHttpRequest* pRequest,long lTotalSize){}
     
    virtual void IHttpNotify_UploadStart(CHttpRequest* pRequest){}
    
    virtual void IHttpNotify_Process(CHttpRequest* pRequest,long lTotalSize,long lCurrentSize,long lSpeed){}
    
    virtual void IHttpNotify_Stop(CHttpRequest* pRequest,BOOL bSuccess){}
};

#endif
