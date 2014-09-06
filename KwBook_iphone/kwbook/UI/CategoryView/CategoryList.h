//
//  CategoryList.h
//  kwbook
//
//  Created by 熊 改 on 13-12-4.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CateListDelegate <NSObject>

-(void)closeCateListViewWithSelectedKey:(NSString *)key; //nil表示没有选中

@end

@interface CategoryList : UIView
@property (nonatomic , weak) id<CateListDelegate> delegate;
//乱序
-(id)initWithCateList:(NSDictionary *)cateDic andFrame:(CGRect)rect defaultKey:(NSString *)theKey;
//有序
-(id)initWithCateList:(NSDictionary *)cateDic andKeyArray:(NSArray *)keys andFrame:(CGRect)rect defaultKey:(NSString *)theKey;
@end