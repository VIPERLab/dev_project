//
//  GetPoiDetailInfo.m
//  QyGuide
//
//  Created by an qing on 13-2-21.
//
//

#import "GetPoiDetailInfo.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "CachePoiData.h"
#import "QYAPIClient.h"


#define getdatamaxtime  10    //获取POI详细信息的请求超时时间


@implementation GetPoiDetailInfo
@synthesize picUrl = _picUrl;
@synthesize duration = _duration;
@synthesize commentRate = _commentRate;
@synthesize commentNum = _commentNum;
@synthesize address = _address;
@synthesize wayTo = _wayTo;
@synthesize openTime = _openTime;
@synthesize ticketPrice = _ticketPrice;
@synthesize telephone = _telephone;
@synthesize website = _website;
@synthesize tips = _tips;
@synthesize detailInfo = _detailInfo;
@synthesize overallMerit = _overallMerit;
@synthesize getPoiDetailInfoRequest = _getPoiDetailInfoRequest;


-(void)dealloc
{
    [_picUrl release];
    [_duration release];
    [_commentRate release];
    [_commentNum release];
    [_address release];
    [_wayTo release];
    [_openTime release];
    [_ticketPrice release];
    [_telephone release];
    [_website release];
    [_tips release];
    [_detailInfo release];
    [_cate_name release];
    [_overallMerit release];
    ////////////[_poiInfoDataDic release];
    
    [super dealloc];
}

-(void)cancle
{
    if(_hasDone == 1)
    {
        [self.getPoiDetailInfoRequest clearDelegatesAndCancel];
    }
}

-(void)getPoiDetailInfoByClientid:(NSString *)client_id
                 andClientSecrect:(NSString *)client_secrect
                            poiId:(NSInteger)poiId
                         finished:(getPoiDetailInfoFinishedBlock)finished
                           failed:(getPoiDetailInfoFailedBlock)failed
{
    _hasDone = 1;
    
    
    [[QYAPIClient sharedAPIClient] getPoiDetailInfoByClientid:client_id
                                             andClientSecrect:client_secrect
                                                        poiId:poiId
                                                     finished:^(NSDictionary *dic){
                                                         _hasDone = 0;
                                                         
                                                         dic = [dic objectForKey:@"data"];
                                                         if(dic && [dic count] > 0)
                                                         {
                                                             NSLog(@"dic:%@",dic);
                                                             finished(dic);
                                                         }
                                                         else
                                                         {
                                                             MYLog(@"  getPoiDetailInfo 暂无数据 ~~~ ");
                                                             failed();
                                                         }
                                                         
                                                     }
                                                       failed:^{
                                                           NSLog(@"  获取数据poidetailinfo失败");
                                                           _hasDone = 0;
                                                           failed();
                                                       }];
}


@end

