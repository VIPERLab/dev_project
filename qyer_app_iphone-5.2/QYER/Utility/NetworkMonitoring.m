//
//  NetworkMonitoring.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-6-14.
//
//

#import "NetworkMonitoring.h"
#import "QYIMObject.h"


#define     NetworkMonitor_domainName   @"www.apple.com"
#define     NetworkMonitor_delayTime    0



@implementation NetworkMonitoring

-(void)dealloc
{
    [_hostReach release];
    [super dealloc];
}


#pragma mark -
#pragma mark --- sharedNetworkMonitoring
static id sharedNetworkMonitoring = nil;
+(NetworkMonitoring *)sharedNetworkMonitoring
{
    if(!sharedNetworkMonitoring)
    {
        sharedNetworkMonitoring = [[self alloc] init];
    }
    return sharedNetworkMonitoring;
}


#pragma mark -
#pragma mark --- NetworkMonitor
-(void)NetworkMonitor //开启网络状况的监听
{
    [self performSelector:@selector(checkNet) withObject:nil afterDelay:NetworkMonitor_delayTime];
    //[self checkNet];
}
-(void)checkNet
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    _hostReach = [[Reachability reachabilityWithHostname:NetworkMonitor_domainName] retain]; //可以以多种形式初始化
    [_hostReach startNotifier];  //开始监听,会启动一个run loop
    
    [self updateInterfaceWithReachability:_hostReach];
}


#pragma mark -
#pragma mark --- 连接改变
-(void)reachabilityChanged: (NSNotification* )note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    [self updateInterfaceWithReachability: curReach];
}


#pragma mark -
#pragma mark --- 处理连接改变后的情况
-(void)updateInterfaceWithReachability: (Reachability*) curReach
{
    //对连接改变做出响应的处理动作:
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable)  //*** 没有连接到网络
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkStatus_NO" object:nil userInfo:nil];
        
        [QYIMObject getInstance].connectStatus = QYIMConnectStatusOffLine;
    }
    else if(status == ReachableViaWiFi)  //*** WiFi网络
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkStatus_WIFI" object:nil userInfo:nil];
        
        if ([QYIMObject getInstance].connectStatus == QYIMConnectStatusOffLine)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reConnectSocket" object:nil];
        }
    }
    else if(status == ReachableViaWWAN)  //*** WWAN网络
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkStatus_WWAN" object:nil userInfo:nil];
        
        if ([QYIMObject getInstance].connectStatus == QYIMConnectStatusOffLine)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reConnectSocket" object:nil];
        }
    }
    else  //*** 特殊情况
    {
        NSLog(@"发生了些意外, 你懂的 ⋯⋯");
    }
}


@end
