//
//  ProduceMyImage.h
//  PackingList
//
//  Created by 安庆 安庆 on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProduceMyImage : NSObject <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *myPicker;
    UIImage *myImage;
    UIViewController *VC;
    NSInteger myFlag;    //是拍照还是从照片库选择的标志(0/1说明是新浪微博;2/3定义为人人网)
}

@property(nonatomic,retain) UIImage *myImage;

-(void)produceImage:(NSInteger)flag;
-(void)getVC:(UIViewController *)vc;
-(void)selectImageFromAlbum;         //从相册库选取
-(void)takePhoto;                    //拍照


@end

