//
//  KSMvSongViewController.h
//  KwSing
//
//  Created by 单 永杰 on 13-11-5.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSMvSongViewController : UIViewController{
    NSString* mvResource;
    NSString* mvRid;
}

@property (retain, nonatomic) NSString* _mvResource;
@property (retain, nonatomic) NSString* _mvRid;

@end
