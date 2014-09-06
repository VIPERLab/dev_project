//
//  KSNetSongDelegate.m
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSMusicLibDelegate.h"
#include "CacheMgr.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "IMusicLibObserver.h"
#include "LocalmusicRequest.h"
#include "iToast.h"
#include "KwConfig.h"
#include "KwConfigElements.h"

#define PATH_SEARCHHISTROY @"searchhistroy.plist"

@interface KSMusicLibDelegate()<UIAlertViewDelegate> 
{
    UIAlertView * deleteView;
    UIAlertView * netView;
    CSongInfoBase * m_pNetSongInfo;
    KSWebView * netTemptWebView;
    std::string strDeleteID;
}
@end

@implementation KSMusicLibDelegate

- (id)init
{
    if(self = [super init])
    {
        m_pNetSongInfo = NULL;
        netTemptWebView = nil;
        [self LoadSearchHistory];
        GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    }
    return self;
}

- (void)dealloc
{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    [arrSearchHistory release];
    [super dealloc];
}

-(void)IObserverApp_EnterBackground
{
    // 保存搜索历史数据
    NSString *filepath = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
    filepath = [filepath stringByAppendingPathComponent:PATH_SEARCHHISTROY];
    KwTools::Dir::DeleteFile(filepath);
    [arrSearchHistory writeToFile:filepath atomically:YES];

}

-(void)IObserverApp_EnterForeground
{
}

- (void)LoadSearchHistory
{
    NSString *filepath = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
    filepath = [filepath stringByAppendingPathComponent:PATH_SEARCHHISTROY];
    if(KwTools::Dir::IsExistFile(filepath))
    {
        arrSearchHistory = [[NSMutableArray alloc]initWithContentsOfFile:filepath];
        if([arrSearchHistory count] > 10)
        {
            //NSLog(@"search filee error:history num>10");
            while ([arrSearchHistory count] > 10) {
                [arrSearchHistory removeLastObject];
            }
        }
        if(arrSearchHistory == nil)
        {
            arrSearchHistory = [[NSMutableArray alloc]initWithCapacity:10];
        }
    }
    else 
    {
        arrSearchHistory = [[NSMutableArray alloc]initWithCapacity:10];
    }

}

- (id) GetSearchHistory
{
    return arrSearchHistory;
}

-(void)KSong :(CSongInfoBase*)songInfo
{
    CSongInfoBase * localmusic = CLocalMusicRequest::GetInstance()->GetLocalMusic(songInfo->strRid);
    if(localmusic && ((CLocalTask*)localmusic)->taskStatus == TaskStatus_Downing)
    {
        strDeleteID = localmusic->strRid;
        deleteView = [[[UIAlertView alloc] initWithTitle:@"" message:@"是否要取消点歌？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否",nil]autorelease];
        [deleteView show];
    }
    else {
        if(songInfo->strRid  == "0") //清唱
        {
            CLocalMusicRequest::GetInstance()->StartDownTask(songInfo);
            return;
        }
        if(CHttpRequest::GetNetWorkStatus() == NETSTATUS_WWAN) // 2g/3g网络或者清唱不提示用户
        {
            if(localmusic &&((CLocalTask*)localmusic)->taskStatus == TaskStatus_Finish)
            {
                CLocalMusicRequest::GetInstance()->StartDownTask(songInfo);
            }
            else {
                bool bvalue = true;
                KwConfig::GetConfigureInstance()->GetConfigBoolValue(AUTHORITY_GROUP, AUTHORITY_AUTHORIZED, bvalue,true);
                if(!bvalue)
                {
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"基于版权保护，酷我音乐目前仅对中国大陆地区用户提供服务，敬请谅解" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil]autorelease];
                    [alert show];
                    return;
                }
                static bool btip = false;
                if(!btip)
                {
                    btip = true;
                    [[[iToast makeText:NSLocalizedString(@"您当前使用的是2G/3G网络\r\n点歌将产生一定的流量", @"")]setGravity:iToastGravityCenter]show];
                }
                CLocalMusicRequest::GetInstance()->StartDownTask(songInfo);
            }
        }
        else if(CHttpRequest::GetNetWorkStatus() == NETSTATUS_NONE)
        {
            if(localmusic &&((CLocalTask*)localmusic)->taskStatus == TaskStatus_Finish)
            {
                CLocalMusicRequest::GetInstance()->StartDownTask(songInfo);
            }
            else
            {
                [[[iToast makeText:NSLocalizedString(@"你的网络未连接\r\n请演唱本地歌曲吧", @"")]setGravity:iToastGravityCenter]show];
            }
        }
        else {
            if(localmusic &&((CLocalTask*)localmusic)->taskStatus == TaskStatus_Finish)
            {
                CLocalMusicRequest::GetInstance()->StartDownTask(songInfo);
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
                CLocalMusicRequest::GetInstance()->StartDownTask(songInfo);
            }
        }
    }
    
}

-(void)ClearSearchHistroy
{
    [arrSearchHistory removeAllObjects];
    //NSLog(@"webcommand:clear search histroy");
}

-(void)DeleteSearchHistroy:(id)key
{
    [arrSearchHistory removeObject:key];
}

- (void)InsertSearchKey:(id)key
{
    if (key && [[key class] isSubclassOfClass:[NSString class]] && ![(NSString*)key isEqualToString:@""])
    {
        if([arrSearchHistory containsObject:key])
        {
            [arrSearchHistory removeObject:key];
            [arrSearchHistory insertObject:key atIndex:0];
        }
        else {
            if([arrSearchHistory count] >= 10)
                [arrSearchHistory removeLastObject];
            [arrSearchHistory insertObject:key atIndex:0];
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(deleteView == alertView && buttonIndex == 0)
    {
        CSongInfoBase * localmusic = CLocalMusicRequest::GetInstance()->GetLocalMusic(strDeleteID);
        if(localmusic && ((CLocalTask*)localmusic)->taskStatus != TaskStatus_Finish)
            CLocalMusicRequest::GetInstance()->DeleteTask(strDeleteID);
    }
    if(netView == alertView )
    {
        if(m_pNetSongInfo)
        {
            if(buttonIndex == 0)
            {
                CLocalMusicRequest::GetInstance()->StartDownTask(m_pNetSongInfo);
            }
            else if(buttonIndex == 1)
            {
                // 若选否，则让网页恢复状态
                CSongInfoBase * songinfo = CLocalMusicRequest::GetInstance()->GetLocalMusic(m_pNetSongInfo->strRid);
                if(songinfo == NULL)
                {
                    NSString * str = [NSString stringWithFormat:@"%s&&delete",m_pNetSongInfo->strRid.c_str()];
                    if(netTemptWebView)
                        [netTemptWebView executeJavaScriptFunc: @"onRefreshStatus" parameter:str];
                }
                else if(((CLocalTask*)songinfo)->taskStatus != TaskStatus_Pause)
                {
                    int nradio = 0;
                    if(songinfo->accompanyRes.uiFileSize!=0)
                        nradio = songinfo->accompanyRes.uiLocalSize*100/songinfo->accompanyRes.uiFileSize;
                    NSString * value = [NSString stringWithFormat: @"%s&&pause&&%d",songinfo->strRid.c_str(),nradio];
                    [netTemptWebView executeJavaScriptFunc: @"onRefreshStatus" parameter:value];
                }

            }
             netTemptWebView = nil;
            delete m_pNetSongInfo;
            m_pNetSongInfo = NULL;
        }

    }
}

@end
