//
//  LocalMusicViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "LocalMusicViewController.h"
#include "IMusicLibObserver.h"
#include "MessageManager.h"
#include "ImageMgr.h"
#include "globalm.h"
#include "LocalMusicRequest.h"
#include "MobClick.h"
#include "KSProgressView.h"
#include "iToast.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "FindSameSongViewController.h"
#include "KSAppDelegate.h"

#define REFRESH_INTERVAL        1

enum ControlTag
{
    KBUTTON_TAG = 1,
    KLABEL_NAME_TAG,
    KLABEL_ARTIST_TAG,
    KLABEL_TITLE_TAG,
    KPROGRESS_TAG
};

const int Tag_EmptyLabel = 100;

@interface LocalMusicViewController ()<UITableViewDataSource,UITableViewDelegate,IMusicLibObserver,UIAlertViewDelegate>
{
    NSTimer * timer;
    UITableView * musicList;
    UIButton* btnedit;
    
    bool m_bEdit;
    UIButton*btndelete; 
    
    UIAlertView * deleteView;
    std::string strDeleteID;
    
    UIAlertView *netView;
    std::string strDownID;
}
@end

@implementation LocalMusicViewController

- (id)init{
    self = [super init];
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    
    return self;
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
    [label_title setText:@"已点歌曲"];
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    CGRect rc = [self view].bounds;
    CGRect rcnav = self.navigationController.navigationBar.bounds;
    rc = BottomRect(rc,rc.size.height-rcnav.size.height,0);
    
    //UIImageView *listbkview = [[[UIImageView alloc]initWithImage:CImageMgr::GetBackGroundImage()]autorelease];
    musicList = [[[UITableView alloc]initWithFrame:rc]autorelease];
    [musicList setDelegate:self];
    [musicList setDataSource:self];
    [[self view ]addSubview:musicList];
    musicList.separatorStyle = UITableViewCellSeparatorStyleNone;
    musicList.backgroundColor = UIColorFromRGBValue(0xededed);
    
    std::vector<CSongInfoBase*> &vec = CLocalMusicRequest::GetInstance()->GetLocalMusicVec();
    
    int ncount = vec.size();
    CGRect rcempty = CenterRect(self.view.bounds, 200, 30);
    rcempty.origin.y -= 30;
    UILabel * emptyLabel = [[[UILabel alloc]initWithFrame:rcempty]autorelease];
    emptyLabel.backgroundColor = [UIColor clearColor];
    emptyLabel.tag = Tag_EmptyLabel;
    //emptyLabel.textColor = [UIColor whiteColor];
    emptyLabel.textAlignment = UITextAlignmentCenter;
    emptyLabel.text = @"你还没有点歌哦!";
    [self.view addSubview:emptyLabel];
    [self.view bringSubviewToFront:emptyLabel];
    if(ncount != 0)
    {
        emptyLabel.hidden = true;
    }
    else
        emptyLabel.hidden = false;
    
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

- (void)dealloc{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    [super dealloc];
}

-(void) ReturnBtnClick:(id)sender
{
    [timer invalidate];
    timer = nil;
    [self.navigationController popViewControllerAnimated:YES];
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

-(void) EditBtnClick:(id)sender
{
    if(!m_bEdit)
    {
        if([musicList isEditing])
            [musicList setEditing:false];

        m_bEdit = true;
        [btnedit setTitle:@"完成" forState:UIControlStateNormal];
        [musicList setEditing:true];
            }
    else{
        m_bEdit = false;
        [btnedit setTitle:@"编辑" forState:UIControlStateNormal];
        [musicList setEditing:false];
    }
    
    [musicList reloadData];

}

-(void)IObMusicLib_AddTask:(NSString*)strRid
{
    UILabel * emptyLabel = (UILabel*)[self.view viewWithTag:Tag_EmptyLabel];
    if(emptyLabel)
        emptyLabel.hidden = true;
    [musicList reloadData];
}

-(void)IObMusicLib_DeleteTask:(NSString*)strRid
{
    std::vector<CSongInfoBase*>& vec =  CLocalMusicRequest::GetInstance()->GetLocalMusicVec();
    if(vec.size() == 0)
    {
        UILabel * emptyLabel = (UILabel*)[self.view viewWithTag:Tag_EmptyLabel];
        if(emptyLabel)
            emptyLabel.hidden = false;
    }
     [musicList reloadData];
}

-(void)IObMusicLib_DownTaskFinish:(NSString*)strRid
{
    [musicList reloadData];
}

-(void)IObMusicLib_StartTask:(NSString*)strRid;
{
    [musicList reloadData];
}

-(void)IObMusicLib_TaskFail:(NSString*)strRid;
{
    [musicList reloadData];
}

-(void)IObMusicLib_PauseTask:(NSString*)strRid
{
    [musicList reloadData];
}

-(void)IObMusicLib_TaskProgress:(NSString*)strRid:(float)fPercent
{
    if(CLocalMusicRequest::GetInstance()->HasDowningTask() && ![musicList isEditing])
    {
        [musicList reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(bool)hasSongs
{
    return [musicList numberOfRowsInSection:0]>0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    std::vector<CSongInfoBase*> &vec =  CLocalMusicRequest::GetInstance()->GetLocalMusicVec();
    return vec.size();
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *s_simpletableIdentifier = @"simpleIdentifier";
    UITableViewCell* cell= [tableView dequeueReusableCellWithIdentifier:s_simpletableIdentifier];
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:s_simpletableIdentifier] autorelease];
        
        int cellheight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        UIImageView * bkimage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, cellheight)]autorelease];
        bkimage.image = CImageMgr::GetImageEx("listbk_5_1.png");
        [cell.contentView addSubview:bkimage];
        
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
//        [button.titleLabel setShadowColor:UIColorFromRGBValue(0x2b2b2b)];
//        [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [button titleLabel].font = [UIFont systemFontOfSize:13];
        [button addTarget:self action:@selector(onKSongClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];

    }
    NSInteger row = [indexPath row];
    std::vector<CSongInfoBase*>& vec=  CLocalMusicRequest::GetInstance()->GetLocalMusicVec();
    if(row >= vec.size())
        return cell;
    CSongInfoBase * songinfo = vec[vec.size() - row - 1];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:KLABEL_NAME_TAG];
    [textLabel setText:[NSString stringWithUTF8String:songinfo->strSongName.c_str()]];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:KLABEL_ARTIST_TAG];
    [detailTextLabel setText:[NSString stringWithUTF8String:songinfo->strArtist.c_str()]];
    
    UIButton*btn = (UIButton*)[cell.contentView viewWithTag:KBUTTON_TAG];
    KSProgressView *progressview = (KSProgressView*)[cell.contentView viewWithTag:KPROGRESS_TAG];
    if(((CLocalTask*)songinfo)->taskStatus == TaskStatus_Finish)
    {
        [btn setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnNormal.png") forState:UIControlStateNormal];
        [btn setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnDown.png") forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"演唱" forState:UIControlStateNormal];
        progressview.hidden = true;
    }
    else {
//        [btn setBackgroundImage:CImageMgr::GetImageEx("KsongDownloadBtn.png") forState:UIControlStateNormal];
//        [btn setBackgroundImage:CImageMgr::GetImageEx("KsongDownloadBtnDown.png") forState:UIControlStateHighlighted];
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
            [btn setBackgroundImage:CImageMgr::GetImageEx("KsongBtn.png") forState:UIControlStateNormal];
            [btn setBackgroundImage:CImageMgr::GetImageEx("KsongBtnDown.png") forState:UIControlStateHighlighted];
            [btn setTitleColor:UIColorFromRGB(53,120,185) forState:UIControlStateNormal];
            [btn setTitle:@"点歌" forState:UIControlStateNormal];
        }
    }
    if([tableView isEditing])
        [btn setHidden:true];
    else {
        [btn setHidden:false];
    }

    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)RefreshTitle
{
    std::vector<CSongInfoBase*> & vec = CLocalMusicRequest::GetInstance()->GetLocalMusicVec();
    int ncount = vec.size();
    UILabel* label = (UILabel*)[self.view viewWithTag:KLABEL_TITLE_TAG];
    if(label)
    {
        if(ncount != 0)
            label.text = [NSString stringWithFormat:@"已点歌曲(%d首)",ncount];
        else 
            label.text = @"已点歌曲";
    }

}

-(void)onKSongClick :(id)sender
{
    UITableViewCell* cell = nil;
    if (NSOrderedAscending != [[[UIDevice currentDevice] systemVersion] compare:@"7.0"]){
        cell = (UITableViewCell*)[[[(UIButton*)sender superview]superview] superview];
    }else {
        cell = (UITableViewCell*)[[(UIButton*)sender superview]superview];
    }
    NSIndexPath *indexPath = [musicList indexPathForCell:cell];
    if(indexPath == nil)
        return;
    int row = indexPath.row;
    std::vector<CSongInfoBase*> & vec = CLocalMusicRequest::GetInstance()->GetLocalMusicVec();
    
    if(row >= vec.size())
        return;
    CSongInfoBase * songinfo = vec[vec.size() - row - 1];
    if(songinfo)
    {
        if(((CLocalTask*)songinfo)->taskStatus == TaskStatus_Finish)
        {
            CLocalMusicRequest::GetInstance()->StartDownTask(songinfo);
        }
        else
        {
            bool bvalue = true;
            KwConfig::GetConfigureInstance()->GetConfigBoolValue(AUTHORITY_GROUP, AUTHORITY_AUTHORIZED, bvalue,true);
            if(!bvalue)
            {
                UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"基于版权保护，酷我音乐目前仅对中国大陆地区用户提供服务，敬请谅解" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil]autorelease];
                [alert show];
                return;
            }
            
            if(((CLocalTask*)songinfo)->taskStatus == TaskStatus_Downing)
            {
                strDeleteID = songinfo->strRid;
                deleteView = [[[UIAlertView alloc] initWithTitle:@"" message:@"是否要取消下载？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否",nil]autorelease];
                [deleteView show];
            }
            else
            {
                if(CHttpRequest::GetNetWorkStatus() == NETSTATUS_WWAN)
                {
                    static bool btip = false;
                    if(!btip)
                    {
                        btip = true;
                        [[[iToast makeText:NSLocalizedString(@"您当前使用的是2G/3G网络\r\n点歌将产生一定的流量", @"")]setGravity:iToastGravityCenter]show];
                    }
                    CLocalMusicRequest::GetInstance()->StartDownTask(songinfo);
                }
                else if(CHttpRequest::GetNetWorkStatus() != NETSTATUS_NONE)
                {
                    CLocalMusicRequest::GetInstance()->StartDownTask(songinfo);
                }
                
            }

            
        }
        
     }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        //NSLog(@"delete:%d",indexPath.row);
        NSInteger row = [indexPath row];
        std::vector<CSongInfoBase*> & vec = CLocalMusicRequest::GetInstance()->GetLocalMusicVec();
        
        if(row >= vec.size())
            return;
        CSongInfoBase * songinfo = vec[vec.size() - row - 1];
        if(songinfo)
            CLocalMusicRequest::GetInstance()->DeleteTask(songinfo->strRid);
        [self RefreshTitle];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = indexPath.row;
    std::vector<CSongInfoBase*> & vec = CLocalMusicRequest::GetInstance()->GetLocalMusicVec();
    
    if(row >= vec.size())
        return;
    CSongInfoBase * songinfo = vec[vec.size() - row - 1];
//    NSLog(@"select song:%s",songinfo->strRid.c_str());
    FindSameSongViewController * sameViewController=[[[FindSameSongViewController alloc] init] autorelease];
    [sameViewController setRankRid:[NSString stringWithFormat:@"%s",songinfo->strRid.c_str()]];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:sameViewController animated:true];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return UITableViewCellEditingStyleDelete; 
} 

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [musicList reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(deleteView == alertView && buttonIndex == 0)
    {
        CLocalMusicRequest::GetInstance()->DeleteTask(strDeleteID);
        [self RefreshTitle];
        [musicList reloadData];
    }
    if(netView == alertView && buttonIndex == 0)
    {
        CSongInfoBase * localmusic = CLocalMusicRequest::GetInstance()->GetLocalMusic(strDownID);
        if(localmusic)
        {
            CLocalMusicRequest::GetInstance()->StartDownTask(localmusic);
        }
    }
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    btndelete = (UIButton*)[cell.contentView viewWithTag:KBUTTON_TAG];
    [btndelete setHidden:true];
    KSProgressView *progressview = (KSProgressView*)[cell.contentView viewWithTag:KPROGRESS_TAG];
    progressview.hidden = true;

}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end
