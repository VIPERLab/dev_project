//
//  QYOperationPage.h
//  QyGuide
//
//  Created by an qing on 12-12-27.
//
//


#import <Foundation/Foundation.h>
@class GuideListViewController;


#if NS_BLOCKS_AVAILABLE
typedef void (^finishedBlock)(void);
typedef void (^failedBlock)(void);
#endif


@interface GetOperationPage : NSObject
{
    NSInteger _open_type;
    NSString *_title;
    NSString *_content;
    NSString *_html;
    NSString *_picUrl;
    NSArray  *_specialJinnangListIdArray;
    
    NSMutableArray *_dataArray;
}


@property(nonatomic,assign) NSInteger open_type;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *content;
@property(nonatomic,retain) NSString *html;
@property(nonatomic,retain) NSString *picUrl;
@property(nonatomic,retain) NSArray *specialJinnangListIdArray;

@property(nonatomic,retain) NSMutableArray *dataArray;


-(void)getOperationPageInfoByClientid:(NSString *)client_id
                     andClientSecrect:(NSString *)client_secrect
                             finished:(finishedBlock)finished
                               failed:(failedBlock)failed;


@end
