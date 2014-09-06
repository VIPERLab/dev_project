//
//  GetHotelNearbyPoi.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-5-27.
//
//

#import <Foundation/Foundation.h>
@class ASIHTTPRequest;


#if NS_BLOCKS_AVAILABLE
typedef void (^getHotelNearbyPoiFinishedBlock)(NSArray *array);
typedef void (^getHotelNearbyPoiFailedBlock)(void);
#endif



@interface GetHotelNearbyPoi : NSObject
{
    NSString        *_hotelId;//酒店 id
    NSString        *_chineseName;//酒店中文名称
    NSString        *_englishName;//酒店英文名称
    NSString        *_bookingId;//book 网站的链接
    NSString        *_bookingUrl;//book 网站的链接
    NSString        *_hotelType;
    NSString        *_hotel_lat;
    NSString        *_hotel_lon;
    NSString        *_hotelStar;
    NSString        *_hotelGrade;
    NSString        *_currency; //币种
    NSString        *_hotelLowerPrice;
    NSString        *_hotelHighPrice;
    NSString        *_hotelActualLowerPrice;
    NSString        *_hotelPic;
    NSString        *_hotelDistance;
    NSString        *_nearby_poi;
    
    
    NSString        *_hotelLowerPrice_Rmb;
    NSString        *_hotelLongitude;
    NSString        *_hotelLatitude;
    NSString        *_hotelCurrencyCode;
    
    __block ASIHTTPRequest  *_getHotelNearbyPoiRequest;
    BOOL            _hasDone;                   //一次获取数据是否完成
    
}

@property(nonatomic,retain)  NSString       *hotelId;
@property(nonatomic,retain)  NSString       *bookingId;
@property(nonatomic,retain)  NSString       *bookingUrl;
@property(nonatomic,retain)  NSString       *chineseName;
@property(nonatomic,retain)  NSString       *englishName;
@property(nonatomic,retain)  NSString       *hotelType;
@property(nonatomic,retain)  NSString       *hotelStar;
@property(nonatomic,retain)  NSString       *hotelGrade;
@property(nonatomic,retain)  NSString       *hotelLowerPrice_Rmb;
@property(nonatomic,retain)  NSString       *hotelPic;
@property(nonatomic,retain)  NSString       *hotelDistance;
@property(nonatomic,retain)  NSString       *hotelLongitude;
@property(nonatomic,retain)  NSString       *hotelLatitude;
@property(nonatomic,retain)  NSString       *hotelCurrencyCode;
@property(nonatomic,retain)  NSString       *hotelLowerPrice;
@property(nonatomic,retain)  NSString       *hotelHighPrice;
@property(nonatomic,retain)  NSString       *hotelActualLowerPrice;

@property(nonatomic,retain)  NSString       *nearby_poi;
@property(nonatomic,retain)  NSString       *hotel_lat;
@property(nonatomic,retain)  NSString       *hotel_lon;
@property(nonatomic,retain)  NSString       *currency;


@property(nonatomic,retain)  ASIHTTPRequest *getHotelNearbyPoiRequest;


-(void)cancle;
-(void)getHotelNearbyPoiByClientid:(NSString *)client_id
                  andClientSecrect:(NSString *)client_secrect
                          andPoiId:(NSInteger)poiId
                          andCount:(NSInteger)count
                          andGrade:(float)grade
                          finished:(getHotelNearbyPoiFinishedBlock)finished
                            failed:(getHotelNearbyPoiFailedBlock)failed;

-(void)getNearByHotelWithPoiId:(NSInteger)poiId
                  andPageCount:(NSString *)pageCount
                       andPage:(NSString *)page
                      finished:(getHotelNearbyPoiFinishedBlock)finished
                        failed:(getHotelNearbyPoiFailedBlock)failed;

@end

