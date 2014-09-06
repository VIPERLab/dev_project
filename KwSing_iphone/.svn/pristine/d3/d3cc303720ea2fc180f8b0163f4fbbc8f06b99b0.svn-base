//
//  MessageManager.mm
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include <pthread.h>
#include "MessageManager.h"
#include "IMessageObserver.h"
#include "Block.h"

typedef std::list<IMessageObserver*> OB_LIST;
typedef OB_LIST::iterator OB_LIST_ITE;
typedef std::list<std::pair<IMessageObserver*,id> > OB_LIST_OC;
typedef OB_LIST_OC::iterator OB_LIST_ITE_OC;

OB_LIST g_lstObservers[OBSERVER_ID_MAX];
OB_LIST_OC g_lstObservers_oc[OBSERVER_ID_MAX];

volatile bool g_bStopAllMessage(false);

OB_LIST* g_pNotifingList(NULL);
IMessageObserver* g_pNotifingObj(NULL);
OB_LIST_OC* g_pNotifingList_oc(NULL);
id g_idNotifingObj_oc(NULL);


CMessageManager* CMessageManager::GetInstance()
{
    static CMessageManager sMessageManager;
    return &sMessageManager;
}

CMessageManager::CMessageManager()
{
}

CMessageManager::~CMessageManager()
{
}

void CMessageManager::AttachMessage(MESSAGE_ID msg,IMessageObserver* pOb)
{
    assert([NSThread isMainThread]);
    if (!pOb) 
    {
        return;
    }
    
    OB_LIST& lstOb=g_lstObservers[msg];
    OB_LIST_ITE ite=std::find(lstOb.begin(), lstOb.end(), pOb);
    if (ite!=lstOb.end())
    {
        assert(false);//同一个对象注册同一个Observer多次
        return;
    }
    g_lstObservers[msg].push_back(pOb);
}

void CMessageManager::AttachMessage(MESSAGE_ID msg,IMessageObserver* pObHelper,id idOb)
{
    assert([NSThread isMainThread]);
    if (!pObHelper || idOb==nil) 
    {
        return;
    }
    
    OB_LIST_OC& lstOb=g_lstObservers_oc[msg];
    OB_LIST_ITE_OC ite;
    for (ite=lstOb.begin(); ite!=lstOb.end(); ++ite) 
    {
        if (ite->second==idOb) 
        {
            assert(false);//同一个对象注册同一个Observer多次
            return;
        }
    }
    g_lstObservers_oc[msg].push_back(std::make_pair(pObHelper,idOb));
}

void CMessageManager::DetachMessage(MESSAGE_ID msg,IMessageObserver* pOb)
{
    assert([NSThread isMainThread]);
    if (!pOb) {
        return;
    }
    
    OB_LIST& lstOb=g_lstObservers[msg];
    OB_LIST_ITE ite=std::find(lstOb.begin(), lstOb.end(), pOb);
    if (ite!=lstOb.end()) {
        lstOb.erase(ite);
        if (g_pNotifingList && pOb!=g_pNotifingObj) {
            OB_LIST_ITE iteNotifing=std::find(g_pNotifingList->begin(), g_pNotifingList->end(), pOb);
            if (iteNotifing!=g_pNotifingList->end()) {
                g_pNotifingList->erase(iteNotifing);
            }
        }
    }
}

void CMessageManager::DetachMessage(MESSAGE_ID msg,IMessageObserver* pObHelper,id idOb)
{
    assert([NSThread isMainThread]);
    if (!pObHelper || idOb==nil) {
        return;
    }
    
    OB_LIST_OC& lstOb=g_lstObservers_oc[msg];
    OB_LIST_ITE_OC ite;
    for (ite=lstOb.begin(); ite!=lstOb.end(); ++ite) {
        if (ite->second==idOb) {
            lstOb.erase(ite);
            if (g_pNotifingList_oc && idOb!=g_idNotifingObj_oc) {
                OB_LIST_ITE_OC iteNotifing;
                for (iteNotifing=g_pNotifingList_oc->begin(); iteNotifing!=g_pNotifingList_oc->end(); ++iteNotifing) {
                    if (iteNotifing->second==idOb) {
                        g_pNotifingList_oc->erase(iteNotifing);
                        break;
                    }
                }
            }
            break;
        }
    }
}

void CMessageManager::StopAllMessage()
{
    g_bStopAllMessage=true;
}

inline void __MessageManagerNotify(MESSAGE_ID msg,unsigned uiMethod,const std::vector<KwTools::Variant>& vecParams)
{
    if(g_bStopAllMessage)return;
    
    @autoreleasepool {
        if (msg==OBSERVER_ID_RESERVE && uiMethod==KS_BLOCK_RUN_MAGIC_NUM) 
        {
            dispatch_block_t __func=vecParams[0];
            __func();
            Block_release(__func);
        }
        else 
        {
            //NSLog(@"ObserverNotify:%d-%d-%ld",msg,uiMethod,vecParams.size());
            if (!g_lstObservers[msg].empty())
            {
                OB_LIST lstOb=g_lstObservers[msg];
                
                OB_LIST* pOldNotifingList(g_pNotifingList);
                g_pNotifingList=&lstOb;
                
                for (OB_LIST::const_iterator ite=lstOb.begin(); ite!=lstOb.end(); ++ite)
                {
                    IMessageObserver* pOldNotifingObj(g_pNotifingObj);
                    g_pNotifingObj=*ite;
                    
                    (*ite)->Notify(uiMethod, vecParams);
                    
                    g_pNotifingObj=pOldNotifingObj;
                }
                
                g_pNotifingList=pOldNotifingList;
            }
            if (!g_lstObservers_oc[msg].empty())
            {
                OB_LIST_OC lstOb_oc=g_lstObservers_oc[msg];
                
                OB_LIST_OC* pOldNotifingList(g_pNotifingList_oc);
                g_pNotifingList_oc=&lstOb_oc;
                
                for (OB_LIST_OC::const_iterator ite=lstOb_oc.begin(); ite!=lstOb_oc.end(); ++ite)
                {
                    IMessageObserver* pObHelper=ite->first;
                    id it=ite->second;
                    
                    id idOldNotifingObj_oc(g_idNotifingObj_oc);
                    g_idNotifingObj_oc=it;
                    pObHelper->Notify(uiMethod, vecParams,it);
                    g_idNotifingObj_oc=idOldNotifingObj_oc;
                }
                
                g_pNotifingList_oc=pOldNotifingList;
            }
        }
    }//@autoreleasepool
}

void CMessageManager::SyncNotify(MESSAGE_ID msg,unsigned uiMethod,const std::vector<KwTools::Variant>& vecParams)
{
    if(g_bStopAllMessage)return;
    
    if([NSThread isMainThread])
    {
        __MessageManagerNotify(msg, uiMethod, vecParams);
    }
    else 
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            __MessageManagerNotify(msg, uiMethod, vecParams);
        });
    }
}


//延时通知辅助OC对象，为了用NSTimer
@interface CMsgTimer:NSObject
@property (nonatomic,assign) MESSAGE_ID msg;
@property (nonatomic,assign) unsigned uiMethod;
@property (nonatomic,assign) std::vector<KwTools::Variant>* pvecParams;
-(void)timerMethod:(NSTimer*)theTimer;
+(void)runMsgTimerWithParas:(MESSAGE_ID)msg method:(unsigned)uiMethod params:(const std::vector<KwTools::Variant>*)pvecParam delay:(int)nDeyay;
@end
@implementation CMsgTimer;
@synthesize msg;
@synthesize uiMethod;
@synthesize pvecParams;
-(void)timerMethod:(NSTimer*)theTimer
{
    [theTimer invalidate];
    __MessageManagerNotify(msg, uiMethod, *pvecParams);
    delete pvecParams;
    [self release];
}
+(void)runMsgTimerWithParas:(MESSAGE_ID)msg method:(unsigned)uiMethod params:(const std::vector<KwTools::Variant>*)pvecParam delay:(int)nDeyay
{
    CMsgTimer* pMsgTimer=[CMsgTimer alloc];
    pMsgTimer.msg=msg;
    pMsgTimer.uiMethod=uiMethod;
    pMsgTimer.pvecParams=new std::vector<KwTools::Variant>(*pvecParam);
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:(double)nDeyay/1000 target:pMsgTimer selector:@selector(timerMethod:) userInfo:nil repeats:NO];
    });       
}
@end


void CMessageManager::AsyncNotify(MESSAGE_ID msg,unsigned uiMethod,int nDelay,const std::vector<KwTools::Variant>& vecParams)
{
    if(g_bStopAllMessage)return; 
    if (0==nDelay) 
    {
        std::vector<KwTools::Variant>* pvecParamsCopy=new std::vector<KwTools::Variant>(vecParams);
        dispatch_async(dispatch_get_main_queue(), ^{
            __MessageManagerNotify(msg, uiMethod, *pvecParamsCopy);   
            delete pvecParamsCopy;
        });     
    }
    else 
    {
        [CMsgTimer runMsgTimerWithParas:msg method:uiMethod params:&vecParams delay:nDelay]; 
    }
}

//BlockHelper
@implementation __KSRunTargetThreadHelper

- (void)run:(id)func
{
    dispatch_block_t f=(dispatch_block_t)func;
    f();
    Block_release(f);
}
@end
