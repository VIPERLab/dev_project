//
//  MayLikeMyLastMinModel.h
//  QYER
//
//  Created by chenguanglin on 14-7-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MayLikeMyLastMinModel : NSObject
/**
 *  图片的url
 */
@property (nonatomic, copy) NSString *photo;
/**
 *  折扣的标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  到期的时间
 */
@property (nonatomic, copy) NSString *expire_date;
/**
 *  折扣价格
 */
@property (nonatomic, copy) NSString *price;
/**
 *  折扣id
 */
@property (nonatomic, assign) int ID;

+ (instancetype)ModeWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

//"id": "4406",
//"title": "测试折扣详情",
//"price": "2000 元起",
//"expire_date": "2014.04.16 结束",
//"photo": "http://static.qyer.com/upload/mobile/operation/db/18/db1895f1be9df943d2e1c128eff35aa6.jpg",
//"big_pic": "http://static.qyer.com/upload/mobile/op
@end
