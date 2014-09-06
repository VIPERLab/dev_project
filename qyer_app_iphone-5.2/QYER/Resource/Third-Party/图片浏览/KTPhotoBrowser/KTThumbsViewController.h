//
//  KTThumbsViewController.h
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTPhotoBrowserDataSource.h"
#import "KTThumbsView.h"

@class KTThumbsView;
@class SDWebImageDataSource;
@class GetPoiPhotoImages;

@interface KTThumbsViewController : UIViewController <KTThumbsViewDataSource,UIScrollViewDelegate>
{
@private
   id <KTPhotoBrowserDataSource> dataSource_;
   KTThumbsView *scrollView_;
   BOOL viewDidAppearOnce_;
   BOOL navbarWasTranslucent_;
    
    SDWebImageDataSource *images_;
    
    
    
    UIImageView     *_headView;
    UILabel         *_chineseTitleLabel;
    UILabel         *_englishTitleLabel;
    UIButton        *_backButton;
    NSString        *_navigationTitle;
    
    NSString        *_chineseTitle;
    NSString        *_englishTitle;
    UIImage         *_typeImage;   //标示:景点／餐饮／住宿／⋯⋯
    
    GetPoiPhotoImages *_getPoiImages;
    GetPoiPhotoImages *_getAllPoiImages;
    
    NSInteger       _max_id;
    
    BOOL            downloadNewDataFlag;  //某一次加载新数据是否完成
    BOOL            isDownloadAllData;    //是否已经加载完毕所有数据
    
    UITableView     *_myTableView;
    NSMutableArray  *_poiPhotoDataArray;
    NSMutableArray  *_poiAllPhotoDataArray;
    NSMutableArray  *_poiImagesMaxidArray;
    SDWebImageDataSource *allImages_;
    id <KTPhotoBrowserDataSource> allDataSource_;
    
    NSInteger            poiId;
    NSInteger            imagePosition;
}

@property(nonatomic,retain) NSString *navigationTitle;
@property(nonatomic,retain) UIImage  *typeImage;
@property(nonatomic,assign) NSInteger poiId;
@property(nonatomic,assign) NSInteger max_id;
@property(nonatomic,assign) id <KTPhotoBrowserDataSource> dataSource_;

-(void)setNavigationgbarInfo:(NSDictionary *)dic;










@property (nonatomic, retain) id <KTPhotoBrowserDataSource> dataSource;

/**
 * Re-displays the thumbnail images.
 */
- (void)reloadThumbs;

/**
 * Called before the thumbnail images are loaded and displayed.
 * Override this method to prepare. For instance, display an
 * activity indicator.
 */
- (void)willLoadThumbs;

/**
 * Called immediately after the thumbnail images are loaded and displayed.
 */
- (void)didLoadThumbs;

/**
 * Used internally. Called when the thumbnail is touched by the user.
 */
- (void)didSelectThumbAtIndex:(NSUInteger)index;

@end
