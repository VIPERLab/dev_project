//
//  RichGMSMarker.h
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-11.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface RichGMSMarker : GMSMarker  <NSCoding>
{
    NSString        *_title;            //chinesetitle
    NSString        *_subtitle;         //englishtitle
    NSString        *_imageUrlString;
    
    NSString        *_poiId;
    NSString        *_cateId;
}

@property (nonatomic,retain) NSString       *title;
@property (nonatomic,retain) NSString       *subtitle;
@property (nonatomic,retain) NSString       *imageUrlString;
@property (nonatomic,retain) NSString       *poiId;
@property (nonatomic,retain) NSString       *cateId;

@end
