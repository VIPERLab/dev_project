//
//  LastMinuteDetail.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-16.
//
//

#import "LastMinuteDetail.h"
#import "QYAPIClient.h"

@implementation LastMinuteDetail

@synthesize lastMinuteId = _lastMinuteId;
@synthesize lastMinutePicture = _lastMinutePicture;
@synthesize lastMinuteTitle = _lastMinuteTitle;
@synthesize lastMinuteDetail = _lastMinuteDetail;
@synthesize lastMinutePrice = _lastMinutePrice;
@synthesize lastMinuteFinishDate = _lastMinuteFinishDate;
@synthesize lastMinuteDiscountCode = _lastMinuteDiscountCode;
@synthesize qyerOnlyFlag = _qyerOnlyFlag;
@synthesize qyerFirstFlag = _qyerFirstFlag;
@synthesize loginVisibleFlag = _loginVisibleFlag;
@synthesize detailPictureArray = _detailPictureArray;
@synthesize detailThumbnailArray = _detailThumbnailArray;
@synthesize orderType = _orderType;
@synthesize orderInfoArray = _orderInfoArray;
@synthesize orderTitleArray = _orderTitleArray;
@synthesize relatedArray = _relatedArray;
@synthesize dealInfo = _dealInfo;
@synthesize useIf = _useIf;
@synthesize qyerURL = _qyerURL;
@synthesize sharePrice = _sharePrice;
@synthesize favoredFlag = _favoredFlag;

//new
@synthesize app_url = _app_url;
@synthesize app_booktype = _app_booktype;
@synthesize app_startDate = _app_startDate;
@synthesize app_endDate = _app_endDate;
@synthesize app_firstpayStartTime = _app_firstpayStartTime;
@synthesize app_firstpayEndTime = _app_firstpayEndTime;
@synthesize app_secondpaypayStartTime = _app_secondpaypayStartTime;
@synthesize app_secondpaypayEndTime = _app_secondpaypayEndTime;
@synthesize app_stock = _app_stock;
@synthesize onsaleType = _onsaleType;

- (id)copyWithZone:(NSZone *)zone
{
    LastMinuteDetail *detail = [[[self class] allocWithZone:zone] init];
    
    detail.lastMinuteId = _lastMinuteId;
    detail.lastMinutePicture = _lastMinutePicture;
    detail.lastMinuteTitle = _lastMinuteTitle;
    detail.lastMinuteDetail = _lastMinuteDetail;
    detail.lastMinutePrice = _lastMinutePrice;
    detail.lastMinuteFinishDate = _lastMinuteFinishDate;
    detail.lastMinuteDiscountCode = _lastMinuteDiscountCode;
    detail.qyerOnlyFlag = _qyerOnlyFlag;
    detail.qyerFirstFlag = _qyerFirstFlag;
    detail.loginVisibleFlag = _loginVisibleFlag;
    detail.detailPictureArray = _detailPictureArray;
    detail.detailThumbnailArray = _detailThumbnailArray;
    detail.orderType = _orderType;
    detail.orderInfoArray = _orderInfoArray;
    detail.orderTitleArray = _orderTitleArray;
    detail.relatedArray = _relatedArray;
    detail.dealInfo = _dealInfo;
    detail.useIf = _useIf;
    detail.qyerURL = _qyerURL;
    detail.sharePrice = _sharePrice;
    detail.favoredFlag = _favoredFlag;
    
    //new
    detail.app_url = _app_url;
    detail.app_booktype = _app_booktype;
    detail.app_startDate = _app_startDate;
    detail.app_endDate = _app_endDate;
    detail.app_firstpayStartTime = _app_firstpayStartTime;
    detail.app_firstpayEndTime = _app_firstpayEndTime;
    detail.app_secondpaypayStartTime = _app_secondpaypayStartTime;
    detail.app_secondpaypayEndTime = _app_secondpaypayEndTime;
    detail.app_stock = _app_stock;
    detail.onsaleType = _onsaleType;
    
    return detail;
}

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
            self.lastMinuteDiscountCode = [attribute objectForKey:@"discount_code"];
            self.qyerOnlyFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"self_use"] intValue]];
            self.qyerFirstFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"first_pub"] intValue]];
            self.loginVisibleFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"login_visible"] intValue]];
            NSArray *detailPictureArray = [attribute objectForKey:@"detail_image"];
            if([detailPictureArray isKindOfClass:[NSArray class]])
            {
                self.detailPictureArray = detailPictureArray;
            }
            NSArray *detailThumbnailArray = [attribute objectForKey:@"detail_image180"];
            if([detailThumbnailArray isKindOfClass:[NSArray class]])
            {
                self.detailThumbnailArray = detailThumbnailArray;
            }
            self.orderType = [NSNumber numberWithInt:[[attribute objectForKey:@"order_type"] intValue]];
            NSArray *orderInfoArray = [attribute objectForKey:@"order_info"];
            if([orderInfoArray isKindOfClass:[NSArray class]])
            {
                self.orderInfoArray = orderInfoArray;
            }
            NSArray *orderTitleArray = [attribute objectForKey:@"order_info_txt"];
            if([orderTitleArray isKindOfClass:[NSArray class]])
            {
                self.orderTitleArray = orderTitleArray;
            }
            self.dealInfo = [attribute objectForKey:@"deal_info"];
            self.useIf = [attribute objectForKey:@"use_if"];
            NSArray *relatedArray = [attribute objectForKey:@"related"];
            if([relatedArray isKindOfClass:[NSArray class]])
            {
                self.relatedArray = relatedArray;
            }
            self.qyerURL = [attribute objectForKey:@"qyer_url"];
            NSMutableString *price = [NSMutableString stringWithString:self.lastMinutePrice];
            NSRange frontRange = [price rangeOfString:@"<em>"];
            if(frontRange.length != 0)
            {
                [price deleteCharactersInRange:frontRange];
            }
            NSRange backRange = [price rangeOfString:@"</em>"];
            if(backRange.length != 0)
            {
                [price deleteCharactersInRange:backRange];
            }
            self.sharePrice = price;
            self.favoredFlag = [NSNumber numberWithInt:[[attribute objectForKey:@"favored"] intValue]];
            
            
            //new
            self.app_url = [attribute objectForKey:@"app_url"];;
            self.app_booktype = [[attribute objectForKey:@"app_booktype"] intValue];
            self.app_startDate = [NSNumber numberWithInt:[[attribute objectForKey:@"app_start_date_new"] intValue]];
            self.app_endDate = [NSNumber numberWithInt:[[attribute objectForKey:@"app_end_date_new"] intValue]];
            self.app_firstpayStartTime = [NSNumber numberWithInt:[[attribute objectForKey:@"app_firstpay_start_time"] intValue]];
            self.app_firstpayEndTime = [NSNumber numberWithInt:[[attribute objectForKey:@"app_firstpay_end_time"] intValue]];
            self.app_secondpaypayStartTime = [NSNumber numberWithInt:[[attribute objectForKey:@"app_secondpay_start_time"] intValue]];
            self.app_secondpaypayEndTime = [NSNumber numberWithInt:[[attribute objectForKey:@"app_secondpay_end_time"] intValue]];
            self.app_stock = [attribute objectForKey:@"app_stock"]!=[NSNull null]?[NSNumber numberWithInt:[[attribute objectForKey:@"app_stock"] intValue]]:[NSNumber numberWithInt:0];
            self.onsaleType = [[attribute objectForKey:@"onsale"] intValue];
            
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
    QY_SAFE_RELEASE(_lastMinuteDiscountCode);
    QY_SAFE_RELEASE(_qyerOnlyFlag);
    QY_SAFE_RELEASE(_qyerFirstFlag);
    QY_SAFE_RELEASE(_loginVisibleFlag);
    QY_SAFE_RELEASE(_detailPictureArray);
    QY_SAFE_RELEASE(_detailThumbnailArray);
    QY_SAFE_RELEASE(_orderType);
    QY_SAFE_RELEASE(_orderInfoArray);
    QY_SAFE_RELEASE(_orderTitleArray);
    QY_SAFE_RELEASE(_dealInfo);
    QY_SAFE_RELEASE(_useIf);
    QY_SAFE_RELEASE(_qyerURL);
    QY_SAFE_RELEASE(_sharePrice);
    QY_SAFE_RELEASE(_favoredFlag);
    
    
    //new
    QY_SAFE_RELEASE(_app_url);
    QY_SAFE_RELEASE(_app_startDate);
    QY_SAFE_RELEASE(_app_endDate);
    QY_SAFE_RELEASE(_app_firstpayStartTime);
    QY_SAFE_RELEASE(_app_firstpayEndTime);
    QY_SAFE_RELEASE(_app_secondpaypayStartTime);
    QY_SAFE_RELEASE(_app_secondpaypayEndTime);
    QY_SAFE_RELEASE(_app_stock);
    
    
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
            LastMinuteDetail *detail = [[LastMinuteDetail alloc] initWithAttribute:attribute];
            [mutableArray addObject:detail];
            [detail release];
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
                    LastMinuteDetail *detail = [[LastMinuteDetail alloc] initWithAttribute:attribute];
                    [mutableArray addObject:detail];
                    [detail release];
                }
            }
        }
        else
        {
            LastMinuteDetail *detail = [[LastMinuteDetail alloc] initWithAttribute:aDictionary];
            [mutableArray addObject:detail];
            [detail release];
        }
    }
    
    return mutableArray;
}

+ (void)getLastMinuteDetailWithId:(NSUInteger)lastMinuteId
                           source:(NSString*)aSource//进入折扣详情页的类名
                          success:(QYLastMinuteDetailSuccessBlock)successBlock
                          failure:(QYLastMinuteDetailFailureBlock)failureBlock
{
    [[QYAPIClient sharedAPIClient] getLastMinuteDetailWithId:lastMinuteId
                                                      source:aSource
                                                     success:^(NSDictionary *dic) {
                                                         if(successBlock)
                                                         {
                                                             successBlock([LastMinuteDetail parseFromeDictionary:dic]);
                                                         }
                                                     }
                                                     failure:^{
                                                         if(failureBlock)
                                                         {
                                                             failureBlock();
                                                         }
                                                     }];
}

@end
