//
//  IMyMessageStateObserver.h
//  KwSing
//
//  Created by 永杰 单 on 12-9-18.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IMyMessageStateObserver_h
#define KwSing_IMyMessageStateObserver_h

#ifndef KwSing_IMessageObserver_h
#include "IMessageObserver.h"
#endif

@protocol IMyMessageStateObserver <NSObject>
@optional
-(void)IMyMessageStateObserver_MessageNumChanged;
@end

class IMyMessageStateObserver:public IMessageObserver
{
public:
    //My New Message Number changed
    virtual void IMyMessageStateObserver_MessageNumChanged(){}
    
    enum eumMethod
    {
        MyMessageNumChanged
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IMyMessageStateObserver)
    NOTIFY_CASE_ITEM(MyMessageNumChanged,IMyMessageStateObserver_MessageNumChanged,_0PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
