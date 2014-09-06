//
//  IObserverNetBufferringState.h
//  kwbook
//
//  Created by 单 永杰 on 13-12-3.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef kwbook_IObserverNetBufferringState_h
#define kwbook_IObserverNetBufferringState_h

#include "IMessageObserver.h"

@protocol IObserverNetBufferringState <NSObject>
@optional
-(void)IObserverNetBufferringChanged:(float)f_buffer_ratio;
@end

class IObserverNetBufferringState:public IMessageObserver
{
public:
    //网络状态切换
    virtual void IObserverNetBufferringChanged(float f_buffer_ratio){}
    
    enum eumMethod
    {
        BufferringRatioChanged
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IObserverNetBufferringState)
    
    NOTIFY_CASE_ITEM(BufferringRatioChanged,IObserverNetBufferringChanged,_1PARA);
    
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
