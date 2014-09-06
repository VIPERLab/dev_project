//
//  Remind.h
//  LastMinute
//
//  Created by lide on 13-9-26.
//
//

#import <Foundation/Foundation.h>

typedef void(^QYRemindSuccessBlock) (NSArray *data);
typedef void(^QYRemindFailureBlock) (void);

@interface Remind : NSObject
{
    NSNumber *_remindId;
    NSString *_remindType;
    NSString *_remindDate;
    NSString *_remindStartPositon;
    NSString *_remindCountry;
}

@property (retain, nonatomic) NSNumber *remindId;
@property (retain, nonatomic) NSString *remindType;
@property (retain, nonatomic) NSString *remindDate;
@property (retain, nonatomic) NSString *remindStartPositon;
@property (retain, nonatomic) NSString *remindCountry;

- (id)initWithAttribute:(NSDictionary *)attribute;
//+ (NSArray *)parseFromeData:(NSData *)data;
+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary;

+ (void)getRemindListWithMaxId:(NSUInteger)maxId
                      pageSize:(NSUInteger)pageSize
                       success:(QYRemindSuccessBlock)successBlock
                       failure:(QYRemindFailureBlock)failureBlock;

- (CGFloat)cellHeight;

@end
