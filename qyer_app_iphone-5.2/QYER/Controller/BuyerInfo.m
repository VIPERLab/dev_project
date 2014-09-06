//
//  BuyerInfo.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-25.
//
//

#import "BuyerInfo.h"
#import "QYAPIClient.h"

@implementation BuyerInfo

@synthesize buyerInfoId = _buyerInfoId;
@synthesize buyerInfoName = _buyerInfoName;
@synthesize buyerInfoPhone = _buyerInfoPhone;
@synthesize buyerInfoEmail = _buyerInfoEmail;

- (id)copyWithZone:(NSZone *)zone
{
    BuyerInfo *buyerInfo = [[[self class] allocWithZone:zone] init];
    
    buyerInfo.buyerInfoId = _buyerInfoId;
    buyerInfo.buyerInfoName = _buyerInfoName;
    buyerInfo.buyerInfoPhone = _buyerInfoPhone;
    buyerInfo.buyerInfoEmail = _buyerInfoEmail;
    
    return buyerInfo;
}

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            self.buyerInfoId = [NSNumber numberWithInt:[[attribute objectForKey:@"id"] intValue]];
            self.buyerInfoName = [attribute objectForKey:@"name"];
            self.buyerInfoPhone = [attribute objectForKey:@"phone"];
            self.buyerInfoEmail = [attribute objectForKey:@"email"];
            
        }
    }
    
    return self;
}

- (void)dealloc
{
    QY_SAFE_RELEASE(_buyerInfoId);
    QY_SAFE_RELEASE(_buyerInfoName);
    QY_SAFE_RELEASE(_buyerInfoPhone);
    QY_SAFE_RELEASE(_buyerInfoEmail);
    
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
            BuyerInfo *buyerInfo = [[BuyerInfo alloc] initWithAttribute:attribute];
            [mutableArray addObject:buyerInfo];
            [buyerInfo release];
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
                    BuyerInfo *buyerInfo = [[BuyerInfo alloc] initWithAttribute:attribute];
                    [mutableArray addObject:buyerInfo];
                    [buyerInfo release];
                }
            }
        }
        else
        {
            BuyerInfo *buyerInfo = [[BuyerInfo alloc] initWithAttribute:aDictionary];
            [mutableArray addObject:buyerInfo];
            [buyerInfo release];
        }
    }
    
    return mutableArray;
}

/**
 获取默认购买人信息
 */
+ (void)getBuyerInfoSuccess:(QYBuyerInfoSuccessBlock)successBlock
                    failure:(QYBuyerInfoFailureBlock)failureBlock
{
    
    [[QYAPIClient sharedAPIClient] getBuyerInfoSuccess:^(NSDictionary *dic) {
        if(successBlock)
        {
            successBlock([BuyerInfo parseFromeDictionary:dic]);
        }
        
    } failure:^{
        if(failureBlock)
        {
            failureBlock();
        }
        
    }];
    
}

/**
 修改默认购买人信息
 */
+ (void)changeBuyerInfoWithName:(NSString*)aName
                          phone:(NSString*)aPhone
                          email:(NSString*)aEmail
                        Success:(QYBuyerInfoDataSuccessBlock)successBlock
                        failure:(QYBuyerInfoFailureBlock)failureBlock
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%@", aName] forKey:@"name"];
    [params setObject:[NSString stringWithFormat:@"%@", aPhone] forKey:@"phone"];
    [params setObject:[NSString stringWithFormat:@"%@", aEmail] forKey:@"email"];
    
    [[QYAPIClient sharedAPIClient] changeBuyerInfoWithParams:params
                                                     success:^(NSDictionary *dic) {
                                                         if (successBlock) {
                                                             successBlock(dic);
                                                         }
                                                         
                                                     } failure:^{
                                                         if (failureBlock) {
                                                             failureBlock();
                                                         }
                                                         
                                                     }];
    


}


@end
