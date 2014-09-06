//
//  IMediaSaveProcessObserver.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IMediaSaveProcessObserver_h
#define KwSing_IMediaSaveProcessObserver_h

#ifndef KwSing_IMessageObserver_h
#include "IMessageObserver.h"
#endif

enum EFileSaveStatus {
    E_SAVE_SUCCESS,
    E_SAVE_FAIL
};

@protocol IMediaSaveProcessObserver <NSObject>
@optional
-(void)IMediaSaveProcessObserver_SaveProgressChanged:(float)f_progress;
-(void)IMediaSaveProcessObserver_SaveStatusFinish:(EFileSaveStatus)e_status : (int)n_save_time;
@end

class IMediaSaveProcessObserver:public IMessageObserver
{
public:
    //Headset Status Changed
    virtual void IMediaSaveProcessObserver_SaveProgressChanged(float f_progress){}
    virtual void IMediaSaveProcessObserver_SaveStatusFinish(EFileSaveStatus e_status, int n_save_time){};
    
    enum eumMethod
    {
        SaveProgressChanged,
        SaveFinish
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IMediaSaveProcessObserver)
    NOTIFY_CASE_ITEM(SaveProgressChanged,IMediaSaveProcessObserver_SaveProgressChanged,_1PARA);
    NOTIFY_CASE_ITEM(SaveFinish,IMediaSaveProcessObserver_SaveStatusFinish,_2PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
