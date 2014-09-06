//
//  IMessageObserver.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IMessageObserver_h
#define KwSing_IMessageObserver_h

#include <vector>
#include "Variant.h"

//paras
#define _0PARA
#define _1PARA vecParam[0]
#define _2PARA _1PARA,vecParam[1]
#define _3PARA _2PARA,vecParam[2]
#define _4PARA _3PARA,vecParam[3]
#define _5PARA _4PARA,vecParam[4]
#define _6PARA _5PARA,vecParam[5]

#define _0PARA_OC 
#define _1PARA_OC :vecParam[0]
#define _2PARA_OC _1PARA_OC :vecParam[1]
#define _3PARA_OC _2PARA_OC :vecParam[2]
#define _4PARA_OC _3PARA_OC :vecParam[3]
#define _5PARA_OC _4PARA_OC :vecParam[4]
#define _6PARA_OC _5PARA_OC :vecParam[5]

#define _0PARA_OC_SPLITTER
#define _1PARA_OC_SPLITTER :
#define _2PARA_OC_SPLITTER _1PARA_OC_SPLITTER:
#define _3PARA_OC_SPLITTER _2PARA_OC_SPLITTER:
#define _4PARA_OC_SPLITTER _3PARA_OC_SPLITTER:
#define _5PARA_OC_SPLITTER _4PARA_OC_SPLITTER:
#define _6PARA_OC_SPLITTER _5PARA_OC_SPLITTER:

//begin
#define MESSAGE_OBSERVER_NOTIFY_BEGIN(classname) \
static classname* __GetInstance()\
{\
    static classname sInstance;\
    return &sInstance;\
}\
void Notify(unsigned uiMethod, const std::vector<KwTools::Variant>& vecParam,id idOC=nil)\
{\
    id<classname> p=idOC;\
    switch(uiMethod)\
    {

//end
#define MESSAGE_OBSERVER_NOTIFY_END() \
    }\
}

//items
#define NOTIFY_CASE_ITEM(methodid,fun,paras) \
    case methodid:\
        if (idOC==nil) \
            fun(paras);\
        else\
        {\
            if([p respondsToSelector:@selector(fun paras##_OC_SPLITTER)]){\
                [p fun paras##_OC];\
            }\
        }\
        break;

//interface
class IMessageObserver
{
public:
	virtual ~IMessageObserver(){};
    
	virtual void Notify(unsigned uiMethod, const std::vector<KwTools::Variant>& vecParam,id idOC=nil) = 0;
};


#endif
