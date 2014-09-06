//
//  MineViewController.h
//  QYER
//
//  Created by 我去 on 14-5-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//


#import "BaseViewController.h"
#import "UserMapCell.h"
#import "UserImageViewCell.h"
#import "CCActiotSheet.h"
#import "UserInfo.h"
@class CityLoginViewController;
@class ODRefreshControl;
@class ProduceMyImage;

@interface MineViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UserMapCellDelegate,UserImageViewCellDelegate, CCActiotSheetDelegate>
{
    UIImageView             *_headView;
    
    UITableView             *_tableview_mine;
    BOOL                    _flag_getData;
    UserInfo                *_userInfo;
    NSString                *_type;  //更换头像还是更换头图
    CityLoginViewController *_loginVC;
    
    UIImagePickerController *myPicker;
    ProduceMyImage *_produceMyImage;
    
    
    BOOL _flag_first; //首次加载的标志
    BOOL _flag_loginOut;
    BOOL _reloading;
    
    BOOL _follow_eachother;
    
    NSString *_clickType; //未登录时点击的类型
    
    //下拉刷新:
    ODRefreshControl *_refreshControl;
    
    BOOL _flag_click;
    
    //add by zyh
    UIButton *button_meassage;
}

@property (assign, nonatomic) UIViewController *currentVC;
@property (assign, nonatomic) NSInteger user_id;
@property (retain, nonatomic) NSString *imUserId;
@property (retain, nonatomic) CityLoginViewController *loginVC;
//@property (retain, nonatomic) NSString *from;

-(void)resetView;

@end
