//
//  SearchTipView.h
//  KwSing
//
//  Created by Hu Qian on 12-11-26.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSMusicLibDelegate.h"

@protocol SearchTipDelegate <NSObject>
- (id)GetSearchHistory;
-(void)SelectTip:(NSString*)word;
-(void)ScrollTip;
-(void)ClearSearchHistroy;
-(void)DeleteSearchHistroy:(id)key;
@end


@interface SearchTipView : UIView
{
    NSString * inputWord;
    id<SearchTipDelegate> searchdelegate;
}

@property (nonatomic,assign) id searchdelegate;
-(void)setInputWord:(NSString *)Word;
@end


