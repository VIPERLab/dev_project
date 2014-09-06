//
//  GuideCoverCell.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//


//*** 锦囊详情页 - 锦囊封面大图cell



#import <UIKit/UIKit.h>
@class QYGuide;



#if NS_BLOCKS_AVAILABLE
typedef void (^GuideCoverCellInitSuccessBlock)(UIImage *image);
typedef void (^GuideCoverCellInitFailedBlock)(void);
#endif



@protocol GuideCoverCellDelegate;
@interface GuideCoverCell : UITableViewCell
{
    UIImageView                 *_imageView_cover;
    UIView                      *_view_backGround;
    UILabel                     *_label_downloadTimes;
    UILabel                     *_label_updateTime;
    UILabel                     *_label_pages;
    UILabel                     *_label_guideSize;
    
    
    QYGuide                     *_guide;
    id<GuideCoverCellDelegate>  _delegate;
}
@property(nonatomic,retain) UIImageView *imageView_cover;
@property(nonatomic,retain) UIView      *view_backGround;
@property(nonatomic,retain) UILabel     *label_downloadTimes;
@property(nonatomic,retain) UILabel     *label_updateTime;
@property(nonatomic,retain) UILabel     *label_pages;
@property(nonatomic,retain) UILabel     *label_guideSize;
@property(nonatomic,retain) QYGuide     *guide;
@property(nonatomic,assign) id<GuideCoverCellDelegate>  delegate;
-(void)initCellWithGuide:(QYGuide *)guide
                finished:(GuideCoverCellInitSuccessBlock)successBlock
                  failed:(GuideCoverCellInitFailedBlock)failedBlock;
@end




#pragma mark -
#pragma mark --- GuideCoverCell - Delegate
@protocol GuideCoverCellDelegate <NSObject>
-(void)readGuideWhenClickPic;
-(void)guideDownloadFinished;
@end

