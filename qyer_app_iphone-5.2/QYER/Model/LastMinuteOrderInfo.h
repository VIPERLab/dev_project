//
//  LastMinuteDetail.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-16.
//
//

#import <Foundation/Foundation.h>

typedef void(^QYLastMinuteOrderInfoSuccessBlock) (NSArray *data);
typedef void(^QYLastMinuteOrderInfoFailureBlock) (NSError *error);//(void);

@interface LastMinuteOrderInfo : NSObject <NSCopying>
{
    
    NSNumber        *_orderInfoId;
    NSString        *_orderInfoTitle;
    NSString        *_orderInfoPicUrl;
    NSString        *_orderInfoPrice;
    
    NSString        *_orderInfoBuyerInfoName;//默认购买人姓名
    NSString        *_orderInfoBuyerInfoPhone;//默认购买人电话
    NSString        *_orderInfoBuyerInfoEmail;//默认购买人邮箱
    
    NSArray         *_orderInfoProductsArray;
    
}

@property (retain, nonatomic) NSNumber *orderInfoId;
@property (retain, nonatomic) NSString *orderInfoTitle;
@property (retain, nonatomic) NSString *orderInfoPicUrl;
@property (retain, nonatomic) NSString *orderInfoPrice;

@property (retain, nonatomic) NSString *orderInfoBuyerInfoName;
@property (retain, nonatomic) NSString *orderInfoBuyerInfoPhone;
@property (retain, nonatomic) NSString *orderInfoBuyerInfoEmail;

@property (retain, nonatomic) NSArray  *orderInfoProductsArray;






- (id)initWithAttribute:(NSDictionary *)attribute;
//+ (NSArray *)parseFromeData:(NSData *)data;
+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary;

+ (void)getLastMinuteOrderInfoWithId:(NSUInteger)lastMinuteId
                             success:(QYLastMinuteOrderInfoSuccessBlock)successBlock
                             failure:(QYLastMinuteOrderInfoFailureBlock)failureBlock;

@end
