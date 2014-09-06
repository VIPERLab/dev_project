//
//  picturePickerView.h
//  playPictures
//
//  Created by 改 熊 on 12-7-26.
//  Copyright (c) 2012年 kuwo. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <vector>
using std::vector;

//imageView.size
#define WIDTH 55
#define HEIGHT 55
//gap between two imageView
#define GAP  10

#define UPGAP 14
//button X size
#define BUTTON_WIDTH 20
#define BUTTON_HEIGHT 20

#define EDGE_WIDTH 6

#define MAX_NUM_IMAGES 10

#define EDGE "pictureBackground@2x.png"
#define ADD_IMAGE_BUTTON "addImageButton@2x.png"
#define CLOSE_X "close_X@2x.png"

//实现协议，获取选择的图片
@protocol imageSelectedDelegate 

-(void)onImageSelected:(UIImage *)selectImage;     
-(void)onAddImage:(UIImage *)addImage;
@end
@protocol imageListChanged <NSObject>

-(void)deleleImage:(NSString *)imagePath;
-(void)addImage:(NSString *)imagePath;

@end

@class playPicturesView;

@interface picturePickerView : UIView<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    std::vector<UIImage*> _imageList;
    std::vector<NSString*> _imagePathList;       //对应imageList,删除的时候同时删除文件
    UIScrollView* sview;
    CGPoint position;                            //当前位置，重绘需要
    BOOL isReLoad;
    CGRect allRect;
    UIButton *addButton;
    UIImageView* addImageEdge;
    id<imageSelectedDelegate> delegate;
}
@property (nonatomic) std::vector<UIImage*> imageList;
@property (nonatomic) std::vector<NSString*> imagePathList;
@property (retain,nonatomic) UIScrollView* sview;
@property (nonatomic) CGPoint position;
@property (nonatomic) CGRect allRect;
@property (retain,nonatomic) UIButton *deletaButton;
@property (retain,nonatomic) UIButton *addButton;
@property (retain,nonatomic) UIImageView *addImageEdge;
@property (assign,nonatomic) id<imageSelectedDelegate> delegate;
@property (assign,nonatomic) playPicturesView<imageListChanged> *playView;

- (id)initWithFrame:(CGRect)frame;  
- (std::vector<UIImage *>)getImageList;
- (void)setImagePathList:(std::vector<NSString *>)imagePathList;
- (void)onImageProsessingDone:(UIImage *)image;
@end
