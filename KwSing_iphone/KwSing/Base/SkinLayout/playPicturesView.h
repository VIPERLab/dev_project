//
//  playPicturesView.h
//  KwSing
//
//  Created by 改 熊 on 12-7-26.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//
#import "picturePickerView.h"
#import <UIKit/UIKit.h>
#include <vector>
using std::vector;


@interface playPicturesView : UIView<imageListChanged>
{
    UIImageView *bView;
    UIImageView *aView;
    UIImageView *defaultView;
    std::vector<NSString*> _imageList;
    std::vector<NSString*>::iterator iter;
    NSTimer *time;
    BOOL isBegin;
    bool isPlaying;
}
@property (nonatomic) std::vector<NSString*> imageList;

-(void)onTimer;
-(void)startPlay;
-(void)stop;
-(void)setImageList:(std::vector<NSString *>)imageList;

@end
