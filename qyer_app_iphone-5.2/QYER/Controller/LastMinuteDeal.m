//
//  LastMinute.m
//  LastMinute
//
//  Created by lide on 13-5-16.
//
//

#import "LastMinuteDeal.h"
#import "QYAPIClient.h"

@implementation LastMinuteDeal

@synthesize lastMinuteId = _lastMinuteId;
@synthesize lastMinutePicture = _lastMinutePicture;
@synthesize lastMinuteTitle = _lastMinuteTitle;
@synthesize lastMinuteDetail = _lastMinuteDetail;
@synthesize lastMinutePrice = _lastMinutePrice;
@synthesize lastMinuteFinishDate = _lastMinuteFinishDate;
@synthesize qyerOnlyFlag = _qyerOnlyFlag;//是否穷游儿独享1-是0-否
@synthesize qyerFirstFlag = _qyerFirstFlag;//是否穷游首发1-是0-否
@synthesize qyerLabAuthFlag = _qyerLabAuthFlag;//是否穷游实验室认证1-是0-否
@synthesize qyerTodayNewFlag = _qyerTodayNewFlag;//是否今日新单1-是0-否
@synthesize lastMinuteDes = _lastMinuteDes;//折扣2.8
@synthesize lastMinutePicture800 = _lastMinutePicture800;

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            self.lastMinuteId = [NSNumber numberWithInt:[[attribute objectForKey:@"id"] intValue]];
            self.lastMinutePicture = [attribute objectForKey:@"pic"];
            self.lastMinuteTitle = [attribute objectForKey:@"title"];
            self.lastMinuteDetail = [attribute objectForKey:@"detail"];
            self.lastMinutePrice = [attribute objectForKey:@"price"];
            self.lastMinuteFinishDate = [attribute objectForKey:@"end_date"];
            self.qyerOnlyFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"self_use"] intValue]];//是否穷游儿独享1-是0-否
            self.qyerFirstFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"first_pub"] intValue]];//是否穷游首发1-是0-否
            self.qyerLabAuthFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"perperty_lab_auth"] intValue]];//是否穷游实验室认证1-是0-否
            self.qyerTodayNewFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"perperty_today_new"] intValue]];//是否今日新单1-是0-否
            self.lastMinuteDes = [attribute objectForKey:@"lastminute_des"];//折扣2.8
            self.lastMinutePicture800 = [attribute objectForKey:@"op_pic1"];
        }
    }
    
    return self;
}

- (void)dealloc
{
    QY_SAFE_RELEASE(_lastMinuteId);
    QY_SAFE_RELEASE(_lastMinutePicture);
    QY_SAFE_RELEASE(_lastMinuteTitle);
    QY_SAFE_RELEASE(_lastMinuteDetail);
    QY_SAFE_RELEASE(_lastMinutePrice);
    QY_SAFE_RELEASE(_lastMinuteFinishDate);
    QY_SAFE_RELEASE(_qyerOnlyFlag);//是否穷游儿独享1-是0-否
    QY_SAFE_RELEASE(_qyerFirstFlag);//是否穷游首发1-是0-否
    QY_SAFE_RELEASE(_qyerLabAuthFlag);//是否穷游实验室认证1-是0-否
    QY_SAFE_RELEASE(_qyerTodayNewFlag);//是否今日新单1-是0-否
    QY_SAFE_RELEASE(_lastMinuteDes);//折扣2.8
    QY_SAFE_RELEASE(_lastMinutePicture800);
    
    [super dealloc];
}

+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
//    NSDictionary *dictionary = (NSDictionary *)[[QYAPIClient sharedAPIClient] responseJSON:data];
    
    if([aDictionary objectForKey:@"data"])
    {
        aDictionary = [aDictionary objectForKey:@"data"];
    }
    
    if([aDictionary isKindOfClass:[NSArray class]])
    {
        for(NSDictionary *attribute in (NSArray *)aDictionary)
        {
            LastMinuteDeal *lastMinute = [[LastMinuteDeal alloc] initWithAttribute:attribute];
            [mutableArray addObject:lastMinute];
            [lastMinute release];
        }
    }
    else if([aDictionary isKindOfClass:[NSDictionary class]])
    {
        if([aDictionary objectForKey:@"LastMinutes"])
        {
            id suppliers = [aDictionary objectForKey:@"LastMinutes"];
            if([suppliers isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *attribute in (NSArray *)suppliers)
                {
                    LastMinuteDeal *lastMinute = [[LastMinuteDeal alloc] initWithAttribute:attribute];
                    [mutableArray addObject:lastMinute];
                    [lastMinute release];
                }
            }
        }
        else
        {
            LastMinuteDeal *lastMinute = [[LastMinuteDeal alloc] initWithAttribute:aDictionary];
            [mutableArray addObject:lastMinute];
            [lastMinute release];
        }
    }
    
    return mutableArray;
}
//
//+ (void)getCommendLastMinuteListSuccess:(QYLastMinuteSuccessBlock)successBlock
//                                failure:(QYLastMinuteFailureBlock)failureBlock
//{
//    [[QYAPIClient sharedAPIClient] getCommendLastMinuteListSuccess:^(NSData *data) {
//        if(successBlock)
//        {
//            successBlock([LastMinute parseFromeData:data]);
//        }
//    } failure:^(NSError *error) {
//        if(failureBlock)
//        {
//            failureBlock(error);
//        }
//    }];
//}
//

//+ (void)getHotLastMinuteListSuccess:(QYLastMinuteSuccessBlock)successBlock
//                       failureBlock:(QYLastMinuteFailureBlock)failureBlock
//{
//    [[QYAPIClient sharedAPIClient]getHotPlaceListSuccess:^(NSDictionary *dic) {
//        
//        NSLog(@"\n==============\n%@\n==========",dic);
//    } failed:^{
//        
//    }];
//    
//    
//}



+ (void)getLastMinuteListWithType:(NSUInteger)type
                            maxId:(NSUInteger)maxId
                         pageSize:(NSUInteger)pageSize
                            times:(NSString *)times
                      continentId:(NSUInteger)continentId
                        countryId:(NSUInteger)countryId
                        departure:(NSString *)departure
                          success:(QYLastMinuteSuccessBlock)successBlock
                          failure:(QYLastMinuteDealFailureBlock)failureBlock
{
    [[QYAPIClient sharedAPIClient] getLastMinuteListWithType:type
                                                       maxId:maxId
                                                    pageSize:pageSize
                                                       times:times
                                                 continentId:continentId
                                                   countryId:countryId
                                                   departure:departure
                                                     success:^(NSDictionary *dic) {
                                                         if(successBlock)
                                                         {
                                                             successBlock([LastMinuteDeal parseFromeDictionary:dic]);
                                                         }
                                                     } failure:^{
                                                         if(failureBlock)
                                                         {
                                                             failureBlock();
                                                         }
                                                     }];
}


//
//+ (void)getLastMinuteFavorListWithMaxId:(NSUInteger)maxId
//                               pageSize:(NSUInteger)pageSize
//                                success:(QYLastMinuteSuccessBlock)successBlock
//                                failure:(QYLastMinuteFailureBlock)failureBlock
//{
//    [[QYAPIClient sharedAPIClient] getLastMinuteFavorListWithMaxId:maxId
//                                                          pageSize:pageSize
//                                                           success:^(NSData *data) {
//                                                               if(successBlock)
//                                                               {
//                                                                   successBlock([LastMinute parseFromeData:data]);
//                                                               }
//                                                           } failure:^(NSError *error) {
//                                                               if(failureBlock)
//                                                               {
//                                                                   failureBlock(error);
//                                                               }
//                                                           }];
//}
//

+ (void)getLastMinuteWithIds:(NSArray *)ids
                     success:(QYLastMinuteSuccessBlock)successBlock
                     failure:(QYLastMinuteDealFailureBlock)failureBlock
{
    [[QYAPIClient sharedAPIClient] getLastMinuteWithIds:ids
                                                success:^(NSDictionary *dic) {
                                                    if(successBlock)
                                                    {
                                                        NSLog(@"didddd is %@",dic);
                                                        if ([dic objectForKey:@"data"]) {
                                                            if ([[dic objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                                                                successBlock([dic objectForKey:@"data"]);

                                                            }
                                                        }
                                                        //successBlock([LastMinuteDeal parseFromeDictionary:dic]);
                                                    }
                                                } failure:^{
                                                    if(failureBlock)
                                                    {
                                                        failureBlock();
                                                    }
                                                }];
}



@end
