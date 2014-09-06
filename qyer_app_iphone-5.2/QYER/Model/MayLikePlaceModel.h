//
//  MayLikePlaceModel.h
//  QYER
//
//  Created by chenguanglin on 14-7-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MayLikePlaceModel : NSObject

/**
 *  目的地的中文名
 */
@property (nonatomic, copy) NSString *title;

/**
 *  图片的URL
 */
@property (nonatomic, copy) NSString *photo;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, assign) int ID;

//"id": "1456",
//"photo": "http://site.qyer.com/uploadfile/2014/0527/20140527015516721.jpg",
//"title": "四日游乐只为边走边吃",
//"user_id": "182328",
//"username": "牛牛安",
//"avatar": "http://static.qyer.com/images/user2/avatar/big4.png",
//"description": "打着“最后一个二字头生日”的大旗帜，去新加坡庆生，来去匆匆，四天时间。好吃好喝不耽误~",
//"count": 4,

+ (instancetype)placeModeWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
