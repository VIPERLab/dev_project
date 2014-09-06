//
//  SegmentControlDelegate.h
//  KWPlayer
//
//  Created by mistyzyq on 11-10-15.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//  从音乐盒搬过来

#import <UIKit/UIKit.h>

@class SegmentControl;

@protocol SegmentControlDelegate

- (void) segmentControl:(SegmentControl*)segmentControl selectedItemChanged:(NSUInteger)index;

@end
