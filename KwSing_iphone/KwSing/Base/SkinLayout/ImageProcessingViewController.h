//
//  ImageProcessingView.h
//  KwSing
//
//  Created by 熊 改 on 13-2-25.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageProcessing <NSObject>

-(void)onImageProcessingDone:(UIImage *)image;

@end


@interface ImageProcessingViewController : UIViewController

@property (assign,nonatomic) id<ImageProcessing> delegate;

-(id)initWithImage:(UIImage *)image;

@end
