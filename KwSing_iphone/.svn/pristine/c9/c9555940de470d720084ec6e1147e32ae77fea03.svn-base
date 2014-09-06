//
//  ILyricParser.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-8.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ILyricParser_h
#define KwSing_ILyricParser_h

#include "LyricInfoDef.h"

class ILyricParser
{
public:
    virtual BOOL ParseLyric(void* pData,unsigned len
                            ,SENTENCE_INFO*& pSentencesInfo
                            ,unsigned& uiSentenceNum
                            ,WORD_TIME_INFO*& pWordsInfo
                            ,unsigned& uiWordNum
                            ,double& dMaxEnvelope
                            ,unsigned& uiMinWordRange
                            ,unsigned& uiMaxWordRange) = 0;
};

#endif
