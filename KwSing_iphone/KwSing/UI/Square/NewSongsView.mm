  //
//  NewSongsView.m
//  KwSing
//
//  Created by 熊 改 on 12-11-21.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "NewSongsView.h"
#import "ButtonItem.h"
#import "ASIHTTPRequest.h"
#import "CacheMgr.h"
#import "MessageManager.h"
#import "Block.h"
#import "HttpRequest.h"
#import "iToast.h"
#import "globalm.h"

@implementation NewSongsView

@synthesize currentPageStr=_currentPageStr,totalPageStr=_totalPageStr;

#define UpToInt(a)      (a)>(int(a))? (int)((a)+1) : a
#define DownToInt(a)    (a)>(int(a))? int(a)       : a
#define NumOfItemsInCell    3

#define NEW_XMLDATA_CACHE_KEY   "newXMLDataCacheKey"
#define BASE_NEWSONGS_URL       @"http://changba.kuwo.cn/kge/mobile/Plaza?t=new"
#define CREATE_TAG(n)           (200+(n))

#define CELL_HAS_LOAD_IMAGE     301
#define CELL_NO_LOAD_IMAGE      300

#define NEWSONGS_CELL_IDENTTIFY @"newSongsCellIdentify"

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
            allItems=[[NSMutableArray alloc] init];
            _currentPage=0;
            _totalPage=0;
            [self fetchDataUseCachedata:YES];
            
            [self setDataSource:self];
            [self setDelegate:self];
            
            [self setSeparatorColor:[UIColor clearColor]];
            [self setBackgroundColor:UIColorFromRGBValue(0xededed)];
            
            self.contentInset=UIEdgeInsetsMake(0, 0, 10.0, 0);
            [self addHeaderView];
        }
        return self;
}
#pragma mark
#pragma mark methods for add and remove header views

-(void)addHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f-self.bounds.size.height, self.bounds.size.width, self.bounds.size.height) arrowImageName:@"blackArrow.png" textColor:UIColorFromRGBValue(0x666666)];
    [_refreshHeaderView setDelegate:self];
    [self addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
}
-(void)removeHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView=nil;
}
-(void)addFooterView{
    CGFloat contentHeight=[allItems count]/3*108;
    CGFloat height=MAX(contentHeight, self.frame.size.height);
    
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView setFrame:CGRectMake(0.0f, height, self.frame.size.width, self.bounds.size.height)];
    }
    else{
        _refreshFooterView=[[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, height, self.frame.size.width, self.bounds.size.height) arrowImageName:@"blackArrow.png" textColor:UIColorFromRGBValue(0x666666)];
        [_refreshFooterView setDelegate:self];
        [self addSubview:_refreshFooterView];
    }
    if (_refreshFooterView) {
        [_refreshFooterView refreshLastUpdatedDate];
    }
}
-(void)removeFooterView{
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView=nil;
}
#pragma mark
#pragma mark methods for get new data and get more data

-(void)refreshAllCellTag
{
    int rows=[self numberOfRowsInSection:0];
    for (int i=0; i<rows; i++) {
        NSString* cellIndentify=[NSString stringWithFormat:@"%d%@",i,NEWSONGS_CELL_IDENTTIFY];
        UITableViewCell *cell=[self dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell) {
            [cell setTag:CELL_NO_LOAD_IMAGE];
        }
    }
    for (UITableViewCell *cell in [self visibleCells]) {
        [cell setTag:CELL_NO_LOAD_IMAGE];
    }

}
-(void)fetchDataUseCachedata:(BOOL)useCache;
{
    __block void *XMLData(NULL);
    __block unsigned length(0);
    BOOL outOfTime(true);
    if (useCache && CCacheMgr::GetInstance()->Read(NEW_XMLDATA_CACHE_KEY, XMLData, length, outOfTime)) {
        NSData *data=[NSData dataWithBytesNoCopy:XMLData length:length freeWhenDone:YES];
        NSXMLParser *parse=[[NSXMLParser alloc] initWithData:data];
        [parse setDelegate:self];
        [parse parse];
        [parse release];
        [self reloadData];
        [self addFooterView];
    }
    else
    {
        KS_BLOCK_DECLARE
        {
            NSString* refreshURL=@"http://changba.kuwo.cn/kge/mobile/Plaza?t=new&pn=1&rn=24";
            BOOL retRes=CHttpRequest::QuickSyncGet([refreshURL UTF8String],XMLData,length);
            KS_BLOCK_DECLARE
            {
                if (retRes) {
                    _currentPage=1;
                    [allItems removeAllObjects];
                    NSData* data=[NSData dataWithBytesNoCopy:XMLData length:length freeWhenDone:YES];
                    NSXMLParser *parser=[[NSXMLParser alloc] initWithData:data];
                    [parser setDelegate:self];
                    [parser parse];
                    [parser release];
                    CCacheMgr::GetInstance()->Cache(T_DAY, 3, NEW_XMLDATA_CACHE_KEY, [data bytes], [data length]);
                    [self refreshAllCellTag];
                    [self reloadData];
                    [self addFooterView];
                }
                else{
                    if (![self isHidden]) {
                        [[[[iToast makeText:NSLocalizedString(@"更新失败", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    }
                }
                [self performSelector:@selector(finishReloadingData) withObject:nil afterDelay:2.0];
            }KS_BLOCK_SYNRUN()
        }
        KS_BLOCK_RUN_THREAD()
    }
}
-(void)fetchMoreData
{
    if (_currentPage >=_totalPage) {
        [self performSelector:@selector(finishReloadingData) withObject:nil afterDelay:2.0];
        return;
    }
    if (CHttpRequest::GetNetWorkStatus() == NETSTATUS_NONE) {
        [[[[iToast makeText:NSLocalizedString(@"更新失败", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
        [self performSelector:@selector(finishReloadingData) withObject:nil afterDelay:2.0];
        return;
    }
    KS_BLOCK_DECLARE
    {
        NSString* nextPageURL=[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/mobile/Plaza?t=new&pn=%d&rn=24",++_currentPage];
        void *XMLData(NULL);
        unsigned length(0);
        
        BOOL retRes=CHttpRequest::QuickSyncGet([nextPageURL UTF8String],XMLData,length);
        KS_BLOCK_DECLARE
        {
            if (retRes) {
                NSData* data=[NSData dataWithBytesNoCopy:XMLData length:length freeWhenDone:YES];
                NSXMLParser *parser=[[NSXMLParser alloc] initWithData:data];
                [parser setDelegate:self];
                [parser parse];
                [parser release];
                
                [self reloadData];
                [self finishReloadingData];
                if (_currentPage<_totalPage) {
                    [self addFooterView];
                    self.contentInset=UIEdgeInsetsMake(0, 0, 10, 0);
                }
                else{
                    [self removeFooterView];
                    self.contentInset=UIEdgeInsetsMake(0, 0, 10, 0);
                }
            }
            else{
                [[[[iToast makeText:NSLocalizedString(@"更新失败", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                [self finishReloadingData];
            }
        }KS_BLOCK_SYNRUN()
    }
    KS_BLOCK_RUN_THREAD()
}
#pragma mark
#pragma mark methods XML parser
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{

    if([elementName isEqualToString:@"current_pn"]){
        tmpFindStr=[[NSMutableString alloc] init];
        [self setCurrentPageStr:tmpFindStr];
    }
    else if ([elementName isEqualToString:@"total_pn"]){
        tmpFindStr=[[NSMutableString alloc] init];
        [self setTotalPageStr:tmpFindStr];
    }
    else if ([elementName isEqualToString:@"list"]) {
        [item release];
        item=[[DataItem alloc] init];
        [item setParentParserDelegate:self];
        [parser setDelegate:item];
    }

}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [tmpFindStr appendString:string];
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"current_pn"]) {
        _currentPage=[self.currentPageStr integerValue];
    }
    else if ([elementName isEqualToString:@"total_pn"]){
        _totalPage=[self.totalPageStr integerValue];
    }
    [tmpFindStr release];
    tmpFindStr=nil;
}
#pragma mark
#pragma mark methods for data Item delegate

-(void)addItem:(DataItem*)addItem
{
    [allItems addObject:addItem];
}
#pragma mark
#pragma mark methods to make ButtonItem load image
-(void)onLoadImage:(NSIndexPath*)indexPath
{
    UITableViewCell *cell=[self cellForRowAtIndexPath:indexPath];
    if (cell != nil) {
        for (int i=0; i<NumOfItemsInCell; i++) {
            NSInteger beginIndex=[indexPath row]*NumOfItemsInCell;
            DataItem *dItem=[allItems objectAtIndex:beginIndex+i];
            ButtonItem *bItem=(ButtonItem*)[cell.contentView viewWithTag:CREATE_TAG(i)];
            [bItem loadImage:dItem.pic];
            //[bItem performSelector:@selector(loadImage:) withObject:dItem.pic afterDelay:i];
            [cell setTag:CELL_HAS_LOAD_IMAGE];
        }
    }
}
#pragma mark
#pragma mark methods tableView dataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return UpToInt([allItems count]/NumOfItemsInCell);
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* CellIdentifier=[NSString stringWithFormat:@"%d%@",[indexPath row],NEWSONGS_CELL_IDENTTIFY];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell || cell.tag == CELL_NO_LOAD_IMAGE) {
        cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
        for(int i=0;i<NumOfItemsInCell;i++)
        {
                switch (i) {
                    case 0:
                    {
                        ButtonItem *bItem=[[[ButtonItem alloc] initWithFrame:CGRectMake(0, 2.5, 105, 105)] autorelease];
                        [bItem setTag:CREATE_TAG(i)];
                        [bItem setType:NEWSONG_BUTTON];
                        [cell.contentView addSubview:bItem];
                        break;
                    }
                    case 1:
                    {
                        ButtonItem *bItem=[[[ButtonItem alloc] initWithFrame:CGRectMake(107.5, 2.5, 105, 105)] autorelease];
                        [bItem setTag:CREATE_TAG(i)];
                        [bItem setType:NEWSONG_BUTTON];
                        [cell.contentView addSubview:bItem];
                        break;
                    }
                    case 2:
                    {
                        ButtonItem *bItem=[[[ButtonItem alloc] initWithFrame:CGRectMake(215, 2.5, 105, 105)] autorelease];
                        [bItem setTag:CREATE_TAG(i)];
                        [bItem setType:NEWSONG_BUTTON];
                        [cell.contentView addSubview:bItem];
                        break;
                    }
                    default:
                        break;
                }
        }
        for (int i=0; i<NumOfItemsInCell; i++) {
            NSInteger beginIndex=[indexPath row]*NumOfItemsInCell;
            DataItem *dItem=[allItems objectAtIndex:beginIndex+i];
            ButtonItem *bItem=(ButtonItem*)[cell.contentView viewWithTag:CREATE_TAG(i)];
            [bItem initDefaulfImage:true];
            [bItem setUpString:dItem.title];
            [bItem setDonwString:dItem.uname];
            [bItem setSongId:dItem.uid];
        }
        [cell setTag:CELL_NO_LOAD_IMAGE];
        [self performSelector:@selector(onLoadImage:) withObject:indexPath afterDelay:1.0];
    }
    return cell;
}


#pragma mark
#pragma mark methods for tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark
#pragma mark methods for begining and ending load data
-(void)beginToReloadData:(EGOReloadPos)reloadPos
{
    if (EGORefreshHeader == reloadPos) {
        //下拉刷新
        _reloading=true;
        [self fetchDataUseCachedata:NO];
    }
    else{
        //下拉加载更多
        [self fetchMoreData];
    }
}
-(void)finishReloadingData
{
    _reloading = NO;
    
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        [self addFooterView];
    }
    
}
#pragma mark
#pragma mark EGORefreshTableDelegate

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}
- (void)egoRefreshTableDidTriggerRefresh:(EGOReloadPos)aRefreshPos
{
    [self beginToReloadData:aRefreshPos];
}
- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view
{
    return _reloading;
}
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
    return [NSDate date];
}
-(void)dealloc
{
    [allItems release];
    [_refreshFooterView release];
    [_refreshHeaderView release];
    [tmpFindStr release];
    [super dealloc];
}


@end
