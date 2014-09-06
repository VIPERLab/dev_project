//
//  QYDateObject.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-19.
//
//

#import <Foundation/Foundation.h>

@interface QYDateCategory : NSObject
{
    NSNumber                 *_categoryId;
    NSString                 *_categoryPrice;
    NSNumber                 *_categoryStock;
    NSNumber                 *_categoryDate;
    NSNumber                 *_categoryDays;
    NSNumber                 *_categoryMonth;
    NSNumber                 *_categoryYear;
    NSNumber                 *_categoryBuyLimit;

}

@property (retain, nonatomic) NSNumber                 *categoryId;
@property (retain, nonatomic) NSString                 *categoryPrice;
@property (retain, nonatomic) NSNumber                 *categoryStock;
@property (retain, nonatomic) NSNumber                 *categoryDate;
@property (retain, nonatomic) NSNumber                 *categoryDays;
@property (retain, nonatomic) NSNumber                 *categoryMonth;
@property (retain, nonatomic) NSNumber                 *categoryYear;
@property (retain, nonatomic) NSNumber                 *categoryBuyLimit;//购买限制

@end
