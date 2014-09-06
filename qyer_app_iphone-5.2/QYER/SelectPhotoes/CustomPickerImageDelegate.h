//
//  CustomPickerImageDelegate.h
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol CustomPickerImageDelegate <NSObject>

- (void)customImagePickerController:(UIViewController *)picker image:(UIImage *)image imageName:(NSString*)imageName;

@end