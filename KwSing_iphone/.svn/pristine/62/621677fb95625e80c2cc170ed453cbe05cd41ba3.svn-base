//
//  SearchViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "SearchViewController.h"
#include "SearchBarView.h"
#include <QuartzCore/QuartzCore.h>
#include "globalm.h"
#include "SearchRequest.h"
#include "MessageManager.h"
#include "ImageMgr.h"
#include "LocalMusicRequest.h"
#include "SearchTipView.h"
#include "IMusicLibObserver.h"
#include "globalm.h"
#include "KSProgressView.h"
#include "FindSameSongViewController.h"
#include "KSAppDelegate.h"
#include "RegistMissingSongViewController.h"

enum ControlTag
{
    KBUTTON_TAG = 1,
    KLABEL_NAME_TAG,
    KLABEL_ARTIST_TAG,
    KLABEL_TITLE_TAG,
    KPROGRESS_TAG
};


@interface SearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,SearchTipDelegate,IMusicLibObserver>
{
    CSearchRequest  *m_pRequest;
    int m_nCurPage;
    SONG_LIST m_vecSong;
    bool hasMore;
    bool loadingMore;
    
    UIButton *BtnRegistMissingSong;
}
@end

@implementation SearchViewController
@synthesize searchWord;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"搜索";
    }
    return self;
}

const int TagSearchBar = 100;
const int TagTableView = 102;
const int TagResultLabel = 103;
const int TagCellLoading = 104;
const int TagSearchTip = 105;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UILabel* lable = [[[UILabel alloc]initWithFrame:CGRectMake(10, 90, 300,30)]autorelease];
    lable.tag = TagResultLabel;
    lable.Font = [UIFont systemFontOfSize:14];
    lable.backgroundColor = UIColorFromRGBValue(0xededed);
    //lable.textColor = [UIColor whiteColor];
    [[self view] addSubview:lable];

    UITableView * resultView = [[[UITableView alloc]init]autorelease];
    resultView.tag = TagTableView;
    resultView.frame = CGRectMake(0, 120, 320, [UIScreen mainScreen].bounds.size.height-140);
    resultView.delegate = self;
    resultView.dataSource = self;
    resultView.backgroundColor = UIColorFromRGBValue(0xededed);
    resultView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[self view] addSubview:resultView];
    
    SearchBarView * searchBar = [[[SearchBarView alloc]initWithFrame:CGRectMake(0, 44, 320, 45)]autorelease];
    searchBar.delegate = self;
    searchBar.tag = TagSearchBar;
    [searchBar addSearchButtonWithTarget:self action:@selector(Search)];
    [searchBar addSearchCancelButtonWithTarget:self action:@selector(CancelSearch)];
    [[self view] addSubview:searchBar];
    searchBar.text = searchWord;
    
    m_pRequest = new CSearchRequest;
    
    SearchTipView * tipview = [[[SearchTipView alloc]initWithFrame:CGRectMake(0, 88, 320, self.view.frame.size.height-88)]autorelease];
    tipview.hidden = true;
    tipview.backgroundColor = [UIColor grayColor];
    tipview.tag = TagSearchTip;
    tipview.searchdelegate = self;
    [self.view addSubview:tipview];
    
    UIView * shadowview = (UIView*)[self.view viewWithTag:TagShadow];
    [self.view bringSubviewToFront:shadowview];
    
    BtnRegistMissingSong =[[[UIButton alloc] initWithFrame:CGRectMake(85, 210, 150, 45)] autorelease];
    [BtnRegistMissingSong addTarget:self action:@selector(onRegistMissingSong:) forControlEvents:UIControlEventTouchUpInside];
    [BtnRegistMissingSong setImage:CImageMgr::GetImageEx("registMissingSong.png") forState:UIControlStateNormal];
    [BtnRegistMissingSong setImage:CImageMgr::GetImageEx("registMissingSongDown.png") forState:UIControlStateHighlighted];
    [[self view] addSubview:BtnRegistMissingSong];
    [BtnRegistMissingSong setHidden:true];

    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    
    [self StartSearch:searchWord];
}

-(void)dealloc
{
    [super dealloc];
    delete m_pRequest;
}

-(void) ReturnBtnClick:(id)sender
{
    [super ReturnBtnClick:sender];
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
}
-(void)onRegistMissingSong:(id)sender
{
    RegistMissingSongViewController *registSongViewController=[[[RegistMissingSongViewController alloc] init] autorelease];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:registSongViewController animated:YES];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(m_bNetFail && !m_bReLoading)
    {
        m_bReLoading = true;
        [self StartSearch:searchWord];
    }
}

#define FAIL_KEYWORD_MAX_LEN 6
#define NORMAL_KEYWORD_MAX_LEN 8
-(void)StartSearch :(NSString*)strword
{
    UIActivityIndicatorView * loading = (UIActivityIndicatorView *)[self.view viewWithTag:TagLoading];
    if (nil != loading) {
        loading.hidden = false;
        [loading startAnimating];
    }
    
    [self.view bringSubviewToFront:loading];
    [(KSMusicLibDelegate*)musiclibDelegate InsertSearchKey:searchWord];
    m_nCurPage = 0;
    //NSLog(@"start search");
    KS_BLOCK_DECLARE
    {
        SearchParam param;
        param.strword = [strword UTF8String];
        if(m_pRequest->StartRequest(param))
        {
            KS_BLOCK_DECLARE
            {
                if(m_bNetFail)
                {
                    UIImageView * netfailview = (UIImageView*)[self.view viewWithTag:TagNetFailView];
                    netfailview.hidden = true;
                    UIImageView * loadfailview = (UIImageView*)[self.view viewWithTag:TagLoadFailView];
                    loadfailview.hidden = true;
                }
                m_bNetFail = false;
                m_bReLoading = false;
                
                if(param.strword == [searchWord UTF8String])
                {
                    m_vecSong.clear();
                    m_vecSong = m_pRequest->GetSongList(m_nCurPage);
                    
                    UIActivityIndicatorView * loading = (UIActivityIndicatorView *)[self.view viewWithTag:TagLoading];
                    [loading stopAnimating];
                    loading.hidden = true;
                    UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
                     tableview.contentOffset = CGPointMake(0, 0);
                    [tableview reloadData];
                    UILabel * label = (UILabel*)[self.view viewWithTag:TagResultLabel];

                    if(m_pRequest->GetHitNum() == 0)
                    {
                        [BtnRegistMissingSong setHidden:false];
                        NSString *key = NULL;
                        if ([searchWord length] > FAIL_KEYWORD_MAX_LEN) {
                            key = [NSString stringWithFormat:@"%@...", [searchWord substringToIndex:FAIL_KEYWORD_MAX_LEN]];
                        }
                        else {
                            key = [NSString stringWithString:searchWord];
                        }
                        label.text = [NSString stringWithFormat:@"很抱歉，没有找到与\"%@\"相关的结果",key];
                    }
                    else
                    {
                        [BtnRegistMissingSong setHidden:true];
                        NSString *key = NULL;
                        if ([searchWord length] > NORMAL_KEYWORD_MAX_LEN) {
                            key = [NSString stringWithFormat:@"%@...", [searchWord substringToIndex:NORMAL_KEYWORD_MAX_LEN]];
                        }
                        else {
                            key = [NSString stringWithString:searchWord];
                        }
                        label.text = [NSString stringWithFormat:@"共找到\"%@\"相关结果%d条",key,m_pRequest->GetHitNum()];
                    }
                    
                    if(m_vecSong.size() < m_pRequest->GetHitNum())
                        hasMore = true;
                    
                }
            }
            KS_BLOCK_SYNRUN()
        }
        else
        {
            KS_BLOCK_DECLARE
            {
                m_bNetFail = true;
                m_bReLoading = false;
                if(CHttpRequest::GetNetWorkStatus() == NETSTATUS_NONE)
                {
                    UIImageView * netfailview = (UIImageView*)[self.view viewWithTag:TagNetFailView];
                    netfailview.hidden = false;
                    [self.view bringSubviewToFront:netfailview];
                }
                else
                {
                    UIImageView * loadfailview = (UIImageView*)[self.view viewWithTag:TagLoadFailView];
                    loadfailview.hidden = false;
                    [self.view bringSubviewToFront:loadfailview];
                }

                UIActivityIndicatorView * loading = (UIActivityIndicatorView *)[self.view viewWithTag:TagLoading];
                [loading stopAnimating];
                loading.hidden = true;
            }
            KS_BLOCK_SYNRUN()
        }
    }
    KS_BLOCK_RUN_THREAD();
}

-(void)SearchNextPage
{
    loadingMore = true;
    SearchParam param = m_pRequest->GetCurSearchParam();
    KS_BLOCK_DECLARE
    {
        if(m_pRequest->RequestNextPage())
        {
            KS_BLOCK_DECLARE
            {
                if(param.strword == [searchWord UTF8String] )
                {
                    SONG_LIST vecsong = m_pRequest->GetSongList(param.pn+1);
                    for (size_t i = 0; i < vecsong.size(); i++) {
                        m_vecSong.push_back(vecsong[i]);
                    }
                    if(m_vecSong.size() < m_pRequest->GetHitNum())
                        hasMore = true;
                    UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
                    [tableview reloadData];
                    loadingMore = false;
                }
            }
            KS_BLOCK_SYNRUN()
        }
    }
    KS_BLOCK_RUN_THREAD();
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)CancelSearch
{
    SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
    tipview.hidden = true;
    SearchBarView * searchbar = (SearchBarView*)[self.view viewWithTag:TagSearchBar];
    searchbar.text = @"";
    [searchbar resignFirstResponder];
    searchbar.editing = false;
}

-(void)Search
{
    SearchBarView * searchbar = (SearchBarView*)[self.view viewWithTag:TagSearchBar];
    if(searchbar.text == nil || [searchbar.text isEqualToString:@""])
        return;
    [searchbar resignFirstResponder];
     searchbar.editing = false;
    SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
    tipview.hidden = true;
    searchWord = searchbar.text;
    
    [self StartSearch:searchWord];
}

-(void)onKSongClick :(id)sender
{
    UITableView * musicList = (UITableView*)[self.view viewWithTag:TagTableView];
    UITableViewCell* cell = nil;
    if (NSOrderedAscending != [[[UIDevice currentDevice] systemVersion] compare:@"7.0"]) {
        cell = (UITableViewCell*)[[[(UIButton*)sender superview]superview] superview];
    }else {
        cell = (UITableViewCell*)[[(UIButton*)sender superview]superview];
    }
    NSIndexPath *indexPath = [musicList indexPathForCell:cell];
    if(indexPath == nil)
        return;
    int row = indexPath.row;
    if(row < m_vecSong.size())
    {
        [musiclibDelegate KSong:&m_vecSong[row]];
        UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
        UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        [self RefreshOneCell:oneCell Rid:m_vecSong[row].strRid];
    }
}

-(int)GetSongRow :(std::string)strRid
{
    for (size_t i = 0; i < m_vecSong.size(); i++) {
        if(m_vecSong[i].strRid == strRid)
            return i;
    }
    return -1;
}

-(void)RefreshOneCell:(UITableViewCell *)cell Rid:(std::string)strrid
{
    if(cell == nil)
        return;
    UIButton*btn = (UIButton*)[cell.contentView viewWithTag:KBUTTON_TAG];
    KSProgressView *progressview = (KSProgressView*)[cell.contentView viewWithTag:KPROGRESS_TAG];
    CSongInfoBase * songinfo = CLocalMusicRequest::GetInstance()->GetLocalMusic(strrid);
    if(songinfo)
    {
        if(((CLocalTask*)songinfo)->taskStatus == TaskStatus_Finish)
        {
            [btn setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnNormal.png") forState:UIControlStateNormal];
            [btn setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnDown.png") forState:UIControlStateHighlighted];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitle:@"演唱" forState:UIControlStateNormal];
            progressview.hidden = true;
        }
        else
        {
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [btn setTitleColor:UIColorFromRGBValue(0xf2ca0e) forState:UIControlStateNormal];
            
            if(((CLocalTask*)songinfo)->taskStatus == TaskStatus_Pause)
            {
                progressview.hidden = false;
                float percent = CLocalMusicRequest::GetInstance()->GetTaskRadio(songinfo);
                int radio = percent*100;
                progressview.progress = percent;
                [btn setTitle:[NSString stringWithFormat:@"暂停%d%%",radio] forState:UIControlStateNormal];
            }
            else if(((CLocalTask*)songinfo)->taskStatus == TaskStatus_Downing){
                progressview.hidden = false;
                float percent = CLocalMusicRequest::GetInstance()->GetTaskRadio(songinfo);
                int radio = percent*100;
                progressview.progress = percent;
                [btn setTitle:[NSString stringWithFormat:@"%d%%",radio] forState:UIControlStateNormal];
            }
            else if(((CLocalTask*)songinfo)->taskStatus == TaskStatus_Fail){
                progressview.hidden = true;
                [btn setTitleColor:UIColorFromRGB(51,120,185) forState:UIControlStateNormal];
                [btn setBackgroundImage:CImageMgr::GetImageEx("KsongBtn.png") forState:UIControlStateNormal];
                [btn setBackgroundImage:CImageMgr::GetImageEx("KsongBtnDown.png") forState:UIControlStateHighlighted];
                [btn setTitle:@"点歌" forState:UIControlStateNormal];
            }
        }
    }
    else
    {
        progressview.hidden = true;
        [btn setTitleColor:UIColorFromRGB(51,120,185) forState:UIControlStateNormal];
        [btn setBackgroundImage:CImageMgr::GetImageEx("KsongBtn.png") forState:UIControlStateNormal];
        [btn setBackgroundImage:CImageMgr::GetImageEx("KsongBtnDown.png") forState:UIControlStateHighlighted];
        [btn setTitle:@"点歌" forState:UIControlStateNormal];
    }    
}


#pragma mark - IMusicLibObserver
-(void)IObMusicLib_StartTask:(NSString*)strRid
{
    int nrow = [self GetSongRow:[strRid UTF8String]];
    if(nrow != -1)
    {
        UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
        UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nrow inSection:0]];
        [self RefreshOneCell:oneCell Rid:[strRid UTF8String]];
    }
}



-(void)IObMusicLib_DownTaskFinish:(NSString*)strRid
{
    int nrow = [self GetSongRow:[strRid UTF8String]];
    if(nrow != -1)
    {
        UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
        UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nrow inSection:0]];
        [self RefreshOneCell:oneCell Rid:[strRid UTF8String]];
    }
}

-(void)IObMusicLib_DeleteTask:(NSString*)strRid
{
    int nrow = [self GetSongRow:[strRid UTF8String]];
    if(nrow != -1)
    {
        UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
        UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nrow inSection:0]];
        [self RefreshOneCell:oneCell Rid:[strRid UTF8String]];
    }
}

-(void)IObMusicLib_TaskProgress:(NSString*)strRid:(float)fPercent
{
    int nrow = [self GetSongRow:[strRid UTF8String]];
    if(nrow != -1)
    {
        UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
        UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nrow inSection:0]];
        [self RefreshOneCell:oneCell Rid:[strRid UTF8String]];
    }
}

-(void)IObMusicLib_PauseTask:(NSString*)strRid
{
    int nrow = [self GetSongRow:[strRid UTF8String]];
    if(nrow != -1)
    {
        UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
        UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nrow inSection:0]];
        [self RefreshOneCell:oneCell Rid:[strRid UTF8String]];
    }
}

-(void)IObMusicLib_TaskFail:(NSString*)strRid
{
    int nrow = [self GetSongRow:[strRid UTF8String]];
    if(nrow != -1)
    {
        UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
        UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nrow inSection:0]];
        [self RefreshOneCell:oneCell Rid:[strRid UTF8String]];
    }
}


#pragma mark - SearchDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [BtnRegistMissingSong setHidden:true];
    SearchBarView * searchbar = (SearchBarView*)[self.view viewWithTag:TagSearchBar];
    searchbar.editing = true;
    SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
    tipview.hidden = false;
    [tipview setInputWord:searchbar.text];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
    [tipview setInputWord:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self Search];
}

#pragma mark - searchTipDelegate
- (id)GetSearchHistory
{
    return [(KSMusicLibDelegate*)musiclibDelegate GetSearchHistory];
}

-(void)SelectTip:(NSString*)word
{
    SearchBarView * searchbar = (SearchBarView*)[self.view viewWithTag:TagSearchBar];
    searchbar.text = word;
    [self Search];
}

-(void)ScrollTip
{
    SearchBarView * searchbar = (SearchBarView*)[self.view viewWithTag:TagSearchBar];
    [searchbar resignFirstResponder];
    
}

-(void)ClearSearchHistroy
{
    [(KSMusicLibDelegate*)musiclibDelegate ClearSearchHistroy];
}

-(void)DeleteSearchHistroy:(id)key
{
    [(KSMusicLibDelegate*)musiclibDelegate DeleteSearchHistroy:key];
}


#pragma mark -TableView DataSource and Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //m_vecSong[indexPath.row].strKid;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSLog(@"select song:%s",m_vecSong[indexPath.row].strRid.c_str());
    FindSameSongViewController * sameViewController=[[[FindSameSongViewController alloc] init] autorelease];
    [sameViewController setRankRid:[NSString stringWithFormat:@"%s",m_vecSong[indexPath.row].strRid.c_str()]];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:sameViewController animated:true];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(m_vecSong.size() == 0)
        return 0;
    if(m_pRequest && m_pRequest->GetHitNum() > m_vecSong.size())
        return m_vecSong.size()+1;
    else
        return m_vecSong.size();
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

const int TagListLabelName = 1000;
const int TagListArrow = 1001;

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *s_commontableIdentifier = @"commonIdentifier";
    static NSString *s_loadingtableIdentifier = @"loadingIdentifier";
    NSInteger row = [indexPath row];

    UITableViewCell* cell = nil;
    if(row < m_vecSong.size())
    {
        cell= [tableView dequeueReusableCellWithIdentifier:s_commontableIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:s_commontableIdentifier] autorelease];
            
            UIImageView * bkimage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 55)]autorelease];
            bkimage.image = CImageMgr::GetImageEx("listbk_5_1.png");
            cell.backgroundView = bkimage;
            
            UILabel *textLabel = [[[UILabel alloc]initWithFrame:CGRectMake(12, 8, 230, 17)]autorelease];
            textLabel.font= [UIFont systemFontOfSize:17];
            //textLabel.textColor = [UIColor whiteColor];
            [textLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
            [textLabel setShadowOffset:CGSizeMake(0, 1)];
            textLabel.lineBreakMode = UILineBreakModeTailTruncation;
            textLabel.backgroundColor = [UIColor clearColor];
            [textLabel setTag:KLABEL_NAME_TAG];
            [cell.contentView addSubview:textLabel];
            
            UILabel *detailTextLabel = [[[UILabel alloc]initWithFrame:CGRectMake(12, 34, 230, 13)]autorelease];
            detailTextLabel.textColor = UIColorFromRGBValue(0x969696);
            [detailTextLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
            [detailTextLabel setShadowOffset:CGSizeMake(0, 1)];
            detailTextLabel.font = [UIFont systemFontOfSize:13];
            detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
            detailTextLabel.backgroundColor = [UIColor clearColor];
            [detailTextLabel setTag:KLABEL_ARTIST_TAG];
            [cell.contentView addSubview:detailTextLabel];
            
            KSProgressView * progress = [[[KSProgressView alloc]initWithFrame:CGRectMake(244, 14.5, 64, 29)]autorelease];
            progress.bkImage = CImageMgr::GetImageEx("KsongDownloadBtn.png");
            progress.trackImage = CImageMgr::GetImageEx("KsongProgress.png");
            progress.hidden = true;
            progress.tag = KPROGRESS_TAG;
            [cell.contentView addSubview:progress];
            
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setTag:KBUTTON_TAG];
            [button setFrame:CGRectMake(244, 14.5, 64, 29)];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button titleLabel].font = [UIFont systemFontOfSize:13];
            [button addTarget:self action:@selector(onKSongClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
            
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }        
        
        CSongInfoBase * netsonginfo = &m_vecSong[row];
        UILabel *textLabel = (UILabel*)[cell viewWithTag:KLABEL_NAME_TAG];
        [textLabel setText:[NSString stringWithUTF8String:netsonginfo->strSongName.c_str()]];
        UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:KLABEL_ARTIST_TAG];
        [detailTextLabel setText:[NSString stringWithUTF8String:netsonginfo->strArtist.c_str()]];
        
        [self RefreshOneCell:cell Rid: netsonginfo->strRid];
        
    }
    else
    {
        cell= [tableView dequeueReusableCellWithIdentifier:s_loadingtableIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:s_loadingtableIdentifier] autorelease];
            
            UIImageView * bkimage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 55)]autorelease];
            bkimage.image = CImageMgr::GetImageEx("listbk_5_1.png");
            cell.backgroundView = bkimage;
            
            UIImage * image = CImageMgr::GetImageEx("blackArrow.png");
            UIImageView* imageview = [[[UIImageView alloc]initWithImage:image]autorelease];
            imageview.frame = CGRectMake(10, 10, image.size.width, image.size.height);
            imageview.tag = TagListArrow;
            [cell.contentView addSubview:imageview];
            imageview.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            
            UILabel *textLabel = [[[UILabel alloc]initWithFrame:CGRectMake(35, 17, 95, 17)]autorelease];
            textLabel.font= [UIFont systemFontOfSize:13];
            textLabel.textColor = UIColorFromRGBValue(0x969696);
            textLabel.backgroundColor = [UIColor clearColor];
            [textLabel setTag:TagListLabelName];
            [cell.contentView addSubview:textLabel];
            
            UIActivityIndicatorView *activiter = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
            activiter.center = CGPointMake(130, 22);
            activiter.tag = TagCellLoading;
            activiter.hidden = true;
            [cell addSubview:activiter];
            
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        UILabel *textLabel = (UILabel*)[cell viewWithTag:TagListLabelName];
        [textLabel setText:@"上拉加载更多"];
    }
    
    
    return cell;
}


#pragma mark - scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!hasMore)
        return;
    UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
    if(tableview != scrollView)
        return;
    if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height + 30) && scrollView.isTracking) {

        UITableViewCell *moreCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_vecSong.size() inSection:0]];
         
        if (!loadingMore && moreCell) {
            UIImageView * imageview = (UIImageView*) [moreCell viewWithTag:TagListArrow];
            
            [UIView animateWithDuration:0.2 animations:^{
                imageview.transform = CGAffineTransformMakeRotation(0);
            } ];
            
            UILabel *textLabel = (UILabel*)[moreCell viewWithTag:TagListLabelName];
            [textLabel setText:@"松开即可更新"];
        }
	}
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!hasMore)
        return;
    UITableView * tableview = (UITableView*)[self.view viewWithTag:TagTableView];
    if(tableview != scrollView)
        return;
    if (loadingMore || !hasMore) {
		return;
	}

    if (scrollView.contentOffset.y > (scrollView.contentSize.height - tableview.frame.size.height + 5)) {
        
        UITableViewCell *moreCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_vecSong.size() inSection:0]];
        
        if (!loadingMore && moreCell) {
            UIActivityIndicatorView	*activiter = (UIActivityIndicatorView*)[moreCell viewWithTag:TagCellLoading];
            if (nil != activiter) {
                [activiter startAnimating];
                activiter.hidden = false;
            }
            
            UIImageView * imageview = (UIImageView*) [moreCell viewWithTag:TagListArrow];
            [UIView animateWithDuration:0.2 animations:^{
                imageview.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            } ];
            
            UILabel *textLabel = (UILabel*)[moreCell viewWithTag:TagListLabelName];
            [textLabel setText:@"正在加载数据"];
        }
        
    [self SearchNextPage];
	}
    
}

@end
