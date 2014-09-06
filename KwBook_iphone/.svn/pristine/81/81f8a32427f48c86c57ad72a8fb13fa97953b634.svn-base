//
//  Lock.cpp
//  KwSing
//
//  Created by 永杰 单 on 12-7-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "Lock.h"

namespace KwTools {
    CLock::CLock(bool b_recursive){
        pthread_mutexattr_t mutex_attr;
        pthread_mutexattr_init(&mutex_attr);
        pthread_mutexattr_settype(&mutex_attr, b_recursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_NORMAL);
        pthread_mutex_init(&m_Mutex, &mutex_attr);
    }
    
    CLock::~CLock(){
        pthread_mutex_destroy(&m_Mutex);
    }
    
    void CLock::Lock(){
        pthread_mutex_lock(&m_Mutex);
    }
    
    bool CLock::TryLock(){
        return (!pthread_mutex_trylock(&m_Mutex));
    }
    
    void CLock::UnLock(){
        pthread_mutex_unlock(&m_Mutex);
    }
}

