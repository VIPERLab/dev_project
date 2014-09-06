//
//  specialGuideListViewController.h
//  QyGuide
//
//  Created by an qing on 12-12-28.
//
//

#import <UIKit/UIKit.h>
#import "GuideViewCell.h"
#import "GetRemoteNotificationData.h"


@interface specialGuideListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,GuideViewCellDelegate>
{
    UILabel                     *_titleDetailLabel;
    UILabel                     *_contentLabel;
    UIImageView                 *_headView;
    UIButton                    *_backButton;
    UILabel                     *_titleLabel;
    UITableView                 *_tableView_specialGuideListVC;
    NSString                    *_navigationTitle;
    NSString                    *_content;
    NSMutableArray              *_array_specialGuide;
    NSString                    *_guideName_needUpdate;
    
    NSInteger                   _position_section_tapCell;  //点击cell的位置section
    NSInteger                   _position_row_tapCell;      //点击cell的位置row
    
    BOOL                        resetFlag;
    GetRemoteNotificationData   *pushClass;
}

@property(nonatomic,retain) NSMutableArray *array_specialGuide;
@property(nonatomic,retain) NSString *navigationTitle;
@property(nonatomic,retain) NSString *content;
@property(nonatomic,assign) BOOL fromPushFlag;

-(void)getRemoteNotificationClass:(GetRemoteNotificationData *)class;

@end
