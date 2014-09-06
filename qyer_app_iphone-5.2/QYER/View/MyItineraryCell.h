//
//  MyItineraryCell.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-10.
//
//

#import <UIKit/UIKit.h>
@class UserItinerary;
@class Plan;

@interface MyItineraryCell : UITableViewCell
{
    UIView          *_view_bg;
    UIImageView     *_imageView_background;
    UIView          *_view_background;
    
    UIImageView     *_shadeImageView;       //阴影
    
    UIImageView     *_imageView_itinerary;  //行程的封面照
    UILabel         *_label_itineraryName;  //行程的名称
    UILabel         *_label_itineraryPath;  //行程路线
    UILabel         *_label_updateTime;     //最后更新时间
    UILabel         *_label_days;           //游玩天数
    UILabel         *_label_userName;       //用户名
    UIImageView     *_imageView_user;       //用户头像
    UIImageView     *_imageView_lastCell;
    
    UILabel         *_label_city;
    UILabel         *_label_verticalLine;
    
    UIView          *_back_click_view;      //点下去的阴影
}
@property(nonatomic,retain) UIImageView     *imageView_background;
@property(nonatomic,retain) UIImageView     *imageView_itinerary;  //行程的封面照
@property(nonatomic,retain) UILabel         *label_itineraryName;  //行程的名称
@property(nonatomic,retain) UILabel         *label_itineraryPath;  //行程路线
@property(nonatomic,retain) UILabel         *label_updateTime;     //最后更新时间
@property(nonatomic,retain) UILabel         *label_days;           //游玩天数
@property(nonatomic,retain) UILabel         *label_userName;       //用户名
@property(nonatomic,retain) UIImageView     *imageView_user;       //用户头像
@property(nonatomic,retain) UIImageView     *imageView_lastCell;
@property(nonatomic,retain) UILabel         *label_verticalLine;

@property(nonatomic,retain) UIView          *back_click_view;      //点下去的阴影
-(void)initMyPlanContentAtPosition:(NSInteger)position WithArray:(NSArray *)array;  //我的行程
-(void)initContentAtPosition:(NSInteger)position WithArray:(NSArray *)array;        //推荐行程
-(void)updateCell:(NSDictionary *)planData;

@end
