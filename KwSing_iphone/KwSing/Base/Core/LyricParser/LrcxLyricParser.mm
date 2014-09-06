//
//  LrcxLyricParser.cpp
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-8.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "LrcxLyricParser.h"
#include "KwTools.h"
#include "base64_.h"
#include "LyricParseTools.h"
using namespace LyricParseTools;

#define LRCX_XOR_KEY "yeelion"


BOOL CLrcxLyricParser::ParseLyric(void* pDataEncrypted,unsigned encryptedLen
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
    
    if (!pDataEncrypted || !encryptedLen) {
        return FALSE;
    }
    unsigned len=base64_decode_length(encryptedLen);
    char* pData=new char[len];
    len=base64_decode((char*)pDataEncrypted, encryptedLen, pData, len);
    if (!len) {
        delete[] pData;
        return FALSE;
    }
    
    KwTools::Encrypt::XOR(pData, len, LRCX_XOR_KEY, strlen(LRCX_XOR_KEY));
    
    std::vector<SENTENCE_FOR_PARSE> vecSentences;
    std::vector<WORD_TIME_INFO> vecWords;
    std::string strAllWords;
    vecSentences.reserve(40);
    vecWords.reserve(400);
    strAllWords.reserve(800);
    
#define is_endline_symbol(n) (pData[(n)]=='\r' || pData[(n)]=='\n')
#define skip_endline_symbol(n) while(n<len && is_endline_symbol(n))++n;
 
#define get_char(n) *(((char*)pData)+(n))
#define put_char(n,c) (*(((char*)pData)+(n))=(c))
#define to_char_ptr(n) (((char*)pData)+(n))
    
    //单次遍历，跟lrc一样，解析完整个文件之前是不知道有多少行多少字的
    //所以都需要vector存放最后生成pSentencesInfo和pWordsInfo
    int nTime1(0),nTime2(0);
    unsigned uiTimeLen(0),timeMilisecond(0),uiKuwoKey1(0),uiKuwoKey2(0);
    for (int i=0; i<len;) {
        if (uiKuwoKey1==0 && uiKuwoKey2==0) {
            GetKuwoKey(pData,len,i,uiKuwoKey1,uiKuwoKey2);
        }
        //句子
        if(GetTimeStart(pData,len,i,uiTimeLen,timeMilisecond)){
            //此时无key更待何时
            if (uiKuwoKey1==0 && uiKuwoKey2==0) {
                return FALSE;
            }
            i+=uiTimeLen;
            vecSentences.push_back(SENTENCE_FOR_PARSE(timeMilisecond,0,0,0));
            SENTENCE_FOR_PARSE& sentence=vecSentences[vecSentences.size()-1];
            sentence.uiStartPos=strAllWords.size();
            
            //字
            unsigned uiWordTimeLen(0),uiPosInSentence(0);
            WORD_TIME_INFO word;
            while (i<len
                   && !is_endline_symbol(i)
                   && !GetTimeStart(pData,len,i,uiWordTimeLen,timeMilisecond)) {
                if (GetEncryptTimeStart(pData, len, i, uiTimeLen, nTime1, nTime2)) {
                    i+=uiTimeLen;
                    unsigned uiWordStartPos(i);
                    //字尾
                    while (i<len
                           && !is_endline_symbol(i)
                           && !GetTimeStart(pData,len,i,uiWordTimeLen,timeMilisecond)
                           && !GetEncryptTimeStart(pData, len, i, uiTimeLen, nTime1, nTime2)) {
                        ++i;
                    }
                    //解二元一次方程
                    int x=(nTime1+nTime2)/uiKuwoKey1/2;
                    int y=(nTime1-nTime2)/uiKuwoKey2/2;
                    word.uiStartTime=timeMilisecond+x;
                    if (!vecWords.empty()) {
                        WORD_TIME_INFO& wordPre=vecWords[vecWords.size()-1];
                        if (word.uiStartTime<wordPre.uiEndTime) {//白痴歌词文件
                            wordPre.uiEndTime=word.uiStartTime;
                            if (wordPre.uiStartTime>wordPre.uiEndTime) {
                                wordPre.uiStartTime=wordPre.uiEndTime;
                            }
                        }
                    }
                    word.uiEndTime=word.uiStartTime+y;
                    word.uiRange=0;
                    word.uiLenAsByte=i-uiWordStartPos;
                    word.uiPosInSentenceAsByte=uiPosInSentence;
                    
                    if (sentence.nStartWordPos==-1) {
                        sentence.nStartWordPos=vecWords.size();
                    }
                    uiPosInSentence+=word.uiLenAsByte;
                    sentence.uiLen=uiPosInSentence;
                    
                    vecWords.push_back(word);
                                       
                    char cTmp=get_char(i);
                    put_char(i,0);
                    strAllWords+=to_char_ptr(uiWordStartPos);
                    put_char(i,cTmp);
                } else {
                    ++i;
                }
            }
            strAllWords+='\0';
            sentence.nEndWordPos=vecWords.size()-1;
            skip_endline_symbol(i);
        } else {
            ++i;
        }
    }
    delete[] pData;
    
    FillEndTime(vecSentences);
    
    //拷贝单字数据
    pWordsInfo=new WORD_TIME_INFO[vecWords.size()];
    memcpy(pWordsInfo, &vecWords[0], sizeof(WORD_TIME_INFO)*vecWords.size());
    uiWordNum=vecWords.size();
    
    //生成句子数据
    uiSentenceNum=vecSentences.size();
    pSentencesInfo=new SENTENCE_INFO[uiSentenceNum];
    memset(pSentencesInfo, 0, uiSentenceNum*sizeof(SENTENCE_INFO));
    
    NSAutoreleasePool* pAutoRelease=[[NSAutoreleasePool alloc] init];
    const char* pText=strAllWords.c_str();
    for(int i=0;i<uiSentenceNum;++i){
        SENTENCE_INFO& info=pSentencesInfo[i];
        SENTENCE_FOR_PARSE& sentence=vecSentences[i];
    
        NSString *str = KwTools::Encoding::Gbk2Utf8(&pText[sentence.uiStartPos]);
        if(str)info.str=[[NSMutableAttributedString alloc] initWithString:str];
        info.uiStartTime=sentence.uiStartTime;
        info.uiEndTime=sentence.uiEndTime;
        info.uiLenAsByte=sentence.uiLen;
        info.pFrequencyInfo=NULL;
        info.uiFrequencyInfoNum=0;
        info.uiId=i;
        info.pStartWord=&pWordsInfo[sentence.nStartWordPos];
        info.pEndWord=&pWordsInfo[sentence.nEndWordPos];
        if (i%64==0) {
            [pAutoRelease release];
            pAutoRelease=[[NSAutoreleasePool alloc] init];
        }
    }
    [pAutoRelease release];
    
    return TRUE;
}


