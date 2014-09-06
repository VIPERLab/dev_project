//
//  GoneAndWantGoCitiesViewController.h
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WantGo_hasGoneCitiesCell.h"

@interface GoneAndWantGoCitiesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,WantGo_hasGoneCitiesCellDelegate>
{
    UIImageView         *_headView;
    NSMutableArray      *_array_GoneAndWantGoCities;
    UITableView         *_tableView_GoneAndWantGoCities;
    NSInteger           _pageNumber;
    BOOL                _flag_delay;
    UIImageView         *_imageView_default;
    CGPoint             point_src;
    BOOL                _flag_fresh;
}

@property(nonatomic,assign) NSInteger user_id;
@property(nonatomic,assign) NSInteger city_id;
@property(nonatomic,assign) NSString  *titleName;
@property(nonatomic,assign) NSString  *type;   //wantgo or hasgone

@end
