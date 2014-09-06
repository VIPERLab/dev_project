//
//  KBDatabaseManagement.h
//  kwbook
//
//  Created by 单 永杰 on 14-1-5.
//  Copyright (c) 2014年 单 永杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <vector>

#ifndef kwbook_BookInfo_h
#include "BookInfo.h"
#endif

#import "LocalTask.h"

@interface KBDatabaseManagement : NSObject

+(KBDatabaseManagement*)sharedInstance;

-(void)addBook : (CBookInfo*) book_info;
-(void)deleteBook : (std::string)str_book_id;

-(void)addChapter : (CChapterInfo*)chapter_info;
-(void)addChapters : (std::vector<CChapterInfo*>&) vec_chapter;
-(void)deleteChapter : (unsigned)n_rid;
-(void)deleteChapters : (std::string)str_book_id;
-(void)deleteChapters : (std::string)str_book_id : (bool)b_downed;
-(void)updateChapter : (CChapterInfo*)chapter_info;

@end
