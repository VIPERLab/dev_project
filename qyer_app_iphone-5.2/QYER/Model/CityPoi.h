//
//  CityPoi.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>

@interface CityPoi : NSObject <NSCoding>
{
    NSString    *_str_poiId;                    //poi的id
    NSString    *_str_poiChineseName;           //poi中文名称
    NSString    *_str_poiEnglishName;           //poi英文名称
    NSString    *_str_poiLocalName;             //poi的当地语言名称
    NSString    *_str_albumCover;               //poi的头图
    NSString    *_str_lat;                      //poi的纬度
    NSString    *_str_lng;                      //poi的经度
    NSString    *_str_wantGo;                   //多少人会去/去过
    NSString    *_str_comprehensiveRating;      //poi综合评星 (取值范围1~10,除以2得到5星级以内的值)
    NSString    *_str_comprehensiveEvaluation;  //poi综合评分 (取值范围1~10,float型)
    NSString    *_str_recommendscores;          //poi推荐指数 (取值范围1~100)
    NSString    *_str_recommendstr;             //poi推荐指数描述
    
    NSString    *_str_hotFlag;                  //是否是热门poi
    
    NSString    *_str_distance;
}

@property(nonatomic,retain) NSString    *str_poiId;                    //poi的id
@property(nonatomic,retain) NSString    *str_poiChineseName;           //poi中文名称
@property(nonatomic,retain) NSString    *str_poiEnglishName;           //poi英文名称
@property(nonatomic,retain) NSString    *str_poiLocalName;             //poi的当地语言名称
@property(nonatomic,retain) NSString    *str_albumCover;               //poi的头图
@property(nonatomic,retain) NSString    *str_lat;                      //poi的纬度
@property(nonatomic,retain) NSString    *str_lng;                      //poi的经度
@property(nonatomic,retain) NSString    *str_wantGo;                   //多少人会去
@property(nonatomic,retain) NSString    *str_comprehensiveRating;      //poi综合评星
@property(nonatomic,retain) NSString    *str_comprehensiveEvaluation;  //poi综合评分
@property(nonatomic,retain) NSString    *str_recommendscores;          //poi推荐指数 (取值范围1~100)
@property(nonatomic,retain) NSString    *str_recommendstr;             //poi推荐指数描述
@property(nonatomic,retain) NSString    *str_hotFlag;                  //是否是热门poi
@property(nonatomic,retain) NSString    *str_distance;
@end
