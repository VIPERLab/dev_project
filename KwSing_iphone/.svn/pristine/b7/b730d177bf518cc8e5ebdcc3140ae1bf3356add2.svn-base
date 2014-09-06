//
//  MessageManagerHelper.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-6.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_MessageManagerHelper_h
#define KwSing_MessageManagerHelper_h

#include <vector>
#include "Variant.h"

class PushPara2Vec
{
public:
	PushPara2Vec(std::vector<KwTools::Variant>* pVec):m_pVec(pVec){}
	void operator()(){}
	template<typename T>
	inline void operator()(const T& p1)
	{
		m_pVec->push_back(p1);
	}
	template<typename T1,typename T2>
	inline void operator()(const T1& p1,const T2& p2)
	{
		m_pVec->reserve(2);
		m_pVec->push_back(p1);
		m_pVec->push_back(p2);
	}
	template<typename T1,typename T2,typename T3>
	inline void operator()(const T1& p1,const T2& p2,const T3& p3)
	{
		m_pVec->reserve(3);
		m_pVec->push_back(p1);
		m_pVec->push_back(p2);
		m_pVec->push_back(p3);
	}
	template<typename T1,typename T2,typename T3,typename T4>
	inline void operator()(const T1& p1,const T2& p2,const T3& p3,const T4& p4)
	{
		m_pVec->reserve(4);
		m_pVec->push_back(p1);
		m_pVec->push_back(p2);
		m_pVec->push_back(p3);
		m_pVec->push_back(p4);
	}
	template<typename T1,typename T2,typename T3,typename T4,typename T5>
	inline void operator()(const T1& p1,const T2& p2,const T3& p3,const T4& p4,const T5& p5)
	{
		m_pVec->reserve(5);
		m_pVec->push_back(p1);
		m_pVec->push_back(p2);
		m_pVec->push_back(p3);
		m_pVec->push_back(p4);
		m_pVec->push_back(p5);
	}
	template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6>
	inline void operator()(const T1& p1,const T2& p2,const T3& p3,const T4& p4,const T5& p5,const T6& p6)
	{
		m_pVec->reserve(6);
		m_pVec->push_back(p1);
		m_pVec->push_back(p2);
		m_pVec->push_back(p3);
		m_pVec->push_back(p4);
		m_pVec->push_back(p5);
		m_pVec->push_back(p6);
	}
private:
    std::vector<KwTools::Variant>* m_pVec;
};


//同步通知
#define SYN_NOTIFY_H(strObserverID,eumMethod,...) {\
std::vector<KwTools::Variant> vecParam;\
PushPara2Vec ppv(&vecParam);\
ppv(__VA_ARGS__);\
CMessageManager::GetInstance()->SyncNotify(strObserverID, eumMethod,vecParam);\
}

//异步通知
#define ASYN_NOTIFY_H(strObserverID,eumMethod,iDelay,...) {\
std::vector<KwTools::Variant> vecParam;\
PushPara2Vec ppv(&vecParam);\
ppv(__VA_ARGS__);\
CMessageManager::GetInstance()->AsyncNotify(strObserverID,eumMethod,iDelay,vecParam);\
}

enum _KS_BLOCK_PRIORITY
{
    _KS_BLOCK_PRIORITY_HIGH           = DISPATCH_QUEUE_PRIORITY_HIGH
    ,_KS_BLOCK_PRIORITY_DEFAULT       = DISPATCH_QUEUE_PRIORITY_DEFAULT
    ,_KS_BLOCK_PRIORITY_LOW           = DISPATCH_QUEUE_PRIORITY_LOW
};

class __KsThreadPriority
{
public:
    __KsThreadPriority():nPriority(_KS_BLOCK_PRIORITY_DEFAULT){}
    __KsThreadPriority(_KS_BLOCK_PRIORITY n):nPriority(n){}
    dispatch_queue_priority_t operator()(){return (dispatch_queue_priority_t)nPriority;}
private:
    _KS_BLOCK_PRIORITY nPriority;
};


@interface __KSRunTargetThreadHelper : NSObject
- (void)run:(id)func;
@end


#endif
