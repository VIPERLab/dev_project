//
//  FeedBackData.h
//  QyGuide
//
//  Created by 你猜你猜 on 13-10-14.
//
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^FeedBackDataSuccessBlock)(NSArray *array);
typedef void (^FeedBackDataFailedBlock)(void);
#endif


@interface FeedBackData : NSObject


//用户反馈信息上传给服务器:
+(void)postUserFeedBackWithContent:(NSString *)content
                    andMailAddress:(NSString *)mail_address
                          finished:(FeedBackDataSuccessBlock)finished
                            failed:(FeedBackDataFailedBlock)failed;

@end
