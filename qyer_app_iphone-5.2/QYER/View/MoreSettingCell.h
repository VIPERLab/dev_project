//
//  MoreSettingCell.h
//  QyGuide
//
//  Created by 你猜你猜 on 13-8-28.
//
//

#import <UIKit/UIKit.h>

@interface MoreSettingCell : UITableViewCell
{
    UIImageView     *_imageView_label_nameBackGround;
    UIView          *_view_backGroundColor;
    UILabel         *_label_titleName;
    UILabel         *_label_userName;
    UIImageView     *_imageView_lastCell;
    UIImageView     *_imageView_arrow;
    UISwitch        *_switch_download;          //只在wifi环境下下载锦囊按钮
    BOOL            _flag_noBackGroundColor;   //点击时是否由点击背景
}

@property(nonatomic,retain) UIImageView     *imageView_label_nameBackGround;
@property(nonatomic,retain) UIView          *view_backGroundColor;
@property(nonatomic,retain) UILabel         *label_titleName;
@property(nonatomic,retain) UILabel         *label_userName;
@property(nonatomic,retain) UIImageView     *imageView_lastCell;
@property(nonatomic,retain) UIImageView     *imageView_arrow;
@property(nonatomic,retain) UISwitch        *switch_download;
@property(nonatomic,assign) BOOL            flag_noBackGroundColor;

-(void)setAppWithArray:(NSArray *)_applicationArray;

@end
