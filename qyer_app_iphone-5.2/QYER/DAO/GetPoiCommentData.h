//
//  GetPoiCommentData.h
//  QYGuide
//
//  Created by 我去 on 14-2-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ASIHTTPRequest;



#if NS_BLOCKS_AVAILABLE
typedef void (^GetPoiCommentDataSuccessBlock)(NSArray *array_poiComment, NSArray *array_currentUser);
typedef void (^GetPoiCommentDataFailedBlock)(void);
#endif



@interface GetPoiCommentData : NSObject
{
    __block ASIHTTPRequest  *_getPoiRequest;
    BOOL            _hasDone;                   //一次获取数据是否完成
    BOOL            _isDeleteUserCommentFlag;   //是否删除了用户自己的评论
    NSInteger       _allCommentNumber;          //总评论条数
    
    __block NSMutableArray  *_commentDataArray;
    __block NSMutableArray  *_userCommentDataArray;     //本用户的评论数据
}
@property(nonatomic,assign) NSInteger       allCommentNumber;
@property(nonatomic,assign) BOOL            isDeleteUserCommentFlag;

+(GetPoiCommentData *)sharedGetPoiCommentData;
-(void)cancle;
-(void)getPoiCommentByClientid:(NSString *)client_id
              andClientSecrect:(NSString *)client_secrect
                      andPoiId:(NSInteger)poiId
                     andMax_Id:(NSInteger)max_id
                andOauth_token:(NSString *)user_oauth_token
                      finished:(GetPoiCommentDataSuccessBlock)finished
                        failed:(GetPoiCommentDataFailedBlock)failed;

@end
