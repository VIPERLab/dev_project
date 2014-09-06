//
//  LyricInfo.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-6.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "LyricInfo.h"
#include "KwTools.h"
#include "LyricParser/ClassicLyricParser.h"
#include "LyricParser/KdtxLyricParser.h"
#include "LyricParser/LrcxLyricParser.h"
#include <algorithm>

#define hash_time(T) ((T)>>11)

//**** 这里面有一个索引结构，降低用时间戳查找句子和单字信息的时间复杂度
//**** 完全读懂之前不要轻易修改！！！

CLyricInfo::CLyricInfo()
:m_bParsed(FALSE)
,m_pBuffer(NULL)
,m_uiBufferLen(0)
,m_pWordTimeInfos(NULL)
,m_uiWordTimeInfoNum(0)
,m_pSentenceInfos(NULL)
,m_uiSentenceInfoNum(0)
,m_pTimeInfoIndex(NULL)
,m_uiTimeInfoIndexItemNum(0)
,m_dMaxEnvelope(0)
,m_uiMinWordRange(0)
,m_uiMaxWordRange(100)
{
}

CLyricInfo::~CLyricInfo()
{
    Clear();
}

void CLyricInfo::Clear()
{
    m_bParsed=FALSE;
    if (m_pBuffer) {
        delete[] (char*)m_pBuffer;
        m_pBuffer=NULL;
    }
    if (m_pWordTimeInfos) {
        delete[] m_pWordTimeInfos;
        m_pWordTimeInfos=NULL;
    }
    if (m_pSentenceInfos) {
        for (int i=0; i<m_uiSentenceInfoNum; ++i) {
            [m_pSentenceInfos[i].str release];
            delete[] m_pSentenceInfos[i].pFrequencyInfo;
            delete[] m_pSentenceInfos[i].pEnvelopeInfo;
        }
        delete[] m_pSentenceInfos;
        m_pSentenceInfos=NULL;
    }
    if (m_pTimeInfoIndex) {
        delete[] m_pTimeInfoIndex;
        m_pTimeInfoIndex=NULL;
    }
    m_uiBufferLen=m_uiWordTimeInfoNum=m_uiSentenceInfoNum=0;
    m_uiTimeInfoIndexItemNum=m_uiMinWordRange=m_uiMaxWordRange=0;
    m_dMaxEnvelope=0.0;
}

CLyricInfo::CLyricInfo(const CLyricInfo& cp)
{
    CopyInfos(cp);
}

const CLyricInfo& CLyricInfo::operator=(const CLyricInfo& cp)
{
    if (&cp!=this) {
        Clear();
        CopyInfos(cp);
    }
    return *this;
}

void CLyricInfo::CopyInfos(const CLyricInfo& cp)
{
    m_bParsed=cp.m_bParsed;
    m_pBuffer=NULL;
    m_uiBufferLen=cp.m_uiBufferLen;
    m_pWordTimeInfos=NULL;
    m_uiWordTimeInfoNum=cp.m_uiWordTimeInfoNum;
    m_pSentenceInfos=NULL;
    m_uiSentenceInfoNum=cp.m_uiSentenceInfoNum;
    m_pTimeInfoIndex=NULL;
    m_uiTimeInfoIndexItemNum=cp.m_uiTimeInfoIndexItemNum;
    m_dMaxEnvelope=cp.m_dMaxEnvelope;
    m_uiMinWordRange=cp.m_uiMinWordRange;
    m_uiMaxWordRange=cp.m_uiMaxWordRange;
    
    if (cp.m_pBuffer) {
        m_pBuffer=new char[cp.m_uiBufferLen];
        memcpy(m_pBuffer, cp.m_pBuffer, cp.m_uiBufferLen);
    }
    if (cp.m_pWordTimeInfos) {
        m_pWordTimeInfos=new WORD_TIME_INFO[cp.m_uiWordTimeInfoNum];
        memcpy(m_pWordTimeInfos, cp.m_pWordTimeInfos, cp.m_uiWordTimeInfoNum);
    }
    if (cp.m_pSentenceInfos) {
        m_pSentenceInfos=new SENTENCE_INFO[cp.m_uiSentenceInfoNum];
        memcpy(m_pSentenceInfos, cp.m_pSentenceInfos, cp.m_uiSentenceInfoNum);
        for (int i=0; i<cp.m_uiSentenceInfoNum; ++i) {
            SENTENCE_INFO& selfItem=m_pSentenceInfos[i];
            SENTENCE_INFO& cpItem=cp.m_pSentenceInfos[i];
            selfItem.str=[cpItem.str copy];
            selfItem.pFrequencyInfo=new double[cpItem.uiFrequencyInfoNum];
            memcpy(selfItem.pFrequencyInfo, cpItem.pFrequencyInfo, cpItem.uiFrequencyInfoNum);
            selfItem.pEnvelopeInfo=new double[cpItem.uiEnvelopInfoNum];
            memcpy(selfItem.pEnvelopeInfo, cpItem.pEnvelopeInfo, cpItem.uiEnvelopInfoNum);
            selfItem.pStartWord=m_pWordTimeInfos+(cpItem.pStartWord-cp.m_pWordTimeInfos);
            selfItem.pEndWord=m_pWordTimeInfos+(cpItem.pEndWord-cp.m_pWordTimeInfos);
        }
    }
    if (cp.m_pTimeInfoIndex) {
        m_pTimeInfoIndex=new TIME_INFO_INDEX_ITEM[cp.m_uiTimeInfoIndexItemNum];
        for (int i=0; i<cp.m_uiTimeInfoIndexItemNum; ++i) {
            TIME_INFO_INDEX_ITEM& selfItem=m_pTimeInfoIndex[i];
            TIME_INFO_INDEX_ITEM& cpItem=cp.m_pTimeInfoIndex[i];
            selfItem.pWordTimeInfoIdx=m_pWordTimeInfos+(cpItem.pWordTimeInfoIdx-cp.m_pWordTimeInfos);
            selfItem.pSentenceTimeInfoIdx=m_pSentenceInfos+(cpItem.pSentenceTimeInfoIdx-cp.m_pSentenceInfos);
        }
    }
    //写完这个函数我后悔允许这个对象被复制了~~>_<~~ 
}

#define COUNT_DOWN_THRESHOLD_VALUE 10*1000
DRAW_COUNTDOWN_STAGE CLyricInfo::GetCountDownStage(unsigned uiMilisecond,DRAW_SENTENCE_INFO& info)
{
    if (!m_pWordTimeInfos) {
        return COUNTDOWN_NORMAL;
    }
    if (!info.pPostSentenceInfo) {
        return COUNTDOWN_NORMAL;
    }
    int nAheadTime(0);
    if (uiMilisecond<info.pCurrentSentenceInfo->pStartWord->uiStartTime) {//125
        if ( (!info.pPreSentenceInfo && info.pCurrentSentenceInfo->uiStartTime>COUNT_DOWN_THRESHOLD_VALUE)
            || (info.pPreSentenceInfo&&info.pCurrentSentenceInfo->pStartWord->uiStartTime-info.pPreSentenceInfo->pEndWord->uiEndTime>COUNT_DOWN_THRESHOLD_VALUE)) {
            nAheadTime=info.pCurrentSentenceInfo->pStartWord->uiStartTime-uiMilisecond;
        }
    } else if (uiMilisecond>info.pCurrentSentenceInfo->pEndWord->uiEndTime) {//34
        if (info.pPostSentenceInfo->pStartWord->uiStartTime-info.pCurrentSentenceInfo->pEndWord->uiEndTime>COUNT_DOWN_THRESHOLD_VALUE) {
            nAheadTime=info.pPostSentenceInfo->pStartWord->uiStartTime-uiMilisecond;
        }
    }
    
#define COUNT_DOWN_PRE_SING_TIME 200
    DRAW_COUNTDOWN_STAGE eumStage(COUNTDOWN_NORMAL);
    if (nAheadTime>0 && nAheadTime<6*1000) {
        nAheadTime-=COUNT_DOWN_PRE_SING_TIME;
        if (nAheadTime<0) {
            eumStage = COUNTDOWN_PRE_PLAY;
        } else if (nAheadTime<COUNTDOWN_STAGE1<<10) {//*1000
            eumStage = COUNTDOWN_STAGE1;
        } else if (nAheadTime<COUNTDOWN_STAGE2<<10) {
            eumStage = COUNTDOWN_STAGE2;
        } else if (nAheadTime<COUNTDOWN_STAGE3<<10) {
            eumStage = COUNTDOWN_STAGE3;
        } else if (nAheadTime<COUNTDOWN_STAGE4<<10) {
            eumStage = COUNTDOWN_STAGE4;
        } else {
            eumStage = COUNTDOWN_STAGE_PREPARE;
        }
    }
    return eumStage;
}

BOOL CLyricInfo::GetDrawSentenceInfo(IN unsigned uiMilisecond,OUT DRAW_SENTENCE_INFO& info)
{
    memset(&info, 0, sizeof(DRAW_SENTENCE_INFO));
    if(!m_pTimeInfoIndex && !ParseLyric()){
        return FALSE;
    }
    
    SENTENCE_INFO* pCurrentSentence=GetSentenceByTime(uiMilisecond);
    info.pCurrentSentenceInfo=pCurrentSentence;
   
    info.pCurrentSentenceInfo=pCurrentSentence;
    if (pCurrentSentence==m_pSentenceInfos) {//第一句
        info.pPreSentenceInfo=NULL;
    } else {
        info.pPreSentenceInfo=pCurrentSentence-1;
    }
    
    if (pCurrentSentence==&m_pSentenceInfos[m_uiSentenceInfoNum-1]) {//最后一句
        info.pPostSentenceInfo=NULL;
    } else {
        info.pPostSentenceInfo=pCurrentSentence+1;
    }
    
    unsigned uiStartTime(pCurrentSentence->uiStartTime);
    unsigned uiEndTime(pCurrentSentence->uiEndTime);
    if (pCurrentSentence->pStartWord) { //逐字歌词以首尾字时间为准，逐行无单字时间，以句子首尾时间为准
        uiStartTime=pCurrentSentence->pStartWord->uiStartTime;
        uiEndTime=pCurrentSentence->pEndWord->uiEndTime;
    }
    if (uiMilisecond<=uiStartTime) { //125首句前的空白或者句子内第一个字前的时间
        info.fCurrentPercent=0;
        info.eumCountDownStage=GetCountDownStage(uiMilisecond, info);
    } else if (uiMilisecond>uiEndTime) { //34两句间的空白/句子内最后字之后/最后一句之后
        info.eumCountDownStage=GetCountDownStage(uiMilisecond, info);
        if (info.eumCountDownStage==COUNTDOWN_NORMAL) {
            info.fCurrentPercent=1;
        } else {
            info.pPreSentenceInfo=info.pCurrentSentenceInfo;
            info.pCurrentSentenceInfo=info.pPostSentenceInfo;
            info.pPostSentenceInfo=info.pPostSentenceInfo==&m_pSentenceInfos[m_uiSentenceInfoNum-1]?NULL:info.pPostSentenceInfo+1;
            info.fCurrentPercent=0;
        }
    } else {
        WORD_TIME_INFO* pCurrentWord=GetWordByTime(uiMilisecond);
        if (pCurrentWord) {//逐字
            unsigned uiCurrentWordPlayedTime=(uiMilisecond-pCurrentWord->uiStartTime);
            unsigned uiCurrentWordTotalTime=pCurrentWord->uiEndTime-pCurrentWord->uiStartTime;
            
            float fCurrentWordPlayedPercent=uiCurrentWordPlayedTime/(float)uiCurrentWordTotalTime;
            if (fCurrentWordPlayedPercent>1) {
                fCurrentWordPlayedPercent=1;
            }
            
            //英文&数字会有误差，除了低效计算绘制长度之外没想到好方法，英文歌曲不多，暂时不改
            info.fCurrentPercent=(pCurrentWord->uiPosInSentenceAsByte+fCurrentWordPlayedPercent*pCurrentWord->uiLenAsByte)/(float)pCurrentSentence->uiLenAsByte;
            if (info.fCurrentPercent>1) {
                info.fCurrentPercent=1;
            }
            
        } else {//逐行
            unsigned uiCurrentSentencePlayedTime=uiMilisecond-pCurrentSentence->uiStartTime;
            unsigned uiCurrentSentenceTotalTime=pCurrentSentence->uiEndTime-pCurrentSentence->uiStartTime;
            info.fCurrentPercent=uiCurrentSentencePlayedTime/(float)uiCurrentSentenceTotalTime;
            if (info.fCurrentPercent>1) {
                info.fCurrentPercent=1;
            }
        }
    }
    
    //当前句子与下一句之间存在较长间隔的时候，暂时不显示下一句
    if (m_pWordTimeInfos && info.pPostSentenceInfo && info.pPostSentenceInfo->pStartWord->uiStartTime-info.pCurrentSentenceInfo->pEndWord->uiEndTime>COUNT_DOWN_THRESHOLD_VALUE) {
        info.pPostSentenceInfo=NULL;
    }
    return TRUE;
}

BOOL CLyricInfo::GetDrawWordInfo(IN unsigned uiMilisecond,OUT DRAW_WORD_INFO& info)
{
    memset(&info, 0, sizeof(DRAW_WORD_INFO));
    if(!m_pTimeInfoIndex && !ParseLyric()){
        return FALSE;
    }
    
    info.pWordCurrent=GetWordByTime(uiMilisecond);
    
    info.pWordLeft=GetWordByTime(uiMilisecond>LYRIC_DRAW_LEFT_USE_TIME?uiMilisecond-LYRIC_DRAW_LEFT_USE_TIME:0);
    info.pWordRight=GetWordByTime(uiMilisecond+LYRIC_DRAW_NOWPOS_RIGHT_USE_TIME);
    if (info.pWordRight && info.pWordRight!=&m_pWordTimeInfos[m_uiWordTimeInfoNum-1]) {
        info.pWordRight=info.pWordRight+1;
    }
    
    info.pCurrentSentence=GetSentenceByTime(uiMilisecond);
    return TRUE;
}

BOOL CLyricInfo::GetRatingInfo(IN unsigned uiSentenceID,OUT LYRIC_RATING_INFO& info)
{
    memset(&info, 0, sizeof(LYRIC_RATING_INFO));
    if(!m_pTimeInfoIndex && !ParseLyric()){
        return FALSE;
    }
    if (uiSentenceID>=m_uiSentenceInfoNum) {
        return FALSE;
    }
    SENTENCE_INFO& sentence=m_pSentenceInfos[uiSentenceID];
    info.pFrequencyInfo=sentence.pFrequencyInfo;
    info.uiFrequencyInfoNum=sentence.uiFrequencyInfoNum;
    info.pEnvelopInfo=sentence.pEnvelopeInfo;
    info.uiEnvelopInfoNum=sentence.uiEnvelopInfoNum;
    info.dMaxEnvelop=m_dMaxEnvelope;
    return TRUE;
}

LYRIC_TYPE CLyricInfo::GetLyricType() const
{
    if (!m_pBuffer || *(unsigned*)m_pBuffer>3 ) {
        return LYRIC_NONE;
    }
    return *(LYRIC_TYPE*)m_pBuffer;
}

BOOL CLyricInfo::ReadFromBuffer(const void* pData,unsigned len)
{
    Clear();
    if (!pData || !len) {
        return FALSE;
    }
    m_uiBufferLen=len;
    m_pBuffer=new char[len];
    memcpy(m_pBuffer, pData, len);
    return TRUE;
}

BOOL CLyricInfo::ReadFromFile(const std::string& strPathName)
{
    NSData* pData=[NSData dataWithContentsOfFile:[NSString stringWithUTF8String:strPathName.c_str()]];
    return ReadFromBuffer([pData bytes], [pData length]);
}

BOOL CLyricInfo::WriteToFile(const std::string& strPathName) const
{
    if (!m_pBuffer || !m_uiBufferLen) {
        return FALSE;
    }
    FILE* f=fopen(strPathName.c_str(), "wb");
    if (!f) {
        return FALSE;
    }
    size_t l=fwrite(m_pBuffer, sizeof(char), m_uiBufferLen, f);
    fclose(f);
    return l==m_uiBufferLen;
}

BOOL CLyricInfo::ParseLyric()
{
    if (m_bParsed || !m_pBuffer || !m_uiBufferLen) {
        return FALSE;
    }
    
    m_bParsed=TRUE;
    
    long lDesLen=((long*)m_pBuffer)[1];
    if (lDesLen<100 || lDesLen>1024*1024) {
        return FALSE;
    }
    char* pDes=new char[lDesLen];
    if(KwTools::Memzip::RESULT_SUC!=KwTools::Memzip::UnCompress(pDes,&lDesLen, ((char*)m_pBuffer)+2*sizeof(unsigned), m_uiBufferLen-2*sizeof(unsigned)) ) {
        delete[] pDes;
        return FALSE;
    }
    ILyricParser* pParser=GetParser(*(LYRIC_TYPE*)m_pBuffer);
    
    if (!pParser) {
        return FALSE;
    }
    BOOL bRet=pParser->ParseLyric(pDes, lDesLen, m_pSentenceInfos,m_uiSentenceInfoNum,m_pWordTimeInfos,m_uiWordTimeInfoNum,m_dMaxEnvelope,m_uiMinWordRange,m_uiMaxWordRange);
    if (bRet) {
        BuildIndex();
    }
    
    delete[] pDes;
    return bRet;
}

ILyricParser* CLyricInfo::GetParser(LYRIC_TYPE eumType)
{
    ILyricParser* p(NULL);
    switch (eumType) {
        case LYRIC_CLASSIC: {
            static CClassLyricParser s;
            p=&s;
        } break;
        case LYRIC_KDTX: {
            static CKdtxLyricParser s;
            p=&s;
        } break;
        case LYRIC_LRCX: {
            static CLrcxLyricParser s;
            p=&s;
        } break; default: break;
    }
    return p;
}

void CLyricInfo::BuildIndex()
{
    unsigned uiTotalTime=std::max(m_pWordTimeInfos?m_pWordTimeInfos[m_uiWordTimeInfoNum-1].uiEndTime:0
                                  ,m_pSentenceInfos[m_uiSentenceInfoNum-1].uiEndTime);
    
    m_uiTimeInfoIndexItemNum=2+hash_time(uiTotalTime);
    m_pTimeInfoIndex=new TIME_INFO_INDEX_ITEM[m_uiTimeInfoIndexItemNum];
    memset(m_pTimeInfoIndex, 0, m_uiTimeInfoIndexItemNum);
    
    if (m_pWordTimeInfos) {
        WORD_TIME_INFO* pWordInfo=m_pWordTimeInfos;
        unsigned uiWortHashTime=hash_time(pWordInfo->uiStartTime);
        for (int i=0; i<m_uiTimeInfoIndexItemNum;) {
            while (i<=uiWortHashTime && i<m_uiTimeInfoIndexItemNum) {
                m_pTimeInfoIndex[i].pWordTimeInfoIdx = (pWordInfo==m_pWordTimeInfos)?pWordInfo:(pWordInfo-1);
                ++i;
            }
            if (pWordInfo-m_pWordTimeInfos<m_uiWordTimeInfoNum-1) {
                ++pWordInfo;
                uiWortHashTime=hash_time(pWordInfo->uiStartTime);
                while (i>uiWortHashTime && pWordInfo-m_pWordTimeInfos<m_uiWordTimeInfoNum-1) {
                    ++pWordInfo;
                    uiWortHashTime=hash_time(pWordInfo->uiStartTime);
                }
            } else {
                while (i<m_uiTimeInfoIndexItemNum-1) {
                    m_pTimeInfoIndex[i].pWordTimeInfoIdx=pWordInfo;
                    ++i;
                }
                break;
            }
        }
        m_pTimeInfoIndex[m_uiTimeInfoIndexItemNum-1].pWordTimeInfoIdx=&m_pWordTimeInfos[m_uiWordTimeInfoNum-1];
    }
    
    SENTENCE_INFO* pSentenceInfo=m_pSentenceInfos;
    unsigned uiSentenceHashTime=hash_time(pSentenceInfo->uiStartTime);
    for (int i=0; i<m_uiTimeInfoIndexItemNum;) {
        while (i<=uiSentenceHashTime && i<m_uiTimeInfoIndexItemNum) {
            m_pTimeInfoIndex[i].pSentenceTimeInfoIdx = (pSentenceInfo==m_pSentenceInfos)?pSentenceInfo:(pSentenceInfo-1);
            ++i;
        }
        if (pSentenceInfo-m_pSentenceInfos<m_uiSentenceInfoNum-1) {
            ++pSentenceInfo;
            uiSentenceHashTime=hash_time(pSentenceInfo->uiStartTime);
            while (i>uiSentenceHashTime && pSentenceInfo-m_pSentenceInfos<m_uiSentenceInfoNum-1) {
                ++pSentenceInfo;
                uiSentenceHashTime=hash_time(pSentenceInfo->uiStartTime);
            }
        } else {
            while (i<m_uiTimeInfoIndexItemNum-1) {
                m_pTimeInfoIndex[i].pSentenceTimeInfoIdx=&m_pSentenceInfos[m_uiSentenceInfoNum-1];
                ++i;
            }
            break;
        }
    }
    m_pTimeInfoIndex[m_uiTimeInfoIndexItemNum-1].pSentenceTimeInfoIdx=&m_pSentenceInfos[m_uiSentenceInfoNum-1];
}

SENTENCE_INFO* CLyricInfo::GetSentenceByTime(unsigned uiMilisecond)
{
    unsigned uiTime=hash_time(uiMilisecond);
    if (uiTime<m_uiTimeInfoIndexItemNum) {
        TIME_INFO_INDEX_ITEM& pre=m_pTimeInfoIndex[uiTime];

        if (uiMilisecond<=pre.pSentenceTimeInfoIdx->uiStartTime) {
            return pre.pSentenceTimeInfoIdx;
        }
        for (SENTENCE_INFO* p=pre.pSentenceTimeInfoIdx; p!=&m_pSentenceInfos[m_uiSentenceInfoNum-1]; ++p) {
            if (uiMilisecond>=p->uiStartTime && uiMilisecond<(p+1)->uiStartTime) {
                return p;
            }
        }
    }
    return &m_pSentenceInfos[m_uiSentenceInfoNum-1];
}

WORD_TIME_INFO* CLyricInfo::GetWordByTime(unsigned uiMilisecond)
{
    if (m_pWordTimeInfos) {
        unsigned uiTime=hash_time(uiMilisecond);
        if (uiTime<m_uiTimeInfoIndexItemNum) {
            TIME_INFO_INDEX_ITEM& pre=m_pTimeInfoIndex[uiTime];

            if (uiMilisecond<=pre.pWordTimeInfoIdx->uiStartTime) {
                return pre.pWordTimeInfoIdx;
            }
            for (WORD_TIME_INFO* p=pre.pWordTimeInfoIdx; p!=&m_pWordTimeInfos[m_uiWordTimeInfoNum-1]; ++p) {
                if (uiMilisecond>=p->uiStartTime && uiMilisecond<(p+1)->uiStartTime) {
                    return p;
                }
            }
         }
        return &m_pWordTimeInfos[m_uiWordTimeInfoNum-1];
    }
    return NULL;
}

SENTENCE_INFO* CLyricInfo::GetSentenceById(unsigned uiId)
{
    if(!m_pTimeInfoIndex && !ParseLyric()){
        return FALSE;
    }
    if (uiId<m_uiSentenceInfoNum) {
        return &m_pSentenceInfos[uiId];
    }
    return NULL;
}

unsigned CLyricInfo::GetMinWordRange()
{
    if(!m_pTimeInfoIndex && !ParseLyric()){
        return 0;
    }
    return m_uiMinWordRange;
}

unsigned CLyricInfo::GetMaxWordRange()
{
    if(!m_pTimeInfoIndex && !ParseLyric()){
        return 100;
    }
    return m_uiMaxWordRange;
}

unsigned CLyricInfo::GetSentenceNum()
{
    if(!m_pTimeInfoIndex && !ParseLyric()){
        return 0;
    }
    return m_uiSentenceInfoNum;
}

