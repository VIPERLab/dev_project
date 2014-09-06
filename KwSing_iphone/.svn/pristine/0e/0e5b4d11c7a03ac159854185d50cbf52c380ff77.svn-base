//
//  KwUpdate.cpp
//  KwSing
//
//  Created by Qian Hu on 12-7-24.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include <iostream>
#include "KwUpdate.h"
#include "log.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "KwConfig.h"
#include "debug.h"
#import <zlib.h>
#include "base64_.h"
#include "KuwoConstants.h"
#include "KuwoLog.h"
#include "HttpRequest.h"
#include "IObserverApp.h"

BOOL KwUpdate::CreateUploadLogFile(const char* logFile, const char* uploadFile)
{
#define CHUNK 8192
    char* dst = NULL;
    char* src = NULL;
	
    FILE* fpSrc = fopen(logFile, "rb");
    FILE* fpZip = fopen(uploadFile, "wb");
    if (!fpSrc || !fpZip)
        goto _Error;
    z_stream stream;
    int err;
    
    dst = (char*)malloc(CHUNK);
    src = (char*)malloc(CHUNK);
    
    stream.zalloc = (alloc_func)0;
    stream.zfree = (free_func)0;
    stream.opaque = (voidpf)0;
    
    stream.next_in = NULL;
    stream.avail_in = 0;
    
    err = deflateInit(&stream, Z_DEFAULT_COMPRESSION);
    if (Z_OK != err)
        goto _Error;
	int flush;
	do {
		size_t size = fread(src + stream.avail_in, 1, CHUNK, fpSrc);
        if (ferror(fpSrc))
            break;
        stream.next_in = (Bytef*)src;
        stream.avail_in += size;
		
        flush = feof(fpSrc) ? Z_FINISH : Z_NO_FLUSH;
		
        /* run deflate() on input until output buffer not full, finish
		 compression if all of source has been read in */
        do {
            stream.avail_out = CHUNK;
            stream.next_out = (Bytef*)dst;
			
            err = deflate(&stream, flush);    /* no bad return value */
            assert(err != Z_STREAM_ERROR);  /* state not clobbered */
			
            size_t have = CHUNK - stream.avail_out;
            if (fwrite(dst, 1, have, fpZip) != have || ferror(fpZip)) {
                (void)deflateEnd(&stream);
                return Z_ERRNO;
            }
			
        } while (stream.avail_out == 0);
        assert(stream.avail_in == 0);     /* all input will be used */
		
        /* done when last data in file processed */
    } while (flush != Z_FINISH);
    assert(err == Z_STREAM_END);        /* stream will be complete */
	
    /* clean up and return */
    (void)deflateEnd(&stream);
    
    
_Error:
    if (fpSrc)
        fclose(fpSrc);
    if (fpZip)
        fclose(fpZip);
	
	if (src)
		free(src);
	if (dst)
		free(dst);
    
    return TRUE;
}

BOOL KwUpdate::UploadLogFileThread(NSString* file)
{
#if defined (DEBUG) || defined (_DEBUG)
	//NSLog(@"UploadLogFileThread start...");
#endif
    
    @autoreleasepool {
        //    NSString* file = [(NSString*)param autorelease];
        if (!file || [file length] == 0)
        {
            return 0;
        }
        
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSString* fileZip = [file stringByAppendingString:@"~"];
        
        if (!CreateUploadLogFile([file UTF8String], [fileZip UTF8String]))
        {
            [fileMgr removeItemAtPath:file error:NULL];
            return 0;
        }
        
        string strurl=KwTools::Encrypt::CreateDesUrl("type=clog");
        
        CHttpRequest* pReq=new CHttpRequest(strurl,[fileZip UTF8String]);
        if(!pReq->SyncSendRequest())
        {
            kuwoDebugLog(@"UploadClientLog",DEBUG_LOG,@"Upload clientlog failed!");
        }
        delete pReq;
        
        [fileMgr removeItemAtPath:file error:NULL];
        [fileMgr removeItemAtPath:fileZip error:NULL];
    }//@autoreleasepool
    
    return 0;
}

static void SendRealtimeLogThread(const char* content, int len)
{
	ASSERT(content != NULL);
    if (!content) {
        return;
    }
	if (len < 0)
		len = strlen(content);
    int logLen = base64_encode_length(len);
//#warning memory leaks  --音乐盒拷贝来的代码竟然带这么个注释，可耻啊可耻啊
    char* szBase64Log = (char*)malloc(logLen + 1);
    logLen = base64_encode(content, len, szBase64Log, logLen);

    std::string strurl=KwTools::Encrypt::CreateDesUrl("type=ilog");
    CHttpRequest::QuickSyncPost(strurl, (void*)szBase64Log, logLen+1);
	free(szBase64Log);
}

void KwUpdate::UpdateConfigThread()
{
    std::string strurl=KwTools::Encrypt::CreateDesUrl("type=getconfig");
    unsigned len;
    void *pvoid = NULL;
    if(CHttpRequest::QuickSyncGet(strurl, pvoid,len) && len != 0)
    {
        RTLog_DownloadConfig(AR_SUCCESS, CHttpRequest::GetNetWorkProviderName().c_str());
        int size = base64_decode_length(len)+1;
        char* buffer = new char[size];
        memset(buffer,0,size);
        size=KwTools::Base64::Base64Decode((char*)pvoid, len, buffer, size);
        delete [](char*)pvoid;
        if(!size)
        {
            delete []buffer;
            return;
        }
        buffer[size] = '\0';
        NSString * str = KwTools::Encoding::Gbk2Utf8(buffer);
        delete[] buffer;
        
        NSString *path = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
        NSString *confpath = [path stringByAppendingPathComponent:@SVR_CONFIG_FILE];
        FILE*fp = fopen([confpath UTF8String], "w");
        if(fp)
        {
            fwrite([str UTF8String], [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 1, fp);
            fclose(fp);
        }
        
        KS_BLOCK_DECLARE
        {
            KwConfig::GetConfigureInstance()->ReLoadSvrConfig();
            ASYN_NOTIFY(OBSERVER_ID_APP, IObserverApp::SvrConfigUpdateFinished, 0);
        }
        KS_BLOCK_SYNRUN();
    }
    else {
        RTLog_DownloadConfig(AR_FAIL, CHttpRequest::GetNetWorkProviderName().c_str());
    }
}


KwUpdate::KwUpdate()
{
    mUploadLogFlag = FALSE;
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP,IObserverApp);
}

KwUpdate::~KwUpdate()
{
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP,IObserverApp);
}

KwUpdate* KwUpdate::GetUpdateInstance()
{
    static KwUpdate g_update;
    return & g_update;
}

BOOL KwUpdate::BackupLogFile()
{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString* file = [NSString stringWithUTF8String:getClientLogFile()];
    if (![fileMgr fileExistsAtPath:file])
		return FALSE;
	
	NSError* error = nil;
	NSDictionary* attrDic = [fileMgr attributesOfItemAtPath:file error:&error];
	NSDate* date = [attrDic valueForKey:NSFileCreationDate];
	//NSDate* now = [NSDate date];
    NSTimeInterval timeInterval = fabs([date timeIntervalSinceNow]);
	if (timeInterval < 60 * 60 * 24)	// one day in seconds
		return FALSE;
    std::string strpath;
    KwTools::Dir::GetPath(KwTools::Dir::PATH_LOG,strpath);
    NSString * pstr = KwTools::Dir::GetPath(KwTools::Dir::PATH_LOG);
	NSString* fileBack = [pstr stringByAppendingPathComponent:TEMP_LOG_FILE];
	[fileMgr removeItemAtPath:fileBack error:NULL];
	[fileMgr moveItemAtPath:file toPath:fileBack error:NULL];
	
	mUploadLogFlag = TRUE;
	
	return TRUE;
}

BOOL KwUpdate::SendClientLogToServer()
{
    if(mUploadLogFlag)
    {
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSString* file = [KwTools::Dir::GetPath(KwTools::Dir::PATH_LOG) stringByAppendingPathComponent:TEMP_LOG_FILE];
        if (![fileMgr fileExistsAtPath:file])
        {
            return FALSE;
        }
    
        KS_BLOCK_DECLARE
        {
            mUploadLogFlag = FALSE;
            UploadLogFileThread(file);
        }
        KS_BLOCK_RUN_THREAD();
        
    }

    return TRUE;
}

BOOL KwUpdate::UpdateConfig()
{
    KS_BLOCK_DECLARE
    {
        UpdateConfigThread();
    }
    KS_BLOCK_RUN_THREAD();
    return TRUE;
}

BOOL KwUpdate::SendActiveRealLog()
{
    char szBuffer[1024];
    int length = BuildLogActivate(szBuffer, 1024, DEVICE_ID);
	RTLogString(szBuffer, length);
    
	SendRealLogToServer(szBuffer, length);

    return TRUE;
}

BOOL KwUpdate::SendRealLogToServer(const char* content, int len)
{
    char * pbuf = new char[1024];
    strcpy(pbuf, content);
    KS_BLOCK_DECLARE
    {
        SendRealtimeLogThread(pbuf,len);
        delete []pbuf;
    }
    KS_BLOCK_RUN_THREAD();
    
    return TRUE;
}

void KwUpdate::IObserverApp_NetWorkStatusChanged(KSNetworkStatus enumStatus)
{
    if(mUploadLogFlag && enumStatus == NETSTATUS_WIFI)
    {
        SendClientLogToServer();
    }
}




