//
//  AutoLock.cpp
//  KwSing
//
//  Created by 永杰 单 on 12-7-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "AutoLock.h"

namespace KwTools {
    CAutoLock::CAutoLock(KwTools::CLock* p_lock){
        if(NULL != p_lock){
            p_lock->Lock();
            m_pLock = p_lock;
        }
    }
    
    CAutoLock::CAutoLock(KwTools::CLock& lock){
        lock.Lock();
        m_pLock = &lock;
    }
    
    CAutoLock::~CAutoLock(){
        if (NULL != m_pLock) {
            m_pLock->UnLock();
        }
    }
    
    CAutoRecursiveLock::CAutoRecursiveLock(NSRecursiveLock* p_lock){
        if(NULL != p_lock){
            [p_lock lock];
            m_pLock = p_lock;
        }
    }
    
    CAutoRecursiveLock::~CAutoRecursiveLock(){
        if (NULL != m_pLock) {
            [m_pLock unlock];
        }
    }
}


