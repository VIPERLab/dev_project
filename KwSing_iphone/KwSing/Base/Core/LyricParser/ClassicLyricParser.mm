//
//  ClassicLyricParser.cpp
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-8.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "ClassicLyricParser.h"
#include <vector>
#include <algorithm>
#include <string>
#include "LyricParseTools.h"
#include "KwTools.h"
using namespace LyricParseTools;


BOOL CClassLyricParser::ParseLyric(void* pData,unsigned len
                                   ,SENTENCE_INFO*& pSentencesInfo
                                   ,unsigned& uiSentenceNum
                                   ,WORD_TIME_INFO*& pWordsInfo
                                   ,unsigned& uiWordNum
                                   ,double& dMaxEnvelope
                                   ,unsigned& uiMinWordRange
                                   ,unsigned& uiMaxWordRange)
{
    pSentencesInfo=NULL;
    uiSentenceNum=0;
    pWordsInfo=NULL;
    uiWordNum=0;
    dMaxEnvelope=0.0;
    
    if (!pData || !len) {
        return FALSE;
    }
    
    std::vector<SENTENCE_FOR_PARSE> vecSentences;
    vecSentences.reserve(50);
    
#define is_endline_symbol(n) (((char*)pData)[(n)]=='\r' || ((char*)pData)[(n)]=='\n') 
#define skip_endline_symbol(n) while(n<len && is_endline_symbol(n))++n;
    
    //单次遍历
    unsigned uiTimeLen(0),timeMilisecond(0);
    for (int i=0; i<len;) {
        unsigned uiTimeNum(0);
        
        //句子
        if(GetTimeStart(pData, len, i, uiTimeLen, timeMilisecond)){
            uiTimeNum++;
            i+=uiTimeLen;
            vecSentences.push_back(SENTENCE_FOR_PARSE(timeMilisecond,0,0,0));
            
            //重复句子
            while (GetTimeStart(pData, len, i, uiTimeLen, timeMilisecond)) {
                uiTimeNum++;
                i+=uiTimeLen;
                vecSentences.push_back(SENTENCE_FOR_PARSE(timeMilisecond,0,0,0));
            }
            
            //找句尾
            unsigned uiTextStart=i;
            while (i<len
                   && !is_endline_symbol(i)
                   && !GetTimeStart(pData,len,i,uiTimeLen,timeMilisecond)) {
                ++i;
            }
            //填充句子包括重复结尾时间
            unsigned uiTextEnd=i;
            for (int j=0; j<uiTimeNum; ++j) {
                SENTENCE_FOR_PARSE& sentence=vecSentences[vecSentences.size()-uiTimeNum+j];
                sentence.uiStartPos=uiTextStart;
                sentence.uiLen=uiTextEnd-uiTextStart;
            }
            
            skip_endline_symbol(i);
        } else {
            ++i;
        }
    }
    if (vecSentences.size()<10) {
        return FALSE;
    }
    //重复句子存在导致时间不是顺序排列
    SortSentencesByTimeStart(vecSentences);
    FillEndTime(vecSentences);
    EraseBlankLine(vecSentences);

    uiSentenceNum=vecSentences.size();
    pSentencesInfo=new SENTENCE_INFO[uiSentenceNum];
    memset(pSentencesInfo, 0, uiSentenceNum*sizeof(SENTENCE_INFO));
    
    //上文只记录了句子文字的位置和长短信息，下面生成句子数据结构
    NSAutoreleasePool* pAutoRelease=[[NSAutoreleasePool alloc] init];
    for(int i=0;i<uiSentenceNum;++i){
        SENTENCE_INFO& info=pSentencesInfo[i];
        SENTENCE_FOR_PARSE& sentence=vecSentences[i];
        char* pTextStart=((char*)pData)+sentence.uiStartPos;
        char* pTextEnd=((char*)pData)+sentence.uiStartPos+sentence.uiLen;
        char cTmp=*pTextEnd;
        *pTextEnd=0;
        NSString *str = KwTools::Encoding::Gbk2Utf8(pTextStart);
        *pTextEnd=cTmp;
        if(str)info.str=[[NSMutableAttributedString alloc] initWithString:str];
        info.uiStartTime=sentence.uiStartTime;
        info.uiEndTime=sentence.uiEndTime;
        info.uiLenAsByte=sentence.uiLen;
        info.pFrequencyInfo=NULL;
        info.uiFrequencyInfoNum=0;
        info.uiId=i;
        if (i%64==0) {
            [pAutoRelease release];
            pAutoRelease=[[NSAutoreleasePool alloc] init];
        }
    }
    [pAutoRelease release];
    
    return TRUE;
}


