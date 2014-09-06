//
//  HotSongsView.h
//  KwSing
//
//  Created by 熊 改 on 12-11-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "DataItem.h"

@interface HotSongsView : UITableView<UITableViewDataSource,UITableViewDelegate,EGORefreshTableDelegate,NSXMLParserDelegate,DataItemDelegate>
{
    DataItem        *item;
    NSMutableArray  *allItems;
    NSInteger       _currentPage;
    NSInteger       _totalPage;
    NSString        *_currentPageStr;
    NSString        *_totalPageStr;
    
    BOOL            _reloading;
    BOOL            _hasNewData;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    EGORefreshTableFooterView *_refreshFooterView;
    
    NSString        *_timeStamp;
    NSMutableString *tmpFindStr;
    
    NSString* _getNewDataRes;
    NSString* _getNewDataMsg;
    
    bool _isFirstRefresh;
}
@property (retain,nonatomic) NSString* timeStamp;
@property (retain,nonatomic) NSString* currentPageStr;
@property (retain,nonatomic) NSString* totalPageStr;
@property (retain,nonatomic) NSString* getNewDataRes;
@property (retain,nonatomic) NSString* getNewDataMsg;

-(void)fetchDataUseCachedata:(BOOL)useCache;
-(void)fetchMoreData;
-(void)beginToReloadData:(EGOReloadPos)reloadPos;
-(void)finishReloadingData;

-(void)addFooterView;
-(void)removeFooterView;
-(void)addHeaderView;
-(void)removeHeaderView;

-(void)addItem:(DataItem*)addItem;
@end
