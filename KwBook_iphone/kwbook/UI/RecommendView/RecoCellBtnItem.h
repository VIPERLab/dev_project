//
//  RecoCellBtnItem.h
//  kwbook
//
//  Created by 熊 改 on 13-11-29.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecoCellDataItem;


@interface RecoCellBtnItem : UIButton
-(id)initWithFrame:(CGRect)frame andAlbumInfo:(RecoCellDataItem *)dataItem;
-(void)startLoadImage;
@end
