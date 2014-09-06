//
//  RootViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyPlanViewController;
@class RecommendViewController,PlaceViewController,LastMinuteViewController;
@class MineViewController;

typedef enum
{
    recommendVC_state = 0,          //当前选择的是推荐页面
    placeVC_state = 1,              //当前选择的是目的地页面
	reservationVC_state = 2,        //当前选择的是折扣页面
    mine_state = 3,                 //当前选择的是个人中心页面
    
} Selected_ViewController_state;


@interface RootViewController : UIViewController
{
    UIImageView                     *_headView;
    UIImageView                     *_titleImageLogo;
    UIView                          *_footView;
    UIViewController                *_currentViewController;
    
    UIButton                        *_button_recommend;
    UIButton                        *_button_place;
    UIButton                        *_button_reservation;
    UIButton                        *_button_myPlan;
    UIButton                        *_button_mine;
    UIButton                        *_updateCountButton;
    
    
    RecommendViewController         *_recommendVC;  //推荐
    PlaceViewController             *_placeVC;      //目的地
    LastMinuteViewController        *_lastMinuteVC; //折扣
    MineViewController              *_mineVC;       //个人中心
    
    
    Selected_ViewController_state   _selectedVC_state;
    BOOL                            _flag_pushVC;
    
    /**
     *  如果有通知或者私信，小红点，显示出来
     */
    UIImageView *noteImageView;
}

@property(nonatomic,retain) UIViewController    *currentViewController;
@property(nonatomic,retain) UIImageView         *headView;
@property(nonatomic,retain) UIImageView         *titleImageLogo;
@property(nonatomic,retain) UIView              *footView;
@property(nonatomic,retain) UIButton            *updateCountButton;

-(void)end;
-(void)begin;

@end
