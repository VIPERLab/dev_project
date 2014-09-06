//
//  BuyerInfo.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-25.
//
//

#import <Foundation/Foundation.h>

typedef void(^QYBuyerInfoSuccessBlock) (NSArray *data);
typedef void(^QYBuyerInfoDataSuccessBlock) (NSDictionary *dic);
typedef void(^QYBuyerInfoFailureBlock) (void);

@interface BuyerInfo : NSObject
{
    NSNumber        *_buyerInfoId;
    NSString        *_buyerInfoName;
    NSString        *_buyerInfoPhone;
    NSString        *_buyerInfoEmail;
    
}

@property (retain, nonatomic) NSNumber        *buyerInfoId;
@property (retain, nonatomic) NSString        *buyerInfoName;
@property (retain, nonatomic) NSString        *buyerInfoPhone;
@property (retain, nonatomic) NSString        *buyerInfoEmail;

- (id)initWithAttribute:(NSDictionary *)attribute;
//+ (NSArray *)parseFromeData:(NSData *)data;
+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary;

/**
 获取默认购买人信息
 */
+ (void)getBuyerInfoSuccess:(QYBuyerInfoSuccessBlock)successBlock
                    failure:(QYBuyerInfoFailureBlock)failureBlock;

/**
 修改默认购买人信息
 */
+ (void)changeBuyerInfoWithName:(NSString*)aName
                          phone:(NSString*)aPhone
                          email:(NSString*)aEmail
                        Success:(QYBuyerInfoDataSuccessBlock)successBlock
                        failure:(QYBuyerInfoFailureBlock)failureBlock;


@end
