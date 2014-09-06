//
//  PhotoListCell.h
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QyYhConst.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoListCell : UITableViewCell
{
    UIImageView *backImageView;
    UIImageView *iconImageView;
    UILabel *photoName;
    UILabel *photoNum;
    UIView *lineView;
    UIImageView *nextImageView;
    
    UIView *back_click_view;
}
/**
 *  刷新UI
 *
 *  @param dict 数据
 *  @param flag 是否加阴影
 */
-(void)upDateUIWithDict:(NSDictionary *)dict isShowd:(BOOL)flag;


@end
