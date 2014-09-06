//
//  LyricParseTools.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-10.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_LyricParseTools_h
#define KwSing_LyricParseTools_h

#include <vector>

#ifndef IN
#define IN
#endif
#ifndef OUT
#define OUT
#endif

namespace LyricParseTools {
    
    BOOL GetTimeStart(const void* pData,unsigned len,unsigned pos
                      ,OUT unsigned& timeStrSize
                      ,OUT unsigned& timeMilisecond
                      );
    
    BOOL GetEncryptTimeStart(const void* pData,unsigned len,unsigned pos
                             ,OUT unsigned& timeStrSize
                             ,OUT int& time1
                             ,OUT int& time2
                             );
    
    
    typedef struct _sentence_for_parse
    {
        _sentence_for_parse():uiStartTime(0),uiEndTime(0),uiStartPos(0),uiLen(0),nStartWordPos(-1),nEndWordPos(-1){}
        _sentence_for_parse(unsigned s,unsigned e,unsigned sp,unsigned l)
        :uiStartTime(s),uiEndTime(e),uiStartPos(sp),uiLen(l),nStartWordPos(-1),nEndWordPos(-1){}
        unsigned uiStartTime;
        unsigned uiEndTime;
        unsigned uiStartPos;
        unsigned uiLen;
        int nStartWordPos;
        int nEndWordPos;
    }SENTENCE_FOR_PARSE;
    
    void SortSentencesByTimeStart(std::vector<SENTENCE_FOR_PARSE>& vec);
    
    void FillEndTime(std::vector<SENTENCE_FOR_PARSE>& vec);
    
    void EraseBlankLine(std::vector<SENTENCE_FOR_PARSE>& vec);
    
    void GetKuwoKey(void* pData,unsigned len,unsigned pos,unsigned& uiKuwoKey1,unsigned& uiKuwoKey2);
    
    void Avoid_EX_ARM_DA_ALIGN(void* dst,const void* src,size_t len);
    void* Avoid_EX_ARM_DA_ALIGN(const void* src,size_t dstLen);
}

#endif
