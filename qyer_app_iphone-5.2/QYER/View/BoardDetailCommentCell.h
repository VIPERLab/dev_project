//
//  BoardDetailCommentCell.h
//  QYER
//
//  Created by Leno on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DidClickCommentsUserAvatarDelegate;

@interface BoardDetailCommentCell : UITableViewCell
{
    UIView * _backViewww;
    
    UIImageView  * _topLine;
    UIButton     * _userAvatarBtn;
    UILabel      * _userNameLabel;
    UILabel      * _postTimeLabel;
    UILabel      * _contentLabel;
}

@property (assign, nonatomic) id<DidClickCommentsUserAvatarDelegate> delegate;

//@property(retain,nonatomic)UIImageView  * topLine;
//@property(retain,nonatomic)UIButton     * userAvatarBtn;
//@property(retain,nonatomic)UILabel      * userNameLabel;
//@property(retain,nonatomic)UILabel      * postTimeLabel;
//@property(retain,nonatomic)UILabel      * contentLabel;

-(void)insertNewComment:(NSDictionary *)dict;
-(void)setContenInfo:(NSDictionary *)dict;

@end

@protocol DidClickCommentsUserAvatarDelegate<NSObject>
-(void)didClickCommentsUserAvatarByTag:(NSInteger)tag;
@end

