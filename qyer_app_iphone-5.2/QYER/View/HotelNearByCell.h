//
//  HotelNearByCell.h
//  QYER
//
//  Created by 我去 on 14-8-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotelNearByCell : UITableViewCell
{
    UIImageView     *_hotelNearbyBackBgView;
    UIImageView     *_imageView_hotel;
    UILabel         *_hotelNameLabel;
    UILabel         *_hotelStarLabel;
    UILabel         *_distanceLabel;
    UILabel         *_hotelPriceLabel;
    UILabel         *_currencycodeLabel;
    UIImageView     *_line_bottom;
}

-(void)setInfoWithArray:(NSArray *)array atPosition:(NSInteger)position;

@end
