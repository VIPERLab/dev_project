//
//  LyricParseTools.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-10.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "LyricParseTools.h"
#include <algorithm>

namespace LyricParseTools {
    
#define get_char(n) *(((char*)pData)+pos+(n))  
#define put_char(n,c) (*(((char*)pData)+pos+(n))=(c))
#define to_char_ptr(n) (((char*)pData)+pos+(n))
    //[-00:00.12]
    BOOL GetTimeStart(const void* pData,unsigned len,unsigned pos
                                         ,OUT unsigned& timeStrSize
                                         ,OUT unsigned& timeMilisecond
                                         )
    {
        if (get_char(0)!='[') {
            return FALSE;
        }
        unsigned i(1),nColonPos(0),nPeriodPos(0);
        for (;i<10 && get_char(i)!=']';++i) {
            char c=get_char(i);
            if (!isdigit(c) && c!=':' && c!='.' && c!='-') {
                return FALSE;
            }
            if (c==':') nColonPos=i;
            if (c=='.') nPeriodPos=i;
        }
        if (get_char(i)!=']') return FALSE;
        
        timeStrSize=i+1;
        
        put_char(nColonPos,0);//加个\0变成c string
        unsigned uiMinute(0);
        if (get_char(1)=='-') {//歌词时间前有可能是负号，音乐盒老代码里直接扔掉了，奇怪，先照做
            uiMinute=atoi(to_char_ptr(2));
        } else {
            uiMinute=atoi(to_char_ptr(1));
        }
        put_char(nColonPos, ':');//改回来
        
        put_char(nPeriodPos, 0);
        unsigned uiSecond=atoi(to_char_ptr(nColonPos+1));
        put_char(nPeriodPos, '.');
        
        put_char(i, 0);
        unsigned uiMilisecond=atoi(to_char_ptr(nPeriodPos+1))*10;//time最后一位单位为10ms
        put_char(i, ']');
        
        timeMilisecond=uiMinute*60*1000+uiSecond*1000+uiMilisecond;
        
        return TRUE;
    }
    //<-3133,7533>
    BOOL GetEncryptTimeStart(const void* pData,unsigned len,unsigned pos
                             ,OUT unsigned& timeStrSize
                             ,OUT int& time1
                             ,OUT int& time2
                             )
    {
        if (get_char(0)!='<') {
            return FALSE;
        }
        unsigned i(1),nCommaPos(0);
        for (;i<15 && get_char(i)!='>';++i) {
            char c=get_char(i);
            if (!isdigit(c) && c!=',' && c!='-') {
                return FALSE;
            }
            if (c==',') nCommaPos=i;
        }
        if (get_char(i)!='>') return FALSE;
            
        timeStrSize=i+1;
        
        put_char(nCommaPos,0);//加个\0变成c string
        time1=atoi(to_char_ptr(1));
        put_char(nCommaPos, ',');//改回来
        
        put_char(i,0);
        time2=atoi(to_char_ptr(nCommaPos+1));
        put_char(i, '>');
        
        return TRUE;
    }
    
    //仿函数，给stl算法用
    class CLyricTimeSorterFunctor
    {
    public:
        bool operator()(const SENTENCE_FOR_PARSE& cp1,const SENTENCE_FOR_PARSE& cp2)
        {
            return cp1.uiStartTime<cp2.uiStartTime;
        }
    };
    
    class CLyricIsEmptyFunctor
    {
    public:
        bool operator()(const SENTENCE_FOR_PARSE& sc)
        {
            return sc.uiLen==0;
        }
    };
            
    void SortSentencesByTimeStart(std::vector<SENTENCE_FOR_PARSE>& vec)
    {
        std::sort(vec.begin(),vec.end(),CLyricTimeSorterFunctor());
    }
            
    void FillEndTime(std::vector<SENTENCE_FOR_PARSE>& vec)
    {
        if (!vec.empty())
        {
            for(int i=0;i<vec.size()-1;++i)
            {
                vec[i].uiEndTime=vec[i+1].uiStartTime;
            }
            vec[vec.size()-1].uiEndTime=vec[vec.size()-1].uiStartTime+1000;
        }
    }
            
    void EraseBlankLine(std::vector<SENTENCE_FOR_PARSE>& vec)
    {
        vec.erase(remove_if(vec.begin(), vec.end(), CLyricIsEmptyFunctor()),vec.end());
    }
            
    void GetKuwoKey(void* pData,unsigned len,unsigned pos,unsigned& uiKuwoKey1,unsigned& uiKuwoKey2)
    {
        static const char* pName="[kuwo:";
        static unsigned uiNameLen=strlen(pName);
        for(int i=0;i<uiNameLen;++i){
            if(get_char(i)!=pName[i]) return;
        }
        
        unsigned uiEnd(uiNameLen);
        while( get_char(uiEnd)!=']' && isdigit(get_char(uiEnd)) )++uiEnd;
        
        if(get_char(uiEnd)!=']') return;
        
        put_char(uiEnd,0);
        unsigned uiKey=strtoul(to_char_ptr(6), NULL, 8);
        put_char(uiEnd,']');
        
        if(uiKey==0) return;
        
        uiKuwoKey1=uiKey/10;
        uiKuwoKey2=uiKey%10;
    }
            
    void Avoid_EX_ARM_DA_ALIGN(void* dst,const void* src,size_t len)
    {
        char* pDst=(char*)dst;
        const char* pSrc=(const char*)src;
        while(len--)
        {
            *pDst++=*pSrc++;
        }
    }
            
    void* Avoid_EX_ARM_DA_ALIGN(const void* src,size_t dstLen)
    {
        assert(dstLen<=32);
        //其实我也不知道加锁还是查表更快一些。。。
        NSValue* p=[[NSThread currentThread].threadDictionary objectForKey:@"avoiddaalign"];
        if(!p) {
            void* pBuf=new char[32];
            p=[NSValue valueWithPointer:pBuf];
            [[NSThread currentThread].threadDictionary setObject:p forKey:@"avoiddaalign"];
        }
        char* dst=(char*)[p pointerValue];
        char* pDst=dst;
        const char * pSrc=(const char*)src;
        while(dstLen--) {
            *pDst++=*pSrc++;
        }
        return dst;
    }

}

            
            
            
            
            
            

