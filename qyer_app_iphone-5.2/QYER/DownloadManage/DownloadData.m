//
//  DownloadData.m
//  DownLoadZipFile_withPods
//
//  Created by an qing on 13-4-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "DownloadData.h"
#import "ASIHTTPRequest.h"
#import "FilePath.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "QYGuideData.h"



#define  request_timeOutSeconds 20  //请求数据超时时间
#define  second_delay           20  //网络中断后再进行second_delay秒的延迟




@implementation DownloadData
@synthesize downloadQueue   = _downloadQueue;
@synthesize requestListDic  = _requestListDic;
@synthesize delegate = _delegate;

-(void)dealloc
{
    self.downloadQueue  = nil;
    self.requestListDic = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- 单例
static DownloadData *sharedDownloadData = nil;
+(id)sharedDownloadData
{
    if (!sharedDownloadData)
    {
        NSLog(@"新申请DownloadData");
        
        
        //后台下载时使用:
        //[(AppDelegate *)[[UIApplication sharedApplication] delegate] performSelector:@selector(initLocationManager) withObject:nil afterDelay:0];
        
        
        sharedDownloadData = [[self alloc] init];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        sharedDownloadData.requestListDic = dic;
        [dic release];
        sharedDownloadData.downloadQueue = [ASINetworkQueue queue];
        sharedDownloadData.downloadQueue.shouldCancelAllRequestsOnFailure = NO;
        sharedDownloadData.downloadQueue.downloadProgressDelegate = self;
        sharedDownloadData.downloadQueue.showAccurateProgress = YES;      //显示精确的下载进度信息
        sharedDownloadData.downloadQueue.maxConcurrentOperationCount = 1; //允许同时下载的最大个数为1,保证依次按序下载。
        
        
        sharedDownloadData.downloadQueue.delegate = sharedDownloadData;   //接受request下载信息
        sharedDownloadData.downloadQueue.requestDidStartSelector = @selector(downloadQueueDidStarted:);
        sharedDownloadData.downloadQueue.requestDidFinishSelector = @selector(downloadQueueDidFinished:);
        sharedDownloadData.downloadQueue.requestDidFailSelector = @selector(downloadQueueDidFailed:);
        
        
        
        [sharedDownloadData.downloadQueue go];
        
        
        
        //*** 网络监听:
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:sharedDownloadData selector:@selector(netChangedToWWAN:) name:@"NetworkStatus_WWAN" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedDownloadData selector:@selector(netChangedToWIFI:) name:@"NetworkStatus_WIFI" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedDownloadData selector:@selector(netChangedToNO:) name:@"NetworkStatus_NO" object:nil];
        
        
    }
    return sharedDownloadData;
}




#pragma mark -
#pragma mark --- addRequest: withDelegate:
-(void)addRequest:(ASIHTTPRequest *)request withDelegate:(id)delegate
{
    NSDictionary *userInfo = [request userInfo];
    NSLog(@"添加请求: %@",[userInfo objectForKey:@"guideName"]);
    
    ASIHTTPRequest *request_ = [_requestListDic objectForKey:[userInfo objectForKey:@"guideName"]];
    if (request_)
    {
        [request clearDelegatesAndCancel];
        request = nil;
        
        [sharedDownloadData.downloadQueue setSuspended:YES];
        [request_ setDelegate:delegate];
        [request_ setDownloadProgressDelegate:delegate];
        [sharedDownloadData.downloadQueue go];
        
        return;
    }
    
    
    [_requestListDic removeObjectForKey:[userInfo objectForKey:@"guideName"]];
    [_requestListDic setObject:request forKey:[userInfo objectForKey:@"guideName"]];
    if(delegate)
    {
        [request setDelegate:delegate];
        [request setDownloadProgressDelegate:delegate];
    }
    [self.downloadQueue addOperation:request];
    [sharedDownloadData.downloadQueue go];
    
}



#pragma mark -
#pragma mark --- ASINetworkQueue - delegate
-(void)downloadQueueDidStarted:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request userInfo];
    NSLog(@"ASINetworkQueue - 开始下载:'%@'",[userInfo objectForKey:@"guideName"]);
    
    if(request.delegate && [request.delegate respondsToSelector:@selector(downloadQueueDidStarted:)])
    {
        [request.delegate downloadQueueDidStarted:request];
    }
}
-(void)downloadQueueDidFinished:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request userInfo];
    NSString *finished_key = [userInfo objectForKey:@"guideName"];
    
    NSLog(@"ASINetworkQueue - '%@'下载成功",[userInfo objectForKey:@"guideName"]);
    
    
    //删除该请求:
    [_requestListDic removeObjectForKey:[userInfo objectForKey:@"guideName"]];
    
    
    //若下载成功的是之前已经失败过又开始下载的，则将该数据删除:
    if(_dic_requesFailed && [_dic_requesFailed count] > 0 && [[_dic_requesFailed allKeys] indexOfObject:finished_key] < [[_dic_requesFailed allKeys] count])
    {
        [_dic_requesFailed removeObjectForKey:finished_key];
    }
    
    //记录锦囊的下载时间(在已下载页面排序用)和锦囊的更新时间(判断是否需要更新时用):
    [self processData:userInfo];
    
    
    if(_requestListDic.count == 0)
    {
        //将下载失败的请求重新再添加到请求队列中:
        [self reloadFailed];
    }
    
    if(_requestListDic.count == 0 && _dic_requesFailed.count == 0)
    {
        NSLog(@"下载完毕");
        AppDelegate *delegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [[delegate_ locationManager] stopUpdatingLocation];
    }
    
    if(_dic_requesFailedNumber)
    {
        [_dic_requesFailedNumber removeObjectForKey:[userInfo objectForKey:@"guideName"]];
    }
    
    
    //执行request的代理方法:
    if(request.delegate && [request.delegate respondsToSelector:@selector(downloadQueueDidFinished:)])
    {
        [request.delegate downloadQueueDidFinished:request];
    }
    else
    {
        NSLog(@" request.delegate  并没有实现'requestDidFinished:'方法 ～～～～～ ");
    }
    
    
    //发消息 [下载成功]:
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadfinished" object:nil userInfo:userInfo];
    
}
-(void)downloadQueueDidFailed:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request userInfo];
    
    [sharedDownloadData.downloadQueue setSuspended:YES];
    
    
    if(_flag_netWrong == 1)
    {
        NSLog(@"ASINetworkQueue - 下载失败原因 = '已取消所有的下载'");
        
        
        //request的delegate去执行requestDidFailed:
        if(request.delegate && [request.delegate respondsToSelector:@selector(downloadQueueDidFailed:)])
        {
            [request.delegate downloadQueueDidFailed:request];
        }
        
        
        //取消延迟调用:
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeFlagAndStop) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetNetFlag) object:nil];
        
        if([[_requestListDic allValues] count] > 0 || [[_dic_requesFailed allValues] count] > 0)
        {
            [self cancleAllRequest];
        }
        
        
        //发消息 [下载失败]:
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadfailed" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:[userInfo objectForKey:@"guideName"], nil],@"names", nil]];
        
        
        return;
    }
    
    else
    {
        NSLog(@"ASINetworkQueue - '%@'下载失败原因 = %@",[userInfo objectForKey:@"guideName"],request.error.localizedDescription);
        NSLog(@"request.delegate:%@",request.delegate);
        
        
        //取消该请求:
        [request clearDelegatesAndCancel];
        [_requestListDic removeObjectForKey:[userInfo objectForKey:@"guideName"]];
        
        
        //记录下载失败的锦囊名称:
        if(!_dic_requesFailed)
        {
            _dic_requesFailed = [[NSMutableDictionary alloc] init];
        }
        [_dic_requesFailed removeObjectForKey:[userInfo objectForKey:@"guideName"]];
        [_dic_requesFailed setObject:userInfo forKey:[userInfo objectForKey:@"guideName"]];
        
        
        //记录'_dic_requesFailed'里request的请求次数:
        if([request.error.localizedDescription rangeOfString:@"A connection failure occurred"].location != NSNotFound)
        {
            if(!_dic_requesFailedNumber)
            {
                _dic_requesFailedNumber = [[NSMutableDictionary alloc] init];
            }
            if([_dic_requesFailedNumber objectForKey:[userInfo objectForKey:@"guideName"]])
            {
                [_dic_requesFailedNumber setObject:[NSString stringWithFormat:@"%d",[[_dic_requesFailedNumber objectForKey:[userInfo objectForKey:@"guideName"]] intValue]+1] forKey:[userInfo objectForKey:@"guideName"]];
            }
            else
            {
                [_dic_requesFailedNumber setObject:@"1" forKey:[userInfo objectForKey:@"guideName"]];
            }
        }
        
        
        [sharedDownloadData.downloadQueue go];
    }
}

-(void)processData:(NSDictionary *)userInfo
{
    //记录锦囊的下载时间［在已下载页面显示时使用; value:guideName --- key:time］:
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloadtime.plist",[pathURL path]];
    if([fileManager fileExistsAtPath:plistPath])
    {
        NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
        
        NSDate *date = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString *str_date = [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[date timeIntervalSince1970]]] retain];
        [dic setObject:str_date forKey:[userInfo objectForKey:@"guideName"]];
        [dic setObject:[userInfo objectForKey:@"guideUpdate_time"] forKey:[NSString stringWithFormat:@"%@_updatetime",[userInfo objectForKey:@"guideName"]]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
        if(data)
        {
            [data writeToFile:plistPath atomically:NO];
        }
        [date release];
        [dateFormatter release];
        [str_date release];
    }
    else
    {
        NSMutableDictionary *dic_ = [[NSMutableDictionary alloc] init];
        
        NSDate *date = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString *str_date = [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[date timeIntervalSince1970]]] retain];
        [dic_ setObject:str_date forKey:[userInfo objectForKey:@"guideName"]];
        [dic_ setObject:[userInfo objectForKey:@"guideUpdate_time"] forKey:[NSString stringWithFormat:@"%@_updatetime",[userInfo objectForKey:@"guideName"]]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic_];
        if(data)
        {
            [data writeToFile:plistPath atomically:NO];
        }
        [dic_ removeAllObjects];
        [dic_ release];
        [date release];
        [dateFormatter release];
        [str_date release];
    }
}
-(void)initRequest:(NSDictionary *)userInfo
{
    NSString *key = [userInfo objectForKey:@"guideName"];
    NSString *value = [NSString stringWithFormat:@"%@?modified=%@",[userInfo objectForKey:@"guideFilePath"],[userInfo objectForKey:@"guideUpdate_time"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:value]];
    NSString *plistPathTmp = [[FilePath sharedFilePath] getFilePath:@"file_tmp"];
    NSString *plistPath = [[FilePath sharedFilePath] getFilePath:@"file"];
    plistPathTmp = [NSString stringWithFormat:@"%@/%@.zip.tmp",plistPathTmp,key];
    plistPath = [NSString stringWithFormat:@"%@/%@.zip",plistPath,key];
    request.temporaryFileDownloadPath = plistPathTmp;
    request.downloadDestinationPath = plistPath;
    [request setAllowResumeForFileDownloads:YES];
    request.shouldContinueWhenAppEntersBackground = YES;  //后台允许下载
    request.delegate = [QYGuideData sharedQYGuideData];
    request.downloadProgressDelegate = [QYGuideData sharedQYGuideData];
    request.userInfo = userInfo;
    [request setDownloadProgressDelegate:[QYGuideData sharedQYGuideData]];
    
    request.shouldAttemptPersistentConnection = NO;
    
    [[DownloadData sharedDownloadData] addRequest:request withDelegate:[userInfo objectForKey:@"delegate"]];
}



#pragma mark -
#pragma mark --- suspend 暂停
-(void)suspend:(NSDictionary *)urlInfo
{
    NSString *key = [urlInfo objectForKey:@"guideName"];
    
    ASIHTTPRequest *suspendRequest = [sharedDownloadData.requestListDic valueForKey:key];
    if(suspendRequest)
    {
        [sharedDownloadData.downloadQueue setSuspended:YES];
        [suspendRequest clearDelegatesAndCancel];
        [sharedDownloadData.requestListDic removeObjectForKey:key];
        [sharedDownloadData.downloadQueue go];
    }
}


#pragma mark -
#pragma mark --- netChangedToWWAN & netChangedToWIFI & netChangedToNO
-(void)netChangedToWWAN:(NSNotification *)notification
{
    NSLog(@" --- 连接到3G网络 :");
    
}
-(void)netChangedToWIFI:(NSNotification *)notification
{
    NSLog(@" --- 连接到WIFI网络 :");
    
    if(_flag_netWrong == 1)
    {
        NSLog(@"已经过了所设的时间,暂停所有的下载");
        [self cancleAllRequest];
        return;
    }
    
    //取消延迟调用:
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeFlagAndStop) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetNetFlag) object:nil];
    
    
    //设置网络状态为正常:
    _flag_netWrong = 0;
    
    
    //开始请求数据:
    [sharedDownloadData.downloadQueue go];
    
    
    //将下载失败的请求重新再添加到请求队列中:
    [self reloadFailed];
    
}
-(void)netChangedToNO:(NSNotification *)notification
{
    NSLog(@" --- 网络错误 :");
    
    /**************************************************
     当监听到网络连接失败后，再过request_timeOutSeconds秒才会调用request的requestFailed代理方法!
     **************************************************/
    
    
    [sharedDownloadData.downloadQueue setSuspended:YES];
    
    
    if(_flag_netWrong == 0)
    {
        NSLog(@" 开始计时啦 ~~~ ");
        [self performSelector:@selector(changeFlagAndStop) withObject:nil afterDelay:second_delay];
    }
    else
    {
        [self cancleAllRequest];
    }
}
-(void)changeFlagAndStop
{
    NSLog(@"网络超时~  取消所有的下载 ~~~ ");
    _flag_netWrong = 1;
    [self cancleAllRequest];
}
-(void)cancleAllRequest
{
    NSLog(@"   cancleAllRequest   cancleAllRequest ");
    
    //暂停所有的下载请求:
    [sharedDownloadData.downloadQueue setSuspended:YES];
    
    //取消所有的数据请求:
    [[[DownloadData sharedDownloadData] downloadQueue] cancelAllOperations];
    
    //暂停获取用户的位置信息:
    AppDelegate *delegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate_ locationManager] stopUpdatingLocation];
    
    //重新设置网络标志:
    [self performSelector:@selector(resetNetFlag) withObject:nil afterDelay:3];
    
    
    //更新下载的状态:
    for(NSString *guidename in [_requestListDic allKeys])
    {
        ASIHTTPRequest *request = [_requestListDic objectForKey:guidename];
        if([request.userInfo objectForKey:@"delegate"] && [[request.userInfo objectForKey:@"delegate"] respondsToSelector:@selector(downloadCancled:)])
        {
            [[request.userInfo objectForKey:@"delegate"] downloadCancled:request.userInfo];
        }
    }
    for(NSString *guidename in [_dic_requesFailed allKeys])
    {
        NSDictionary *info_request = [_dic_requesFailed objectForKey:guidename];
        if([info_request objectForKey:@"delegate"] && [[info_request objectForKey:@"delegate"] respondsToSelector:@selector(downloadCancled:)])
        {
            [[info_request objectForKey:@"delegate"] downloadCancled:info_request];
        }
    }
    
    
    
    //发消息 [下载失败]:
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadfailed" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[_dic_requesFailed allKeys],@"names", nil]];
    
    
    
    //清空还未开始下载和下载失败的请求:
    [_requestListDic removeAllObjects];
    [_dic_requesFailed removeAllObjects];
    
}
-(void)resetNetFlag
{
    _flag_netWrong = 0;
}

-(void)reloadFailed //开始下载之前下载失败的
{
    NSArray *keys = [_dic_requesFailed allKeys];
    for(int i = 0; i < keys.count; i++)
    {
        NSString *key = [keys objectAtIndex:i];
        NSDictionary *userInfo = [_dic_requesFailed objectForKey:key];
        
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"changeGuideStatus" object:nil userInfo:userInfo];
        
        NSLog(@" reloadFailed - userInfo: %@",userInfo);
        [self initRequest:userInfo];
    }
    
    [_dic_requesFailed removeAllObjects];
}


#pragma mark -
#pragma mark --- downloadCancled
-(void)downloadCancled:(id)info
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(downloadCancled:)])
    {
        [self.delegate downloadCancled:info];
    }
}


@end

