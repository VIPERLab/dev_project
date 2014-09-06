//
//  MyCallOutAnnotationView.h
//  OnLineMap
//
//  Created by an qing on 13-1-30.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <MapKit/MapKit.h>
@protocol MYCalloutPopViewDelegate;
@class CalloutButton;

@interface MyCallOutAnnotationView : MKAnnotationView
{
    UIView                  *_bgView;
    NSString                *_title;
    NSString                *_subtitle;
    NSString                *_cateIdStr;
    NSInteger               _poiId;
    float                   _lat;
    float                   _lng;
    UIImageView             *_rightArrowImageV;
    float                   positionX;
    float                   positionLastX;
    BOOL                    _hasRightArrow;
    CalloutButton           *_readPoiDetailInfoButton;
    UIButton                *_turnToSystemMapButton;
    BOOL                    _isRightButtonEnabled;
    
    UIImageView             *_imageView_pop;
    UIImageView             *_imageView_poi;
    
    id<MYCalloutPopViewDelegate> delegate;
    
}
@property (nonatomic,retain) UIView             *bgView;
@property (nonatomic,retain) UIImageView        *contentView;
@property (nonatomic,retain) UIImageView        *rightArrowImageV;
@property (nonatomic,retain) UIImage            *backgroundImage;
@property (nonatomic,assign) NSInteger          poiId;
@property (nonatomic,assign) BOOL               hasRightArrow;
@property (nonatomic,assign) float              lat;
@property (nonatomic,assign) float              lng;
@property (nonatomic,assign) id<MYCalloutPopViewDelegate> delegate;
@property (nonatomic,assign) BOOL isRightButtonEnabled;
@property (nonatomic,retain) UIImageView *imageView_poi;

@property (nonatomic,retain) NSString           *title;
@property (nonatomic,retain) NSString           *subtitle;
@property (nonatomic,retain) NSString           *cateIdStr;

@property (nonatomic,retain) CalloutButton      *readPoiDetailInfoButton;
@property (nonatomic,retain) UIButton           *turnToSystemMapButton;

-(void)setBackgroundImage:(UIImage*)image;
-(void)setMyPopView;
-(void)initStartViewWithGrade:(NSInteger)grade;

@end





#pragma mark -
#pragma mark --- MYCalloutPopViewDelegate
@protocol MYCalloutPopViewDelegate <NSObject>
-(void)popViewDidSelectedWithType:(NSString*)type andTitle:(NSString*)title andSubtitle:(NSString*)subtitle andLat:(float)lat andLng:(float)lng andPoiId:(NSInteger)poi_id;
@end

