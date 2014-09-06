//
//  City.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>

@interface City : NSObject <NSCoding>
{
    NSString        *_str_cityId;               //城市的id
    NSString        *_str_countryId;            //国家id，父类id
    NSString        *_chineseName;              //城市的中文名
    NSString        *_englishName;              //城市的英文名
    NSString        *_str_albumCover;           //相册头图
    NSString        *_str_imagesCount;          //相册里的图片总张数
    NSString        *_str_hotelUrl;             //精选酒店url(必有)
    NSString        *_str_PracticalGuideUrl;    //实用指南
    NSString        *_str_guideFlag;            //城市是否有锦囊列表
    NSString        *_str_hotFlag;              //是否是热门城市
    
    NSMutableArray *_photoArray;                //滚动图
}

@property(nonatomic,retain) NSString      *str_cityId;              //城市的id
@property(nonatomic,retain) NSString      *str_countryId;           //国家id，父类id
@property(nonatomic,retain) NSString      *chineseName;             //城市的中文名
@property(nonatomic,retain) NSString      *englishName;             //城市的英文名
@property(nonatomic,retain) NSString      *str_albumCover;          //相册头图
@property(nonatomic,retain) NSString      *str_imagesCount;         //相册里的图片总张数
@property(nonatomic,retain) NSString      *str_PracticalGuideUrl;   //实用指南
@property(nonatomic,retain) NSString      *str_hotelUrl;            //精选酒店url(必有)
@property(nonatomic,retain) NSString      *str_guideFlag;           //城市是否有锦囊列表
@property(nonatomic,retain) NSString      *str_hotFlag;             //是否是热门城市
@property(nonatomic,retain) NSMutableArray *photoArray;             //滚动图
@end
