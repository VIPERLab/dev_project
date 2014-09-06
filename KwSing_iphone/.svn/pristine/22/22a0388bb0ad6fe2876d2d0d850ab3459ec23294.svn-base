//
//  KdtxLyricParser.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-8.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "KdtxLyricParser.h"
#include "LyricParseTools.h"
#include "KwTools.h"


BOOL CKdtxLyricParser::ParseLyric(void* pData,unsigned len
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

#define read_skip(p,n) (p+=(n));
    
#define read_buf(p,t) (*(t*)LyricParseTools::Avoid_EX_ARM_DA_ALIGN(p,sizeof(t)));p+=sizeof(t);
#define read_uint(p) read_buf(p,unsigned);
#define read_double(p) read_buf(p,double);
#define read_char(p) read_buf(p,char);
    
#define write_buf(p,t,v) *((t*)p)=v;p+=sizeof(t);
#define write_char(p,v) write_buf(p,char,v);

    //单次遍历，保证效率
    
    char* pNow=(char*)pData;
    uiSentenceNum=read_uint(pNow);
    if (uiSentenceNum>1000) {
        return FALSE;
    }
    pSentencesInfo=new SENTENCE_INFO[uiSentenceNum];
    memset(pSentencesInfo, 0, uiSentenceNum*sizeof(SENTENCE_INFO));
    
    //频谱
    for (int i=0; i<uiSentenceNum; ++i) {
        SENTENCE_INFO& sentence=pSentencesInfo[i];
        sentence.uiStartTime=read_uint(pNow);
        sentence.uiEndTime=read_uint(pNow);
        sentence.uiFrequencyInfoNum=read_uint(pNow)
        sentence.pFrequencyInfo=new double[sentence.uiFrequencyInfoNum];
        for (int j=0; j<sentence.uiFrequencyInfoNum; ++j) {
            sentence.pFrequencyInfo[j]=read_double(pNow);
        }
        sentence.uiId=i;
    }
    
    //包络最大幅度值
    dMaxEnvelope=read_double(pNow);
    
    //原唱包络
    unsigned uiEnvelopTotalNum=read_uint(pNow);
    if (((char*)pNow)+uiEnvelopTotalNum>((char*)pData)+len) {
        return FALSE;
    }
    
    unsigned uiEnvelopTotalReadNum(pSentencesInfo[0].uiStartTime/100);//避免数据问题导致num与句子时间信息不一致
    read_skip(pNow, uiEnvelopTotalReadNum*sizeof(double));
    
    for (int i=0; i<uiSentenceNum; ++i) {
        SENTENCE_INFO& sentence=pSentencesInfo[i];
        sentence.uiEnvelopInfoNum=(sentence.uiEndTime-sentence.uiStartTime)/100;
        sentence.pEnvelopeInfo=new double[sentence.uiEnvelopInfoNum];
        for (int j=0; j<sentence.uiEnvelopInfoNum; ++j) {
            sentence.pEnvelopeInfo[j]=read_double(pNow);
            ++uiEnvelopTotalReadNum;
        }
    }
    if (uiEnvelopTotalReadNum<uiEnvelopTotalNum) {
        read_skip(pNow, (uiEnvelopTotalNum-uiEnvelopTotalReadNum)*sizeof(double))
    }
    
    //逐字信息
    uiWordNum=read_uint(pNow);
    pWordsInfo=new WORD_TIME_INFO[uiWordNum];
    
    WORD_TIME_INFO* pNowWord=pWordsInfo;
    NSAutoreleasePool* pAutoRelease=[[NSAutoreleasePool alloc] init];
    for (int i=0; i<uiSentenceNum; ++i) {
        unsigned uiSentenceWordNum=read_uint(pNow);
        unsigned uiSentenceWordLen=read_uint(pNow);
        
        char cTmp=pNow[uiSentenceWordLen];
        pNow[uiSentenceWordLen]=0;  //换上个\0以便于当作c字符串处理，一会再换回来
        NSString *str = KwTools::Encoding::Gbk2Utf8(pNow);
        pNow[uiSentenceWordLen]=cTmp;
        SENTENCE_INFO& sentence=pSentencesInfo[i];
        sentence.str=[[NSMutableAttributedString alloc] initWithString:str];
        sentence.uiLenAsByte=uiSentenceWordLen;
        //NSLog(@"[%d,%d] %@\n",sentence.uiStartTime,sentence.uiEndTime,sentence.str);
        
        read_skip(pNow, uiSentenceWordLen);
        
        //字
        unsigned uiPosInSentence(0);
        for (int j=0; j<uiSentenceWordNum; ++j) {
            WORD_TIME_INFO& word=*(pNowWord++);
            word.uiLenAsByte=read_uint(pNow);
            word.uiStartTime=100*read_uint(pNow);
            word.uiEndTime=100*read_uint(pNow);
            word.uiRange=read_uint(pNow);
            if (word.uiRange<uiMinWordRange) {
                uiMinWordRange=word.uiRange;
            }
            if (word.uiRange>uiMaxWordRange) {
                uiMaxWordRange=word.uiRange;
            }
            word.uiPosInSentenceAsByte=uiPosInSentence;
            uiPosInSentence+=word.uiLenAsByte;
            if (j==0) {
                sentence.pStartWord=&word;
            }
            if(j==uiSentenceWordNum-1){
                sentence.pEndWord=&word;
            }
        }
        
        if (i%32==0) {
            [pAutoRelease release];
            pAutoRelease=[[NSAutoreleasePool alloc] init];
        }
    }
    
    [pAutoRelease release];
    return TRUE;
}

