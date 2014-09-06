//
//  Block.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-16.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_Block_h
#define KwSing_Block_h


#define KS_BLOCK_RUN_MAGIC_NUM 7753

#define KS_BLOCK_DECLARE \
{\
    dispatch_block_t __func=^(void)\
    {\
        @autoreleasepool {

//主线程中执行，阻塞
#define KS_BLOCK_SYNRUN() \
        }\
    };\
    SYN_NOTIFY(OBSERVER_ID_RESERVE,KS_BLOCK_RUN_MAGIC_NUM,__func);\
}

//主线程中执行，异步
#define KS_BLOCK_ASYNRUN(delay) \
        }\
    };\
    ASYN_NOTIFY(OBSERVER_ID_RESERVE,KS_BLOCK_RUN_MAGIC_NUM,(delay),__func);\
}

//在线程里执行(用的dispatch_get_global_queue，不一定是全新的线程，不过不用关心)
//参数可以留空,默认为 PRIORITY_DEFAULT
#define KS_BLOCK_RUN_THREAD(...) \
        }\
    };\
    dispatch_queue_priority_t priority=__KsThreadPriority(__VA_ARGS__)();\
    dispatch_async(dispatch_get_global_queue(priority,0),__func);\
}

//在特定线程中执行，线程要有runloop
#define KS_BLOCK_RUN_TARGET_THREAD(pNSTHREAD,bSync) \
        }\
    };\
    __block __KSRunTargetThreadHelper* pHelper=[__KSRunTargetThreadHelper alloc];\
    [pHelper performSelector:@selector(run:) onThread:(pNSTHREAD) withObject:Block_copy(__func) waitUntilDone:bSync];\
    [pHelper release];\
}

//线程优先级
#define KS_BLOCK_PRIORITY_HIGH          _KS_BLOCK_PRIORITY_HIGH
#define KS_BLOCK_PRIORITY_DEFAULT       _KS_BLOCK_PRIORITY_DEFAULT
#define KS_BLOCK_PRIORITY_LOW           _KS_BLOCK_PRIORITY_LOW

#endif

//支持类似如下写法，无限嵌套
//
//  KS_BLOCK_DECLARE
//  {
//      //do sth. on thread
//      KS_BLOCK_DECLARE
//      {
//          //do sth. on main thread
//      }
//      KS_BLOCK_SYNRUN();
//  }
//  KS_BLOCK_RUN_THREAD();
//











