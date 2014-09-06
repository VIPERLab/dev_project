//
//  CatalogCell.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookMark.h"

@interface CatalogCell : UITableViewCell
{
    UIImageView     *_imageView_backGround;
    UIView          *_view_backGround;
    UIImageView     *_imgView_bookmark;
    UIImageView     *_imageView_lastCell;
    
    UILabel         *_label_pageNumber;
    UILabel         *_label_catalogName;
}

@property(nonatomic,retain) UILabel     *label_pageNumber;
@property(nonatomic,retain) UILabel     *label_catalogName;
@property(nonatomic,retain) UIImageView *imgView_bookmark;

-(void)initWithCatelogArray:(NSArray *)array_catelog andBookmarkArray:(NSArray *)array_bookmark atPosition:(NSInteger)position;
-(void)initBookMarkCatelogWithArray:(NSArray *)array atPosition:(NSInteger)position;
+(float)cellHeightWithContent:(NSString *)string andLength:(NSInteger)width;

@end
