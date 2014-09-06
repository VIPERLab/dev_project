//
//  LastMinuteDetail.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-16.
//
//

#import "QYTime.h"
#import "QYAPIClient.h"

#define Setting_ServerTime_Adjust             @"Setting_ServerTime_Adjust"

@implementation QYTime

@synthesize serverTime = _serverTime;

- (id)copyWithZone:(NSZone *)zone
{
    QYTime *time = [[[self class] allocWithZone:zone] init];
    
    time.serverTime = _serverTime;
    
    return time;
}

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            self.serverTime = [NSNumber numberWithInt:[[attribute objectForKey:@"time"] intValue]];
            
        }
    }
    
    return self;
}

- (void)dealloc
{

    QY_SAFE_RELEASE(_serverTime);
    
    [super dealloc];
}

+ (NSArray *)parseFromeDic:(NSDictionary *)dic{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    if([dic objectForKey:@"data"])
    {
        dic = [dic objectForKey:@"data"];
    }
    
    if([dic isKindOfClass:[NSDictionary class]])
    {
        QYTime *time = [[QYTime alloc] initWithAttribute:dic];
        [mutableArray addObject:time];
        [time release];
    
    
    }
    
    return mutableArray;
}

+ (void)getServerTimeSuccess:(QYTimeSuccessBlock)successBlock
                     failure:(QYTimeFailureBlock)failureBlock
{
    
    [[QYAPIClient sharedAPIClient] getServerTimeSuccess:^(NSDictionary *dic) {
        if (successBlock) {
            successBlock([QYTime parseFromeDic:dic]);
        }
        
    } failure:^{
        if (failureBlock) {
            failureBlock();
        }
        
    }];
}

//校准服务器时间
+ (void)checkServerTime
{
    [self getServerTimeSuccess:^(NSArray *data) {
        
        
        QYTime *time = [data objectAtIndex:0];
        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
        
        NSInteger seconds = [time.serverTime intValue] - nowInterval;
        
        NSLog(@"--------seconds:%d", seconds);
        NSLog(@"------------now:%f", nowInterval);
        NSLog(@"-----serverTime:%d", [time.serverTime intValue]);
        
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:[NSNumber numberWithInt:seconds] forKey:Setting_ServerTime_Adjust];
        [settings synchronize];

        
        
        
    } failure:^{

    }];



}

//获得当前时间戳
+ (NSTimeInterval)nowAdjustTimeInterval
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSNumber *timeAdjust = [settings objectForKey:Setting_ServerTime_Adjust];
    
    return [[NSDate date] timeIntervalSince1970]+[timeAdjust intValue];

}

//获得当前时间戳
+ (NSTimeInterval)adjustTimeInterval:(NSTimeInterval)timeInterval
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSNumber *timeAdjust = [settings objectForKey:Setting_ServerTime_Adjust];
    
    return timeInterval-[timeAdjust intValue];
    
}


@end
