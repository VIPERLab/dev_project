//
//  Lock.h
//  KwSing
//
//  Created by 永杰 单 on 12-7-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CLock_h
#define KwSing_CLock_h

#include <pthread.h>

namespace KwTools {
    class CLock{
    public:
        CLock(bool b_recursive = true);
        virtual ~CLock();
        
    public:
        void Lock();
        bool TryLock();
        void UnLock();
        
    private:
        pthread_mutex_t m_Mutex;
    };
}//namespace KwTools

#endif
