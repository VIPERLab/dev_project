//
//  GetMinePoiComment.h
//  QyGuide
//
//  Created by an qing on 13-3-7.
//
//

#import <UIKit/UIKit.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^getMineCommentFinishedBlock)(void);
typedef void (^getMineCommentFailedBlock)(void);
#endif


@interface GetMinePoiComment : NSObject
{
    NSString        *_userImageUrl;             //用户的头像
    NSString        *_userName;                 //用户名
    NSString        *_userComment;              //用户的评论
    NSString        *_userCommentRate;          //用户的评星
    NSString        *_userCommentTime;          //用户评论时间
}

@property(nonatomic,retain) NSString        *userImageUrl;          //用户的头像
@property(nonatomic,retain) NSString        *userName;              //用户名
@property(nonatomic,retain) NSString        *userComment;           //用户的评论
@property(nonatomic,retain) NSString        *userCommentRate;       //用户的评星
@property(nonatomic,retain) NSString        *userCommentTime;       //用户评论时间
@property(nonatomic,assign) NSInteger       userCommentId;


-(void)getMineCommentByClientid:(NSString *)client_id
                       andPoiId:(NSInteger)poiId
                       finished:(getMineCommentFinishedBlock)finished
                         failed:(getMineCommentFailedBlock)failed;

@end

