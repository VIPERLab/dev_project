//
//  GetHotelNearbyPoi.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-5-27.
//
//

#import "GetHotelNearbyPoi.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "QYAPIClient.h"


#define hasGrade       0     //获取数据时是否对酒店的评星有要求

#define getdatamaxtime 10    //获取POI周边酒店时的请求超时时间



@implementation GetHotelNearbyPoi

@synthesize hotelId = _hotelId;
@synthesize bookingId = _bookingId;
@synthesize bookingUrl = _bookingUrl;
@synthesize chineseName = _chineseName;
@synthesize englishName = _englishName;
@synthesize hotelType = _hotelType;
@synthesize hotelStar = _hotelStar;
@synthesize hotelGrade = _hotelGrade;
@synthesize hotelLowerPrice_Rmb = _hotelLowerPrice_Rmb;
@synthesize hotelPic = _hotelPic;
@synthesize hotelDistance = _hotelDistance;
@synthesize hotelLongitude = _hotelLongitude;
@synthesize hotelLatitude = _hotelLatitude;
@synthesize hotelCurrencyCode = _hotelCurrencyCode;
@synthesize hotelLowerPrice = _hotelLowerPrice;
@synthesize hotelHighPrice = _hotelHighPrice;
@synthesize hotelActualLowerPrice = _hotelActualLowerPrice;
@synthesize getHotelNearbyPoiRequest = _getHotelNearbyPoiRequest;

@synthesize nearby_poi = _nearby_poi;
@synthesize hotel_lat = _hotel_lat;
@synthesize hotel_lon = _hotel_lon;
@synthesize currency = _currency;


-(void)dealloc
{
    self.hotelId = nil;
    self.bookingId = nil;
    self.bookingUrl = nil;
    self.chineseName = nil;
    self.englishName = nil;
    self.hotelType = nil;
    self.hotelStar = nil;
    self.hotelGrade = nil;
    self.hotelLowerPrice_Rmb = nil;
    self.hotelPic = nil;
    self.hotelDistance = nil;
    self.hotelLongitude = nil;
    self.hotelLatitude = nil;
    self.hotelCurrencyCode = nil;
    self.hotelLowerPrice = nil;
    self.hotelHighPrice = nil;
    self.hotelActualLowerPrice = nil;
    
    self.nearby_poi = nil;
    self.hotel_lat = nil;
    self.hotel_lon = nil;
    self.currency = nil;
    
    [super dealloc];
}

-(void)cancle
{
    if(_hasDone == 1)
    {
        [self.getHotelNearbyPoiRequest clearDelegatesAndCancel];
    }
}

-(void)getHotelNearbyPoiByClientid:(NSString *)client_id
                  andClientSecrect:(NSString *)client_secrect
                          andPoiId:(NSInteger)poiId
                          andCount:(NSInteger)count
                          andGrade:(float)grade
                          finished:(getHotelNearbyPoiFinishedBlock)finished
                            failed:(getHotelNearbyPoiFailedBlock)failed
{
    _hasDone = 1;
    
    if(hasGrade)
    {
        _getHotelNearbyPoiRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/poi/get_near_hotel?client_id=%@&client_secret=%@&poi_id=%d&count=%d&grade=%f",@"http://open.qyer.com",client_id,client_secrect,poiId,count,grade]]];
    }
    else
    {
        _getHotelNearbyPoiRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/poi/get_near_hotel?client_id=%@&client_secret=%@&poi_id=%d&count=%d",@"http://open.qyer.com",client_id,client_secrect,poiId,count]]];
    }
    _getHotelNearbyPoiRequest.timeOutSeconds = getdatamaxtime;
    MYLog(@"url ==GetHotelNearbyPoi== %@",[_getHotelNearbyPoiRequest.url absoluteString]);
    
    
    [_getHotelNearbyPoiRequest setCompletionBlock:^{
        
        _hasDone = 0;
        
        NSString *result = [_getHotelNearbyPoiRequest responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            MYLog(@"获取GetHotelNearbyPoi数据成功");
            
            if([[result JSONValue] valueForKey:@"data"] && ![[[result JSONValue] valueForKey:@"data"] isKindOfClass:[NSNull class]] && [[[result JSONValue] valueForKey:@"data"] isKindOfClass:[NSArray class]] && [[[result JSONValue] valueForKey:@"data"] count] > 0)
            {
                NSArray *array = [[result JSONValue] valueForKey:@"data"];
                NSArray *array_out = [self produceData:array];
                
                finished(array_out);
            }
            else
            {
                MYLog(@"GetHotelNearbyPoi没有数据");
                failed();
            }
        }
        else
        {
            if([_getHotelNearbyPoiRequest.error.localizedDescription rangeOfString:@"timed out"].location != NSNotFound)
            {
                MYLog(@"请求GetHotelNearbyPoi数据超时 ~~~");
                failed();
            }
            else
            {
                MYLog(@"获取GetHotelNearbyPoi数据失败");
                failed();
            }
        }
        
    }];
    
    [_getHotelNearbyPoiRequest setFailedBlock:^{
        MYLog(@"获取GetHotelNearbyPoi失败");
        _hasDone = 0;
        failed();
    }];
    [_getHotelNearbyPoiRequest startAsynchronous];
}


-(NSArray *)produceData:(NSArray *)array
{
    if(array && [array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        NSMutableArray *hotelNearbyDataArray = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [array count]; i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            if(dic && [dic count] > 0)
            {
                GetHotelNearbyPoi *hotelNearby = [[GetHotelNearbyPoi alloc] init];
                
                hotelNearby.hotelId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
                hotelNearby.bookingId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"booking_id"]];
                hotelNearby.bookingUrl = [dic objectForKey:@"booking_url"];
                hotelNearby.chineseName = [dic objectForKey:@"cn_name"];
                hotelNearby.englishName = [dic objectForKey:@"en_name"];
                hotelNearby.hotelType = [NSString stringWithFormat:@"%@",[dic objectForKey:@"type"]];
                
                if([dic objectForKey:@"star"])
                {
                    if([[dic objectForKey:@"star"] isEqualToString:@"1"])
                    {
                        hotelNearby.hotelStar = @"一星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"2"])
                    {
                        hotelNearby.hotelStar = @"二星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"3"])
                    {
                        hotelNearby.hotelStar = @"三星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"4"])
                    {
                        hotelNearby.hotelStar = @"四星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"5"])
                    {
                        hotelNearby.hotelStar = @"五星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"6"])
                    {
                        hotelNearby.hotelStar = @"六星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"7"])
                    {
                        hotelNearby.hotelStar = @"七星级";
                    }
                    else
                    {
                        hotelNearby.hotelStar = @"暂无星级";
                    }
                }
                else
                {
                    hotelNearby.hotelStar = @"暂无星级";
                }
                hotelNearby.hotelGrade = [dic objectForKey:@"grade"];
                hotelNearby.hotelLowerPrice_Rmb = [dic objectForKey:@"lower_price_rmb"];
                hotelNearby.hotelPic = [dic objectForKey:@"pic"];
                hotelNearby.hotelDistance = [NSString stringWithFormat:@"%@",[dic objectForKey:@"distance"]];
                hotelNearby.hotelLongitude = [NSString stringWithFormat:@"%@",[dic objectForKey:@"longitude"]];
                hotelNearby.hotelLatitude = [NSString stringWithFormat:@"%@",[dic objectForKey:@"latitude"]];
                hotelNearby.hotelCurrencyCode = [dic objectForKey:@"currencycode"];
                hotelNearby.hotelLowerPrice = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lower_price"]];
                hotelNearby.hotelHighPrice = [NSString stringWithFormat:@"%@",[dic objectForKey:@"high_price"]];
                hotelNearby.hotelActualLowerPrice = [NSString stringWithFormat:@"%@",[dic objectForKey:@"actual_lower_price"]];
                
                [hotelNearbyDataArray addObject:hotelNearby];
                [hotelNearby release];
            }
        }
        
        return [hotelNearbyDataArray autorelease];
    }
    else
    {
        return  nil;
    }
}



//
//
// ------- 新接口 2014.08.06

-(void)getNearByHotelWithPoiId:(NSInteger)poiId
                  andPageCount:(NSString *)pageCount
                       andPage:(NSString *)page
                      finished:(getHotelNearbyPoiFinishedBlock)finished
                        failed:(getHotelNearbyPoiFailedBlock)failed
{
    [[QYAPIClient sharedAPIClient] getNearByHotelWithPoiId:poiId
                                              andPageCount:pageCount
                                                   andPage:page
                                                  success:^(NSDictionary *dic){
                                                      
                                                      NSArray *array = [dic objectForKey:@"data"];
                                                      if(array && array.count > 0)
                                                      {
                                                          NSArray *array_out = [self produceHotelData:array];
                                                          finished(array_out);
                                                      }
                                                      else
                                                      {
                                                          failed();
                                                      }
                                                  } failed:^(NSError *error){
                                                      failed();
                                                  }];
}
-(NSArray *)produceHotelData:(NSArray *)array
{
    if(array && [array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        NSMutableArray *hotelNearbyDataArray = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [array count]; i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            if(dic && [dic count] > 0)
            {
                GetHotelNearbyPoi *hotelNearby = [[GetHotelNearbyPoi alloc] init];
                
                hotelNearby.hotelId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
                hotelNearby.bookingId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"booking_id"]];
                hotelNearby.bookingUrl = [dic objectForKey:@"booking_url"];
                hotelNearby.chineseName = [dic objectForKey:@"chinesename"];
                hotelNearby.englishName = [dic objectForKey:@"englishname"];
                hotelNearby.hotelType = [NSString stringWithFormat:@"%@",[dic objectForKey:@"type"]];
                
                if([dic objectForKey:@"star"])
                {
                    if([[dic objectForKey:@"star"] isEqualToString:@"1"])
                    {
                        hotelNearby.hotelStar = @"一星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"2"])
                    {
                        hotelNearby.hotelStar = @"二星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"3"])
                    {
                        hotelNearby.hotelStar = @"三星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"4"])
                    {
                        hotelNearby.hotelStar = @"四星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"5"])
                    {
                        hotelNearby.hotelStar = @"五星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"6"])
                    {
                        hotelNearby.hotelStar = @"六星级";
                    }
                    else if([[dic objectForKey:@"star"] isEqualToString:@"7"])
                    {
                        hotelNearby.hotelStar = @"七星级";
                    }
                    else
                    {
                        hotelNearby.hotelStar = @"暂无星级";
                    }
                }
                else
                {
                    hotelNearby.hotelStar = @"暂无星级";
                }
                hotelNearby.hotelGrade = [dic objectForKey:@"grade"];
                hotelNearby.hotelLowerPrice_Rmb = [dic objectForKey:@"lower_price_rmb"];
                hotelNearby.hotelPic = [dic objectForKey:@"photo"];
                hotelNearby.hotelDistance = [NSString stringWithFormat:@"%@",[dic objectForKey:@"distance"]];
                hotelNearby.hotelLongitude = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lng"]];
                hotelNearby.hotelLatitude = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lat"]];
                hotelNearby.hotelCurrencyCode = [dic objectForKey:@"currencycode"];
                hotelNearby.hotelLowerPrice = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lower_price"]];
                hotelNearby.hotelHighPrice = [NSString stringWithFormat:@"%@",[dic objectForKey:@"high_price"]];
                hotelNearby.hotelActualLowerPrice = [NSString stringWithFormat:@"%@",[dic objectForKey:@"actual_lower_price"]];
                hotelNearby.nearby_poi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"nearby_poi"]];
                hotelNearby.currency = [NSString stringWithFormat:@"%@",[dic objectForKey:@"currency"]];
                
                [hotelNearbyDataArray addObject:hotelNearby];
                [hotelNearby release];
            }
        }
        
        return [hotelNearbyDataArray autorelease];
    }
    else
    {
        return  nil;
    }
}

@end


