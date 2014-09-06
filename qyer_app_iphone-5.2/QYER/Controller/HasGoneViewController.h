//
//  HasGoneViewController.h
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WantGo_hasGoneCell.h"

@interface HasGoneViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,WantGo_hasGoneCellDelegate>
{
    UIImageView         *_headView;
    NSMutableArray      *_array_country;
    NSMutableArray      *_array_country_en;
    NSMutableDictionary *_dic_hasGone;
    UITableView         *_tableView_hasGone;
    UIImageView         *_imageView_failed;
    UIImageView         *_imageView_default;
}

@property(nonatomic,assign) NSInteger user_id;
@property(nonatomic,assign) NSString *titleName;

@end
