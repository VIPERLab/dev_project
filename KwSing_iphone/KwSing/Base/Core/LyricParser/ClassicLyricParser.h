//
//  ClassicLyricParser.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-8.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__ClassicLyricParser__
#define __KwSing__ClassicLyricParser__

#include "ILyricParser.h"

class CClassLyricParser:public ILyricParser
{
public:
    BOOL ParseLyric(void* pData,unsigned len
                    ,SENTENCE_INFO*& pSentencesInfo
                    ,unsigned& uiSentenceNum
                    ,WORD_TIME_INFO*& pWordsInfo
                    ,unsigned& uiWordNum
                    ,double& dMaxEnvelope
                    ,unsigned& uiMinWordRange
                    ,unsigned& uiMaxWordRange);
    
};

#endif
