//
//  QYOperation.h
//  JinNangFrameApp
//
//  Created by lide on 12-12-28.
//
//

#import <Foundation/Foundation.h>




/**
 折扣的运营图片。
 */

typedef void(^LastMinuteOperationSuccessBlock) (NSArray *data);
typedef void(^LastMinuteOperationFailureBlock) (void);

@interface QYOperation : NSObject <NSCoding, NSCopying>
{
    NSNumber    *_openType;
    NSString    *_operationTitle;
    NSString    *_operationContent;
    NSArray     *_operationIds;
    NSString    *_operationUrl;
    NSString    *_operationPic;
    NSString    *_operationBigPic;
}

@property (retain, nonatomic) NSNumber *openType;
@property (retain, nonatomic) NSString *operationTitle;
@property (retain, nonatomic) NSString *operationContent;
@property (retain, nonatomic) NSArray *operationIds;
@property (retain, nonatomic) NSString *operationUrl;
@property (retain, nonatomic) NSString *operationPic;
@property (retain, nonatomic) NSString *operationBigPic;

- (id)initWithAttribute:(NSDictionary *)attribute;
+ (NSArray *)parseFromeData:(NSArray *)array;

+ (void)getOperationWithCount:(NSUInteger)count
                      success:(LastMinuteOperationSuccessBlock)successBlock
                      failure:(LastMinuteOperationFailureBlock)failureBlock;


@end
