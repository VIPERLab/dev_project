//
//  bannerRootView.h
//  QYER
//
//  Created by chenguanglin on 14-7-11.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, bannerType) {
    BannerTypePlace = 0,
    BannerTypeBBS  = 1,
    BannerTypeMyLastMin = 2
};

@protocol bannerRootViewDelegate <NSObject>

- (void)DiscountClick:(long)ID;

- (void)tripClick:(NSString *)viewURL;

- (void)placeClick:(long)ID;

@end



@interface bannerRootView : UIView

@property (nonatomic, assign) id<bannerRootViewDelegate>delegate;

@property (nonatomic, assign) int type;

@property (nonatomic, strong) NSArray *mayLikePlaceModelArray;

@property (nonatomic, strong) NSArray *mayLikeBBSModelArray;

@property (nonatomic, strong) NSArray *mayLikeMyLastMinModelArray;

@end
