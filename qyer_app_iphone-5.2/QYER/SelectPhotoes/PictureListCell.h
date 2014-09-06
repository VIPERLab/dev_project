//
//  PictureListCell.h
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CustomPickerImageDelegate.h"
#import "QYImageView.h"

@interface PictureListCell : UITableViewCell
{
    
}
@property (nonatomic, assign) id delegate;
-(void)upDateUIWithDict:(NSMutableArray *)photoArray index:(int)row;
@end
