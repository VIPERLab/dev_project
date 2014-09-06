//
//  SearchHistory.h
//  kwbook
//
//  Created by 单 永杰 on 13-12-6.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef __kwbook__SearchHistory__
#define __kwbook__SearchHistory__

#include <iostream>

class CSearchHistroy {
public:
    virtual ~CSearchHistroy(){}
    
    static CSearchHistroy* GetInstance();
    NSArray* GetSearchHistory()const;
    void AddSearchKey(NSString* str_search_key);
    void DeleteSearchKey(NSString* str_search_key);
    void ClearHistory();
    
private:
    CSearchHistroy();
    
    NSMutableArray* m_arrySearchHistroy;
};

#endif /* defined(__kwbook__SearchHistory__) */
