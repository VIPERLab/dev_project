//
//  PhotoListController.h
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//


/**
 
 自定义相册调用方法
 PhotoListController *photoVc = [[PhotoListController alloc]init];
 photoVc.delegate = self;
 UINavigationController *navPhoto = [[UINavigationController alloc]initWithRootViewController:photoVc];
 navPhoto.navigationBar.hidden = YES;
 [self presentViewController:navPhoto animated:YES completion:nil];
 [photoVc release];
 
 需在当前控制器，实现CustomPickerImageDelegate方法
-(void)customImagePickerController:(UIViewController *)picker image:(UIImage *)image{
 
 拿到image
 [picker dismissViewControllerAnimated:YES completion:nil];
 
 
 }
 
 
 */


#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CustomPickerImageDelegate.h"

@interface PhotoListController : QYBaseViewController<UITableViewDelegate,UITableViewDataSource,CustomPickerImageDelegate,UIAlertViewDelegate>
{
    ALAssetsLibrary *assetLibrary;
    NSMutableArray *muArrPhotoes;
    UITableView *mainTable;
    int index;

    NSMutableData * _photoData;
    NSString *_selectedImageName;
}

@property(nonatomic,assign)id delegate;

@end



