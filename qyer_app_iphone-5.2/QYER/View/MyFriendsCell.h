//
//  MyFriendsCell.h
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyFriendsCell : UITableViewCell
{
    UIImageView     *_imageView_user;
    UILabel         *_label_userName;
    UIImageView     *_imageView_gender;
    UILabel         *_label_track;
    UIImageView     *_imageView_bothFollow;
}

@property(nonatomic,assign) NSInteger user_id;

-(void)initInfoWithUserData:(NSArray *)array atPosition:(NSInteger)position;

@end
