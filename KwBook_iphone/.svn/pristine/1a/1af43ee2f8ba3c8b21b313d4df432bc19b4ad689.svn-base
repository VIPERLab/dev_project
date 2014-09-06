//
//  HotSearchWords.h
//  kwbook
//
//  Created by 单 永杰 on 13-12-5.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef __kwbook__HotSearchWords__
#define __kwbook__HotSearchWords__

#include <iostream>

class CHotSearchWords {
public:
    virtual~CHotSearchWords(){}
    
    static CHotSearchWords* GetInstance();
    NSArray* GetHotSearchWords();
    
private:
    CHotSearchWords();
    
    NSMutableArray* m_arrySearchWords;
};

#endif /* defined(__kwbook__HotSearchWords__) */
