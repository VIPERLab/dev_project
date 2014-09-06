//
//  ArtistCatViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-3.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "ArtistCatViewController.h"
#include "MessageManager.h"
#include "IMusicLibObserver.h"
#include "KSAppDelegate.h"
#include "ArtistListRequest.h"
#include "globalm.h"
#include <QuartzCore/QuartzCore.h>
#include "CacheMgr.h"
#include "KwTools.h"
#include "ImageMgr.h"
#include "MusicListViewController.h"
#include "HttpRequest.h"

const int TagArtistList = 100;
const int TagListImage = 101;
const int TagListLabel = 102;
const int TagListNumLabel = 104;

@interface ArtistCatViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CArtistListRequest *m_pRequest;
    ListInfo m_listInfo;
    NSMutableArray * arrKey;
//    std::map<std::pair<int, int>, UIImage*> m_mapImageCache;
}
@end

@implementation ArtistCatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initwithListInfo : (ListInfo) info
{
    self = [super init];
    if (self) {
        // Custom initialization
        m_listInfo = info;
        self.title = [NSString stringWithUTF8String:m_listInfo.strName.c_str()];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    UITableView * artistList = [[[UITableView alloc]initWithFrame: CGRectMake(0, 44, 320, self.view.frame.size.height-44)
                                                            style:UITableViewStylePlain]autorelease];
    artistList.tag = TagArtistList;
    artistList.delegate = self;
    artistList.dataSource = self;
    [[self view] addSubview:artistList];
    artistList.separatorStyle = UITableViewCellSeparatorStyleNone;
    artistList.backgroundColor = UIColorFromRGBValue(0xededed);
    
    m_pRequest = new CArtistListRequest(m_listInfo);
    arrKey = [[NSMutableArray alloc]init];
    
    UIView * shadowview = (UIView*)[self.view viewWithTag:TagShadow];
    [self.view bringSubviewToFront:shadowview];
    
    UIActivityIndicatorView * loading = (UIActivityIndicatorView *)[self.view viewWithTag:TagLoading];
    if (nil != loading) {
        loading.hidden = false;
        [loading startAnimating];
        [self.view bringSubviewToFront:loading];
    }
    
    [self LoadData];
    
}

-(void)dealloc
{
    [super dealloc];
    delete m_pRequest;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(m_bNetFail && !m_bReLoading)
    {
        m_bReLoading = true;
        [self LoadData];
    }
}

-(void)LoadData
{
    UIActivityIndicatorView * loading = (UIActivityIndicatorView *)[self.view viewWithTag:TagLoading];
    if (nil != loading) {
        loading.hidden = false;
        [loading startAnimating];
    }
    
    KS_BLOCK_DECLARE
    {
        if(m_pRequest->StartRequest())
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
                if (loading != nil) {
                    [loading stopAnimating];
                    loading.hidden = true;
                }
                
                [arrKey removeAllObjects];
                std::vector<std::string> & vecKey = m_pRequest->GetArtistKey();
                for (size_t i = 0; i < vecKey.size(); i++) {
                    [arrKey addObject:[NSString stringWithUTF8String:vecKey[i].c_str()]];
                }
                UITableView * tableview = (UITableView*)[self.view viewWithTag:TagArtistList];
                [tableview reloadData];
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
                if (loading != nil) {
                    [loading stopAnimating];
                    loading.hidden = true;
                }
                //获取失败
            }
            KS_BLOCK_SYNRUN()
            
        }
    }
    KS_BLOCK_RUN_THREAD();
    
}

-(void)LoadArtistPic : (int)row InSection :(int)section  View:(UIImageView *)picView
{
    std::vector<std::string> & vecKey = m_pRequest->GetArtistKey();
    std::string strkey = vecKey[section];
    std::map< std::string,ARTIST_LIST >& mapArtist = m_pRequest->GetArtistList();
    ARTIST_LIST & vecArtist  = mapArtist[strkey];
    std::string strPicUrl = vecArtist[row].strPicUrl;

    std::string strRankPic;
    BOOL bouttime;
    if(CCacheMgr::GetInstance()->GetCacheFile(strPicUrl,strRankPic,bouttime) && !bouttime)
    {
        picView.image = [UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:strRankPic.c_str()]];
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
                    UITableView * tableview = (UITableView*)[self.view viewWithTag:TagArtistList];
                    UITableViewCell *oneCell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if(oneCell)
                    {
                        UIImageView * imageview = (UIImageView*)[oneCell viewWithTag:TagListImage];
                        imageview.image = [UIImage imageWithData:data];
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
        
    }


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

#pragma mark -TableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    std::vector<std::string> & vecKey = m_pRequest->GetArtistKey();
    std::string strkey = vecKey[section];
    std::map< std::string,ARTIST_LIST >& mapArtist = m_pRequest->GetArtistList();
    
    return  mapArtist[strkey].size();
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  arrKey.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return arrKey;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * str = [arrKey objectAtIndex:section];
    return str;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *s_commontableIdentifier = @"commonIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:s_commontableIdentifier];
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:s_commontableIdentifier] autorelease];
        
        int cellheight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        UIImageView * bkimage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, cellheight)]autorelease];
        bkimage.image = CImageMgr::GetImageEx("listbk_5_1.png");
        cell.backgroundView = bkimage;
        
        UIImageView * ArtistPic = [[[UIImageView alloc]initWithFrame:CGRectMake(4, 4, 60, 60)]autorelease];
        ArtistPic.tag = TagListImage;
        [cell.contentView addSubview:ArtistPic];
        
        UILabel *textLabel = [[[UILabel alloc]initWithFrame:CGRectMake(72, 17, 200, 14)]autorelease];
        textLabel.font= [UIFont systemFontOfSize:13];
        textLabel.textColor = UIColorFromRGBValue(0x2b2b2b);
        textLabel.shadowOffset = CGSizeMake(0, 1);
        textLabel.shadowColor = [UIColor whiteColor];
        textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        textLabel.backgroundColor = [UIColor clearColor];
        [textLabel setTag:TagListLabel];
        [cell.contentView addSubview:textLabel];
        
        UILabel *numLabel = [[[UILabel alloc]initWithFrame:CGRectMake(72, 42, 200, 10)]autorelease];
        numLabel.textColor = UIColorFromRGBValue(0x969696);
        numLabel.font= [UIFont systemFontOfSize:9.5];
        numLabel.shadowOffset = CGSizeMake(0, 1);
        numLabel.shadowColor = [UIColor whiteColor];
        numLabel.lineBreakMode = UILineBreakModeTailTruncation;
        numLabel.backgroundColor = [UIColor clearColor];
        [numLabel setTag:TagListNumLabel];
        [cell.contentView addSubview:numLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
         cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    std::vector<std::string> & vecKey = m_pRequest->GetArtistKey();
    std::string strkey = vecKey[section];
    std::map< std::string,ARTIST_LIST >& mapArtist = m_pRequest->GetArtistList();
    
    if(section < vecKey.size())
    {
        std::string strkey = vecKey[section];
        ARTIST_LIST & artistList = mapArtist[strkey];
        if(row < artistList.size())
        {
            UILabel * textLabel = (UILabel*)[cell viewWithTag:TagListLabel];
            textLabel.text = [NSString stringWithUTF8String:artistList[row].strName.c_str()];
            
            UILabel * numLabel = (UILabel*)[cell viewWithTag:TagListNumLabel];
            numLabel.text = [NSString stringWithFormat:@"%d首",artistList[row].nCount];
            UIImageView * imageview = (UIImageView*)[cell viewWithTag:TagListImage];
            imageview.image = CImageMgr::GetImageEx("defaultface.png");
            [self LoadArtistPic:row InSection: section View:imageview];
        
        }
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    std::vector<std::string> & vecKey = m_pRequest->GetArtistKey();
    std::string strkey = vecKey[section];
    std::map< std::string,ARTIST_LIST >& mapArtist = m_pRequest->GetArtistList();
    ARTIST_LIST & artistList = mapArtist[strkey];
    if(row < mapArtist[strkey].size())
    {
        MusicListViewController * listview = [[[MusicListViewController alloc]initwithListInfo :artistList[row]] autorelease];
        listview.title = [NSString stringWithFormat:@"%@(%d首)",[NSString stringWithUTF8String:artistList[row].strName.c_str()],artistList[row].nCount];
        listview.musiclibDelegate = musiclibDelegate;
        [ROOT_NAVAGATION_CONTROLLER pushViewController: listview animated:YES];
    }
}


@end
