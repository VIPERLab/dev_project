//
//  GuideViewCell.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-4.
//  Copyright (c) 2013年 an qing. All rights reserved.
//



//*** 展示锦囊详情的cell



#import <UIKit/UIKit.h>
#import "DownloadData.h"
#import "QAControl.h"
@class QYGuide;
@class CustomProessView;



@protocol GuideViewCellDelegate;
@interface GuideViewCell : UITableViewCell <DownloadDataDelegate>
{
    UIImageView         *_imageViewBackGround;
    
    UIImageView         *_imageView_cover;                  //锦囊封面
    UIImageView         *_imageView_cover_NewOrUpdate;      //根据'是否是新锦囊或是否需要更新'的不同情况显示不同的图片
    UILabel             *_label_guideName;                  //锦囊名称
    UILabel             *_label_guideBelongtoCountryName;   //锦囊所属国家名称
    UILabel             *_label_guideDownloadTimes;         //锦囊下载次数
    UILabel             *_label_guideUpdateTime;            //锦囊更新时间
    UILabel             *_label_progress;                   //显示锦囊的下载进度
    UIButton            *_button_fuction;                   //'下载／阅读／暂停'按钮
    UILabel             *_label_fileSize;                   //锦囊文件大小
    UIImageView         *_imageView_lastCell;
    
    QAControl           *_detailControl;
    
    UIProgressView    *_progressView;                     //记录下载进度
    //CustomProessView    *_progressView;                     //记录下载进度
    NSInteger           _position_section;                  //guide在数组中的位置
    NSInteger           _position_row;                      //guide在数组中的位置
    QYGuide             *_guide;
    
    id<GuideViewCellDelegate>   _delegate;
    UILabel             *_bottomLine;
}
@property(nonatomic,retain) UIImageView     *imageViewBackGround;

@property(nonatomic,retain) UIImageView     *imageView_cover;                  //锦囊封面
@property(nonatomic,retain) UIImageView     *imageView_cover_NewOrUpdate;
@property(nonatomic,retain) UILabel         *label_guideName;                  //锦囊名称
@property(nonatomic,retain) UILabel         *label_guideBelongtoCountryName;   //锦囊所属国家名称
@property(nonatomic,retain) UILabel         *label_guideDownloadTimes;         //锦囊下载次数
@property(nonatomic,retain) UILabel         *label_guideUpdateTime;            //锦囊更新时间
@property(nonatomic,retain) UILabel         *label_fileSize;                   //锦囊文件大小
@property(nonatomic,retain) UILabel         *label_progress;                   //显示锦囊的下载进度
@property(nonatomic,retain) UIButton        *button_fuction;                   //'下载／阅读／暂停'按钮
@property(nonatomic,retain) UIProgressView  *progressView;
@property(nonatomic,assign) NSInteger       position_section;
@property(nonatomic,assign) NSInteger       position_row;
@property(nonatomic,retain) QYGuide         *guide;
@property(nonatomic,assign) id<GuideViewCellDelegate>   delegate;
@property(nonatomic,assign) BOOL            flag_isInDownloadigVC;
@property(nonatomic,retain) UILabel         *bottomLine;
@property(nonatomic,retain) UIImageView     *imageView_lastCell;
@property(nonatomic,retain) NSString        *where_from;
-(void)resetCell;
-(void)initCellWithArray:(NSArray *)array_guide atPosition:(NSInteger)position;
-(void)button_selected:(id)sender;
-(void)initProgressView:(QYGuide *)guide_;
-(void)changeButtonFuctionStateAndImage_ProgressLabelState;
-(void)freshCellWithGuide:(QYGuide *)guide_;
@end




#pragma mark -
#pragma mark --- GuideViewCell - Delegate
@protocol GuideViewCellDelegate <NSObject>
-(void)guideViewCellSelectedDetail:(GuideViewCell *)cell;
-(void)guideViewCellSelectedReadGuide:(GuideViewCell *)cell;
-(void)guideViewCellCancleDownload:(GuideViewCell *)cell;
@end

