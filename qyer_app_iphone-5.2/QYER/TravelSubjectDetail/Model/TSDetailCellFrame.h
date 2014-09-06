//
//  TSDetailCellFrame.h
//  TravelSubject
//
//  Created by chenguanglin on 14-7-21.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TSDetailCellModel;

@interface TSDetailCellFrame : NSObject

@property (nonatomic, strong) TSDetailCellModel *TSDetailModel;

/**
 *  cell的高度
 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;


@property (nonatomic, assign, readonly) CGRect countryNameF;

@property (nonatomic, assign, readonly) CGRect cityNameF;

@property (nonatomic, assign, readonly) CGRect descriptionF;

@property (nonatomic, assign, readonly) CGRect cellFootF;

@end
