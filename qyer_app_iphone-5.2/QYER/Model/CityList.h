//
//  CityList.h
//  QYER
//
//  Created by 我去 on 14-3-19.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityList : NSObject <NSCoding>
{
    NSString *_str_id;           //城市id
    NSString *_str_catename;     //中文名称
    NSString *_str_catename_en;  //英文名
    NSString *_str_photo;        //封面图
    NSString *_str_lat;          //维度
    NSString *_str_lng;          //经度
    NSString *_str_wantstr;      //统计会去，去过人数的比例
    NSString *_str_ishot;        //是否热门,为true时为热门
    
}
@property(nonatomic,retain) NSString *str_id;           //城市id
@property(nonatomic,retain) NSString *str_catename;     //中文名称
@property(nonatomic,retain) NSString *str_catename_en;  //英文名
@property(nonatomic,retain) NSString *str_photo;        //封面图
@property(nonatomic,retain) NSString *str_lat;          //维度
@property(nonatomic,retain) NSString *str_lng;          //经度
@property(nonatomic,retain) NSString *str_wantstr;      //统计会去，去过人数的比例
@property(nonatomic,retain) NSString *str_ishot;        //是否热门,为true时为热门


//********** Insert By ZhangDong 2014.3.31 Start **********
@property (nonatomic, assign) NSInteger beennumber;
@property (nonatomic, retain) NSString *beenstr;
@property (nonatomic, assign) NSInteger recommendnumber;
@property (nonatomic, retain) NSString *recommendstr;
@property (nonatomic, assign) NSInteger recommendscores;
@property (nonatomic, retain) NSString *representative;
//********** Insert By ZhangDong 2014.3.31 End **********
@end
