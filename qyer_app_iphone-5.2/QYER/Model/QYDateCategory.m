//
//  QYDateObject.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-19.
//
//

#import "QYDateCategory.h"

@implementation QYDateCategory

@synthesize categoryId = _categoryId;
@synthesize categoryPrice = _categoryPrice;
@synthesize categoryStock = _categoryStock;
@synthesize categoryDate = _categoryDate;
@synthesize categoryDays = _categoryDays;
@synthesize categoryMonth = _categoryMonth;
@synthesize categoryYear = _categoryYear;
@synthesize categoryBuyLimit = _categoryBuyLimit;

- (void)dealloc
{
    QY_SAFE_RELEASE(_categoryId);
    QY_SAFE_RELEASE(_categoryPrice);
    QY_SAFE_RELEASE(_categoryStock);
    QY_SAFE_RELEASE(_categoryDate);
    QY_SAFE_RELEASE(_categoryDays);
    QY_SAFE_RELEASE(_categoryMonth);
    QY_SAFE_RELEASE(_categoryYear);
    QY_SAFE_RELEASE(_categoryBuyLimit);
    
    [super dealloc];
}

@end
