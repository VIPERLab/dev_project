//
//  ApplicationCell.h
//  NewPackingList
//
//  Created by lide on 12-10-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplicationCell : UITableViewCell
{
    UIImageView     *_imageView_background;
    UIImageView     *_applicationImageView;
    UILabel         *_applicationTitle;
    UILabel         *_applicationContent;
    UIImageView     *_imageView_lastCell;
}
@property (retain, nonatomic) UIImageView *imageView_background;
@property (retain, nonatomic) UIImageView *applicationImageView;
@property (retain, nonatomic) UILabel *applicationTitle;
@property (retain, nonatomic) UILabel *applicationContent;
@property (retain, nonatomic) UIImageView *imageView_lastCell;

-(void)reset;
-(void)initDataWithArray:(NSArray *)array atPosition:(NSInteger)position andHeightDic:(NSDictionary *)heightDic;

@end

