//
//  Plan.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>

@interface Plan : NSObject <NSCoding>
{
    NSString    *_str_planId;           //行程id
    NSString    *_str_planName;         //行程标题
    NSString    *_str_planAlbumCover;   //行程头图
    NSString    *_str_planRoute;        //行程的路线
    NSString    *_str_planDays;         //行程花费的天数
    NSString    *_str_planBelongTo;     //创建该行程的用户
    NSString    *_str_planUpdateTime;   //行程最后更新时间
    NSString    *_str_planUrl;          //行程正文的url
    
    NSString    *_str_avatar;           //用户头像
}

@property(nonatomic,retain) NSString    *str_planId;           //行程id
@property(nonatomic,retain) NSString    *str_planName;         //行程标题
@property(nonatomic,retain) NSString    *str_planAlbumCover;   //行程头图
@property(nonatomic,retain) NSString    *str_planRoute;        //行程的路线
@property(nonatomic,retain) NSString    *str_planDays;         //行程花费的天数
@property(nonatomic,retain) NSString    *str_planBelongTo;     //创建该行程的用户
@property(nonatomic,retain) NSString    *str_planUpdateTime;   //行程最后更新时间
@property(nonatomic,retain) NSString    *str_planUrl;          //行程正文的url
@property(nonatomic,retain) NSString    *str_avatar;           //用户头像

@end
