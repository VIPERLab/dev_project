//
//  IEmigratedObserver.h
//  KwSing
//
//  Created by Hu Qian on 12-10-16.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IEmigratedObserver_h
#define KwSing_IEmigratedObserver_h

#include "IMessageObserver.h"

@protocol IEmigratedObserver <NSObject>
@optional
-(void)IObEmigrated_EmigratedFinish:(unsigned)uipoint;
@end

class IEmigratedObserver:public IMessageObserver
{
public:
    virtual void IObEmigrated_EmigratedFinish(unsigned uipoint){}

    enum eumMethod
    {
        EmigratedFinish
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IEmigratedObserver)
    NOTIFY_CASE_ITEM(EmigratedFinish,IObEmigrated_EmigratedFinish,_1PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};


#endif
