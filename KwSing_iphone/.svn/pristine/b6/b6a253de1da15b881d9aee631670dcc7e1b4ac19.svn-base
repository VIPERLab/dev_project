//
//  ILyricNotify.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-6.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ILyricNotify_h
#define KwSing_ILyricNotify_h
#include "LyricInfo.h"

class CLyricRequest;

@protocol ILyricNotify
@optional
- (void)ILyricNotify_Finished:(CLyricRequest*)request success:(BOOL)bSuccess;
@end

class ILyricNotify
{
public:
    virtual void ILyricNotify_Finished(CLyricRequest* request,BOOL bSuccess){}
};


#endif
