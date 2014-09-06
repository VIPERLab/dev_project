//
//  HotelNearByCell.m
//  QYER
//
//  Created by 我去 on 14-8-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "HotelNearByCell.h"
#import "GetHotelNearbyPoi.h"
#import "UIImageView+WebCache.h"


#define     positionX   10
#define     intervalX   10


@implementation HotelNearByCell

-(void)dealloc
{
    QY_VIEW_RELEASE(_line_bottom);
    QY_VIEW_RELEASE(_currencycodeLabel);
    QY_VIEW_RELEASE(_hotelPriceLabel);
    QY_VIEW_RELEASE(_distanceLabel);
    QY_VIEW_RELEASE(_hotelStarLabel);
    QY_VIEW_RELEASE(_hotelNameLabel);
    QY_VIEW_RELEASE(_imageView_hotel);
    QY_VIEW_RELEASE(_hotelNearbyBackBgView);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        //背景:
        _hotelNearbyBackBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
        _hotelNearbyBackBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_hotelNearbyBackBgView];
        
        
        //酒店图片:
        _imageView_hotel = [[UIImageView alloc] initWithFrame:CGRectMake(positionX, 11, 100, 66)];
        _imageView_hotel.backgroundColor = [UIColor clearColor];
        [_hotelNearbyBackBgView addSubview:_imageView_hotel];
        
        
        //酒店名称:
        _hotelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_hotel.frame.origin.x+_imageView_hotel.frame.size.width+intervalX, 11, 145, 20)];
        _hotelNameLabel.backgroundColor = [UIColor clearColor];
        _hotelNameLabel.textAlignment = NSTextAlignmentLeft;
        _hotelNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
        _hotelNameLabel.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [_hotelNearbyBackBgView addSubview:_hotelNameLabel];
        
        
        //距离:
        if(ios7)
        {
            _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_hotelNameLabel.frame.origin.x+_hotelNameLabel.frame.size.width, _hotelNameLabel.frame.origin.y+5, 45, 14)];
        }
        else
        {
            _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_hotelNameLabel.frame.origin.x+_hotelNameLabel.frame.size.width, _hotelNameLabel.frame.origin.y+2, 45, 16)];
        }
        _distanceLabel.backgroundColor = [UIColor clearColor];
        _distanceLabel.adjustsFontSizeToFitWidth = YES;
        _distanceLabel.textAlignment = NSTextAlignmentRight;
        _distanceLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        _distanceLabel.textColor = [UIColor colorWithRed:102/255. green:102/255. blue:102/255. alpha:1];
        [_hotelNearbyBackBgView addSubview:_distanceLabel];
        
        
        
        //星级:
        _hotelStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_hotel.frame.origin.x+_imageView_hotel.frame.size.width+intervalX, _hotelNameLabel.frame.size.height+_hotelNameLabel.frame.origin.y, 190, 16)];
        _hotelStarLabel.backgroundColor = [UIColor clearColor];
        _hotelStarLabel.textAlignment = NSTextAlignmentLeft;
        _hotelStarLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        _hotelStarLabel.textColor = [UIColor colorWithRed:102/255. green:102/255. blue:102/255. alpha:1];
        [_hotelNearbyBackBgView addSubview:_hotelStarLabel];
        
        
        
        //货币单位:
        if(ios7)
        {
            _currencycodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_hotel.frame.origin.x+_imageView_hotel.frame.size.width+intervalX, _imageView_hotel.frame.origin.y+_imageView_hotel.frame.size.height-16, 40, 16)];
        }
        else
        {
            _currencycodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_hotel.frame.origin.x+_imageView_hotel.frame.size.width+intervalX, _imageView_hotel.frame.origin.y+_imageView_hotel.frame.size.height-16+4, 40, 20)];
        }
        _currencycodeLabel.backgroundColor = [UIColor clearColor];
        _currencycodeLabel.textAlignment = NSTextAlignmentLeft;
        _currencycodeLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
        _currencycodeLabel.textColor = [UIColor colorWithRed:102/255. green:102/255. blue:102/255. alpha:1];
        [_hotelNearbyBackBgView addSubview:_currencycodeLabel];
        
        
        
        //价格:
        if(ios7)
        {
            _hotelPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_currencycodeLabel.frame.origin.x+_currencycodeLabel.frame.size.width, _currencycodeLabel.frame.origin.y-4, 150, 20)];
        }
        else
        {
            _hotelPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_currencycodeLabel.frame.origin.x+_currencycodeLabel.frame.size.width, _currencycodeLabel.frame.origin.y-4, 150, 26)];
        }
        _hotelPriceLabel.backgroundColor = [UIColor clearColor];
        _hotelPriceLabel.textAlignment = NSTextAlignmentLeft;
        _hotelPriceLabel.textColor = [UIColor colorWithRed:241./255 green:103./255 blue:0./255 alpha:1];
        _hotelPriceLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:18];
        [_hotelNearbyBackBgView addSubview:_hotelPriceLabel];
        
        
        //分割线:
        _line_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(positionX, _hotelNearbyBackBgView.frame.size.height-0.5, 320-positionX, 0.5)];
        _line_bottom.backgroundColor = [UIColor colorWithRed:211/255. green:211/255. blue:211/255. alpha:1];
        [self addSubview:_line_bottom];
    }
    return self;
}

-(void)setInfoWithArray:(NSArray *)array atPosition:(NSInteger)position
{
    _line_bottom.frame = CGRectMake(positionX, _hotelNearbyBackBgView.frame.size.height-0.5, 320-positionX, 0.5);
    if(position == array.count - 1)
    {
        _line_bottom.frame = CGRectMake(0, _hotelNearbyBackBgView.frame.size.height-0.5, 320, 0.5);
    }
    
    
    GetHotelNearbyPoi *hotelNearbyPoi = (GetHotelNearbyPoi *)[array objectAtIndex:position];
    
    [_imageView_hotel setImageWithURL:[NSURL URLWithString:hotelNearbyPoi.hotelPic] placeholderImage:[UIImage imageNamed:@"hotel_default"]];
    
    
    if(hotelNearbyPoi.englishName && hotelNearbyPoi.englishName.length > 0)
    {
        _hotelNameLabel.text = hotelNearbyPoi.englishName;
    }
    else if(hotelNearbyPoi.chineseName && hotelNearbyPoi.chineseName.length > 0)
    {
        _hotelNameLabel.text = hotelNearbyPoi.chineseName;
    }
    
    
    
    if(hotelNearbyPoi.nearby_poi && hotelNearbyPoi.nearby_poi.length > 0 && hotelNearbyPoi.hotelStar && hotelNearbyPoi.hotelStar.length > 0)
    {
        _hotelStarLabel.text = [NSString stringWithFormat:@"%@ | %@",hotelNearbyPoi.hotelStar,hotelNearbyPoi.nearby_poi];
    }
    else if(hotelNearbyPoi.hotelStar && hotelNearbyPoi.hotelStar.length > 0)
    {
        _hotelStarLabel.text = hotelNearbyPoi.hotelStar;
    }
    
    
    
    float value_float = [hotelNearbyPoi.hotelDistance floatValue]/1000;
    NSString *value = [NSString stringWithFormat:@"%.1f",value_float];
    NSRange range = [value rangeOfString:@".0"];
    if(range.location != NSNotFound)
    {
        value = [value substringToIndex:range.location];
    }
    _distanceLabel.text = [NSString stringWithFormat:@"%@km",value];
    
    
    
    if(hotelNearbyPoi.currency && hotelNearbyPoi.currency.length > 0)
    {
        _currencycodeLabel.text = [NSString stringWithFormat:@"%@",hotelNearbyPoi.currency];
    }
    _hotelPriceLabel.text = hotelNearbyPoi.hotelLowerPrice;
}

-(float)countHotelLabelWidthByString:(NSString*)content andTypeSize:(float)size
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:size] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 999)];
    
    return sizeToFit.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
