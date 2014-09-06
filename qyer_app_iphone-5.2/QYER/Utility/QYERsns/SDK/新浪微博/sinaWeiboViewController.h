//
//  sinaWeiboViewController.h
//  TEST
//
//  Created by an qing on 12-11-20.
//  Copyright (c) 2012年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SinaWeibo.h"
#import "ImageCropper.h"
//@class ProduceMyImage;

@interface sinaWeiboViewController : UIViewController<UITextViewDelegate,CLLocationManagerDelegate,ImageCropperDelegate,UIActionSheetDelegate>
{
    UITextView *textV;
    UIView *myInputAccessoryView;
    UILabel *shuziLabel;
    UIImage *shareImage;
    UIImageView *showImageView;      //显示图片的imageview
    UIView *shareView;               //showImageView的父视图
    UIImageView *takePhotoImageView; //拍照按钮
    BOOL isWordTooLong;              //发布的文字超出140时的标志
    
    UIImageView *_headView;
    UILabel *_titleLabel;
    
    //定位:
    BOOL isDingweiFlag;              //是否进行定位的标志
    UIImageView *positionImageView;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D theCenter;
    NSString *weidu;
    NSString *jingdu;
    
    ImageCropper *myCropper;
//    ProduceMyImage *myProduceMyImage;
}
@property(nonatomic,assign) BOOL isWordTooLong;
@property(nonatomic,retain) UITextView *textV;
@property(nonatomic,retain) UIImage *shareImage;
@property(nonatomic,retain) UIImageView *showImageView;
@property(nonatomic,retain) NSString *str_title;

-(void)initTitle:(NSString *)title;
-(void)initImageView:(UIImage *)image;
-(void)setShuziLabelNumber;
/**
 *  insert by yihui
 */
/**
 *  默认type是0，新浪微博
    if type = 1 ，腾讯微博
 */
@property (nonatomic, assign) int type;
@end
