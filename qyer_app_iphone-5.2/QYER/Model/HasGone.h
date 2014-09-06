//
//  HasGone.h
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HasGone : NSObject
{
    NSString        *_country_cn;
    NSString        *_country_en;
    NSString        *_country_idstring;
    NSMutableArray  *_array_cityInfo;
}
@property(nonatomic,retain) NSString        *country_cn;
@property(nonatomic,retain) NSString        *country_en;
@property(nonatomic,retain) NSString        *country_idstring;
@property(nonatomic,retain) NSMutableArray  *array_cityInfo;
@end
