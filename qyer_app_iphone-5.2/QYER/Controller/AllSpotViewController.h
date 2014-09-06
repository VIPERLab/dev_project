//
//  AllSpotViewController.h
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
#import "CityPoiData.h"
#import "SpotTableView.h"


@interface AllSpotViewController : QYBaseViewController<SpotTableViewDelegate>
{
    
    NSMutableArray *btnsArray;
    
    UIImageView *categoryBackImage;
        
    UIImageView *statueImageView;

}

@property(assign,nonatomic)int select;

@property(nonatomic,retain)NSString *cityId;
@property(nonatomic,retain)NSString *cityName;
@end
