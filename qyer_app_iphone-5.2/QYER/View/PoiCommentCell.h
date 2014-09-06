//
//  PoiCommentCell.h
//  QyGuide
//
//  Created by an qing on 13-2-28.
//
//

#import <UIKit/UIKit.h>
#import "PoiComment.h"

@interface PoiCommentCell : UITableViewCell
{
    UIView          *_bgView;
    UIImageView     *_userImageView;            //用户头像
    UILabel         *_userNameLabel;            //用户名称
    UIImageView     *_userCommentRateView1;     //用户评星1
    UIImageView     *_userCommentRateView2;     //用户评星2
    UIImageView     *_userCommentRateView3;     //用户评星3
    UIImageView     *_userCommentRateView4;     //用户评星4
    UIImageView     *_userCommentRateView5;     //用户评星5
    UILabel         *_userCommentTimeLabel;     //用户评论时间
    UILabel         *_userCommentLabel;         //用户评论
    
    UILabel         *_topLabel;
    UILabel         *_leftLabel;
    UILabel         *_rightLabel;
    UIImageView     *_bottomLabel;
}
@property(nonatomic,retain) UIView          *bgView;
@property(nonatomic,retain) UIImageView     *userImageView;            //用户头像
@property(nonatomic,retain) UILabel         *userNameLabel;            //用户名称
@property(nonatomic,retain) UIImageView     *userCommentRateView1;     //用户评星1
@property(nonatomic,retain) UIImageView     *userCommentRateView2;     //用户评星2
@property(nonatomic,retain) UIImageView     *userCommentRateView3;     //用户评星3
@property(nonatomic,retain) UIImageView     *userCommentRateView4;     //用户评星4
@property(nonatomic,retain) UIImageView     *userCommentRateView5;     //用户评星5
@property(nonatomic,retain) UILabel         *userCommentTimeLabel;     //用户评论时间
@property(nonatomic,retain) UILabel         *userCommentLabel;         //用户评论

-(void)initWithPoiComment:(PoiComment *)poiComment;
-(void)initCommentRateViewByRate:(NSString *)rate;
-(void)removeTopBorderView;
-(void)initTopBorderView;
-(void)initBorderViewWithHeight:(NSInteger)height;
-(void)setBottomLabelColor:(BOOL)showBrokenLine;
+(float)cellHeightWithContent:(NSString *)string;

@end

