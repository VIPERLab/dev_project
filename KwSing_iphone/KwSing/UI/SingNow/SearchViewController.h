//
//  SearchViewController.h
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "BaseListViewController.h"
#include "KSMusicLibDelegate.h"


@interface SearchViewController : BaseListViewController
{
    NSString * searchWord;
}
@property (nonatomic, retain) NSString * searchWord;
@end
