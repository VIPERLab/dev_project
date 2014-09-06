//
//  LastMinute.h
//  LastMinute
//
//  Created by lide on 13-5-16.
//
//

#import <Foundation/Foundation.h>

typedef void(^QYLastMinuteSuccessBlock) (NSArray *data);
typedef void(^QYLastMinuteDealFailureBlock) (void);//(NSError *error);//

@interface LastMinuteDeal : NSObject
{
    NSNumber    *_lastMinuteId;
    NSString    *_lastMinutePicture;
    NSString    *_lastMinuteTitle;
    NSString    *_lastMinuteDetail;
    NSString    *_lastMinutePrice;
    NSString    *_lastMinuteFinishDate;
    NSNumber    *_qyerOnlyFlag;//是否穷游儿独享1-是0-否
    NSNumber    *_qyerFirstFlag;//是否穷游首发1-是0-否
    NSNumber    *_qyerLabAuthFlag;//是否穷游实验室认证1-是0-否
    NSNumber    *_qyerTodayNewFlag;//是否今日新单1-是0-否
    NSString    *_lastMinuteDes;//折扣2.8
    NSString    *_lastMinutePicture800;
}

@property (retain, nonatomic) NSNumber *lastMinuteId;
@property (retain, nonatomic) NSString *lastMinutePicture;
@property (retain, nonatomic) NSString *lastMinuteTitle;
@property (retain, nonatomic) NSString *lastMinuteDetail;
@property (retain, nonatomic) NSString *lastMinutePrice;
@property (retain, nonatomic) NSString *lastMinuteFinishDate;
@property (retain, nonatomic) NSNumber *qyerOnlyFlag;//是否穷游儿独享1-是0-否
@property (retain, nonatomic) NSNumber *qyerFirstFlag;//是否穷游首发1-是0-否
@property (retain, nonatomic) NSNumber *qyerLabAuthFlag;//是否T1-是0-否
@property (retain, nonatomic) NSNumber *qyerTodayNewFlag;//是否今日新单1-是0-否
@property (retain, nonatomic) NSString *lastMinuteDes;//折扣2.8
@property (retain, nonatomic) NSString *lastMinutePicture800;

- (id)initWithAttribute:(NSDictionary *)attribute;
//+ (NSArray *)parseFromeData:(NSData *)data;
+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary;

//+ (void)getCommendLastMinuteListSuccess:(QYLastMinuteSuccessBlock)successBlock
//                                failure:(QYLastMinuteFailureBlock)failureBlock;

//+ (void)getLastMinuteListWithType:(NSUInteger)type
//                            maxId:(NSUInteger)maxId
//                         pageSize:(NSUInteger)pageSize
//                          success:(QYLastMinuteSuccessBlock)successBlock
//                          failure:(QYLastMinuteFailureBlock)failureBlock;

//+ (void)getHotLastMinuteListSuccess:(QYLastMinuteSuccessBlock)successBlock
//                       failureBlock:(QYLastMinuteFailureBlock)failureBlock;

+ (void)getLastMinuteListWithType:(NSUInteger)type
                            maxId:(NSUInteger)maxId
                         pageSize:(NSUInteger)pageSize
                            times:(NSString *)times
                      continentId:(NSUInteger)continentId
                        countryId:(NSUInteger)countryId
                        departure:(NSString *)departure
                          success:(QYLastMinuteSuccessBlock)successBlock
                          failure:(QYLastMinuteDealFailureBlock)failureBlock;

//+ (void)getLastMinuteFavorListWithMaxId:(NSUInteger)maxId
//                               pageSize:(NSUInteger)pageSize
//                                success:(QYLastMinuteSuccessBlock)successBlock
//                                failure:(QYLastMinuteFailureBlock)failureBlock;

+ (void)getLastMinuteWithIds:(NSArray *)ids
                     success:(QYLastMinuteSuccessBlock)successBlock
                     failure:(QYLastMinuteDealFailureBlock)failureBlock;

@end
