//
//  QYMoreApp.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-15.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYMoreApp : NSObject <NSCoding>
{
    NSString      *_appVersion;     //应用版本号
    NSString      *_appName;        //应用名称
    NSString      *_apptitle;       //应用的title
    NSString      *_appAppStoreURL; //appstore链接地址
    NSString      *_appPicUrl;      //应用图标
    NSArray       *_array_app;      //与该应用相关的推荐应用id
}

@property (nonatomic, retain) NSString      *appVersion;
@property (nonatomic, retain) NSString      *appName;
@property (nonatomic, retain) NSString      *apptitle;
@property (nonatomic, retain) NSString      *appAppStoreURL;
@property (nonatomic, retain) NSString      *appPicUrl;
@property (nonatomic, retain) NSArray       *array_app;

@end
