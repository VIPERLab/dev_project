//
//  GetPoiDetailInfo.h
//  QyGuide
//
//  Created by an qing on 13-2-21.
//
//

#import <Foundation/Foundation.h>
@class ASIHTTPRequest;


#if NS_BLOCKS_AVAILABLE
typedef void (^getPoiDetailInfoFinishedBlock)(NSDictionary *dic);
typedef void (^getPoiDetailInfoFailedBlock)(void);
#endif



@interface GetPoiDetailInfo : NSObject
{
    NSString   *_picUrl;         //poi图片
    NSString   *_duration;       //poi推荐游玩时间
    NSString   *_commentRate;    //poi的评论星级
    NSString   *_commentNum;     //poi的评论条数
    NSString   *_address;        //poi地址
    NSString   *_wayTo;          //poi的到达方式
    NSString   *_openTime;       //poi的开放时间
    NSString   *_ticketPrice;    //poi门票价格
    NSString   *_telephone;      //poi电话
    NSString   *_website;        //poi网址
    NSString   *_tips;           //poi小贴士
    NSString   *_detailInfo;     //poi简介
    NSString   *_cate_name;      //poi所属分类
    
    NSString   *_overallMerit;   //所有用户对该poi的综合评价
//    NSMutableDictionary *_poiInfoDataDic; //存放这个poi所有详情的数据
    
    __block ASIHTTPRequest *_getPoiDetailInfoRequest;
    BOOL            _hasDone; //一次获取数据是否完成
}

@property(nonatomic,retain) NSString   *picUrl;         //poi图片
@property(nonatomic,retain) NSString   *duration;       //poi推荐游玩时间
@property(nonatomic,retain) NSString   *commentRate;    //poi的评论星级
@property(nonatomic,retain) NSString   *commentNum;     //poi的评论条数
@property(nonatomic,retain) NSString   *address;        //poi地址
@property(nonatomic,retain) NSString   *wayTo;          //poi的到达方式
@property(nonatomic,retain) NSString   *openTime;       //poi的开放时间
@property(nonatomic,retain) NSString   *ticketPrice;    //poi门票价格
@property(nonatomic,retain) NSString   *telephone;      //poi电话
@property(nonatomic,retain) NSString   *website;        //poi网址
@property(nonatomic,retain) NSString   *tips;           //poi小贴士
@property(nonatomic,retain) NSString   *detailInfo;     //poi简介
@property(nonatomic,retain) ASIHTTPRequest *getPoiDetailInfoRequest;

//@property(nonatomic,retain) NSMutableDictionary *poiInfoDataDic;
@property(nonatomic,retain) NSString   *overallMerit;


-(void)cancle;
-(void)getPoiDetailInfoByClientid:(NSString *)client_id
                 andClientSecrect:(NSString *)client_secrect
                            poiId:(NSInteger)poiId
                         finished:(getPoiDetailInfoFinishedBlock)finished
                           failed:(getPoiDetailInfoFailedBlock)failed;

@end

