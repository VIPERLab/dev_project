//
//  BaseListViewController.h
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "BaseViewController.h"

const int TagLoading = 1000;
const int TagNetFailView = 1001;
const int TagLoadFailView = 1002;
const int TagShadow = 1003;

@interface BaseListViewController : BaseViewController
{
    id musiclibDelegate;
    bool m_bNetFail;
    bool m_bReLoading;
}
@property (nonatomic, assign) id musiclibDelegate;
@end
