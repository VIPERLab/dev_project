//
//  LyricInfo.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-6.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_LyricInfo_h
#define KwSing_LyricInfo_h
#include <string>
#include "LyricParser/LyricInfoDef.h"
#include "LyricParser/ILyricParser.h"

class CLyricInfo
{
public:
    LYRIC_TYPE GetLyricType() const;
    
    BOOL GetDrawSentenceInfo(IN unsigned uiMilisecond,OUT DRAW_SENTENCE_INFO& info);
    
    BOOL GetDrawWordInfo(IN unsigned uiMilisecond,OUT DRAW_WORD_INFO& info);
    
    BOOL GetRatingInfo(IN unsigned uiSentenceID,OUT LYRIC_RATING_INFO& info);
    
    SENTENCE_INFO* GetSentenceByTime(unsigned uiMilisecond);
    
    SENTENCE_INFO* GetSentenceById(unsigned uiId);
    
    WORD_TIME_INFO* GetWordByTime(unsigned uiMilisecond);
    
    unsigned GetSentenceNum();
    
    unsigned GetMinWordRange();
    unsigned GetMaxWordRange();
    
    CLyricInfo();
    ~CLyricInfo();
    CLyricInfo(const CLyricInfo& cp);
    const CLyricInfo& operator=(const CLyricInfo& cp);
    
public:
    BOOL ReadFromBuffer(const void* pData,unsigned len);
    BOOL ReadFromFile(const std::string& strPathName);
    BOOL WriteToFile(const std::string& strPathName) const;
    
private:
    void CopyInfos(const CLyricInfo& cp);
    void Clear();
    BOOL ParseLyric();
    ILyricParser* GetParser(LYRIC_TYPE eumType);
    void BuildIndex();
    DRAW_COUNTDOWN_STAGE GetCountDownStage(unsigned uiMilisecond,DRAW_SENTENCE_INFO& info);
    
private:
    BOOL m_bParsed;
    void* m_pBuffer;
    unsigned m_uiBufferLen;
    
    WORD_TIME_INFO* m_pWordTimeInfos;
    unsigned m_uiWordTimeInfoNum;
    SENTENCE_INFO* m_pSentenceInfos;
    unsigned m_uiSentenceInfoNum;
    TIME_INFO_INDEX_ITEM* m_pTimeInfoIndex;
    unsigned m_uiTimeInfoIndexItemNum;

    double m_dMaxEnvelope;
    unsigned m_uiMinWordRange;
    unsigned m_uiMaxWordRange;
};

#endif
