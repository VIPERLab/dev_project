//
//  FindSameSongViewController.m
//  KwSing
//
//  Created by 熊 改 on 13-2-25.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//
#include <QuartzCore/QuartzCore.h>
#import "FindSameSongViewController.h"
#import "globalm.h"
#import "ImageMgr.h"
#import "KSAppDelegate.h"
#import "HttpRequest.h"
#import "MessageManager.h"
#import "SBJson.h"
#import "CacheMgr.h"
#import "NowPlayViewController.h"
#import "BaseWebViewController.h"
#import "CommentViewController.h"
#import "User.h"
#import "MyPageViewController.h"
#import "KwTools.h"

#define TAG_FIRST_LABEL         11

#define TAG_SONG_BACK_VIEW      20
#define TAG_SONG_RANK_LABEL     21
#define TAG_SONG_HEAD_BUTTON    22
#define TAG_SONG_NAME_LABEL     23
#define TAG_SONG_SCORE_LABEL    24
#define TAG_SONG_PLAY_BUTTON    25
#define TAG_SONG_LISTEN_LABEL   26
#define TAG_SONG_FLOWER_LABEL   27
#define TAG_SONG_TIME_LABEL     28
#define TAG_SONG_HEAD_VIEW      29

#define TAG_COMMENT_IMAGE           31
#define TAG_COMMENT_FIRST_LABEL     32
#define TAG_COMMENT_SECOND_LABEL    33
#define TAG_COMMENT_THIRD_LABEL     34
#define TAG_COMMENT_MORE_IMAGE      35
#define TAG_COMMENT_MORE_LABEL      36

#define GET_RANK_URL    @"http://changba.kuwo.cn/kge/mobile/getKgeRelList?"
//#define GET_RANK_URL    @"http://60.28.205.41:8180/kge/mobile/getKgeRelList?"

@interface CellItemData : NSObject
@property (retain,nonatomic) NSString *nickName;
@property (retain,nonatomic) NSString *title;
@property (retain,nonatomic) NSString *userId;
@property (retain,nonatomic) NSString *headPic;
@property (retain,nonatomic) NSString *score;
@property (retain,nonatomic) NSString *numListened;
@property (retain,nonatomic) NSString *numFlowers;
@property (retain,nonatomic) NSString *numCommnets;
@property (retain,nonatomic) NSString *singTime;
//@property (retain,nonatomic) NSDictionary *commentDic;  //[uname:comment]
@property (retain,nonatomic) NSArray *commentName;
@property (retain,nonatomic) NSArray *commentContent;
@property (retain,nonatomic) NSString *songId;
@property (retain,nonatomic) NSString *sid;
@end
@implementation CellItemData


@end

const int CAPACITY_OF_RANK=20;

static bool b_exist=false;
static KwTools::CLock S_SAMESONG_HTTP_LOCK;

@interface FindSameSongViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CHttpRequest *_request;
    UITableView * _resTabView;
    bool _hasDataRec;
    bool _isRecNull;
    int _selfRank;
    int _itemNum;
    NSMutableArray *_cellItemArr;
    
    UIView *_noNetworkView;
}
-(void)fetchJsonData;
-(void)parserJsonData:(NSData *)jsonData;
-(void)headBtnClick:(UIButton *)sender;
-(void)playBtnClick:(UIButton *)sender;
-(void)fetchHeadPicAtURL:(NSString *)imageUrl inView:(UIImageView *)view;
-(void)setTagLabel:(int)tag inCell:(UITableViewCell*) cell Content:(NSString *)string;
-(void)showNoNetwork;
@end

@implementation FindSameSongViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        b_exist = true;
        _itemNum=0;
        _hasDataRec=false;
        _isRecNull=true;
        _cellItemArr =[[NSMutableArray alloc] initWithCapacity:CAPACITY_OF_RANK];
//        NSLog(@"array allco size:%d",[_cellItemArr count]);
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    _itemNum=0;
    _hasDataRec=false;
    _isRecNull=true;
//    [_cellItemArr removeAllObjects];
//    [_resTabView reloadData];
    [self fetchJsonData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:@"演唱排行"];
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    //[self fetchJsonData];
    
    _resTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height, 320, [UIScreen mainScreen].bounds.size.height-ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height) style:UITableViewStylePlain];
    [_resTabView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_resTabView setDelegate:self];
    [_resTabView setDataSource:self];
    [[self view] addSubview:_resTabView];
}
-(void)showNoNetwork
{
    if (!_noNetworkView) {
        CGRect mainRect=self.view.bounds;
        mainRect=BottomRect(mainRect, mainRect.size.height-ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height, 0);
        _noNetworkView = [[UIView alloc] initWithFrame:mainRect];
        [_noNetworkView setBackgroundColor:[UIColor whiteColor]];
        UIImageView *imageView=[[[UIImageView alloc] initWithFrame:mainRect] autorelease];
        [imageView setImage:CImageMgr::GetImageEx("failmsgNoNet.png")];
        [_noNetworkView addSubview:imageView];
        
        [[self view] addSubview:_noNetworkView];
        
        UITapGestureRecognizer *tapGestureRecognize=[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapErrorViewGestureRecognizer:)] autorelease];
        tapGestureRecognize.numberOfTapsRequired=1;
        
        [_noNetworkView addGestureRecognizer:tapGestureRecognize];
    }
    [_noNetworkView setHidden:false];
}
- (void)singleTapErrorViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    [self fetchJsonData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ReturnBtnClick:(UIButton *)sender
{
    b_exist = false;
    S_SAMESONG_HTTP_LOCK.Lock();
    if (_request) {
        _request->StopRequest();
        
        delete _request;
        _request = NULL;
    }
    
    [_cellItemArr release];
//    NSLog(@"cellItemrelease");
    _cellItemArr =nil;
    S_SAMESONG_HTTP_LOCK.UnLock();
    
    [_resTabView release];
    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
}
-(NSString *)createUrl
{
    if (User::GetUserInstance()->isOnline()) {
        return [NSString stringWithFormat:@"%@rid=%@&uid=%@",GET_RANK_URL,_rankRid,User::GetUserInstance()->getUserId()];
    }
    else{
        return [NSString stringWithFormat:@"%@rid=%@",GET_RANK_URL,_rankRid];
    }
}
-(void)fetchJsonData
{
    if (_noNetworkView) {
        [_noNetworkView setHidden:true];
    }
    
    if (CHttpRequest::GetNetWorkStatus() == NETSTATUS_NONE){
       [self showNoNetwork];
        return;
    }
    KS_BLOCK_DECLARE{
        KwTools::CAutoLock auto_lock(&S_SAMESONG_HTTP_LOCK);
        
        if (!b_exist) {
            return;
        }
        
        std::string getRankUrl=[[self createUrl] UTF8String];
        if (NULL != _request) {
            _request->StopRequest();
            delete _request;
            _request = NULL;
        }
        _request =new CHttpRequest(getRankUrl);
        _request->SetTimeOut(5000);
        BOOL res=_request->SyncSendRequest();
        
        if (res) {
            //请求成功
            void * buf(NULL);
            unsigned l(0);
            _request->ReadAll(buf, l);
            NSData *retData=[NSData dataWithBytesNoCopy:buf length:l freeWhenDone:YES];
            [self parserJsonData:retData];
            _hasDataRec=true;
            if (!b_exist) {
                return;
            }
        }
        KS_BLOCK_DECLARE
        {
            [_resTabView reloadData];
        }KS_BLOCK_SYNRUN()
    }
    KS_BLOCK_RUN_THREAD()
//    __block void* jsonData(NULL);
//    __block unsigned int dataLength(0);
//    KS_BLOCK_DECLARE{
//        NSString * getRankUrl=[self createUrl];
//        NSLog(@"rank:%@",getRankUrl);
//        CHttpRequest::QuickSyncGet(getRankUrl.UTF8String, jsonData, dataLength);
//        NSLog(@"request return");
//        NSData *retData=[NSData dataWithBytesNoCopy:jsonData length:dataLength freeWhenDone:YES];
//        
//            [self parserJsonData:retData];
//            _hasDataRec=true;
//            if (!b_exist) {
//                return;
//            }
//        KS_BLOCK_DECLARE{
//            [_resTabView reloadData];
//        }KS_BLOCK_SYNRUN()
//    }KS_BLOCK_RUN_THREAD()
}
-(void)parserJsonData:(NSData *)jsonData
{
//    NSLog(@"begin parser");
    if (!b_exist) {
//        NSLog(@"exist");
        return;
    }
    if (_cellItemArr == nil) {
        return;
    }
    if ([_cellItemArr count] > 0) {
        [_cellItemArr removeAllObjects];
    }
    //[_resTabView reloadData];
//    NSLog(@"array remove all  size:%d",[_cellItemArr count]);

    SBJsonParser *parser=[[SBJsonParser alloc] init];
    NSDictionary *parserDic=[parser objectWithData:jsonData];
    [parser release];
    //NSLog(@"ret dic:%@",[parserDic description]);
    NSString *retStat=[parserDic objectForKey:@"stat"];
    if ([retStat isEqualToString:@"ok"]) {
        _isRecNull=false;
        _selfRank=[[parserDic objectForKey:@"chart"] intValue];
        //_cellNum=[[parserDic objectForKey:@"total_pn"] intValue];
        //_cellNum=_cellNum*2+1;
        NSArray *kgeList=[parserDic objectForKey:@"kgelist"];
        for (NSDictionary * item in kgeList) {
            CellItemData * iData = [[CellItemData alloc] init];
            [iData setNickName:[item objectForKey:@"uname"]];
            [iData setUserId:[item objectForKey:@"uid"]];
            [iData setTitle:[item objectForKey:@"title"]];
            [iData setHeadPic:[item objectForKey:@"pic"]];
            [iData setNumFlowers:[item objectForKey:@"flower"]];
            [iData setNumListened:[item objectForKey:@"play"]];
            [iData setScore:(NSString*)[item objectForKey:@"score"]];
            [iData setSingTime:[item objectForKey:@"time"]];
            [iData setSongId:[item objectForKey:@"kid"]];
            [iData setSid:[item objectForKey:@"subid"]];
            
            NSArray *commentArr=[item objectForKey:@"messlist"];
            
            NSMutableArray *nameArr=[[NSMutableArray alloc] init];
            NSMutableArray *contentArr=[[NSMutableArray alloc] init];
            for (NSDictionary *commentItem in commentArr) {
                NSString* comContent=[commentItem objectForKey:@"content"];
                NSString* comAuthor=[commentItem objectForKey:@"userName"];
                [nameArr addObject:comAuthor];
                [contentArr addObject:comContent];
                
                [iData setNumCommnets:[commentItem objectForKey:@"totalCount"]];
            }
            [iData setCommentName:nameArr];
            [iData setCommentContent:contentArr];
            _itemNum++;
            [nameArr release];
            [contentArr release];
//            NSLog(@"array add size:%d",[_cellItemArr count]);
            [_cellItemArr addObject:iData];
            [iData release];
        }
    }
}

#pragma mark
#pragma mark tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row =[indexPath row];
    if (row != 0 && row%2 == 0) {
        int index=row/2-1;
        if (index >= [_cellItemArr count]) {
            return;
        }
        CellItemData *dataItem = [_cellItemArr objectAtIndex:index];
        CommentViewController * commentViewController = [[[CommentViewController alloc] init] autorelease];
        [commentViewController SetMusicId:[dataItem.songId UTF8String] subjectID:[dataItem.sid UTF8String] UserID:[dataItem.userId UTF8String]];
        [ROOT_NAVAGATION_CONTROLLER pushViewController:commentViewController animated:YES];
    }
}

#pragma mark
#pragma mark tableView Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 28;
    }
    if (indexPath.row %2 == 1) {
        return 81;
    }
    else{
        //NSLog(@"%d",indexPath.row);
        NSInteger index=(indexPath.row-1)/2;
        
        if (index >= [_cellItemArr count]) {
            return 0;
        }

        CellItemData *dataItem =(CellItemData*)[_cellItemArr objectAtIndex:index];
        int numComments = [[dataItem numCommnets] intValue];
        if (numComments == 0) {
            return 40;
        }
        else if (numComments == 1){
            return 60;
        }
        else if(numComments == 2){
            return 65;
        }
        else{
            return 80;
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemNum*2+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * firstCellIndentify=@"firstCell";
    static NSString * songCellIndentify=@"songCell";
    static NSString * commentCellIndentify_0=@"commentCell_0";
    static NSString * commentCellIndentify_1=@"commentCell_1";
    static NSString * commentCellIndentify_2=@"commentCell_2";
    static NSString * commentCellIndentify_3=@"commentCell_3";
    
    int index=(indexPath.row-1)/2;      // 数组中0对应1&2两个cell
    
    CGFloat cellHeight=[self tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell=[tableView dequeueReusableCellWithIdentifier:firstCellIndentify];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:firstCellIndentify] autorelease];
            UILabel *label=[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, cellHeight)] autorelease];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont systemFontOfSize:14.0]];
            [label setTag:TAG_FIRST_LABEL];
            [cell.contentView addSubview:label];
        }
        [(UILabel*)[[cell contentView] viewWithTag:TAG_FIRST_LABEL] setText:[self firstCellText]];
    }
    else if(indexPath.row%2 == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:songCellIndentify];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:songCellIndentify] autorelease];
            UIImageView *backView=[[[UIImageView alloc] init] autorelease];
            [backView setFrame:CGRectMake(0, 0, 320, cellHeight)];
            [backView setTag:TAG_SONG_BACK_VIEW];
            [cell.contentView addSubview:backView];
            
            UILabel *rankLabel=[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, cellHeight)] autorelease];
            [rankLabel setBackgroundColor:[UIColor clearColor]];
            [rankLabel setTextColor:[UIColor whiteColor]];
            [rankLabel setTextAlignment:NSTextAlignmentCenter];
            //[rankLabel setFont:[UIFont fontWithName:@"Helvetica-Oblique" size:18.0]];
            [rankLabel setTag:TAG_SONG_RANK_LABEL];
            [cell.contentView addSubview:rankLabel];
            
            UIImageView *headImage=[[[UIImageView alloc] init] autorelease];
            [headImage setFrame:CGRectMake(25, 10, 65, 65)];
            [headImage setImage:CImageMgr::GetImageEx("defaultHeadPic.jpg")];
            [headImage setTag:TAG_SONG_HEAD_VIEW];
            [[cell contentView] addSubview:headImage];
            
            UIButton *headBtn=[[[UIButton alloc] initWithFrame:CGRectMake(25, 10, 65, 65)] autorelease];
            [headBtn setTag:TAG_SONG_PLAY_BUTTON];
            [headBtn addTarget:self action:@selector(headBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            headBtn.showsTouchWhenHighlighted=true;
            [headBtn setBackgroundImage:CImageMgr::GetImageEx("headBack.png") forState:UIControlStateNormal];
            //[headBtn setBackgroundImage:CImageMgr::GetImageEx("headBackDown.png") forState:UIControlStateHighlighted];
            [[cell contentView] addSubview:headBtn];
            
            UILabel *namelabel=[[[UILabel alloc] initWithFrame:CGRectMake(96, 5, 130, 30)] autorelease];
            [namelabel setTag:TAG_SONG_NAME_LABEL];
            [namelabel setBackgroundColor:[UIColor clearColor]];
            //[namelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
            [namelabel setFont:[UIFont systemFontOfSize:17.0]];
            [namelabel setShadowColor:UIColorFromRGBValue(0xffffff)];
            [namelabel setShadowOffset:CGSizeMake(0, 1)];
            [[cell contentView] addSubview:namelabel];
            
            UILabel *scoreLabel=[[[UILabel alloc] initWithFrame:CGRectMake(225, 5, 40, 30)] autorelease];
            [scoreLabel setTag:TAG_SONG_SCORE_LABEL];
            [scoreLabel setBackgroundColor:[UIColor clearColor]];
            //[scoreLabel setTextColor:UIColorFromRGBValue(0xea9a1c)];
            [scoreLabel setFont:[UIFont fontWithName:@"Helvetica-Oblique" size:14.0]];
            [cell.contentView addSubview:scoreLabel];
            
            UIImageView *listen = [[[UIImageView alloc] initWithFrame:CGRectMake(96, 32, 10, 10)] autorelease];
            [listen setImage:CImageMgr::GetImageEx("listenNum.png")];
            [[cell contentView] addSubview:listen];
            
            UILabel *listenLabel=[[[UILabel alloc] initWithFrame:CGRectMake(112, 30, 40, 15)] autorelease];
            [listenLabel setTag:TAG_SONG_LISTEN_LABEL];
            [listenLabel setFont:[UIFont systemFontOfSize:12.0]];
            [listenLabel setBackgroundColor:[UIColor clearColor]];
            [[cell contentView] addSubview:listenLabel];
            
            UIImageView *rose = [[[UIImageView alloc] initWithFrame:CGRectMake(145, 32, 10, 10)] autorelease];
            [rose setImage:CImageMgr::GetImageEx("flowerNum.png")];
            [[cell contentView] addSubview:rose];
            
            UILabel *roseLabel=[[[UILabel alloc] initWithFrame:CGRectMake(162, 30, 40, 15)] autorelease];
            [roseLabel setTag:TAG_SONG_FLOWER_LABEL];
            [roseLabel setFont:[UIFont systemFontOfSize:12.0]];
            [roseLabel setBackgroundColor:[UIColor clearColor]];
            [[cell contentView] addSubview:roseLabel];
            
            
            UILabel *timeLabel=[[[UILabel alloc] initWithFrame:CGRectMake(96, 55, 150, 20)] autorelease];
            [timeLabel setTag:TAG_SONG_TIME_LABEL];
            [timeLabel setBackgroundColor:[UIColor clearColor]];
            [timeLabel setFont:[UIFont systemFontOfSize:13.0]];
            [timeLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
            [timeLabel setShadowOffset:CGSizeMake(0, 1)];
            [timeLabel setTextColor:UIColorFromRGBValue(0x969696)];
            [cell.contentView addSubview:timeLabel];
            
            UIButton *playBtn=[[[UIButton alloc] initWithFrame:CGRectMake(260, 10, 58, 58)] autorelease];
            [playBtn setBackgroundImage:CImageMgr::GetImageEx("cellPlayBtn.png") forState:UIControlStateNormal];
            //[playBtn setBackgroundImage:CImageMgr::GetImageEx("finishPlayDown.png") forState:UIControlStateSelected];
            [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [playBtn setTag:TAG_SONG_PLAY_BUTTON];
            [cell.contentView addSubview:playBtn];
        }
        if (index >2) {
            [(UIImageView *)[[cell contentView] viewWithTag:TAG_SONG_BACK_VIEW] setImage:CImageMgr::GetImageEx("blueCellBk.png")];
            [(UILabel *)[[cell contentView] viewWithTag:TAG_SONG_SCORE_LABEL] setTextColor:UIColorFromRGBValue(0x6abeff)];
        }
        else{
            [(UIImageView *)[[cell contentView] viewWithTag:TAG_SONG_BACK_VIEW] setImage:CImageMgr::GetImageEx("yellowCellBk.png")];
            [(UILabel *)[[cell contentView] viewWithTag:TAG_SONG_SCORE_LABEL] setTextColor:UIColorFromRGBValue(0xea9a1c)];
        }

        S_SAMESONG_HTTP_LOCK.Lock();
        CellItemData *dataItem=(CellItemData*)[_cellItemArr objectAtIndex:index];
        
        [(UILabel *)[[cell contentView] viewWithTag:TAG_SONG_RANK_LABEL] setText:[NSString stringWithFormat:@"%d",index+1]];
        [(UILabel *)[[cell contentView] viewWithTag:TAG_SONG_NAME_LABEL] setText:[NSString stringWithFormat:@"%@-%@",[dataItem nickName],[dataItem title]]];
        [(UILabel*)[[cell contentView] viewWithTag:TAG_SONG_SCORE_LABEL] setText:[NSString stringWithFormat:@"%@分",[dataItem score]]];
         [(UILabel *)[[cell contentView] viewWithTag:TAG_SONG_LISTEN_LABEL] setText:[NSString stringWithFormat:@"%@",[dataItem numListened]]];
        [(UILabel *)[[cell contentView] viewWithTag:TAG_SONG_FLOWER_LABEL] setText:[NSString stringWithFormat:@"%@",[dataItem numFlowers]]];
        [(UILabel *)[[cell contentView] viewWithTag:TAG_SONG_TIME_LABEL] setText:[dataItem singTime]];
        [self fetchHeadPicAtURL:[dataItem headPic] inView:(UIImageView *)[cell.contentView viewWithTag:TAG_SONG_HEAD_VIEW]];
        S_SAMESONG_HTTP_LOCK.UnLock();
        
    }
    else{
        S_SAMESONG_HTTP_LOCK.Lock();
        CellItemData *dataItem=(CellItemData*)[_cellItemArr objectAtIndex:index];
        int numOfComments=[[dataItem numCommnets] intValue];
        if (numOfComments == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:commentCellIndentify_0];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIndentify_0] autorelease];
                UIImageView *moreCommetView =[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("moreComment.png")] autorelease];
                [moreCommetView setFrame:CGRectMake(16, 10, 18, 5)];
                [[cell contentView] addSubview:moreCommetView];
                
                UILabel *moreCommentLabel=[[[UILabel alloc] initWithFrame:CGRectMake(35, 0, 280, 20)] autorelease];
                [moreCommentLabel setTextColor:UIColorFromRGBValue(0x969696)];
                [moreCommentLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
                [moreCommentLabel setShadowOffset:CGSizeMake(0, 1)];
                [moreCommentLabel setText:@"还不快来抢沙发"];
                [moreCommentLabel setBackgroundColor:[UIColor clearColor]];
                [moreCommentLabel setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:moreCommentLabel];
            }
        }
        else if (numOfComments == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:commentCellIndentify_1];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIndentify_1] autorelease];
                UIImageView *commentView = [[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("showComment.png")] autorelease];
                [commentView setFrame:CGRectMake(9, 5, 22, 20)];
                [[cell contentView] addSubview:commentView];
                
                UILabel *firstCommentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(35, 0, 280, 20)] autorelease];
                [firstCommentLabel setBackgroundColor:[UIColor clearColor]];
                [firstCommentLabel setTextColor:UIColorFromRGBValue(0x969696)];
                [firstCommentLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
                [firstCommentLabel setShadowOffset:CGSizeMake(0, 1)];
                [firstCommentLabel setTag:TAG_COMMENT_FIRST_LABEL];
                [firstCommentLabel setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:firstCommentLabel];
                
                UIImageView *moreCommetView =[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("moreComment.png")] autorelease];
                [moreCommetView setFrame:CGRectMake(16, 30, 18, 5)];
                [[cell contentView] addSubview:moreCommetView];
                
                UILabel *moreCommentLabel=[[[UILabel alloc] initWithFrame:CGRectMake(35, 20, 280, 20)] autorelease];
                [moreCommentLabel setTextColor:UIColorFromRGBValue(0x969696)];
                [moreCommentLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
                [moreCommentLabel setShadowOffset:CGSizeMake(0, 1)];
                [moreCommentLabel setText:@"查看全部评论"];
                [moreCommentLabel setBackgroundColor:[UIColor clearColor]];
                [moreCommentLabel setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:moreCommentLabel];
            }
            NSString *firstUserName =[[dataItem commentName] objectAtIndex:0];
            NSString *firstComment=[[dataItem commentContent] objectAtIndex:0];
            [(UILabel *)[cell.contentView viewWithTag:TAG_COMMENT_FIRST_LABEL] setText:[NSString stringWithFormat:@"%@ : %@",firstUserName,firstComment]];
        }
        else if (numOfComments == 2){
            cell = [tableView dequeueReusableCellWithIdentifier:commentCellIndentify_2];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIndentify_2] autorelease];
                
                UIImageView *commentView = [[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("showComment.png")] autorelease];
                [commentView setFrame:CGRectMake(9, 5, 22, 20)];
                [[cell contentView] addSubview:commentView];
                
                UILabel *firstCommentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(35, 0, 280, 20)] autorelease];
                [firstCommentLabel setBackgroundColor:[UIColor clearColor]];
                [firstCommentLabel setTextColor:UIColorFromRGBValue(0x969696)];
                [firstCommentLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
                [firstCommentLabel setShadowOffset:CGSizeMake(0, 1)];
                [firstCommentLabel setTag:TAG_COMMENT_FIRST_LABEL];
                [firstCommentLabel setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:firstCommentLabel];
                
                UILabel *secondCommentLable = [[[UILabel alloc] initWithFrame:CGRectMake(35, 20, 280, 20)] autorelease];
                [secondCommentLable setBackgroundColor:[UIColor clearColor]];
                [secondCommentLable setTextColor:UIColorFromRGBValue(0x969696)];
                [secondCommentLable setShadowColor:UIColorFromRGBValue(0xffffff)];
                [secondCommentLable setShadowOffset:CGSizeMake(0, 1)];
                [secondCommentLable setTag:TAG_COMMENT_SECOND_LABEL];
                [secondCommentLable setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:secondCommentLable];
                
                UIImageView *moreCommetView =[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("moreComment.png")] autorelease];
                [moreCommetView setFrame:CGRectMake(16, 50, 18, 5)];
                [[cell contentView] addSubview:moreCommetView];
                
                UILabel *moreCommentLabel=[[[UILabel alloc] initWithFrame:CGRectMake(35, 40, 280, 20)] autorelease];
                [moreCommentLabel setTextColor:UIColorFromRGBValue(0x969696)];
                [moreCommentLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
                [moreCommentLabel setShadowOffset:CGSizeMake(0, 1)];
                [moreCommentLabel setText:@"查看全部评论"];
                [moreCommentLabel setBackgroundColor:[UIColor clearColor]];
                [moreCommentLabel setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:moreCommentLabel];
            }
            NSString *firstUserName =[[dataItem commentName] objectAtIndex:0];
            NSString *firstComment=[[dataItem commentContent] objectAtIndex:0];
            [(UILabel *)[cell.contentView viewWithTag:TAG_COMMENT_FIRST_LABEL] setText:[NSString stringWithFormat:@"%@ : %@",firstUserName,firstComment]];
            
            NSString *secondUserName=[[dataItem commentName] objectAtIndex:1];
            NSString *secondComment=[[dataItem commentContent] objectAtIndex:1];
            [(UILabel *)[cell.contentView viewWithTag:TAG_COMMENT_SECOND_LABEL] setText:[NSString stringWithFormat:@"%@ : %@",secondUserName,secondComment]];
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:commentCellIndentify_3];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIndentify_3] autorelease];
                UIImageView *commentView = [[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("showComment.png")] autorelease];
                [commentView setFrame:CGRectMake(9, 5, 22, 20)];
                [[cell contentView] addSubview:commentView];
                
                UILabel *firstCommentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(35, 0, 280, 20)] autorelease];
                [firstCommentLabel setBackgroundColor:[UIColor clearColor]];
                [firstCommentLabel setTextColor:UIColorFromRGBValue(0x969696)];
                [firstCommentLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
                [firstCommentLabel setShadowOffset:CGSizeMake(0, 1)];
                [firstCommentLabel setTag:TAG_COMMENT_FIRST_LABEL];
                [firstCommentLabel setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:firstCommentLabel];
                
                UILabel *secondCommentLable = [[[UILabel alloc] initWithFrame:CGRectMake(35, 20, 280, 20)] autorelease];
                [secondCommentLable setBackgroundColor:[UIColor clearColor]];
                [secondCommentLable setTextColor:UIColorFromRGBValue(0x969696)];
                [secondCommentLable setShadowColor:UIColorFromRGBValue(0xffffff)];
                [secondCommentLable setShadowOffset:CGSizeMake(0, 1)];
                [secondCommentLable setTag:TAG_COMMENT_SECOND_LABEL];
                [secondCommentLable setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:secondCommentLable];
                
                UILabel *thirdCommentLabel=[[[UILabel alloc] initWithFrame:CGRectMake(35, 40, 280, 20)] autorelease];
                [thirdCommentLabel setBackgroundColor:[UIColor clearColor]];
                [thirdCommentLabel setTextColor:UIColorFromRGBValue(0x969696)];
                [thirdCommentLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
                [thirdCommentLabel setShadowOffset:CGSizeMake(0, 1)];
                [thirdCommentLabel setTag:TAG_COMMENT_THIRD_LABEL];
                [thirdCommentLabel setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:thirdCommentLabel];
                
                UIImageView *moreCommetView =[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("moreComment.png")] autorelease];
                [moreCommetView setFrame:CGRectMake(16, 70, 18, 5)];
                [[cell contentView] addSubview:moreCommetView];
                
                UILabel *moreCommentLabel=[[[UILabel alloc] initWithFrame:CGRectMake(35, 60, 280, 20)] autorelease];
                [moreCommentLabel setTextColor:UIColorFromRGBValue(0x969696)];
                [moreCommentLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
                [moreCommentLabel setShadowOffset:CGSizeMake(0, 1)];
                [moreCommentLabel setText:@"查看全部评论"];
                [moreCommentLabel setBackgroundColor:[UIColor clearColor]];
                [moreCommentLabel setFont:[UIFont systemFontOfSize:13.0]];
                [[cell contentView] addSubview:moreCommentLabel];
            }
            NSString *firstUserName =[[dataItem commentName] objectAtIndex:0];
            NSString *firstComment=[[dataItem commentContent] objectAtIndex:0];
            [(UILabel *)[cell.contentView viewWithTag:TAG_COMMENT_FIRST_LABEL] setText:[NSString stringWithFormat:@"%@ : %@",firstUserName,firstComment]];
            
            NSString *secondUserName=[[dataItem commentName] objectAtIndex:1];
            NSString *secondComment=[[dataItem commentContent] objectAtIndex:1];
            [(UILabel *)[cell.contentView viewWithTag:TAG_COMMENT_SECOND_LABEL] setText:[NSString stringWithFormat:@"%@ : %@",secondUserName,secondComment]];
            
            NSString *thirdUserName=[[dataItem commentName] objectAtIndex:2];
            NSString *thidComment=[[dataItem commentContent] objectAtIndex:2];
            [(UILabel *)[cell.contentView viewWithTag:TAG_COMMENT_THIRD_LABEL] setText:[NSString stringWithFormat:@"%@ : %@",thirdUserName,thidComment]];
        }
        S_SAMESONG_HTTP_LOCK.UnLock();
        [[cell contentView] setBackgroundColor:UIColorFromRGBValue(0xededed)];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(NSString *)firstCellText
{
    if (!_hasDataRec) {
        return @"正在努力加载中...";
    }
    if (_isRecNull) {
        return @"加载失败，请稍后再试!";
    }
    if (_itemNum == 0) {
        return @"这首歌还没有人唱过哦，快来抢第一名吧！";
    }
    
    if (_selfRank <= 0)
        return @"你还没有上传过这首歌，上传后可以参加排名。";
    if (_selfRank > 20) 
        return @"你还没有进入top20哦，还不继续努力。";
    if (_selfRank >0 && _selfRank <=20) 
        return [NSString stringWithFormat:@"你当前排第%d名，太厉害了!",_selfRank];
    return nil;
}
-(void)headBtnClick:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview]  superview];
    NSIndexPath *indexPath = [_resTabView indexPathForCell:cell];
    NSInteger index=(indexPath.row-1)/2;
    if (index <0 || index > [_cellItemArr count] -1) {
        return;
    }
    
    CellItemData *dataItem = (CellItemData *)[_cellItemArr objectAtIndex:index];
    BOOL isSelf=[dataItem.userId isEqualToString:User::GetUserInstance()->getUserId()];
    if (isSelf) {
        MyPageViewController *homeViewController=[[[MyPageViewController alloc] init] autorelease];
        [homeViewController setHasReturn:true];
        [ROOT_NAVAGATION_CONTROLLER pushViewController:homeViewController animated:YES];
    }
    else{
        BaseWebViewController *homePage=[[[BaseWebViewController alloc] init] autorelease];
        [homePage setStrUrl:[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/webmobile/ios/userhome.html?=111=%@",dataItem.userId]];
        [homePage setTitle:[NSString stringWithFormat:@"%@的个人主页",dataItem.nickName]];
        [ROOT_NAVAGATION_CONTROLLER pushViewController:homePage animated:YES];

    }
}
-(void)playBtnClick:(UIButton *)sender
{
    
    UITableViewCell *cell = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        cell = (UITableViewCell *)[[sender superview] superview];
    }
    else{
        cell = (UITableViewCell *)[[[sender superview] superview] superview];
    }
    NSIndexPath *indexPath = [_resTabView indexPathForCell:cell];
    NSInteger index=(indexPath.row-1)/2;
    if (index <0 || index > [_cellItemArr count] -1) {
        return;
    }
    CellItemData *dataItem = (CellItemData *)[_cellItemArr objectAtIndex:index];
    NowPlayViewController *nowPlay = [[[NowPlayViewController alloc] init] autorelease];
//    [nowPlay playId:dataItem.songId];
    [nowPlay setPlayType:false];
    [nowPlay setKid:dataItem.songId];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:nowPlay animated:YES];
}
-(void)setTagLabel:(int)tag inCell:(UITableViewCell*) cell Content:(NSString *)string
{
    UILabel *label=(UILabel*)[[cell contentView] viewWithTag:tag];
    NSString *str=[NSString stringWithFormat:@"%@",string];
    [label setText:str];
}
-(void)fetchHeadPicAtURL:(NSString *)imageUrl inView:(UIImageView *)view
{
    __block void* imageData(NULL);
    __block unsigned length(0);
    BOOL outOfTime(true);
    if ( (nil != imageUrl) && CCacheMgr::GetInstance()->Read([imageUrl UTF8String], imageData, length, outOfTime)) {
        NSData *cacheImageData=[[NSData alloc] initWithBytesNoCopy:imageData length:length freeWhenDone:YES];
        UIImage *image=[[UIImage alloc] initWithData:cacheImageData];
        [view setImage:image];
        [cacheImageData release];
        [image release];
    }
    else
    {
        KS_BLOCK_DECLARE{
            if (nil == imageUrl || 0 == [imageUrl length]) {
                return;
            }
            bool retRes=CHttpRequest::QuickSyncGet([imageUrl UTF8String], imageData, length);
            KS_BLOCK_DECLARE{
            if (retRes) {
                NSData* webImageData=[[NSData alloc] initWithBytesNoCopy:imageData length:length freeWhenDone:true];
                CCacheMgr::GetInstance()->Cache(T_DAY, 3, [imageUrl UTF8String], [webImageData bytes], [webImageData length]);
                UIImage *image=[[UIImage alloc] initWithData:webImageData];

                [view setImage:image];
                [webImageData release];
                [image release];
            }
            }KS_BLOCK_SYNRUN()
        }KS_BLOCK_RUN_THREAD()
    }
}
@end
