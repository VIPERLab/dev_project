//
//  LastMinute.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-15.
//
//

#import "LastMinute.h"
#import "QYAPIClient.h"

@implementation LastMinute
@synthesize str_end_date = _str_end_date;
@synthesize str_id = _str_id;
@synthesize str_m_url = _str_m_url;
@synthesize str_pic = _str_pic;
@synthesize str_price = _str_price;
@synthesize str_title = _str_title;
@synthesize str_web_url = _str_web_url;
@synthesize str_productType = _str_productType;
@synthesize str_detail = _str_detail;

@synthesize qyerOnlyFlag = _qyerOnlyFlag;
@synthesize qyerFirstFlag = _qyerFirstFlag;
@synthesize lastMinutePicture800 = _lastMinutePicture800;

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            self.str_id = [NSString stringWithFormat:@"%d", [[attribute objectForKey:@"id"] intValue]];
            self.str_pic = [attribute objectForKey:@"pic"];
            self.str_title = [attribute objectForKey:@"title"];
            self.str_detail = [attribute objectForKey:@"detail"];
            self.str_price = [attribute objectForKey:@"price"];
            self.str_end_date = [attribute objectForKey:@"end_date"];
            self.qyerOnlyFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"self_use"] intValue]];
            self.qyerFirstFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"first_pub"] intValue]];
            self.lastMinutePicture800 = [attribute objectForKey:@"op_pic1"];
        }
    }
    
    return self;
}

-(void)dealloc
{
    self.str_end_date = nil;
    self.str_id = nil;
    self.str_m_url = nil;
    self.str_pic = nil;
    self.str_price = nil;
    self.str_title = nil;
    self.str_web_url = nil;
    self.str_productType = nil;
    self.str_detail = nil;
    
    self.qyerOnlyFlag = nil;
    self.qyerFirstFlag = nil;
    self.lastMinutePicture800 = nil;
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
            LastMinute *lastMinute = [[LastMinute alloc] initWithAttribute:attribute];
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
                    LastMinute *lastMinute = [[LastMinute alloc] initWithAttribute:attribute];
                    [mutableArray addObject:lastMinute];
                    [lastMinute release];
                }
            }
        }
        else
        {
            LastMinute *lastMinute = [[LastMinute alloc] initWithAttribute:aDictionary];
            [mutableArray addObject:lastMinute];
            [lastMinute release];
        }
    }
    
    return mutableArray;
}


+ (void)getLastMinuteFavorListWithMaxId:(NSUInteger)maxId
                               pageSize:(NSUInteger)pageSize
                                success:(QYLastMinuteSuccessBlock)successBlock
                                failure:(QYLastMinuteFailureBlock)failureBlock
{
    [[QYAPIClient sharedAPIClient] getLastMinuteFavorListWithMaxId:maxId
                                                          pageSize:pageSize
                                                           success:^(NSDictionary *dic) {
                                                               if(successBlock)
                                                               {
                                                                   successBlock([LastMinute parseFromeDictionary:dic]);
                                                               }
                                                           } failure:^{
                                                               if(failureBlock)
                                                               {
                                                                   failureBlock();
                                                               }
                                                           }];
}

@end
