//
//  QYLastminuteCategory.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-19.
//
//

#import <Foundation/Foundation.h>
#import "QYDateCategory.h"

typedef void(^QYSectionCategorySuccessBlock) (NSArray *data);
typedef void(^QYSectionCategoryFailureBlock) (NSError *error);//(void);

@interface QYSectionCategory : NSObject
{
    NSNumber                  *_cateYear;
    NSNumber                  *_cateMonth;
    NSMutableArray            *_cateDateCategoryArray;
}

@property (retain, nonatomic) NSNumber                  *cateYear;
@property (retain, nonatomic) NSNumber                  *cateMonth;
@property (retain, nonatomic) NSMutableArray            *cateDateCategoryArray;

@property (assign, nonatomic) NSInteger                 catePreMonth;
@property (assign, nonatomic) NSInteger                 catePreYear;
@property (assign, nonatomic) NSInteger                 catePreDays;
@property (assign, nonatomic) NSInteger                 cateDays;
@property (assign, nonatomic) NSInteger                 cateDayOfWeek;


- (id)initWithAttribute:(NSDictionary *)attribute;
//+ (NSArray *)parseFromeData:(NSData *)data;
+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary;

+ (void)getSectionCategorysWithId:(NSUInteger)productId
                          success:(QYSectionCategorySuccessBlock)successBlock
                          failure:(QYSectionCategoryFailureBlock)failureBlock;

//根据年、月计算天数
+ (NSInteger)daysFromMonth:(NSInteger)aMonth year:(NSInteger)aYear;
//根据年、月计算1号星期几
+ (NSInteger)dayOfWeekFromMonth:(NSInteger)aMonth year:(NSInteger)aYear;
//计算有多少行
+ (NSInteger)dateRowsFromDays:(NSInteger)aDays dayOfWeek:(NSInteger)aDayOfWeek;

@end
