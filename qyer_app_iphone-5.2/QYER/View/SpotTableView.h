//
//  SpotTableView.h
//  QYER
//
//  Created by 张伊辉 on 14-4-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadMoreView.h"
#import "CityPoiData.h"
#import "SpotCell.h"
#import "Toast+UIView.h"


@protocol SpotTableViewDelegate <NSObject>

-(void)spotTableViewdidSelectRowAtIndexPath:(CityPoi *)citypoi;
@optional
-(void)changeAllSpotWithIsHaveData:(BOOL)flag;
-(void)changeNotReachableView:(BOOL)flag;
-(void)showMapBtn:(BOOL)flag;

@end
@interface SpotTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
{
    
    
    NSMutableArray *muArrData;
    BOOL isLoading;
    LoadMoreView *footView;
    
    NSString *_cityId;
    NSString *_cateType;
    
    int page;
}
@property(nonatomic,assign)id<SpotTableViewDelegate>spotTableDelegate;
- (id)initWithFrame:(CGRect)frame cityId:(NSString *)cityId cateType:(NSString *)cateType;
- (void)requestData;
@end
