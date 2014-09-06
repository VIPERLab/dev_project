//
//  LoadMore.h
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadMoreView : UIView
{
    
}
@property(nonatomic,assign)BOOL isHaveData;

-(void)changeLoadingStatus:(BOOL)isLoading;
@end
