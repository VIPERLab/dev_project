//
//  PoiPhotoBrowserViewController.h
//  QyGuide
//
//  Created by an qing on 13-2-19.
//
//

#import <UIKit/UIKit.h>
#import "PoiImageCell.h"
#import "QYBaseViewController.h"

#import "KTPhotoBrowserDataSource.h"
@class SDWebImageDataSource;
@class GetPoiPhotoImages;
@class KTPhotoScrollViewController;

@interface PoiPhotoBrowserViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,PoiImageCellDelegate,UIScrollViewDelegate>
{
    SDWebImageDataSource            *allImages_;
    id <KTPhotoBrowserDataSource>   allDataSource_;
    NSMutableArray                  *_poiAllPhotoDataArray;
    GetPoiPhotoImages               *_getAllPoiImages;
    NSMutableArray                  *_poiImagesMaxidArray;
    NSInteger                       imagePosition;
    UIView                          *_footView;
    UIActivityIndicatorView         *_activityView;
    NSDictionary                    *_dic_navation;
    UIImageView                     *_headView;
    UILabel                         *_chineseTitleLabel;
    UILabel                         *_englishTitleLabel;
    UIButton                        *_backButton;
    NSString                        *_navigationTitle;
    NSString                        *_chineseTitle;
    NSString                        *_englishTitle;
    UIImage                         *_typeImage;   //标识:景点／餐饮／住宿／⋯⋯
    NSInteger                       _max_id;
    BOOL                            downloadNewDataFlag;  //某一次加载新数据是否完成
    BOOL                            isDownloadAllData;    //是否已经加载完毕所有数据
    UITableView                     *_myTableView;
    NSMutableArray                  *_poiPhotoDataArray;
    NSInteger                       poiId;
    NSInteger                       count;
    
    BOOL                            _flag_unavailable;
    
    NSInteger page;
    NSInteger pageSize;
}

@property(nonatomic,retain) NSDictionary *dic_navation;
@property(nonatomic,retain) NSString *navigationTitle;
@property(nonatomic,retain) UIImage  *typeImage;
@property(nonatomic,assign) NSInteger poiId;
@property(nonatomic,assign) NSInteger max_id;

/**
 分类：country city poi
 */
@property(nonatomic,retain) NSString *strType;
-(void)setNavigationgbarInfo:(NSDictionary *)dic;

@end
