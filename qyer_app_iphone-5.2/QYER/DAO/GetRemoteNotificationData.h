//
//  GetRemoteNotificationData.h
//  NewPackingList
//
//  Created by an qing on 13-1-5.
//
//


#import <Foundation/Foundation.h>
@class QYGuide;
@class HomeViewController;
@class GuideDetailViewController;
@class specialGuideListViewController;
@class WebViewViewController;


#if NS_BLOCKS_AVAILABLE
typedef void (^myFinishedBlock)(void);
typedef void (^myFailedBlock)(void);
#endif


@interface GetRemoteNotificationData : NSObject <UIAlertViewDelegate>
{
    NSString *pushMsg;
    NSString *htmlString;
    NSInteger openType;
    NSString *title;
    NSMutableArray *allGuideDataArray;
    
    NSString *content;
    NSArray *guideIdArray;
    
    QYGuide *pushGuide;
    
    GuideDetailViewController *guideDetailVC;
    specialGuideListViewController *specialGuideListVC;
    WebViewViewController *_webVC;
    
//    UIWindow *myWindow;
//    UIViewController *myRootVC;
    UINavigationController *pushNavigationVC;
    
}

@property(nonatomic,assign) NSInteger openType;
@property(nonatomic,retain) NSString *htmlString;

+(id)sharedGetRemoteNotificationData;
-(void)getPushDataByClientid:(NSString *)client_id
            andClientSecrect:(NSString *)client_secrect
                andExtend_id:(NSInteger)extend_id
                    finished:(myFinishedBlock)finished
                      failed:(myFailedBlock)failed
                    withFlag:(BOOL)flag
                      andMsg:(NSString*)pushMseeage;


@end

