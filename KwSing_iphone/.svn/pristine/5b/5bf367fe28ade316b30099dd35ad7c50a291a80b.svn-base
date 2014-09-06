//
//  MyOpusData.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-9-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__MyOpusData__
#define __KwSing__MyOpusData__

#include "SongInfo.h"
#include <vector>
#include "IObserverApp.h"

class CMyOpusData : public IObserverApp
{
public:
    static CMyOpusData* GetInstance();

    BOOL AddSong(const CRecoSongInfo* pInfo);
    
    typedef enum {
        REMOVE_LOCAL    = 1
        ,REMOVE_REMOTE  = 2
        ,REMOVE_ALL     = 3
    }RemoveType;
    BOOL RemoveSong(unsigned idx,RemoveType t);
    
    CRecoSongInfo* GetSong(unsigned idx);
    
    void GetAllSongs(std::vector<CRecoSongInfo*> &vecSongs);
    
    unsigned GetSongNum();
    
    BOOL UploadSong(unsigned idx);
    
    typedef enum{
        SEND_SUCCESS,
        SEND_FAIL,
        SEND_TIMEOUT,
        SEND_BEYOND_LIMIT
    }SEND_RESULT;
    
private:
    CMyOpusData();
public:
    virtual ~CMyOpusData();
    
public:
    void IObserverApp_ResignActive();
    
private:
    void LoadData();
    void SaveData();
    
    void ReleaseData();
    
    BOOL RemoveRemote(CRecoSongInfo* info);
    
    NSString* GetSaveFilePath();
    
    typedef enum
    {
        STEP_PIC_PACKAGE   = 1
        ,STEP_MUSIC_FILE   = 2
    }UPLOAD_STEP;

    std::string CreateUploadUrl(const CRecoSongInfo* pSong,UPLOAD_STEP step);
    
    
    SEND_RESULT SendFile(CRecoSongInfo* pSong,const std::string& strUrl,const std::string& strFile);
private:
    std::vector<CRecoSongInfo*> m_vecSongs;
    
    NSString* m_pStrSaveFilePath;
    
    dispatch_queue_t m_dispatchQueue;
    
private:
    bool m_bCancel;
public:
    void cancelUpload();
};

#endif
