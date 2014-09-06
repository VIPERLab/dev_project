//
//  WantGoViewController.h
//  QYER
//
//  Created by 我去 on 14-5-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WantGo_hasGoneCell.h"

@interface WantGoViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,WantGo_hasGoneCellDelegate>
{
    UIImageView         *_headView;
    NSMutableArray      *_array_country;
    NSMutableArray      *_array_country_en;
    NSMutableDictionary *_dic_wantGo;
    UITableView         *_tableView_wantGo;
    UIImageView         *_imageView_failed;
    UIImageView         *_imageViewDefault;
}

@property(nonatomic,assign) NSInteger user_id;
@property(nonatomic,assign) NSString *titleName;

@end
