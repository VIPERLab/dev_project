//
//  LastMinuteDetail.h
//  LastMinute
//
//  Created by lide(蔡小雨) on 13-5-16.
//
//

#import <Foundation/Foundation.h>


typedef enum {
    BookTypeNotPay = 0,
    BookTypePay = 1
} BookType;

typedef enum {
    OnsaleTypeOff = 0,//下架
    OnsaleTypeOn = 1//在售
} OnsaleType;

typedef void(^QYLastMinuteDetailSuccessBlock) (NSArray *data);
typedef void(^QYLastMinuteDetailFailureBlock) (void);

@interface LastMinuteDetail : NSObject <NSCopying>
{
    NSNumber        *_lastMinuteId;
    NSString        *_lastMinutePicture;
    NSString        *_lastMinuteTitle;
    NSString        *_lastMinuteDetail;
    NSString        *_lastMinutePrice;
    NSString        *_lastMinuteFinishDate;
    NSString        *_lastMinuteDiscountCode;
    NSNumber        *_qyerOnlyFlag;
    NSNumber        *_qyerFirstFlag;
    NSNumber        *_loginVisibleFlag;
    NSArray         *_detailPictureArray;
    NSArray         *_dateilThumbnailArray;
    NSNumber        *_orderType;
    NSArray         *_orderInfoArray;
    NSArray         *_orderTitleArray;
    NSArray         *_relatedArray;
    NSString        *_dealInfo;
    NSString        *_useIf;
    NSString        *_qyerURL;
    NSString        *_sharePrice;
    NSNumber        *_favoredFlag;
    
    //new
    NSString        *_app_url;
    BookType         _app_booktype;
    NSNumber        *_app_startDate;
    NSNumber        *_app_endDate;
    NSNumber        *_app_firstpayStartTime;
    NSNumber        *_app_firstpayEndTime;
    NSNumber        *_app_secondpaypayStartTime;
    NSNumber        *_app_secondpaypayEndTime;
    NSNumber        *_app_stock;
    OnsaleType       _onsaleType;
}

@property (retain, nonatomic) NSNumber          *lastMinuteId;
@property (retain, nonatomic) NSString          *lastMinutePicture;
@property (retain, nonatomic) NSString          *lastMinuteTitle;
@property (retain, nonatomic) NSString          *lastMinuteDetail;
@property (retain, nonatomic) NSString          *lastMinutePrice;
@property (retain, nonatomic) NSString          *lastMinuteFinishDate;
@property (retain, nonatomic) NSString          *lastMinuteDiscountCode;
@property (retain, nonatomic) NSNumber          *qyerOnlyFlag;
@property (retain, nonatomic) NSNumber          *qyerFirstFlag;
@property (retain, nonatomic) NSNumber          *loginVisibleFlag;
@property (retain, nonatomic) NSArray           *detailPictureArray;
@property (retain, nonatomic) NSArray           *detailThumbnailArray;
@property (retain, nonatomic) NSNumber          *orderType;
@property (retain, nonatomic) NSArray           *orderInfoArray;
@property (retain, nonatomic) NSArray           *orderTitleArray;
@property (retain, nonatomic) NSArray           *relatedArray;
@property (retain, nonatomic) NSString          *dealInfo;
@property (retain, nonatomic) NSString          *useIf;
@property (retain, nonatomic) NSString          *qyerURL;
@property (retain, nonatomic) NSString          *sharePrice;
@property (retain, nonatomic) NSNumber          *favoredFlag;

//new
@property (retain, nonatomic) NSString          *app_url;
@property (assign, nonatomic) BookType           app_booktype;
@property (retain, nonatomic) NSNumber          *app_startDate;
@property (retain, nonatomic) NSNumber          *app_endDate;
@property (retain, nonatomic) NSNumber          *app_firstpayStartTime;
@property (retain, nonatomic) NSNumber          *app_firstpayEndTime;
@property (retain, nonatomic) NSNumber          *app_secondpaypayStartTime;
@property (retain, nonatomic) NSNumber          *app_secondpaypayEndTime;
@property (retain, nonatomic) NSNumber          *app_stock;
@property (assign, nonatomic) OnsaleType         onsaleType;





- (id)initWithAttribute:(NSDictionary *)attribute;
//+ (NSArray *)parseFromeData:(NSData *)data;
+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary;

+ (void)getLastMinuteDetailWithId:(NSUInteger)lastMinuteId
                           source:(NSString*)aSource//进入折扣详情页的类名
                          success:(QYLastMinuteDetailSuccessBlock)successBlock
                          failure:(QYLastMinuteDetailFailureBlock)failureBlock;

@end
