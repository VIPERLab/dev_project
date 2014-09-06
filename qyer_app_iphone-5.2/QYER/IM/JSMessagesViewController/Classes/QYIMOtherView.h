//
//  QYIMOtherView.h
//  IMTest
//
//  Created by Frank on 14-4-30.
//  Copyright (c) 2014年 Frank. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OtherMessage;

/**
 *  IM自定义试图
 */
@interface QYIMOtherView : UIView
{
    UIView *_line;
}
/**
 *  标题
 */
@property (nonatomic, retain) UILabel *labelTitle;

/**
 *  主要内容
 */
@property (nonatomic, retain) UILabel *labelContent;

/**
 *  类型ICON
 */
@property (nonatomic, retain) UIImageView *imageViewIcon;

/**
 *  图片信息
 */
@property (nonatomic, retain) UIImageView *imageView;

/**
 *  数据
 */
@property (nonatomic, retain) OtherMessage *otherMessage;

/**
 *  使用视图类型初始化
 *
 *  @return 
 */
- (id)init;


@end
