//
//  CountryViewController.h
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QYBaseViewController.h"

#import "CountryData.h"
#import "CityData.h"
#import "XLCycleScrollView.h"

#import "CountryCityDiscountView.h"
#import "CountryCityThreadView.h"


typedef enum {
   
    guide = 0,      //锦囊
    userGuide = 1,  //实用指南
    hotCity = 2,    //热门城市
    recomTravel = 3,//推荐行程
    travelList = 4, //精华游记
    hotDiscount = 5,//折扣
    allSpot = 6,    //旅行地
    hotel = 7,      //酒店精选
    
}category;
  

@interface CountryViewController : QYBaseViewController<XLCycleScrollViewDelegate,XLCycleScrollViewDatasource,UITableViewDataSource,UITableViewDelegate,ClickCountryCityDiscountDelegate,ClickCountryCityThreadDelegate>
{
    NSDictionary * _infoDictionary;//得到的返回数据字典
        
    UIScrollView *_scrollView;
    XLCycleScrollView *_topScrollView;

//    AppDelegate     * _appDelegate;
    
    UIImageView * _bottomImgView;
    UIButton * _goneBtn;//去过按钮
    UIButton * _wannaGoBtn;//想去按钮
    
    
    BOOL    _planToStatus;//判断想去的状态
    BOOL    _beenToStatus;//判断去过的状态
    
    
    NSMutableArray * _photosArray;
    
    
    UILabel *_chinaNameLabel;
    UILabel *_englishNameLabel;
    UILabel *_numberPicLabel;
    UIImageView *_numBackImageView;
    UIImageView *_shadeImageView;
    
    NSMutableArray * _arrGates;//锦囊,专题,行程,贴士的数组
    NSMutableArray * _arrCities;//城市列表的数组
    NSMutableArray * _arrDiscounts;//折扣的数组
    NSMutableArray * _arrThreads;//相关游记的数组
    
}
//if type = 1 country
//type = 2 city
@property(nonatomic,assign)int type;


@property (nonatomic, retain) NSString *key;
@end
