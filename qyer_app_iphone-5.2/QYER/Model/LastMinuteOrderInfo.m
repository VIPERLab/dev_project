//
//  LastMinuteDetail.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-16.
//
//

#import "LastMinuteOrderInfo.h"
#import "QYAPIClient.h"
#import "LastMinuteProduct.h"

@implementation LastMinuteOrderInfo


@synthesize orderInfoId = _orderInfoId;
@synthesize orderInfoTitle = _orderInfoTitle;
@synthesize orderInfoPicUrl = _orderInfoPicUrl;
@synthesize orderInfoPrice = _orderInfoPrice;

@synthesize orderInfoBuyerInfoName = _orderInfoBuyerInfoName;
@synthesize orderInfoBuyerInfoPhone = _orderInfoBuyerInfoPhone;
@synthesize orderInfoBuyerInfoEmail = _orderInfoBuyerInfoEmail;

@synthesize orderInfoProductsArray = _orderInfoProductsArray;

- (id)copyWithZone:(NSZone *)zone
{
    LastMinuteOrderInfo *orderInfo = [[[self class] allocWithZone:zone] init];
    
    orderInfo.orderInfoId = _orderInfoId;
    orderInfo.orderInfoTitle = _orderInfoTitle;
    orderInfo.orderInfoPicUrl = _orderInfoPicUrl;
    orderInfo.orderInfoPrice = _orderInfoPrice;
    
    orderInfo.orderInfoBuyerInfoName = _orderInfoBuyerInfoName;
    orderInfo.orderInfoBuyerInfoPhone = _orderInfoBuyerInfoPhone;
    orderInfo.orderInfoBuyerInfoEmail = _orderInfoBuyerInfoEmail;
    
    orderInfo.orderInfoProductsArray = _orderInfoProductsArray;

    return orderInfo;
}

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            
            self.orderInfoId = [NSNumber numberWithInt:[[attribute objectForKey:@"id"] intValue]];
            self.orderInfoTitle = [attribute objectForKey:@"title"];
            self.orderInfoPicUrl = [attribute objectForKey:@"pic"];
            self.orderInfoPrice = [attribute objectForKey:@"price"];
            
            self.orderInfoBuyerInfoName = [attribute objectForKey:@"buyerinfo_name"];
            self.orderInfoBuyerInfoPhone = [attribute objectForKey:@"buyerinfo_phone"];
            self.orderInfoBuyerInfoEmail = [attribute objectForKey:@"buyerinfo_email"];
            
            NSArray *productsArr = [attribute objectForKey:@"products"];
            NSMutableArray *productsArray = [[NSMutableArray alloc] init];
            for (int i=0; i<[productsArr count]; i++) {
                
                NSDictionary *dic = [productsArr objectAtIndex:i];
                
                LastMinuteProduct *product = [[LastMinuteProduct alloc] init];
                product.productId = [NSNumber numberWithInt:[[dic objectForKey:@"id"] intValue]];
                product.productCid = [NSNumber numberWithInt:[[dic objectForKey:@"cid"] intValue]];
                product.productTitle = [dic objectForKey:@"title"];
                product.productStock = [[dic objectForKey:@"stock"] respondsToSelector:@selector(intValue)]?[NSNumber numberWithInt:[[dic objectForKey:@"stock"] intValue]]:[NSNumber numberWithInt:0];
                product.productBuyLimit = [NSNumber numberWithInt:[[dic objectForKey:@"buy_limit"] intValue]];
                product.productType = [[dic objectForKey:@"type"] intValue];
                product.productPrice = [dic objectForKey:@"product_price"];
                product.currentBuyCount = kDefaultBuyCount;//默认购买数为1
                
                if (i==0) {
                    product.isSelected = YES;//默认选中第一个产品
                }
                
                if ([product.productStock intValue]>0) {
                    [productsArray addObject:product];
                }
                
                [product release];
                
                
            }
            
            self.orderInfoProductsArray = productsArray;
            [productsArray release];
            
            

        }
    }
    
    return self;
}

- (void)dealloc
{
    QY_SAFE_RELEASE(_orderInfoId);
    QY_SAFE_RELEASE(_orderInfoTitle);
    QY_SAFE_RELEASE(_orderInfoPicUrl);
    QY_SAFE_RELEASE(_orderInfoPrice);
    
    QY_SAFE_RELEASE(_orderInfoBuyerInfoName);
    QY_SAFE_RELEASE(_orderInfoBuyerInfoPhone);
    QY_SAFE_RELEASE(_orderInfoBuyerInfoEmail);
    
    QY_SAFE_RELEASE(_orderInfoProductsArray);

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
            LastMinuteOrderInfo *orderInfo = [[LastMinuteOrderInfo alloc] initWithAttribute:attribute];
            [mutableArray addObject:orderInfo];
            [orderInfo release];
        }
    }
    else if([aDictionary isKindOfClass:[NSDictionary class]])
    {
        LastMinuteOrderInfo *orderInfo = [[LastMinuteOrderInfo alloc] initWithAttribute:aDictionary];
        [mutableArray addObject:orderInfo];
        [orderInfo release];

    }
    
    return mutableArray;
}

+ (void)getLastMinuteOrderInfoWithId:(NSUInteger)lastMinuteId
                             success:(QYLastMinuteOrderInfoSuccessBlock)successBlock
                             failure:(QYLastMinuteOrderInfoFailureBlock)failureBlock
{
    [[QYAPIClient sharedAPIClient] getLastMinuteOrderInfoWithId:lastMinuteId
                                                        success:^(NSDictionary *dic) {
                                                            if(successBlock)
                                                            {
                                                                successBlock([LastMinuteOrderInfo parseFromeDictionary:dic]);
                                                            }
                                                        }
                                                        failure:^(NSError *error){
                                                            if(failureBlock)
                                                            {
                                                                failureBlock(error);
                                                            }
                                                        }];
}

@end
