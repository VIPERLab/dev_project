//
//  QYAPIClient.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-4.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^QYApiClientSuccessBlock)(NSDictionary *dic);
typedef void (^QYApiClientFailedBlock)(void);
typedef void (^QYApiClientFailedBlock_detail)(NSString *info);
typedef void (^QYApiClientFailedBlock_Error)(NSError *error);
#endif


@interface QYAPIClient : NSObject
{
    NSMutableDictionary     *_dic_request; //保存request的请求链接
}
@property(nonatomic,retain) NSMutableDictionary     *dic_request;


+(id)sharedAPIClient;


//第三方账号登录验证
-(void)sendSNSToServerWithType:(NSString *)type
                  Access_Token:(NSString *)token
                           UID:(NSString *)userID
                  SNS_Username:(NSString *)userName
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock;

//取消某个请求:
-(void)cancleRequestByUrlString:(NSString *)urlString;


//获取未登录状态下允许下载锦囊的个数:
-(void)getMobileDownloadLimit:(QYApiClientSuccessBlock)successBlock
                       failed:(QYApiClientFailedBlock)failedBlock;

//获取全部锦囊列表:
-(void)getAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime
                                     success:(QYApiClientSuccessBlock)successBlock
                                      failed:(QYApiClientFailedBlock)failedBlock;

//获取已下线的锦囊列表:
-(void)getAllInvalidGuideListSuccess:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock;

//获取某本锦囊的评论列表:
-(void)getGuideCommentByGuideId:(NSInteger)guideId
                       andCount:(NSInteger)count
                       andMaxId:(NSInteger)maxId
                        success:(QYApiClientSuccessBlock)successBlock
                         failed:(QYApiClientFailedBlock)failedBlock;

//获取锦囊分类:
-(void)getGuideCategoryListMobile:(BOOL)bMobile
                     successBlock:(QYApiClientSuccessBlock)successBlock
                      failedBlock:(QYApiClientFailedBlock)failedBlock;

//发送我的评论:
-(void)sendMyCommentByAccessToken:(NSString *)accessToken
                       andGuideId:(NSString *)guideid
                   andCommentText:(NSString *)comment
                         finished:(QYApiClientSuccessBlock)successBlock
                           failed:(QYApiClientFailedBlock_detail)failedBlock;


//获取更多穷游应用:
-(void)getMoreApplicationSuccess:(QYApiClientSuccessBlock)successBlock
                          failed:(QYApiClientFailedBlock)failedBlock;

//获取推送的相关信息:
-(void)getPushDataByClientid:(NSString *)client_id
            andClientSecrect:(NSString *)client_secrect
                andExtend_id:(NSInteger)extend_id
                    finished:(QYApiClientSuccessBlock)successBlock
                      failed:(QYApiClientFailedBlock)failedBlock;


//用户行为统计:
-(void)postUserHabitWithAppId:(NSString *)appId
                andOauthToken:(NSString *)oauthToken
                  andDeviceId:(NSString *)deviceId
                      andData:(NSDictionary *)dic
                     finished:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock;

//用户反馈:
-(void)postUserFeedBackWithContent:(NSString *)content
                          finished:(QYApiClientSuccessBlock)finishedBlock
                            failed:(QYApiClientFailedBlock)failedBlock;



//获取锦囊的最新下载次数:
-(void)getGuideDownloadTimeFinished:(QYApiClientSuccessBlock)finishedBlock
                             failed:(QYApiClientFailedBlock)failedBlock;




// ====================================== V4.0 =====================


//用户添加想去/去过的城市或国家
-(void)addCountryCityPlanOrBeenToWithType:(NSString *)type
                               ID:(NSString *)countryCityID
                           status:(NSString *)status
                          success:(QYApiClientSuccessBlock)finishedBlock
                           failed:(QYApiClientFailedBlock)failedBlock;

//用户取消想去/去过的城市或国家
-(void)removeCountryCityPlanOrBeenToWithType:(NSString *)type
                                       ID:(NSString *)countryCityID
                                   status:(NSString *)status
                                  success:(QYApiClientSuccessBlock)finishedBlock
                                   failed:(QYApiClientFailedBlock)failedBlock;


//获取国家数据:
-(void)getCountryDataByCountryId:(NSString *)str_countryId
                         success:(QYApiClientSuccessBlock)finishedBlock
                          failed:(QYApiClientFailedBlock)failedBlock;

//获取城市数据:
-(void)getCityDataByCityId:(NSString *)str_cityId
                   success:(QYApiClientSuccessBlock)finishedBlock
                    failed:(QYApiClientFailedBlock)failedBlock;

//获取某城市下的poi:
-(void)getCityPoiDataByCityId:(NSString *)str_cityId
                andCategoryId:(NSString *)str_categoryId
                     pageSize:(NSString *)str_pageSize
                         page:(NSString *)str_page
                      success:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock;

//获取某国家／城市下的行程:
-(void)getRecommandPlanListByType:(int )type
                               ID:(NSString *)countryCityID
                           source:(NSString *)fromSource
                             page:(NSString *)pageIndex
                          success:(QYApiClientSuccessBlock)finishedBlock
                           failed:(QYApiClientFailedBlock)failedBlock;


//-(void)getPlanDataOfCountryByCountryId:(NSString *)str_Id
//                              pageSize:(NSString *)str_pageSize
//                                  page:(NSString *)str_page
//                               success:(QYApiClientSuccessBlock)finishedBlock
//                                failed:(QYApiClientFailedBlock)failedBlock;
//
//
//-(void)getPlanDataOfCityByCityId:(NSString *)str_Id
//                        pageSize:(NSString *)str_pageSize
//                            page:(NSString *)str_page
//                         success:(QYApiClientSuccessBlock)finishedBlock
//                          failed:(QYApiClientFailedBlock)failedBlock;


//获取某国家／城市下的微游记:
-(void)getMicroTravelDataOfCountryByCountryId:(NSString *)str_Id
                                     pageSize:(NSString *)str_pageSize
                                         page:(NSString *)str_page
                                      success:(QYApiClientSuccessBlock)finishedBlock
                                       failed:(QYApiClientFailedBlock)failedBlock;

-(void)getMicroTravelDataOfCityByCityId:(NSString *)str_Id
                               pageSize:(NSString *)str_pageSize
                                   page:(NSString *)str_page
                                success:(QYApiClientSuccessBlock)finishedBlock
                                 failed:(QYApiClientFailedBlock)failedBlock;

//根据国家或城市维度获取照片列表:
-(void)getPhotoListByType:(NSString *)type
              andObjectId:(NSString *)str_id
                  success:(QYApiClientSuccessBlock)finishedBlock
                   failed:(QYApiClientFailedBlock)failedBlock;


//获取当即热门目的地列表:
-(void)getHotPlaceListSuccess:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock;

//获取所有目的地列表:
-(void)getAllPlaceListSuccess:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock;

-(void)searchDataByText:(NSString*)text page:(NSInteger)page success:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock;

//获取某大洲／当季热门／专题下的锦囊列表:
-(void)getCountryListByContinentId:(NSString *)str_continentId
                           success:(QYApiClientSuccessBlock)finishedBlock
                            failed:(QYApiClientFailedBlock)failedBlock;

//获取某国家下的城市列表:
-(void)getCityListDataByCountryId:(NSString *)str_continentId
                         pageSize:(NSString *)pageSize
                             page:(NSString *)page
                          success:(QYApiClientSuccessBlock)finishedBlock
                           failed:(QYApiClientFailedBlock)failedBlock;


//获取锦囊详情:
-(void)getGuideDeatilInfoWithGuideId:(NSString *)guide_id
                             success:(QYApiClientSuccessBlock)finishedBlock
                              failed:(QYApiClientFailedBlock)failedBlock;
//取消获取锦囊详情:
-(void)cancleGuideDetailInfoWithGuideId:(NSString *)guide_id;


//获取全部锦囊列表:
-(void)fromV4_getAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime
                                            success:(QYApiClientSuccessBlock)successBlock
                                             failed:(QYApiClientFailedBlock)failedBlock;
//取消获取全部锦囊列表:
-(void)cancleGetAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime;


//根据国家或城市ID获取锦囊列表:
-(void)getGuideListWithType:(NSString *)type
                      andId:(NSString *)str_id
                    success:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock)failedBlock;

//根据搜索字符串获取锦囊列表:
-(void)getGuideListWithSearchString:(NSString *)str
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock;


/**
 获取锦囊运营图片
 */
- (void)getOperationWithCount:(NSUInteger)count
                      success:(QYApiClientSuccessBlock)successBlock
                      failure:(QYApiClientFailedBlock)failureBlock;


/**
 获取折扣运营图片
 */
- (void)getLastMinuteTopSuccess:(QYApiClientSuccessBlock)successBlock
                         failure:(QYApiClientFailedBlock)failureBlock;

/**
 获取服务器时间
 */
- (void)getServerTimeSuccess:(QYApiClientSuccessBlock)successBlock
                     failure:(QYApiClientFailedBlock)failureBlock;

/*
 通过id字符串获取折扣列表
 */
- (void)getLastMinuteWithIds:(NSArray *)ids
                     success:(QYApiClientSuccessBlock)successBlock
                     failure:(QYApiClientFailedBlock)failureBlock;

/**
 获取折扣总分类
 */
- (void)getCategoryAllWithType:(NSUInteger)type
                         times:(NSString *)times
                   continentId:(NSUInteger)continentId
                     countryId:(NSUInteger)countryId
                     departure:(NSString *)departure
                       success:(QYApiClientSuccessBlock)successBlock
                       failure:(QYApiClientFailedBlock)failureBlock;

/**
 获取折扣总分类 (提醒) by jessica
 */
- (void)getCategoryTotalWithType:(NSUInteger)type
                           times:(NSString *)times
                     continentId:(NSUInteger)continentId
                       countryId:(NSUInteger)countryId
                       departure:(NSString *)departure
                         success:(QYApiClientSuccessBlock)successBlock
                         failure:(QYApiClientFailedBlock)failureBlock;

/**
 获取折扣热门国家
 */
- (void)getHotCountrySuccess:(QYApiClientSuccessBlock)successBlock
                     failure:(QYApiClientFailedBlock)failureBlock;

/**
 获取折扣列表（改）
 */
- (void)getLastMinuteListWithType:(NSUInteger)type
                            maxId:(NSUInteger)maxId
                         pageSize:(NSUInteger)pageSize
                            times:(NSString *)times
                      continentId:(NSUInteger)continentId
                        countryId:(NSUInteger)countryId
                        departure:(NSString *)departure
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock)failureBlock;


///**
// 获取折扣详情信息
// */
//- (void)getLastMinuteDetailWithID:(NSUInteger)ID
//                       OAuthToken:(NSString *)token
//                          success:(QYApiClientSuccessBlock)successBlock
//                          failure:(QYApiClientFailedBlock)failureBlock;

/**
 获取折扣详情 by 折扣
 */
- (void)getLastMinuteDetailWithId:(NSUInteger)lastMinuteId
                           source:(NSString*)aSource//进入折扣详情页的类名
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock)failureBlock;

/**
 获取默认购买人信息 by 折扣
 */
- (void)getBuyerInfoSuccess:(QYApiClientSuccessBlock)successBlock
                    failure:(QYApiClientFailedBlock)failureBlock;

/**
 lastminute 修改默认联系人信息 by 折扣
 */

- (void)changeBuyerInfoWithParams:(NSDictionary*)aParams
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock)failureBlock;

/**
 获取折扣预订信息 by 折扣
 */
- (void)getLastMinuteOrderInfoWithId:(NSUInteger)lastMinuteId
                             success:(QYApiClientSuccessBlock)successBlock
                             failure:(QYApiClientFailedBlock_Error)failureBlock;

/**
 获取折扣套餐的品类信息 by 折扣
 */
- (void)getSectionCategorysWithId:(NSUInteger)productId
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock_Error)failureBlock;

/**
 lastminute 提交订单 by 折扣
 */

- (void)lastMinutePostOrderWithParams:(NSDictionary*)aParams
                              success:(QYApiClientSuccessBlock)successBlock
                              failure:(QYApiClientFailedBlock_Error)failureBlock;

/**
 APP获取订单信息 by 折扣
 */
- (void)getLastMinuteOrderInfoDetailWithId:(NSUInteger)orderId
                                   success:(QYApiClientSuccessBlock)successBlock
                                   failure:(QYApiClientFailedBlock_Error)failureBlock;

/**
 APP获取订单列表 by 折扣
 */
- (void)getLastMinuteUserOrderListWithCount:(NSUInteger)aCount
                                       page:(NSUInteger)aPage
                                    success:(QYApiClientSuccessBlock)successBlock
                                    failure:(QYApiClientFailedBlock_Error)failureBlock;

/**
 lastminute 删除订单 by 折扣
 */

- (void)deleteLastMinuteUserOrderWithParams:(NSDictionary*)aParams
                                    success:(QYApiClientSuccessBlock)successBlock
                                    failure:(QYApiClientFailedBlock_Error)failureBlock;

/**
 lastminute 生成尾款订单 by 折扣
 */

- (void)createLastMinuteBalanceOrderWithParams:(NSDictionary*)aParams
                                       success:(QYApiClientSuccessBlock)successBlock
                                       failure:(QYApiClientFailedBlock_Error)failureBlock;


/**
 lastminute提醒条件列表 by Jessica
 */
- (void)getRemindListWithMaxId:(NSUInteger)maxId
                      pageSize:(NSUInteger)pageSize
                       success:(QYApiClientSuccessBlock)successBlock
                       failure:(QYApiClientFailedBlock)failureBlock;

/**
 lastminute添加提醒条件
 */
- (void)addLastMinuteRemindWithType:(NSUInteger)type
                              times:(NSString *)times
                      startPosition:(NSString *)startPosition
                          countryId:(NSUInteger)countryId
                            success:(QYApiClientSuccessBlock)successBlock
                            failure:(QYApiClientFailedBlock)failureBlock;

/**
 lastminute取消提醒条件 by Jessica
 */
- (void)deleteLastMinuteRemindWithId:(NSUInteger)remindId
                             success:(QYApiClientSuccessBlock)successBlock
                             failure:(QYApiClientFailedBlock)failureBlock;

/**
 lastminute收藏列表 by Jessica
 */
- (void)getLastMinuteFavorListWithMaxId:(NSUInteger)maxId
                               pageSize:(NSUInteger)pageSize
                                success:(QYApiClientSuccessBlock)successBlock
                                failure:(QYApiClientFailedBlock)failureBlock;

/**
 lastminute添加收藏
 */
- (void)lastMinuteAddFavorWithId:(NSUInteger)lastMinuteId
                         success:(QYApiClientSuccessBlock)successBlock
                         failure:(QYApiClientFailedBlock)failureBlock;

/**
 lastminute取消收藏 by Jessica
 */
- (void)lastMinuteDeleteFavorWithId:(NSUInteger)lastMinuteId
                            success:(QYApiClientSuccessBlock)successBlock
                            failure:(QYApiClientFailedBlock)failureBlock;


/**
 回复论坛游记帖子
 */
- (void)sendThreadWithThreadID:(NSString *)threadID
                       Message:(NSString *)message
                       floorID:(NSString *)PID
                        userID:(NSString *)UID
                    floorIndex:(NSString *)floorIndexxx
                    OAuthToken:(NSString *)token
                       success:(QYApiClientSuccessBlock)successBlock
                       failure:(QYApiClientFailedBlock)failureBlock;


//获得首页web框架
-(void)getRecommendWebHtmlWithAppVer:(NSString *)app_version
                           andWebVer:(NSString *)web_version
                             success:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock;


/**
 获取所有poi的位置坐标
 */
- (void)getAllPoiPositionByCityId:(NSString *)city_id
                          success:(QYApiClientSuccessBlock)successBlock
                           failed:(QYApiClientFailedBlock)failedBlock;

/**
 获取国家的位置坐标
 */
- (void)getMapByCountryName:(NSString *)countryName
                    success:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock)failedBlock;

//获取我的信息:
-(void)getMyInfoWithUserid:(NSString *)userid
                orImUserId:(NSString *)userid_im
                   success:(QYApiClientSuccessBlock)successBlock
                    failed:(QYApiClientFailedBlock)failedBlock;

//获取他人的个人信息:
-(void)getUserInfoWithUserId:(NSString *)user_id
                  orImUserId:(NSString *)userid_im
                     success:(QYApiClientSuccessBlock)successBlock
                      failed:(QYApiClientFailedBlock)failedBlock;

//获取聊天室的小黑板列表
-(void)getChatRoomWallListWithRoomID:(NSString *)roomID
                                page:(NSInteger)pageIndex
                             success:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock;

//用户在聊天室发布小黑板
- (void)postBoardToServerWithTitle:(NSString *)titleee
                           content:(NSString *)contenttt
                             imageData:(NSData *)imageData
                        chatRoomID:(NSString *)roomID
                             token:(NSString *)userToken
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock)failureBlock;

//删除小黑板
-(void)deleteBoardDetailByWallID:(NSString *)wallID
                         success:(QYApiClientSuccessBlock)successBlock
                          failed:(QYApiClientFailedBlock)failedBlock;

//获取小黑板详情
-(void)getBoardDetailByWallID:(NSString *)wallID
                      success:(QYApiClientSuccessBlock)successBlock
                       failed:(QYApiClientFailedBlock)failedBlock;

//获取小黑板评论列表
-(void)getBoardCommentsListByWallID:(NSString *)wallID
                              Count:(NSString *)count
                               Page:(NSString *)page
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock;

//评论回复小黑板的内容
-(void)replyToBoardByWallID:(NSString *)wallID
                    Message:(NSString *)content
                    success:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock)failedBlock;
//http://maps.google.com/maps/api/geocode/json?latlng=30.905361,116.463103&sensor=true&language=en
//根据经纬度，反地里编码
-(void)getLocationDataWithLat:(NSString *)lat
                          lng:(NSString *)lng
                       sensor:(NSString *)sensor
                     language:(NSString *)language
                      success:(QYApiClientSuccessBlock)successBlock
                       failed:(QYApiClientFailedBlock)failedBlock;


//获取用户所在地的聊天室:
-(void)getChatRoomWithLocation:(CLLocation *)location
                andCountryName:(NSString *)countryName
                   andCityName:(NSString *)cityName
                   andAreaName:(NSString *)areaName
                    andStreetName:(NSString *)streetName
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock;

//获取用户所在地的聊天室2:
-(void)getChatRoomWithLocation:(CLLocation *)location
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock;


//获取用户Fans:
-(void)getFansDataWithUserid:(NSString *)user_id
                    andCount:(NSString *)count
                     andPage:(NSString *)page
                     success:(QYApiClientSuccessBlock)successBlock
                      failed:(QYApiClientFailedBlock)failedBlock;
-(void)cancleGetFansDataWithUserid:(NSString *)user_id
                          andCount:(NSString *)count
                           andPage:(NSString *)page;



//获取用户Follow:
-(void)getFollowDataWithUserid:(NSString *)user_id
                      andCount:(NSString *)count
                       andPage:(NSString *)page
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock;
-(void)cancleGetFollowDataWithUserid:(NSString *)user_id
                            andCount:(NSString *)count
                             andPage:(NSString *)page;

//统计聊天室人数
-(void)getChatroomStatsHotNum:(NSString *)HotNum
                       newNum:(NSString *)newNum
                      success:(QYApiClientSuccessBlock)successBlock
                       failed:(QYApiClientFailedBlock)failedBlock;

//获取聊天室成员列表
-(void)getChatRoomMembersWithRoomID:(NSString *)roomID
                           andCount:(NSString *)count
                            andPage:(NSString *)page
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock;
//新接口，获取聊天室成员
-(void)getChatRoomMembersWithIDs:(NSString *)userIDs
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock;


//获取用户想去的国家:
-(void)getWantGoDataWithUserid:(NSString *)userid
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock;
//取消获取用户想去的国家的请求:
-(void)cancleGetWantGoDataWithUserid:(NSString *)userid;



//获取通知列表
-(void)getNotificationListWithCount:(NSString *)count
                            andPage:(NSString *)page
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock;

// 获取私信列表
-(void)getPrichatListWithImUserId:(NSString *)imUserId
                            count:(NSString *)count
                            since:(NSString *)since
                          success:(QYApiClientSuccessBlock)successBlock
                           failed:(QYApiClientFailedBlock)failedBlock;
//获取未读通知个数
-(void)getNotificationUnreadCount:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock;


//获取用户去过的国家:
-(void)getHasGoneDataWithUserid:(NSString *)userid
                        success:(QYApiClientSuccessBlock)successBlock
                         failed:(QYApiClientFailedBlock)failedBlock;
-(void)cancleGetHasGoneDataWithUserid:(NSString *)userid;


//获取用户去过/想去的城市的poi:
-(void)getGoneAndWantGoCitiesDataWithUserid:(NSString *)userid
                                  andCityId:(NSString *)str_cityId
                                    andType:(NSString *)type
                                    success:(QYApiClientSuccessBlock)successBlock
                                     failed:(QYApiClientFailedBlock)failedBlock;

//关注:
-(void)followWithUserid:(NSString *)userid
                success:(QYApiClientSuccessBlock)successBlock
                 failed:(QYApiClientFailedBlock)failedBlock;

//取消关注:
-(void)unFollowWithUserid:(NSString *)userid
                  success:(QYApiClientSuccessBlock)successBlock
                   failed:(QYApiClientFailedBlock)failedBlock;

//上传用户的头像:
-(void)postAvatarWithImage:(UIImage *)image
                   success:(QYApiClientSuccessBlock)successBlock
                    failed:(QYApiClientFailedBlock)failedBlock;

//上传用户的头图:
-(void)postPhotoWithImage:(UIImage *)image
                  success:(QYApiClientSuccessBlock)successBlock
                   failed:(QYApiClientFailedBlock)failedBlock;
//得到新首页推荐
-(void)getRecommandsSuccess:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock)failedBlock;
//新 精华游记推荐
-(void)getRecommandsTripByObjectId:(NSString *)str_Id
                              type:(NSString *)str_type
                          pageSize:(NSString *)str_pageSize
                              page:(NSString *)str_page
                           success:(QYApiClientSuccessBlock)finishedBlock
                            failed:(QYApiClientFailedBlock)failedBlock;

//获取poi详情:
-(void)getPoiDetailInfoByClientid:(NSString *)client_id
                 andClientSecrect:(NSString *)client_secrect
                            poiId:(NSInteger)poiId
                         finished:(QYApiClientSuccessBlock)finished
                           failed:(QYApiClientFailedBlock)failed;

//评论poi:
-(void)postMyCommentWithContent:(NSString *)comment
                        andRate:(NSString *)rate
                       andPoiid:(NSString *)poiid
                   andCommentid:(NSString *)commentId_user
                       finished:(QYApiClientSuccessBlock)finished
                         failed:(QYApiClientFailedBlock_detail)failed;
 

//获得你可能喜欢页面的数据
- (void)getYouMayLikeSuccess:(QYApiClientSuccessBlock)successBlock
                      failed:(QYApiClientFailedBlock)failedBlock;

//绑定追踪信息
-(NSString *)addTrackInfoWithUrlString:(NSString *)url;


//获取用户的帖子(游记):
-(void)getUserTravelDataWithUserId:(NSInteger)userId
                           andType:(NSString *)type
                          andCount:(NSInteger)count
                           andPage:(NSInteger)page
                           success:(QYApiClientSuccessBlock)successBlock
                            failed:(QYApiClientFailedBlock_Error)failedBlock;


//获取用户收藏的帖子(游记):
-(void)getUserCollectTravelDataWithUserId:(NSInteger)userId
                                  andType:(NSString *)type
                                 andCount:(NSInteger)count
                                  andPage:(NSInteger)page
                                  success:(QYApiClientSuccessBlock)successBlock
                                   failed:(QYApiClientFailedBlock_Error)failedBlock;

//将锦囊下载成功的消息反馈给服务器:
-(void)feedBackToServerWithGuideId:(NSInteger)guideId
                           success:(QYApiClientSuccessBlock)successBlock
                            failed:(QYApiClientFailedBlock)failedBlock;

//获得微锦囊列表页数据
- (void)getTravelSubjectListWithType:(NSString *)type
                                  ID:(NSString *)ID
                               count:(NSInteger)count
                                page:(NSInteger)page
                             success:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock;
//获得微锦囊详情页数据
- (void)getTravelSubjectDetailWithID:(NSString *)ID
                                page:(NSInteger)page
                              source:(NSString *)source
                             success:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock;
//帖子（游记）收藏状态的改变
- (void)postBBSCollectStateWithOauthToken:(NSString *)oauthToken
                                      tid:(NSString *)tid
                                      fid:(NSString *)fid
                                     oper:(NSString *)oper
                                  success:(QYApiClientSuccessBlock)successBlock
                                   failed:(QYApiClientFailedBlock)failedBlock;
//获得帖子（游记）的收藏状态
- (void)getBBSCollectStateWithOauthToken:(NSString *)oauthToken
                                     tid:(NSString *)tid
                                  source:(NSString *)source
                                 success:(QYApiClientSuccessBlock)successBlock
                                  failed:(QYApiClientFailedBlock)failedBlock;

//添加足迹:
-(void)addFootPrintWithOper:(NSString *)oper
                    andType:(NSString *)type
                   andObjId:(NSInteger)obj_id
                    success:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock_Error)failedBlock;

//删除足迹:
-(void)deleteFootPrintWithOper:(NSString *)oper
                       andType:(NSString *)type
                      andObjId:(NSInteger)obj_id
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock_Error)failedBlock;

//POI周边列表:
-(void)getPoiNearByWithLat:(float)lat
                    andLon:(float)lon
             andCategoryId:(NSInteger)categoryId
                  andPoiId:(NSInteger)poi_id
               andPageSize:(NSString *)str_pageSize
                   andPage:(NSString *)str_page
                   success:(QYApiClientSuccessBlock)finishedBlock
                    failed:(QYApiClientFailedBlock_Error)failedBlock;

//poi周边酒店:
-(void)getNearByHotelWithPoiId:(NSInteger)poi_id
                  andPageCount:(NSString *)pageCount
                       andPage:(NSString *)page
                       success:(QYApiClientSuccessBlock)finishedBlock
                        failed:(QYApiClientFailedBlock_Error)failedBlock;

@end


