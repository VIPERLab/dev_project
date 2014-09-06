//
//  UserItinerary.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-10.
//
//

#import <Foundation/Foundation.h>

@interface UserItinerary : NSObject <NSCoding>
{
    NSString        *_itineraryId;           //行程id
    NSString        *_itineraryImageLink;    //行程封图
    NSString        *_itineraryPlannerName;  //行程标题
    NSString        *_itineraryUpdateTime;   //行程最后更新时间
    NSString        *_itineraryPath_desc;    //行程的路径
    NSString        *_itineraryLinkString;   //行程对应webView链接
    NSString        *_itineraryDays;         //行程天数
    NSString        *_itineraryCost;         //行程所花费用
    NSString        *_userName;              //用户名称
    NSString        *_userIcon;              //用户头像
}

@property(nonatomic,retain) NSString        *itineraryId;           //行程id
@property(nonatomic,retain) NSString        *itineraryImageLink;    //行程封图
@property(nonatomic,retain) NSString        *itineraryPlannerName;  //行程标题
@property(nonatomic,retain) NSString        *itineraryUpdateTime;   //行程最后更新时间
@property(nonatomic,retain) NSString        *itineraryPath_desc;    //行程的路径
@property(nonatomic,retain) NSString        *itineraryLinkString;   //行程对应webView链接
@property(nonatomic,retain) NSString        *itineraryDays;         //行程天数
@property(nonatomic,retain) NSString        *itineraryCost;         //行程所花费用
@property(nonatomic,retain) NSString        *userName;              //用户名称
@property(nonatomic,retain) NSString        *userIcon;              //用户头像

@end
