//
//  SubjectViewController.h
//  LastMinute
//
//  Created by lide on 13-10-17.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SMGridView.h"
#import "LastMinuteView.h"
#import "QYOperation.h"
#import "QYBaseViewController.h"
#import "LastMinute.h"

@interface SubjectViewController : QYBaseViewController <SMGridViewDelegate, SMGridViewDataSource, LastMinuteViewDelegate>
{
    UIView              *_gridHeaderView;
    UIImageView         *_backView;
    UIImageView         *_backgroundImageView;
    UILabel             *_contentLabel;
    UIImageView         *_subjectImageView;
    
    SMGridView          *_gridView;
    
    QYOperation         *_operation;
    NSMutableArray      *_lastMinuteArray;
}

@property (retain, nonatomic) NSArray *operationIds;
@property (retain, nonatomic) QYOperation *operation;
@property (retain, nonatomic) NSMutableArray *lastMinuteArray;

@end
