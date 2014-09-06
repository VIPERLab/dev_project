//
//  RankViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-3.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "RankViewController.h"
#include "SearchBarView.h"
#include "SearchTipView.h"
#include "SearchViewController.h"
#include "KSAppDelegate.h"
#include "RanksListRequest.h"
#include "MessageManager.h"
#include "HttpRequest.h"
#include "CacheMgr.h"
#include "KwTools.h"
#include "globalm.h"
#include <QuartzCore/QuartzCore.h>
#include "IMusicLibObserver.h"
#include "ArtistRankViewController.h"
#include "ImageMgr.h"
#include "MusicListViewController.h"
#include "LocalMusicViewController.h"
#include "MySongsViewController.h"

const int TagSearchTip = 105;
const int TagSearchBar = 100;
const int TagRankList = 101;
const int TagFirstListLabel = 102;
const int TagSecondListLabel = 112;
const int TagThirdListLabel = 113;
const int TagListImage = 103;
const int TagShadowView = 104;

const int TAG_FIRST_RANK_BTN = 116;
const int TAG_SECOND_RANK_BTN = 106;
const int TAG_THIRD_RANK_BTN = 107;

const int TAG_FREE_SING_BTN = 108;
const int TAG_LOCAL_MUSIC_BTN = 109;
const int TAG_ARTIST_LIST_BTN = 110;
const int TAG_MY_OPUS_BTN = 111;

const int TAG_BTN_FREE_SING = 120;
const int TAG_BTN_LOCAL_MUSIC = 121;
const int TAG_BTN_ARTIST_LIST = 122;
const int TAG_BTN_MY_OPUS     = 123;

const int RANK_NUM_PER_CELL = 3;


@interface RankViewController ()<SearchTipDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    CRanksListRequest * m_pRequest;
    std::vector<ListInfo> m_vecRankList;
    bool bsearching;
    bool m_bNetFail;
    bool m_bReLoading;
}
@end

@implementation RankViewController
@synthesize musiclibDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
    bsearching = false;
    

//    self.view.backgroundColor = UIColorFromRGBValue(0xededed);
    self.view.backgroundColor = [UIColor blackColor];
    
    UITableView * rankList = [[[UITableView alloc]init]autorelease];
    rankList.tag = TagRankList;
    rankList.frame = CGRectMake(0, 43, 320, self.view.frame.size.height-43);
    rankList.delegate = self;
    rankList.dataSource = self;
    rankList.separatorStyle = UITableViewCellSeparatorStyleNone;
    rankList.backgroundColor = UIColorFromRGBValue(0xededed);
    
    [[self view] addSubview:rankList];
    
    SearchBarView * searchBar = [[[SearchBarView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)]autorelease];
    searchBar.tag = TagSearchBar;
    searchBar.delegate = self;
    [searchBar addSearchButtonWithTarget:self action:@selector(Search)];
    [searchBar addSearchCancelButtonWithTarget:self action:@selector(CancelSearch)];
    [[self view] addSubview:searchBar];
    
    UIActivityIndicatorView * loading = [[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 86, 86)]autorelease];
    loading.tag = TagLoading;
    loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loading.backgroundColor = UIColorFromRGBAValue(0x000000,0xb5);
    //loading.layer.masksToBounds = true;
    loading.layer.cornerRadius = 10;
    loading.center = CGPointMake(160, 250);
    loading.hidden = true;
    UILabel *label=[[[UILabel alloc] initWithFrame:CGRectMake(0, 56, 86, 30)] autorelease];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setText:@"正在加载中"];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:13]];
    
    [loading addSubview:label];
    
    SearchTipView * tipview = [[[SearchTipView alloc]initWithFrame:CGRectMake(0, 43, 320, self.view.frame.size.height)]autorelease];
    //tipview.hidden = true;
    tipview.alpha = 0;
    tipview.backgroundColor = [UIColor grayColor];
    tipview.tag = TagSearchTip;
    tipview.searchdelegate = self;
    [self.view addSubview:tipview];
    
    m_pRequest = new CRanksListRequest(eMusicRank);
    m_vecRankList = m_pRequest->QuickGetList();
    if(m_vecRankList.size() == 0)
    {
        loading.hidden = false;
        [loading startAnimating];
    }
    
    UIImageView * netfailview = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)]autorelease];
    netfailview.tag = TagNetFailView;
    netfailview.userInteractionEnabled = true;
    netfailview.hidden = true;
    netfailview.backgroundColor = UIColorFromRGBValue(0xededed);
    netfailview.image = CImageMgr::GetImageEx("failmsgNoNet.png");
    [self.view addSubview:netfailview];
    
    UIImageView * loadfailview = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)]autorelease];
    loadfailview.tag = TagLoadFailView;
    loadfailview.userInteractionEnabled = true;
    loadfailview.hidden = true;
    loadfailview.backgroundColor = UIColorFromRGBValue(0xededed);
    loadfailview.image = CImageMgr::GetImageEx("failmsgLoadFail.png");
    [self.view addSubview:loadfailview];
//       [self LoadRankPic];
    [self UpdateList];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)dealloc
{
    [super dealloc];
    delete m_pRequest;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)onKSongClick :(id)sender
{
     SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::RecordMusic,"");
}

-(void)OnArtistList :(id)sender
{
    ArtistRankViewController * artistview = [[[ArtistRankViewController alloc]init] autorelease];
    artistview.musiclibDelegate = musiclibDelegate;
    [ROOT_NAVAGATION_CONTROLLER pushViewController: artistview animated:YES];
}

-(void)onBtnClick : (id)sender{
    UIButton* cur_btn = (UIButton*)sender;
    if (cur_btn) {
        switch (cur_btn.tag) {
            case TAG_MY_OPUS_BTN:
            {
                KSMySongsViewController * viewController = [[[KSMySongsViewController alloc]init]autorelease];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:viewController animated:YES];
                break;
            }
            case TAG_LOCAL_MUSIC_BTN:
            {
                LocalMusicViewController * viewController = [[[LocalMusicViewController alloc]init]autorelease];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:viewController animated:YES];
                break;
            }
            default:
                break;
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(m_bNetFail && !m_bReLoading)
    {
        m_bReLoading = true;
        [self UpdateList];
    }
}

-(void)UpdateList
{
    KS_BLOCK_DECLARE
    {
        if(m_pRequest->UpdateList())
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
                UIActivityIndicatorView * loading = (UIActivityIndicatorView *)[self.view viewWithTag:TagLoading];
                [loading stopAnimating];
                loading.hidden = true;
                m_vecRankList = m_pRequest->GetRankList();
                UITableView * listview = (UITableView*)[self.view viewWithTag:TagRankList];
                [listview reloadData];
                //[self LoadRankPic];
            }
            KS_BLOCK_SYNRUN()
        }
        else
        {
            KS_BLOCK_DECLARE
            {
                UIActivityIndicatorView * loading = (UIActivityIndicatorView *)[self.view viewWithTag:TagLoading];
                [loading stopAnimating];
                loading.hidden = true;
                m_bReLoading = false;
                if(m_vecRankList.size() == 0)
                {
                    m_bNetFail = true;
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
                }
            }
            KS_BLOCK_SYNRUN()
        }

    }
    KS_BLOCK_RUN_THREAD();
}


-(void)LoadRankPic : (int)row Column : (int)column View : (UIButton *) picView
{
    std::string strPicUrl = m_vecRankList[(row - 1) * RANK_NUM_PER_CELL + column].strPicUrl;
    std::string strRankPic;
    BOOL bouttime;
    if(CCacheMgr::GetInstance()->GetCacheFile(strPicUrl,strRankPic,bouttime) && !bouttime)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:strRankPic.c_str()]];
        [picView setBackgroundImage:image forState:UIControlStateNormal];
    }
    else
    {
        std::string strname = strPicUrl.substr(strPicUrl.rfind("/")+1,-1);
        NSString *strSavePath = KwTools::Dir::GetPath(KwTools::Dir::PATH_CASHE);
        strSavePath = [strSavePath stringByAppendingPathComponent: [NSString stringWithUTF8String:strname.c_str()]];
        
        KS_BLOCK_DECLARE
        {
            NSError *error = nil;
            NSURLResponse * response;
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:strPicUrl.c_str()]]];
            NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error:&error];
            if([data length] > 0 && error==nil){
                KS_BLOCK_DECLARE
                {
                    if([data writeToFile:strSavePath atomically:true])
                    {
                        CCacheMgr::GetInstance()->Cache(T_MONTH, 1, strPicUrl, [strSavePath UTF8String]);
                        KwTools::Dir::DeleteFile(strSavePath);
                    }
//                    UITableView * tableview = (UITableView*)[self.view viewWithTag:TagRankList];
//                    UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
//                    UIButton* cur_button = (UIButton*)[oneCell.contentView viewWithTag:column];
//                    if (nil != cur_button) {
//                        [cur_button setBackgroundImage:[UIImage imageWithData:data] forState:(UIControlStateNormal)];
//                    }
                    if (nil != picView) {
                        [picView setBackgroundImage:[UIImage imageWithData:data] forState:(UIControlStateNormal)];
                    }
                }
                KS_BLOCK_SYNRUN();
            }
            else
            {
                //NSLog(@"downpic fail");
            }
        }
        KS_BLOCK_RUN_THREAD();

        
//            KS_BLOCK_DECLARE
//            {
//                CHttpRequest req(strPicUrl);
//                if(req.SyncSendRequest([strSavePath UTF8String]))
//                {
//                    KS_BLOCK_DECLARE
//                    {
//                        //CCacheMgr::GetInstance()->Cache(T_MONTH, 1, strPicUrl, [strSavePath UTF8String]);
//                        UITableView * tableview = (UITableView*)[self.view viewWithTag:TagRankList];
//                        UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//                        UIImageView * Rankimage = (UIImageView*)[oneCell viewWithTag:TagListImage];
//                        Rankimage.image = [UIImage imageWithContentsOfFile:strSavePath];
//                       // KwTools::Dir::DeleteFile(strSavePath);
//                    }
//                    KS_BLOCK_SYNRUN()
//                }
//            }
//            KS_BLOCK_RUN_THREAD();
    }
}

-(void)CancelSearch
{
    [self MoveSearchView:NO];
//    SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
//    tipview.hidden = true;
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
    [self MoveSearchView:NO];
    [searchbar resignFirstResponder];
    searchbar.editing = false;
//    SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
//    tipview.hidden = true;    

    SearchViewController * searchview = [[[SearchViewController alloc]init] autorelease];
    searchview.searchWord = searchbar.text;
    searchview.musiclibDelegate = musiclibDelegate;
    [ROOT_NAVAGATION_CONTROLLER pushViewController: searchview animated:YES];
    
    searchbar.text = @"";
}

- (void)MoveSearchView:(BOOL)bsearch
{
	void (^animations)(void) = ^{
             UIView * rootview = self.view.superview.superview;
            SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
            if (bsearch)
            {
                rootview.frame = CGRectOffset(rootview.frame, 0.0f, -44);
                tipview.alpha = 1;
            }
            else
            {
                tipview.alpha = 0;
                if(rootview.frame.origin.y < 0)
                    rootview.frame = CGRectOffset(rootview.frame, 0.0f,44);
            }
            
	};
     if(bsearching != bsearch)
     {
        UIView * rootview = self.view;
        CGRect rc = rootview.frame;
        if(bsearch)
            rc.size.height += 44;
         else
             rc.size.height -= 44;
         self.view.frame = rc;
         
         rootview = self.view.superview.superview;
         rc = rootview.frame;
         if(bsearch)
             rc.size.height += 44;
         else
             rc.size.height -= 44;
         self.view.superview.superview.frame = rc;
         
         rootview = self.view.superview;
         rc = rootview.frame;
         if(bsearch)
             rc.size.height += 44;
         else
             rc.size.height -= 44;
         self.view.superview.frame = rc;
         
		[UIView animateWithDuration:0.2
							  delay:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:animations
						 completion:nil];
         bsearching = bsearch;
     }
}


#pragma mark - SearchDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self MoveSearchView:YES];

    SearchBarView * searchbar = (SearchBarView*)[self.view viewWithTag:TagSearchBar];
    searchbar.editing = true;
    SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
//    tipview.hidden = false;
    [tipview setInputWord:searchbar.text];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    SearchTipView * tipview = (SearchTipView*)[self.view viewWithTag:TagSearchTip];
    [tipview setInputWord:searchText];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location>=50)
    {
        return  NO;
    }
    else
    {
        return YES;
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == m_vecRankList.size() % 3) {
        return 1 + m_vecRankList.size() / 3;
    }
    return  2 + m_vecRankList.size() / 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        return 90;
    }else {
        return 150;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    UITableViewCell* cell = nil;
    if (0 == row) {
        static NSString* s_str_control_cell_identifier = @"strControlCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:s_str_control_cell_identifier];
        if (nil == cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:s_str_control_cell_identifier] autorelease];
            UIButton* btn_free_sing = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_free_sing.frame = CGRectMake(0, 0, 160, 45);
            [btn_free_sing setBackgroundColor:[UIColor clearColor]];
            [btn_free_sing setBackgroundImage:CImageMgr::GetImageEx("KgeFreeSingBtn.png") forState:(UIControlStateNormal)];
            [btn_free_sing setBackgroundImage:CImageMgr::GetImageEx("KgeFreeSingBtnClick.png") forState:(UIControlStateHighlighted)];
            [btn_free_sing setBackgroundImage:CImageMgr::GetImageEx("KgeFreeSingBtnClick.png") forState:(UIControlStateSelected)];
            
            [btn_free_sing setTag:TAG_FREE_SING_BTN];
            [btn_free_sing addTarget:self action:@selector(onKSongClick:) forControlEvents:(UIControlEventTouchUpInside)];
            [cell.contentView addSubview:btn_free_sing];
            
            UIButton* btn_local_music = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_local_music.frame = CGRectMake(160, 0, 160, 45);
            [btn_local_music setBackgroundColor:[UIColor clearColor]];
            [btn_local_music setBackgroundImage:CImageMgr::GetImageEx("LocalMusicBtn.png") forState:(UIControlStateNormal)];
            [btn_local_music setBackgroundImage:CImageMgr::GetImageEx("LocalMusicBtnClick.png") forState:(UIControlStateHighlighted)];
            [btn_local_music setBackgroundImage:CImageMgr::GetImageEx("LocalMusicBtnClick.png") forState:(UIControlStateSelected)];
            
            [btn_local_music setTag:TAG_LOCAL_MUSIC_BTN];
            [btn_local_music addTarget:self action:@selector(onBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
            [cell.contentView addSubview:btn_local_music];
            
            UIButton* btn_artist_list = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_artist_list.frame = CGRectMake(0, 45, 160, 45);
            [btn_artist_list setBackgroundColor:[UIColor clearColor]];
            [btn_artist_list setBackgroundImage:CImageMgr::GetImageEx("KSongArtistListBtn.png") forState:(UIControlStateNormal)];
            [btn_artist_list setBackgroundImage:CImageMgr::GetImageEx("KSongArtistListBtnClick.png") forState:(UIControlStateHighlighted)];
            [btn_artist_list setBackgroundImage:CImageMgr::GetImageEx("KSongArtistListBtnClick.png") forState:(UIControlStateSelected)];
            
            [btn_artist_list setTag:TAG_ARTIST_LIST_BTN];
            [btn_artist_list addTarget:self action:@selector(OnArtistList:) forControlEvents:(UIControlEventTouchUpInside)];
            [cell.contentView addSubview:btn_artist_list];
            
            UIButton* btn_my_opus = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_my_opus.frame = CGRectMake(160, 45, 160, 45);
            [btn_my_opus setBackgroundColor:[UIColor clearColor]];
            [btn_my_opus setBackgroundImage:CImageMgr::GetImageEx("MyOpusBtn.png") forState:(UIControlStateNormal)];
            [btn_my_opus setBackgroundImage:CImageMgr::GetImageEx("MyOpusBtnClick.png") forState:(UIControlStateHighlighted)];
            [btn_my_opus setBackgroundImage:CImageMgr::GetImageEx("MyOpusBtnClick.png") forState:(UIControlStateSelected)];
            [btn_my_opus addTarget:self action:@selector(onBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
            
            [btn_my_opus setTag:TAG_MY_OPUS_BTN];
            [cell.contentView addSubview:btn_my_opus];
        }
    }else {
        if ((row - 1) * 3 > m_vecRankList.size()) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (1 == m_vecRankList.size() % 3) {
                UIButton* first_rank_btn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 2, 104, 104)] autorelease];
                [first_rank_btn setTag:TAG_FIRST_RANK_BTN];
                [first_rank_btn addTarget:self action:@selector(onRankBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
                [cell.contentView addSubview:first_rank_btn];
                UILabel* first_rank_label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 106, 104, 43)] autorelease];
                first_rank_label.font= [UIFont systemFontOfSize:17];
                first_rank_label.lineBreakMode = UILineBreakModeTailTruncation;
                first_rank_label.backgroundColor = [UIColor clearColor];
                [first_rank_label setTag:TagFirstListLabel];
                [cell.contentView addSubview:first_rank_label];
            }else {
                UIButton* first_rank_btn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 2, 104, 104)] autorelease];
                [first_rank_btn setTag:TAG_FIRST_RANK_BTN];
                [first_rank_btn addTarget:self action:@selector(onRankBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
                [cell.contentView addSubview:first_rank_btn];
                UILabel* first_rank_label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 106, 104, 43)] autorelease];
                first_rank_label.font= [UIFont systemFontOfSize:17];
                first_rank_label.lineBreakMode = UILineBreakModeTailTruncation;
                first_rank_label.backgroundColor = [UIColor clearColor];
                [first_rank_label setTag:TagFirstListLabel];
                [cell.contentView addSubview:first_rank_label];
                
                UIButton* second_rank_btn = [[[UIButton alloc] initWithFrame:CGRectMake(108, 2, 104, 104)] autorelease];
                [second_rank_btn setTag:TAG_SECOND_RANK_BTN];
                [second_rank_btn addTarget:self action:@selector(onRankBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
                [cell.contentView addSubview:second_rank_btn];
                UILabel* second_rank_label = [[[UILabel alloc] initWithFrame:CGRectMake(108, 106, 104, 43)] autorelease];
                second_rank_label.font= [UIFont systemFontOfSize:17];
                second_rank_label.lineBreakMode = UILineBreakModeTailTruncation;
                second_rank_label.backgroundColor = [UIColor clearColor];
                [second_rank_label setTag:TagSecondListLabel];
                [cell.contentView addSubview:second_rank_label];
            }
        }else {
            static NSString *s_commontableIdentifier = @"commonIdentifier";
            
            cell = [tableView dequeueReusableCellWithIdentifier:s_commontableIdentifier];
            if(cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s_commontableIdentifier] autorelease];
                
                UIButton* first_rank_btn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 2, 104, 104)] autorelease];
                [first_rank_btn setTag:TAG_FIRST_RANK_BTN];
                [first_rank_btn addTarget:self action:@selector(onRankBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
                [cell.contentView addSubview:first_rank_btn];
                UILabel* first_rank_label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 106, 104, 43)] autorelease];
                first_rank_label.font= [UIFont systemFontOfSize:17];
                first_rank_label.lineBreakMode = UILineBreakModeTailTruncation;
                first_rank_label.backgroundColor = [UIColor clearColor];
                [first_rank_label setTag:TagFirstListLabel];
                [first_rank_label setTextAlignment:NSTextAlignmentCenter];
                [cell.contentView addSubview:first_rank_label];
                
                UIButton* second_rank_btn = [[[UIButton alloc] initWithFrame:CGRectMake(108, 2, 104, 104)] autorelease];
                [second_rank_btn setTag:TAG_SECOND_RANK_BTN];
                [second_rank_btn addTarget:self action:@selector(onRankBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
                [cell.contentView addSubview:second_rank_btn];
                UILabel* second_rank_label = [[[UILabel alloc] initWithFrame:CGRectMake(108, 106, 104, 43)] autorelease];
                second_rank_label.font= [UIFont systemFontOfSize:17];
                second_rank_label.lineBreakMode = UILineBreakModeTailTruncation;
                second_rank_label.backgroundColor = [UIColor clearColor];
                [second_rank_label setTag:TagSecondListLabel];
                [second_rank_label setTextAlignment:NSTextAlignmentCenter];
                [cell.contentView addSubview:second_rank_label];
                
                UIButton* third_rank_btn = [[[UIButton alloc] initWithFrame:CGRectMake(216, 2, 104, 104)] autorelease];
                [third_rank_btn setTag:TAG_THIRD_RANK_BTN];
                [third_rank_btn addTarget:self action:@selector(onRankBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
                [cell.contentView addSubview:third_rank_btn];
                UILabel* third_rank_label = [[[UILabel alloc] initWithFrame:CGRectMake(216, 106, 104, 43)] autorelease];
                third_rank_label.font= [UIFont systemFontOfSize:17];
                third_rank_label.lineBreakMode = UILineBreakModeTailTruncation;
                third_rank_label.backgroundColor = [UIColor clearColor];
                [third_rank_label setTag:TagThirdListLabel];
                [third_rank_label setTextAlignment:NSTextAlignmentCenter];
                [cell.contentView addSubview:third_rank_label];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
            }
        }
        UIButton* first_btn = (UIButton*)[cell.contentView viewWithTag:TAG_FIRST_RANK_BTN];
        if (first_btn) {
            [first_btn setBackgroundImage:CImageMgr::GetImageEx("defaultface.png") forState:(UIControlStateNormal)];
            [self LoadRankPic:row Column:0 View:first_btn];
            UILabel * textLabel = (UILabel*)[cell viewWithTag:TagFirstListLabel];
            textLabel.text = [NSString stringWithUTF8String:m_vecRankList[(row - 1) * 3].strName.c_str()];
        }
        
        UIButton* second_btn = (UIButton*)[cell.contentView viewWithTag:TAG_SECOND_RANK_BTN];
        if (second_btn) {
            [second_btn setBackgroundImage:CImageMgr::GetImageEx("defaultface.png") forState:(UIControlStateNormal)];
            [self LoadRankPic:row Column:1 View:second_btn];
            UILabel * textLabel = (UILabel*)[cell viewWithTag:TagSecondListLabel];
            textLabel.text = [NSString stringWithUTF8String:m_vecRankList[(row - 1) * 3 + 1].strName.c_str()];
        }
        
        UIButton* third_btn = (UIButton*)[cell.contentView viewWithTag:TAG_THIRD_RANK_BTN];
        if (third_btn) {
            [third_btn setBackgroundImage:CImageMgr::GetImageEx("defaultface.png") forState:(UIControlStateNormal)];
            [self LoadRankPic:row Column:2 View:third_btn];
            UILabel * textLabel = (UILabel*)[cell viewWithTag:TagThirdListLabel];
            textLabel.text = [NSString stringWithUTF8String:m_vecRankList[(row - 1) * 3 + 2].strName.c_str()];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onRankBtnClicked : (id)sender{
    UIButton* cur_btn = (UIButton*)sender;
    UITableViewCell* cur_cell = nil;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        cur_cell = (UITableViewCell*)[[[(UIButton*)sender superview]superview] superview];
    }else {
        cur_cell = (UITableViewCell*)[[(UIButton*)sender superview]superview];
    }
    
    UITableView* rank_list = (UITableView*)[self.view viewWithTag:TagRankList];
    if (rank_list && cur_cell) {
        NSIndexPath* cur_index_path = [rank_list indexPathForCell:cur_cell];
        int row = cur_index_path.row;
        
        switch (cur_btn.tag) {
            case TAG_FIRST_RANK_BTN:
            {
                MusicListViewController * listview = [[[MusicListViewController alloc]initwithListInfo :m_vecRankList[(row - 1) * 3]] autorelease];
                listview.title = [NSString stringWithUTF8String:m_vecRankList[(row - 1) * 3].strName.c_str()];
                listview.musiclibDelegate = musiclibDelegate;
                [ROOT_NAVAGATION_CONTROLLER pushViewController: listview animated:YES];
                
                break;
            }
                
            case TAG_SECOND_RANK_BTN:
            {
                MusicListViewController * listview = [[[MusicListViewController alloc]initwithListInfo :m_vecRankList[(row - 1) * 3 + 1]] autorelease];
                listview.title = [NSString stringWithUTF8String:m_vecRankList[(row - 1) * 3 + 1].strName.c_str()];
                listview.musiclibDelegate = musiclibDelegate;
                [ROOT_NAVAGATION_CONTROLLER pushViewController: listview animated:YES];

                break;
            }
            case TAG_THIRD_RANK_BTN:
            {
                MusicListViewController * listview = [[[MusicListViewController alloc]initwithListInfo :m_vecRankList[(row - 1) * 3 + 2]] autorelease];
                listview.title = [NSString stringWithUTF8String:m_vecRankList[(row - 1) * 3 + 2].strName.c_str()];
                listview.musiclibDelegate = musiclibDelegate;
                [ROOT_NAVAGATION_CONTROLLER pushViewController: listview animated:YES];

                break;
            }
            default:
                break;
        }
        
        
    }
    
}


@end
