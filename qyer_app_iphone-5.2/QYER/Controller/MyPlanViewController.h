//
//  MyPlanViewController.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-10.
//
//

#import <UIKit/UIKit.h>

@interface MyPlanViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    UIScrollView        *_view_backGround;
    UIButton            *_button_back;
    UITableView         *_tableView_itineraryVC;
    NSMutableArray      *_array_myItinerary;
    UIControl           *_imageView_failed;
    UIImageView         *_headView;
}

@property (retain, nonatomic) NSString         *userId;
@property (assign, nonatomic) NSMutableArray   *array_myItinerary;
@property (assign, nonatomic) UITableView      *tableView_itineraryVC;
@property (assign, nonatomic) UIViewController *currentVC;

@end
