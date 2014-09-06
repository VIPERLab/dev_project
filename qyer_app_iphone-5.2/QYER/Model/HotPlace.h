//
//  HotPlace.h
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotPlace : NSObject <NSCoding>
{
    NSString *_str_placeId;
    NSString *_str_placePhoto;
    NSString *_str_placeCatename;
}

@property(nonatomic,retain) NSString *str_placeId;
@property(nonatomic,retain) NSString *str_placePhoto;
@property(nonatomic,retain) NSString *str_placeCatename;

@end
