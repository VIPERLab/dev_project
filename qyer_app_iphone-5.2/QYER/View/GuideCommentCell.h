//
//  GuideCommentCell.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-8.
//  Copyright (c) 2013年 an qing. All rights reserved.
//


//*** 锦囊评论cell


#import <UIKit/UIKit.h>
@class QYGuideComment;

@interface GuideCommentCell : UITableViewCell
{
    UIImageView     *_imageView_background;
    
    UILabel         *_label_userName;
    UIImageView     *_imageView_userIcon;
    UILabel         *_label_userComment;
    UILabel         *_label_commentTime;
    UIImageView     *_imageView_lastCell;
}
@property(nonatomic,retain) UILabel         *label_userName;
@property(nonatomic,retain) UIImageView     *imageView_userIcon;
@property(nonatomic,retain) UILabel         *label_userComment;
@property(nonatomic,retain) UILabel         *label_commentTime;

-(void)initCellWithArray:(NSArray *)array atPosition:(NSInteger)position;
+(float)cellHeightWithContent:(NSString *)string;

@end

