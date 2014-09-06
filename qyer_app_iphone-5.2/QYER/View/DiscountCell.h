//
//  DiscountCell.h
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QyYhConst.h"

@protocol DiscountCellDelegate <NSObject>

/**
 *  点击某一个分块
 *
 *  @param index 索引
 */
-(void)clickDiscount:(int)index;

@end

@interface DiscountCell : UITableViewCell
{
    UIView *blackView;
    int _indexRow;
    BOOL limitMultiple;
}
@property (nonatomic, assign) id<DiscountCellDelegate>delegate;

-(void)updateCellWithLastMinuteDeal:(NSMutableArray *)array index:(int)row;


@end


