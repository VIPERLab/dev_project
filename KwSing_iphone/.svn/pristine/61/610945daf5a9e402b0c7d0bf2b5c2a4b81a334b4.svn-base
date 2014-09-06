//
//  HttpRequest.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-19.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_HttpRequest_h
#define KwSing_HttpRequest_h

#import <string>
#import "IHttpNotify.h"
#import "ASIHTTP/ASIHTTPRequest.h"
#import "IObserverApp.h"

#ifndef IN
#define IN
#endif
#ifndef OUT
#define OUT
#endif

typedef void(^BLOCK_START)(CHttpRequest*);
typedef void(^BLOCK_PROCESS)(CHttpRequest*,unsigned,unsigned,unsigned);
typedef void(^BLOCK_STOP)(CHttpRequest*,BOOL);

@class KSHttpRequestHelper;

class CHttpRequest
{
public:
    //网络状态，就一个函数，不值得单独到外面
    static KSNetworkStatus GetNetWorkStatus();
    static std::string GetNetWorkProviderName();
    
    //换取防盗链
    typedef struct
    {
        std::string strRid;
        std::string strBitrate;
        std::string strContinueSig;
        BOOL bOnlyMusic;//伴奏
    }CONVERT_URL_PARA;
    
    static BOOL ConvertUrl(IN const CONVERT_URL_PARA& para
                           ,OUT std::string& strFormat
                           ,OUT std::string& strBitrate
                           ,OUT std::string& strUrl
                           ,OUT std::string& strSig);
    
    
    //简便用法，适合不关心返回body的场合，需要body内容请用下面的三步用法
    
    //同步Get
    static BOOL QuickSyncGet(IN const std::string& strUrl
                             ,OUT std::string& strOut);
    
    //同步Get,pData请传空指针变量，返回的数据外面用完需要自己delete[]
    static BOOL QuickSyncGet(IN const std::string& strUrl
                             ,OUT void*&pData
                             ,OUT unsigned& len);
    
    //同步Posts
    //***NSString请用NSString专用的重载，否则len需要用lengthOfBytesUsingEncoding:NSUTF8StringEncoding计算***
    //strKey不为空的话，Post请求将以FormRequest方式进行（模拟网页Post提交）
    static BOOL QuickSyncPost(IN const std::string& strUrl
                              ,IN  const void* pData
                              ,IN unsigned len
                              ,IN const std::string& strKey=std::string());
    
    //同步Post，std::string重载
    static BOOL QuickSyncPost(IN const std::string& strUrl
                              ,IN  const std::string& strSend
                              ,IN const std::string& strKey=std::string());
    
    //同步Post，NSString专用重载，省去计算UTF8长度的麻烦
    static BOOL QuickSyncPost(IN NSString* strUrl
                              ,IN  NSString* strSend
                              ,IN NSString* strKey=NULL);
    
    //异步Get，在线程中执行，通过block处理状态，block_stop执行完毕后，http对象会自动销毁
    static BOOL QuickAsyncGet(IN const std::string& strUrl
                              ,void(^block_start)(CHttpRequest*)
                              ,void(^block_process)(CHttpRequest*,unsigned uiTotalSize,unsigned uiCurrentSize,unsigned uiSpeed)=NULL
                              ,void(^block_stop)(CHttpRequest*,BOOL bSuccess)=NULL
                              ,NSThread* pNotifyTargetThread=NULL/*默认currentThread*/
                              );
     
    
    //三步用法：declare---SendRequest---ReadData/response notify
    //***记得异步请求不要放在栈上，否则出了作用域析构的时候会cancle掉***
    //***异步接受通知的线程一定要有RunLoop，否则通知没有机会被执行***
    //strKey不为空，Post请求将以FormRequest方式进行（模拟网页Post提交）
    
    //Get
    CHttpRequest(const std::string& strUrl);
    
    //Upload file
    CHttpRequest(const std::string& strUrl
                 ,const std::string& strSendFile
                 ,const std::string& strKey=std::string()
                 ,NSDictionary* dictKeyValue=NULL);
    
    //Post
    CHttpRequest(const std::string& strUrl
                 ,const void* pData
                 ,unsigned len
                 ,const std::string& strKey=std::string());
    
    //Post NSString专用重载
    CHttpRequest(const std::string& strUrl
                 ,NSString* strPost
                 ,NSString* strKey=NULL);
    
    //以表单形式post提交
    CHttpRequest(const std::string& strUrl
                 ,NSDictionary* dictKeyValue);
    

    
    //同步请求，大多数同步请求用Quick方法即可，此处的复杂用法用于需要获取请求详细信息的场合
    //bAllowContinue为TRUE的话，如果strSaveFile存在，则以文件大小为start range向服务器请求断点续传
    BOOL SyncSendRequest(const std::string& strSaveFile=std::string(),BOOL bAllowContinue=FALSE);
    
    //异步请求通过回调通知，可以指定在哪个线程里执行回调(默认为主线程)，便于省掉加锁操作。
    //NSThread对象可以通过在对应线程里调用[NSThread currentThread]等api来获取，要求Thread有RunLoop
    //NSThread引用计数会加一，Http对象析构之后会减一
    BOOL AsyncSendRequest(IHttpRequestNotify* pNotify=NULL
                         ,const std::string& strSaveFile=std::string()
                         ,BOOL bAllowContinue=FALSE);
    
    BOOL AsyncSendRequest(id<IHttpRequestNotify> idNotify
                         ,const std::string& strSaveFile=std::string()
                         ,BOOL bAllowContinue=FALSE);
    
    BOOL AsyncSendRequest(void(^block_start)(CHttpRequest*)
                          ,void(^block_process)(CHttpRequest*,unsigned uiTotalSize,unsigned uiCurrentSize,unsigned uiSpeed)=NULL
                          ,void(^block_stop)(CHttpRequest*,BOOL bSuccess)=NULL
                          ,const std::string& strSaveFile=std::string()
                          ,BOOL bAllowContinue=FALSE);
    
    void StopRequest();
    
    BOOL IsFinished() const;
    
    BOOL IsSuccess() const;
    
    unsigned GetRetCode() const;
    
    void SetTimeOut(unsigned t);
    
    //发起异步请求之后，可以通过这个函数来分段取数据
    //在请求没有完成(成功or失败)前，如果数据不够lSize大小，会执行RunLoop阻塞等待新数据的到来
    BOOL ReadData(OUT void* pBuf,IN OUT unsigned& uiSize);
    
    //一次读取所有数据，请求结束前，当前缓冲区有多少数据就能独到多少数据，记得自己外面delete[]，虽然不合规则，但比较方便
    BOOL ReadAll(OUT void*& pBuf,IN OUT unsigned& uiSize) const;
    
    //当前已经接收到的数据量
    unsigned GetSize() const;
    
    //OMG 更复杂的功能直接调吧。。。
    ASIHTTPRequest* GetOriginalRequestObject();
    
public:
    ~CHttpRequest();
    
private:
    void Init(const std::string& strUrl);
    BOOL CheckWriteFile(const std::string& strFile,BOOL bAllowContinue);
    __block KSHttpRequestHelper* m_pHelper;
    __block ASIHTTPRequest* m_pHttp;
    unsigned m_lPos;
};

#endif
