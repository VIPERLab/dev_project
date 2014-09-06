//
//  SpotTableView.m
//  QYER
//
//  Created by 张伊辉 on 14-4-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "SpotTableView.h"

@implementation SpotTableView

- (id)initWithFrame:(CGRect)frame cityId:(NSString *)cityId cateType:(NSString *)cateType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        muArrData = [[NSMutableArray alloc]init];
        page = 1;
        
        _cityId = [cityId retain];
        _cateType = [cateType retain];
        
        
        self.backgroundColor = [UIColor clearColor];
        self.separatorColor = [UIColor clearColor];
        
        self.delegate = self;
        self.dataSource = self;
        
        footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
        footView.hidden = YES;
        [self setTableFooterView:footView];
        [footView release];
        
        
        

    }
    return self;
}
- (void)requestData{
    
   [self.spotTableDelegate changeAllSpotWithIsHaveData:YES];

    if (muArrData.count == 0) {
        
        if (isLoading == NO) {
            //开始加载设置为yes
            isLoading = YES;
            [self makeToastActivityOffsetTop];
            
            [CityPoiData getCityPoiDataByCityId:_cityId andCategoryId:_cateType pageSize:reqNumber page:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array_guideData) {
                
                if (array_guideData.count == 0) {
                    
                    [self.spotTableDelegate changeAllSpotWithIsHaveData:NO];
                    
                }else{
                    [self.spotTableDelegate changeAllSpotWithIsHaveData:YES];
                    
                    [muArrData addObjectsFromArray:array_guideData];
                    [self reloadData];
                    
                    page ++;
                    if (array_guideData.count < [reqNumber intValue]) {
                        footView.hidden = YES;
                    }else{
                        footView.hidden = NO;
                    }
                }
                
                /**
                 *  控制地图按钮是否显示，如果有数据显示。
                 */
                if (array_guideData.count == 0) {
                    
                    [self.spotTableDelegate showMapBtn:YES];
                }else{
                    [self.spotTableDelegate showMapBtn:NO];
                }
                
                [self.spotTableDelegate changeNotReachableView:NO];
                
                [self hideToastActivity];
                isLoading = NO;
                
            } failed:^{
                
                [self.spotTableDelegate changeNotReachableView:YES];
                
                /**
                 *  控制地图按钮是否显示，如果有数据显示。
                 */
                [self.spotTableDelegate showMapBtn:YES];

                
                [self hideToastActivity];

                isLoading = NO;
                
            }];
        }
        
    }
    
    else
    {
        /**
         *  控制地图按钮是否显示，如果有数据显示。
         */
        [self.spotTableDelegate showMapBtn:NO];
    }
}
#pragma mark
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 88;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return muArrData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *strInd = @"cell";
    SpotCell *cell = [tableView dequeueReusableCellWithIdentifier:strInd];
    if (cell == nil) {
        cell = [[[SpotCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strInd] autorelease];
    }
    [cell setCityPoi:[muArrData objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [self.spotTableDelegate spotTableViewdidSelectRowAtIndexPath:[muArrData objectAtIndex:indexPath.row]];
    
    NSLog(@"didSelectRowAtIndexPath");
}

#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    
    if (footView.hidden == YES) {
        return;
    }
    
    if(self.contentOffset.y + self.frame.size.height - self.contentSize.height >= 5 && isLoading == NO)
    {
        //NSLog(@"再去网上加载数据 ^ ^ ");
        isLoading = YES;
        [footView changeLoadingStatus:isLoading];
        
        [CityPoiData getCityPoiDataByCityId:_cityId andCategoryId:_cateType pageSize:reqNumber page:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array_guideData) {
            
            [muArrData addObjectsFromArray:array_guideData];
            page ++;
            
            
            if (array_guideData.count < [reqNumber intValue]) {
                
                footView.hidden = YES;
                
            }else{
                
                footView.hidden = NO;
            }
            [self reloadData];
            
            isLoading = NO;
            [footView changeLoadingStatus:isLoading];
            
        } failed:^{
            
            
            isLoading = NO;
            [footView changeLoadingStatus:isLoading];
            
            
        }];
        
        
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)dealloc{
    
    [_cityId release];
    [_cateType release];
    [muArrData release];
    [super dealloc];
}

@end
