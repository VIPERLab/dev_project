//
//  GoneAndWantGoCities.h
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoneAndWantGoCities : NSObject
{
    NSString        *_city_cn;
    NSString        *_city_en;
    NSString        *_city_idstring;
    NSMutableArray  *_array_poiInfo;
}
@property(nonatomic,retain) NSString        *city_cn;
@property(nonatomic,retain) NSString        *city_en;
@property(nonatomic,retain) NSString        *city_idstring;
@property(nonatomic,retain) NSMutableArray  *array_poiInfo;
@end
