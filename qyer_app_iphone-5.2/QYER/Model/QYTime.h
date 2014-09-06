//
//  LastMinuteDetail.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-16.
//
//

#import <Foundation/Foundation.h>

#define Time_One_Minute                       60

typedef void(^QYTimeSuccessBlock) (NSArray *data);
typedef void(^QYTimeFailureBlock) (void);

@interface QYTime : NSObject <NSCopying>
{

    NSNumber        *_serverTime;

}

@property (retain, nonatomic) NSNumber *serverTime;

- (id)initWithAttribute:(NSDictionary *)attribute;
//+ (NSArray *)parseFromeData:(NSData *)data;

//获得服务器时间
+ (void)getServerTimeSuccess:(QYTimeSuccessBlock)successBlock
                     failure:(QYTimeFailureBlock)failureBlock;


//校准服务器时间
+ (void)checkServerTime;

//获得当前时间戳
+ (NSTimeInterval)nowAdjustTimeInterval;

//获得当前时间戳
+ (NSTimeInterval)adjustTimeInterval:(NSTimeInterval)timeInterval;




@end
