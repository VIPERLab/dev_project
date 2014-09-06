//
//  IObserverFlowProtect.h
//  kwbook
//
//  Created by 单 永杰 on 14-3-6.
//  Copyright (c) 2014年 单 永杰. All rights reserved.
//

#ifndef kwbook_IObserverFlowProtect_h
#define kwbook_IObserverFlowProtect_h

#include "IMessageObserver.h"

@protocol IObserverFlowProtect <NSObject>
@optional
-(void)IObserverFlowProtectStatusChanged:(bool)b_protect_on;
@end

class IObserverFlowProtect:public IMessageObserver
{
public:
    //启动画面显示完毕
    virtual void IObserverFlowProtectStatusChanged(bool b_protect_on){}
    
    enum eumMethod
    {
        FlowProtectStatusChange
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IObserverFlowProtect)
    NOTIFY_CASE_ITEM(FlowProtectStatusChange,IObserverFlowProtectStatusChanged,_1PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
