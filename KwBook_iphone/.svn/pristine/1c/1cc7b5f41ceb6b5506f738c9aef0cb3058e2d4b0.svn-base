//
//  LocalTask.h
//  kwbook
//
//  Created by 单 永杰 on 14-1-6.
//  Copyright (c) 2014年 单 永杰. All rights reserved.
//

#ifndef __kwbook__LocalTask__
#define __kwbook__LocalTask__

#ifndef kwbook_ChapterInfo_h
#include "ChapterInfo.h"
#endif

#ifndef KwSing_HttpRequest_h
#include "HttpRequest.h"
#endif

#include <iostream>

enum TaskStatus
{
    TaskStatus_Null = 0,
    TaskStatus_Downing,
    TaskStatus_Waiting,
    TaskStatus_Finish,
    TaskStatus_Pause,
    TaskStatus_Fail
};

enum DowningStatus
{
    Status_DowningNull = 0,
    Status_DowningBook,
};

class CLocalTask : public CChapterInfo
{
public:
    TaskStatus taskStatus;
    DowningStatus downStatus;
    CHttpRequest * pRequest;
    int nRetryCount;
    
    CLocalTask()
    {
        taskStatus = TaskStatus_Null;
        downStatus = Status_DowningNull;
        pRequest = NULL;
        nRetryCount = 0;
    }
    
    virtual~CLocalTask()
    {
        if(pRequest)
            delete pRequest;
    }
    
};

#endif /* defined(__kwbook__LocalTask__) */
