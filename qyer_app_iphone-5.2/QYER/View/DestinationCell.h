//
//  DestinationCell.h
//  QYER
//
//  Created by 张伊辉 on 14-6-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DestinationCell : UITableViewCell
{
    UIImageView *backImage;

    UILabel *titleLbl;
    UILabel *numberLbl;
   
    UIImageView *iconImage;
    UIView *back_click_view;
}
-(void)updateUIWithDict:(NSDictionary *)dict;
@end
