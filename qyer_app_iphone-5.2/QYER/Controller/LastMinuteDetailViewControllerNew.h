//
//  LastMinuteDetailViewController.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-10.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LastMinute.h"
#import "LastMinuteDetail.h"
//#import "DetailCell.h"
#import "BookView.h"
//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"

@interface LastMinuteDetailViewControllerNew : QYLMBaseViewController </*UITableViewDelegate, UITableViewDataSource, DetailCellDelegate,*/ BookViewDelegate>
{
//    UIButton        *_collectButton;
//    UIButton        *_cancelCollectButton;
//    UIButton        *_shareButton;
    
//    UITableView     *_tableView;
//    UIImageView     *_tableHeaderView;
//    UIImageView     *_tableFooterView;
    
//    UILabel         *_lmTitleLabel;
//    UIImageView     *_lmImageView;
//    UIImageView     *_lmImageMask;
//    UIImageView     *_qyerOnlyImageView;
//    UIImageView     *_qyerFirstImageView;
    
//    UIImageView     *_iconTime;
//    UIImageView     *_lineImageView;
//    UIImageView     *_iconPrice;
    
    
    UILabel         *_lmTimeLabel;
//    UILabel         *_prefixLabel;
//    UILabel         *_priceLabel;
//    UILabel         *_suffixLabel;
//    UILabel         *_lmDiscountLabel;
//    UILabel         *_codeLabel;
    UIButton        *_lmBookButton;
    
//    NSMutableArray  *_detailArray;
    NSMutableArray  *_relatedArray;
    
//    LastMinute      *_lastMinute;
//    LastMinuteDetail    *_detail;
    NSUInteger      _lastMinuteId;
//    NSString        *_lastMinuteTitle;
    
    BOOL            _isLoading;
}

//@property (retain, nonatomic) LastMinute *lastMinute;
@property (assign, nonatomic) NSUInteger lastMinuteId;
//@property (retain, nonatomic) NSString *lastMinuteTitle;
@property (retain, nonatomic) NSString *source;

@end
