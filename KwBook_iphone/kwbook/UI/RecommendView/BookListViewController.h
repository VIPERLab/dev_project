//
//  RankBookListViewController.h
//  kwbook
//
//  Created by 熊 改 on 13-12-3.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import "KBViewController.h"

enum BOOKLIST_TYPE
{
    BOOKLIST_RANK,
    BOOKLIST_CATE
};

@interface BookListViewController : KBViewController
@property (nonatomic , assign) BOOKLIST_TYPE type;
-(instancetype)initWithBookListId:(NSString *)theID andName:(NSString *)theName;
@end
