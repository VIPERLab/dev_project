//
//  AutoLock.h
//  KwSing
//
//  Created by 永杰 单 on 12-7-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CAutoLock_h
#define KwSing_CAutoLock_h

#ifndef KwSing_CLock_h
#include "Lock.h"
#endif

namespace KwTools {
    class CAutoLock{
    public:
        CAutoLock(KwTools::CLock* p_lock);
        CAutoLock(KwTools::CLock& lock);
        virtual~ CAutoLock();
        
    private:
        KwTools::CLock* m_pLock;
    };
    
    class CAutoRecursiveLock{
    public:
        CAutoRecursiveLock(NSRecursiveLock* p_lock);
        virtual~ CAutoRecursiveLock();
        
    private:
        NSRecursiveLock* m_pLock;
    };
}

#define AutoLock(lock) KwTools::CAutoLock _temp_lock(lock)

#endif
