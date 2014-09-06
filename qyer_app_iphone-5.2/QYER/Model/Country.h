//
//  Country.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>

@interface Country : NSObject <NSCoding>
{
    NSString        *_str_countryId;            //国家的id
    NSString        *_chineseName;              //国家的中文名
    NSString        *_englishName;              //国家的英文名
    NSString        *_str_albumCover;           //相册头图
    NSString        *_str_imagesCount;          //相册里的图片总张数
    NSString        *_str_lastMinuteFlag;       //是否有特惠折扣
    NSString        *_str_hotFlag;              //是否是热门国家
    NSString        *_str_isguideFlag;          //是否有国家的锦囊
    NSString        *_str_PracticalGuide_url;   //实用指南
    
    NSMutableArray *_photoArray;                //滚动图
    
}

@property(nonatomic,retain) NSString      *str_countryId;           //国家的id
@property(nonatomic,retain) NSString      *chineseName;             //国家的中文名
@property(nonatomic,retain) NSString      *englishName;             //国家的英文名
@property(nonatomic,retain) NSString      *str_albumCover;          //相册头图
@property(nonatomic,retain) NSString      *str_imagesCount;         //相册里的图片总张数
@property(nonatomic,retain) NSString      *str_lastMinuteFlag;      //是否有特惠折扣
@property(nonatomic,retain) NSString      *str_hotFlag;             //是否是热门国家
@property(nonatomic,retain) NSString      *str_PracticalGuide_url;  //实用指南
@property(nonatomic,retain) NSString      *str_isguideFlag;         //是否有国家的锦囊

@property(nonatomic,retain) NSMutableArray *photoArray;             //滚动图

@end

