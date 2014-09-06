//
//  KBSegmentControl.h
//  kwbook
//
//  Created by 熊 改 on 13-11-28.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KBSegmentProtocol <NSObject>
//当且仅当主动点击导致的index改变会触发该消息，被动调用selectIndex不会触发该方法
-(void)didSegmentControlSelectIndex:(NSUInteger)index;

@end

@interface KBSegmentControl : UIControl

@property (strong, nonatomic) UIView*     selectedStainView;        //阴影效果
@property (strong, nonatomic) UIColor*    segmentTextColor;
@property (strong, nonatomic) UIColor*    selectedSegmentTextColor;
@property (strong, nonatomic) UIImage*    backgroundImage;
@property (assign, nonatomic) NSInteger   selectedSegmentIndex;
@property (weak , nonatomic)  id<KBSegmentProtocol> delegate;

- (id)initWithItems:(NSArray *)items;
-(void)selectIndex:(NSUInteger)index;

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;

- (void)removeAllSegments;
- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;

@end
