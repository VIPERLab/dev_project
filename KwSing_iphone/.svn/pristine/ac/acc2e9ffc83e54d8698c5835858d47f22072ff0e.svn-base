//
//  MyOpusData.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-9-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "MyOpusData.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "SongInfo.h"
#include "IMyOpusObserver.h"
#include "HttpRequest.h"
#include "KwTools.h"
#include "KuwoConstants.h"
#include "User.h"
#include "KuwoLog.h"
#include "KwUMengElement.h"
#include "UMengLog.h"
#include "MobClick.h"
#include "KwUMengElement.h"
#include "RecordTask.h"

#define FILENAME_MYOPUS @"myopus.plist"

CMyOpusData* CMyOpusData::GetInstance()
{
    static CMyOpusData sData;
    return &sData;
}

CMyOpusData::CMyOpusData()
{
    m_pStrSaveFilePath=[GetSaveFilePath() retain];
    
    LoadData();
    
    m_dispatchQueue=dispatch_queue_create("com.KwSing.MyOpusQueue", NULL);
    
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP,IObserverApp);
}

CMyOpusData::~CMyOpusData()
{
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    
    dispatch_release(m_dispatchQueue);
    
    SaveData();
    ReleaseData();
    
    [m_pStrSaveFilePath release];
}

BOOL CMyOpusData::AddSong(const CRecoSongInfo* pInfo)
{
    if (!pInfo) {
        return FALSE;
    }
    CRecoSongInfo* pCopy=new CRecoSongInfo;
    *pCopy=*pInfo;
    pCopy->eumLocalState=CRecoSongInfo::STATE_NOUPLOAD;
    
    NSDateFormatter* fmt=[[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    pCopy->strSaveTime=[[fmt stringFromDate:[NSDate date]] UTF8String];
    [fmt release];
    
    m_vecSongs.insert(m_vecSongs.begin(), pCopy);
    
    SaveData();
    
    SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::AddSong,pCopy);
    SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::Refresh);
    
    return TRUE;
}

BOOL CMyOpusData::RemoveSong(unsigned idx,RemoveType t)
{
    if (idx>=m_vecSongs.size()) {
        return FALSE;
    }
    CRecoSongInfo* info=m_vecSongs[idx];
    
    SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::BeforeDeleteItem,idx,info);
    
    if (t & REMOVE_REMOTE) {
        RemoveRemote(info);
    }
    if (t & REMOVE_LOCAL) {
        KwTools::Dir::DeleteFile(info->strLocalPicPack);
        KwTools::Dir::DeleteFile(info->recoRes.strLocalPath);
        m_vecSongs.erase(m_vecSongs.begin()+idx);
    }
    
    SaveData();
    
    SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::AfterDeleteItem,idx);
    SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::Refresh);
    return TRUE;
}

#define DELETE_URL "http://changba.kuwo.cn/kge/mobile/DelKge?"
BOOL CMyOpusData::RemoveRemote(CRecoSongInfo* info)
{
    if (info->eumLocalState!=CRecoSongInfo::STATE_UPLOADED || info->strKid.empty()) {
        return FALSE;
    }
    std::vector<CRecoSongInfo*>::iterator ite=std::find(m_vecSongs.begin(),m_vecSongs.end(),info);
    if (ite==m_vecSongs.end()) {
        return FALSE;
    }
    int nPos(std::distance(m_vecSongs.begin(), ite));
    
    std::string strUrl=KwTools::StringUtility::Format("%skid=%s&uid=%s&sid=%s",
                                                      DELETE_URL
                                                      ,info->strKid.c_str()
                                                      ,[User::GetUserInstance()->getUserId() UTF8String]
                                                      ,[User::GetUserInstance()->getSid() UTF8String]);
    info->eumLocalState=CRecoSongInfo::STATE_DELETING;
    SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::BeforeDeleteItem,nPos,info);
    SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::Refresh);

    KS_BLOCK_DECLARE
    {
        BOOL bSuccess(FALSE);
        std::string strOut;
        if(CHttpRequest::QuickSyncGet(strUrl, strOut))
        {
            std::vector<std::string> vecTokens;
            KwTools::StringUtility::Tokenize(strOut, "=", vecTokens);
            if (vecTokens.size()>=2 && (vecTokens[1].substr(0,2)=="ok" || vecTokens[2].substr(0,6)=="no_kge")) {
                bSuccess=TRUE;
            }
        }
        info->eumLocalState=bSuccess?CRecoSongInfo::STATE_NOUPLOAD:CRecoSongInfo::STATE_UPLOADED;
        
        SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::AfterDeleteItem,nPos,info);
        SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::Refresh);
    }
    KS_BLOCK_RUN_THREAD();
    
    return TRUE;
}

CRecoSongInfo* CMyOpusData::GetSong(unsigned idx)
{
    if (idx>=m_vecSongs.size()) {
        return NULL;
    }
    return m_vecSongs[idx];
}

void CMyOpusData::GetAllSongs(std::vector<CRecoSongInfo*> &vecSongs)
{
    vecSongs=m_vecSongs;
}

unsigned CMyOpusData::GetSongNum()
{
    return m_vecSongs.size();
}


#define UPLOAD_URL "http://mboxspace.kuwo.cn/ks/mobile/Upload?"
//#define UPLOAD_URL "http://60.28.205.41/ks/mobile/Upload?"
std::string CMyOpusData::CreateUploadUrl(const CRecoSongInfo* pSong,UPLOAD_STEP step)
{
    if (step==STEP_PIC_PACKAGE && pSong->strLocalPicPack.empty()) {
        return "";
    }
    
    BOOL bVideo=KwTools::Dir::GetFileExt(pSong->recoRes.strLocalPath)=="mp4";
    return KwTools::StringUtility::Format(UPLOAD_URL
                                          "src=kwsing_ios"
                                          "&type=%s"
                                          "&step=%d"
                                          "&title=%s"
                                          "&userid=%s"
                                          "&rid=%s"
                                          "&mediaType=%s"
                                          "&artist=%s"
                                          "&sid=%s"
                                          ,bVideo?"video":"audio"
                                          ,bVideo?STEP_MUSIC_FILE:step
                                          ,KwTools::Encoding::UrlEncode(pSong->strSongName).c_str()
                                          ,[User::GetUserInstance()->getUserId() UTF8String]
                                          ,pSong->strRid.c_str()
                                          ,bVideo?"mp4":"aac"
                                          ,KwTools::Encoding::UrlEncode(pSong->strArtist).c_str()
                                          ,[User::GetUserInstance()->getSid() UTF8String]
                                          ,pSong->strLocalPicPack.empty()?"false":"true"
                                          );
}

CMyOpusData::SEND_RESULT CMyOpusData::SendFile(CRecoSongInfo* pSong,const std::string& strUrl,const std::string& strFile)
{
    NSLog(@"uploda song:%s",strUrl.c_str());
    unsigned uiLastPercent=pSong->uiUploadPercent;
    
    __block CMyOpusData::SEND_RESULT sendRes(SEND_FAIL);
    __block unsigned uiLastNotifyProgress(0);
    
    BLOCK_START blockStart=^(CHttpRequest* p){};
    BLOCK_PROCESS blockProcess=^(CHttpRequest* p,unsigned uiTotalSize,unsigned uiCurrentSize,unsigned uiSpeed){
        if (uiCurrentSize>0) {
            KS_BLOCK_DECLARE
            {
                if (pSong->strLocalPicPack.empty()) {
                    pSong->uiUploadPercent=uiCurrentSize*100/uiTotalSize;
                } else {
                    pSong->uiUploadPercent=uiLastPercent+uiCurrentSize*50/uiTotalSize;
                }
                if (pSong->uiUploadPercent>100) {
                    pSong->uiUploadPercent=100;
                }
                if (pSong->uiUploadPercent<uiLastNotifyProgress) {
                    pSong->uiUploadPercent=uiLastNotifyProgress;
                } else {
                    uiLastNotifyProgress=pSong->uiUploadPercent;
                }
//                NSLog(@"UploadProcess:%d  %d",pSong->uiUploadPercent,[p->GetOriginalRequestObject() responseStatusCode]);
                int nPos(-1);
                std::vector<CRecoSongInfo*>::iterator ite=std::find(m_vecSongs.begin(),m_vecSongs.end(),pSong);
                if (ite!=m_vecSongs.end()) {
                    nPos=std::distance(m_vecSongs.begin(), ite);
                }
                
                SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::UploadProgress,nPos,pSong,uiLastNotifyProgress);
                SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::Refresh);
            }
            KS_BLOCK_SYNRUN();
        }
    };
    __block BOOL bFinished(FALSE);
    BLOCK_STOP blockStop=^(CHttpRequest* p,BOOL b){
//        NSLog(@"UploadFinishedMsg,code=%d success=%d",p->GetRetCode(),b);
        UMengLog(KS_UPLOAD_MUSIC, [[NSString stringWithFormat:@"httpRequestMsg,retCode=%d,success=%d",p->GetRetCode(),b] UTF8String]);
        while (TRUE) {
            if (b && p->GetRetCode()==200) {
                void* pBuf(NULL);
                unsigned uiSize(0);
                if(!p->ReadAll(pBuf, uiSize) || !pBuf || !uiSize || uiSize>32) {
                    if (pBuf) {
                        delete[] (char*)pBuf;
                    }
                    break;
                }
                std::string strRet((char*)pBuf,uiSize);
                delete[] (char*)pBuf;
//                NSLog(@"UploadFinished:%s",strRet.c_str());
                std::vector<std::string> vecTokens;
                KwTools::StringUtility::Tokenize(strRet, "|", vecTokens);
//                UMengLog(KS_UPLOAD_MUSIC, vecTokens[0]+vecTokens[1]);
                if (vecTokens.size()==2 && vecTokens[0] == "500") {
                    sendRes=SEND_BEYOND_LIMIT;
                    break;
                }
                if (vecTokens.size()<3 || vecTokens[1]!="ok") {
                    break;
                }
                
                KS_BLOCK_DECLARE
                {
                    pSong->strKid=vecTokens[2];
                }
                KS_BLOCK_SYNRUN();
                sendRes=SEND_SUCCESS;
            }
            break;
        }
        bFinished=TRUE;
    };

//    NSLog(@"filesize:%ld",KwTools::Dir::GetFileSize(strFile));
    CHttpRequest* pRequest=new CHttpRequest(strUrl,strFile);
    m_bCancel=false;
    if(pRequest->AsyncSendRequest(blockStart,blockProcess,blockStop))
    {
        //NSTimeInterval t=[NSDate timeIntervalSinceReferenceDate];
        while (!pRequest->IsFinished() || !bFinished) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.25]];
            //NSLog(@"time:%f",t);
            //[NSDate timeIntervalSinceReferenceDate]-t>(CHttpRequest::GetNetWorkStatus()==NETSTATUS_WIFI?60:120
            if (m_bCancel) {
//                NSLog(@"cancel upload");
                sendRes=SEND_TIMEOUT;
                break;
            }
        }
        pRequest->StopRequest();
    }
    delete pRequest;

    return sendRes;
}

void CMyOpusData::cancelUpload()
{
    m_bCancel=true;
}

BOOL CMyOpusData::UploadSong(unsigned idx)
{
    if (CHttpRequest::GetNetWorkStatus()==NETSTATUS_NONE) {
        return FALSE;
    }
    if (idx>=m_vecSongs.size()) {
        return FALSE;
    }
    CRecoSongInfo* pInfo=m_vecSongs[idx];
    if (pInfo->eumLocalState==CRecoSongInfo::STATE_UPLOADED) {
        return TRUE;
    }
    if (pInfo->eumLocalState!=CRecoSongInfo::STATE_NOUPLOAD) {
        return FALSE;
    }
    if (!KwTools::Dir::IsExistFile(pInfo->recoRes.strLocalPath)) {
        return FALSE;
    }
    pInfo->eumLocalState=CRecoSongInfo::STATE_UPLOADING;
    pInfo->uiUploadPercent=0;
    
    std::string strPreparePicPackUrl=CreateUploadUrl(pInfo,STEP_PIC_PACKAGE);
    std::string strPrepareMusicUrl=CreateUploadUrl(pInfo,STEP_MUSIC_FILE);
    //NSLog(@"pic:%@\nmusic:%@",[NSString stringWithUTF8String:strPreparePicPackUrl.c_str()],[NSString stringWithUTF8String:strPrepareMusicUrl.c_str()]);
    std::string strPicPackDir=pInfo->strLocalPicPack;
    std::string strMusicFile=pInfo->recoRes.strLocalPath;
    pInfo->strKid.clear();
    
    dispatch_async(m_dispatchQueue,^{
        CRecoSongInfo::LOCAL_STATE state(CRecoSongInfo::STATE_NOUPLOAD);
        
        
        NSTimeInterval tStart=[NSDate timeIntervalSinceReferenceDate];
        
        std::string strMusicUrl=strPrepareMusicUrl+KwTools::StringUtility::Format("&size=%d&score=%d"    //崩溃，最后关头非要加上个大小，乱改
                                                                                  ,KwTools::Dir::GetFileSize(strMusicFile),
                                                                                pInfo->uiPoints);
        if (User::GetUserInstance()->getPartInType() == PARTIN) {
            strMusicUrl=strMusicUrl+"&from=HRB";
        }
        else if (CRecordTask::GetInstance()->m_bIsOtherActivity){
            NSArray *array = CRecordTask::GetInstance()->m_ActivityArray;
            if (array && [array count] > 0) {
                for (NSDictionary *dic in array) {
                    if (dic != nil) {
                        NSString *actiId = [dic objectForKey:@"bangId"];
                        if (actiId !=nil && [actiId UTF8String] == CRecordTask::GetInstance()->activityId) {
                            NSString *type = [dic objectForKey:@"type"];
                            if (type != nil) {
                                strMusicUrl = strMusicUrl + "&from=" +[type UTF8String];
                            }
                        }
                    }
                }
            }
        }
        SEND_RESULT sendRes(SEND_SUCCESS);
        [MobClick beginEvent:[NSString stringWithUTF8String:KS_UPLOAD_TIME]];
        if (!strPreparePicPackUrl.empty())
        {
            SEND_RESULT sendPicRes(SEND_FAIL);
            std::string strTempPicPackPath;
            KwTools::Dir::GetPath(KwTools::Dir::PATH_CASHE,strTempPicPackPath);
            strTempPicPackPath+="/TempPicPack";
            KwTools::Dir::MakeDir(strTempPicPackPath);
            strTempPicPackPath+="/picpack.zip";
            KwTools::Dir::DeleteFile(strTempPicPackPath);
            
            std::vector<std::string> vecFiles;
            if (KwTools::Dir::FindFiles(strPicPackDir, "jpg", vecFiles)
                && KwTools::Filezip::Compress(vecFiles, strTempPicPackPath) )
            {
                std::string strPicPackUrl=strPreparePicPackUrl+KwTools::StringUtility::Format("&size=%d"
                                                                                            ,KwTools::Dir::GetFileSize(strTempPicPackPath));
                SEND_RESULT picRes=SendFile(pInfo,strPicPackUrl, strTempPicPackPath);
                if ( picRes== SEND_SUCCESS) {
                    sendPicRes=SEND_SUCCESS;
                    state=CRecoSongInfo::STATE_UPLOADED;
                }
                else if (picRes == SEND_BEYOND_LIMIT){
                    sendPicRes=SEND_BEYOND_LIMIT;
                }
                else if (picRes == SEND_TIMEOUT){
                    sendPicRes = SEND_TIMEOUT;
                }
                
            }
            KwTools::Dir::DeleteFile(strTempPicPackPath);
            sendRes=sendPicRes;
        }
        
        if (!pInfo->strKid.empty()) {
            strMusicUrl += "&kid="+pInfo->strKid;
        }
        SEND_RESULT musicRes = SEND_FAIL;
        if (SEND_SUCCESS == sendRes) {
            musicRes = SendFile(pInfo,strMusicUrl,strMusicFile);
        }
        
        [MobClick endEvent:[NSString stringWithUTF8String:KS_UPLOAD_TIME]];
        
        if(sendRes == SEND_SUCCESS && musicRes ==SEND_SUCCESS)
        {
            state=CRecoSongInfo::STATE_UPLOADED;
        }
        else if(sendRes == SEND_BEYOND_LIMIT || musicRes == SEND_BEYOND_LIMIT){
            sendRes=SEND_BEYOND_LIMIT;
            state=CRecoSongInfo::STATE_NOUPLOAD;
        }
        else if (sendRes == SEND_TIMEOUT || musicRes == SEND_TIMEOUT){
            sendRes=SEND_TIMEOUT;
            state=CRecoSongInfo::STATE_NOUPLOAD;
        }
        else{
            sendRes=SEND_FAIL;
            state=CRecoSongInfo::STATE_NOUPLOAD;
        }
        double tUsed=[NSDate timeIntervalSinceReferenceDate] - tStart;
        
        KS_BLOCK_DECLARE
        {
            pInfo->eumLocalState=state;
            pInfo->uiUploadPercent = state==CRecoSongInfo::STATE_UPLOADED?100:0;
            
            RTLog_UpLoadMusic(sendRes==SEND_SUCCESS?AR_SUCCESS:AR_FAIL, pInfo->strSongName.c_str()
                              ,pInfo->strArtist.c_str(),pInfo->strRid.c_str(),GetFormatName(pInfo->recoRes.eumFormat),(int)(tUsed*1000));
            
        }
        KS_BLOCK_SYNRUN();
        
        SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::FinishUploadOne,idx,pInfo,sendRes);
        SYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::Refresh);
    });
    
    return TRUE;
}

void CMyOpusData::LoadData()
{
    NSMutableDictionary* array = [NSMutableArray arrayWithContentsOfFile:m_pStrSaveFilePath];
    for (NSMutableDictionary *dict in array)
    {
        CRecoSongInfo* pInfo=new CRecoSongInfo;
        pInfo->LoadFromDict(dict);
        if(pInfo->eumLocalState==CRecoSongInfo::STATE_DELETING) {
            pInfo->eumLocalState=CRecoSongInfo::STATE_NOUPLOAD;
        }
        //覆盖安装应用程序id变化，修改以前保存作品的绝对路径
        //NSLog(@"before:%s",pInfo->recoRes.strLocalPath.c_str());
        int pos = pInfo->recoRes.strLocalPath.find("/MyOpus");
        if (-1 != pos) {
            pInfo->recoRes.strLocalPath = [KwTools::Dir::GetPath(KwTools::Dir::PATH_OPUS) UTF8String] + pInfo->recoRes.strLocalPath.substr(pos + 7);
        }
        pos = pInfo->strLocalPicPack.find("/Caches");
        if (-1 != pos) {
            pInfo->strLocalPicPack = [KwTools::Dir::GetPath(KwTools::Dir::PATH_LIBRARY) UTF8String] + pInfo->strLocalPicPack.substr(pos);
        }
        //NSLog(@"after:%s",pInfo->recoRes.strLocalPath.c_str());
        m_vecSongs.push_back(pInfo);
    }
    ASYN_NOTIFY(OBSERVER_ID_MYOPUS, IMyOpusObserver::Refresh, 0);
}

void CMyOpusData::SaveData()
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:m_vecSongs.size()];
    for (int i=0; i<m_vecSongs.size(); ++i) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        m_vecSongs[i]->SaveToDict(dict);
        [array addObject:dict];
    }
    [array writeToFile:m_pStrSaveFilePath atomically:YES];
}

void CMyOpusData::ReleaseData()
{
    for (std::vector<CRecoSongInfo*>::iterator ite=m_vecSongs.begin(); ite!=m_vecSongs.end(); ++ite) {
        delete *ite;
    }
    m_vecSongs.clear();
}

NSString* CMyOpusData::GetSaveFilePath()
{
    NSString *filepath = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
    return [filepath stringByAppendingPathComponent:FILENAME_MYOPUS];
}

void CMyOpusData::IObserverApp_ResignActive()
{
    SaveData();
}




