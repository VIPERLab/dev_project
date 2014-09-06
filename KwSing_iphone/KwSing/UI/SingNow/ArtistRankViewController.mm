//
//  ArtistRankViewController.m
//  KwSing
//
//  Created by Hu Qian on 12-11-29.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "ArtistRankViewController.h"
#include <QuartzCore/QuartzCore.h>
#include "globalm.h"
#include "RanksListRequest.h"
#include "MessageManager.h"
#include "CacheMgr.h"
#include "KwTools.h"
#include "ArtistCatViewController.h"
#include "KSAppDelegate.h"
#include "ImageMgr.h"
#include "HttpRequest.h"

const int TagRankList = 100;
const int TagScrollButton = 150;

@interface ArtistRankViewController ()<UIScrollViewDelegate>
{
    CRanksListRequest * m_pRequest;
    std::vector<ListInfo> m_vecRankList;
}
@end

@implementation ArtistRankViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"歌手列表";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView * rankview = [[[UIScrollView alloc]init]autorelease];
    rankview.backgroundColor = UIColorFromRGBValue(0xededed);
    rankview.tag = TagRankList;
    rankview.frame = CGRectMake(0, 44, 320, self.view.frame.size.height-44);
    rankview.delegate = self;
    [[self view] addSubview:rankview];
    
    UIView * shadowview = (UIView*)[self.view viewWithTag:TagShadow];
    [self.view bringSubviewToFront:shadowview];
    
    UIActivityIndicatorView * loading = (UIActivityIndicatorView *)[self.view viewWithTag:TagLoading];
    m_pRequest = new CRanksListRequest(eArtistRank);
    
    m_vecRankList = m_pRequest->QuickGetList();
    if(m_vecRankList.size() == 0)
    {
        if (loading != nil) {
            loading.hidden = false;
            [loading startAnimating];
            [self.view bringSubviewToFront:loading];
        }
    }
    [self RefreshScrollView];
    [self UpdateList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(m_bNetFail && !m_bReLoading)
    {
        m_bReLoading = true;
        [self UpdateList];
    }
}

-(void)RefreshScrollView
{
    UIScrollView *scrollview = (UIScrollView*)[self.view viewWithTag:TagRankList];
    for (UIView * view in scrollview.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < m_vecRankList.size(); i++) {
        UIButton * btnpic = [UIButton buttonWithType:UIButtonTypeCustom];
        btnpic.tag = TagScrollButton + i;
        [btnpic setImage:CImageMgr::GetImageEx("defaultface.png") forState:UIControlStateNormal];
        [btnpic addTarget:self action:@selector(OnClickRank:) forControlEvents:UIControlEventTouchUpInside];
        [scrollview addSubview:btnpic];
        
        UILabel * labelname = [[[UILabel alloc]init]autorelease];
        [scrollview addSubview:labelname];
        labelname.text = [NSString stringWithUTF8String:m_vecRankList[i].strName.c_str()];
        labelname.backgroundColor = [UIColor clearColor];
        labelname.textAlignment = NSTextAlignmentCenter;
        labelname.font = [UIFont systemFontOfSize:13];
        labelname.textColor = UIColorFromRGBValue(0x2b2b2b);
        labelname.shadowOffset = CGSizeMake(0, 1);
        labelname.shadowColor = [UIColor whiteColor];

        
        int line = i%3;
        int row = i/3;
        CGRect rcbtn;
        CGRect rclabel;
        if (!IsIphone5()) {
            rcbtn = CGRectMake(line*108, row*137 + 4, 104, 104);
            rclabel = CGRectMake(rcbtn.origin.x, rcbtn.origin.y+rcbtn.size.height, 104, 30);
        }
        else{
            rcbtn = CGRectMake(line*108, row*160 + 4, 104, 104);
            rclabel = CGRectMake(rcbtn.origin.x, rcbtn.origin.y+rcbtn.size.height+10, 104, 30);
        }
        btnpic.frame = rcbtn;
        labelname.frame = rclabel;
            
    }
    
    int temp = (m_vecRankList.size()-1)/3;
    scrollview.contentSize = CGSizeMake(scrollview.frame.size.width, temp*130 + 135);
    [self LoadRankPic];
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
                if(m_vecRankList.size() == 0)
                {
                    m_vecRankList = m_pRequest->GetRankList();
                    [self RefreshScrollView];
                }
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

-(void)OnClickRank:(id)sender
{
    int index = ((UIButton*)sender).tag - TagScrollButton;
    if(index < m_vecRankList.size())
    {
        ArtistCatViewController * ArtistCatView = [[ArtistCatViewController alloc]initwithListInfo:m_vecRankList[index]];
        ArtistCatView.musiclibDelegate = musiclibDelegate;
        [ROOT_NAVAGATION_CONTROLLER pushViewController: ArtistCatView animated:YES];
        [ArtistCatView release];
        ArtistCatView = nil;
    }

}

-(void)LoadRankPic
{
    for (size_t i = 0; i < m_vecRankList.size(); i++) {
        std::string strPicUrl = m_vecRankList[i].strPicUrl;
        std::string strRankPic;
        BOOL bouttime;
        if(CCacheMgr::GetInstance()->GetCacheFile(strPicUrl,strRankPic,bouttime) && !bouttime)
        {
            UIScrollView *Rankview = (UIScrollView*)[self.view viewWithTag:TagRankList];
            UIButton * btnpic = (UIButton*)[Rankview viewWithTag:TagScrollButton+i];
            if(btnpic)
            {
                UIImage *pic = [UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:strRankPic.c_str()]];
                [btnpic setImage:pic forState:UIControlStateNormal];
            }
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
                        UIScrollView *Rankview = (UIScrollView*)[self.view viewWithTag:TagRankList];
                        UIButton * btnpic = (UIButton*)[Rankview viewWithTag:TagScrollButton+i];
                        if(btnpic)
                        {
                            [btnpic setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
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
}


@end
