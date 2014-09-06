//
//  TravelsListViewController.m
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import "TravelsListViewController.h"
#import "TravelsCell.h"
#import "MicroTravelData.h"
#import "BBSDetailViewController.h"

#define reqPageSize @"10"

@interface TravelsListViewController ()

@end

@implementation TravelsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        travelsListArray = [[NSMutableArray alloc] initWithCapacity:0];

    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [MobClick beginLogPageView:@"精华游记列表"];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    
    [MobClick endLogPageView:@"精华游记列表"];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = @"精选游记";
    page = 1;
    
    self.view.backgroundColor = RGB(232, 243, 248);
    
    mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, UIHeight - height_need_reduce)];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.backgroundColor = [UIColor clearColor];
    mainTable.separatorColor = [UIColor clearColor];
    [self.view addSubview:mainTable];
    [mainTable release];
    
    [self.view sendSubviewToBack:mainTable];
    [ChangeTableviewContentInset changeTableView:mainTable withOffSet:0];
    /*
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 120, 15)];
    lblTitle.text = @"精华游记";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textAlignment = NSTextAlignmentLeft;
    lblTitle.font = [UIFont boldSystemFontOfSize:15.0];
    lblTitle.textColor = RGB(68, 68, 68);
    [headView addSubview:lblTitle];
    [lblTitle release];
    
    mainTable.tableHeaderView = headView;
    [headView release];
    */
    
    footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    footView.hidden = YES;
    [mainTable setTableFooterView:footView];
    [footView release];
    
    
    [self queryData];
    
	// Do any additional setup after loading the view.
}

- (void)queryData
{
    [self.view makeToastActivity];
    
    if (isNotReachable) {
        [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
        [super setNotReachableView:YES];
        return;
    }else{
        
        [super setNotReachableView:NO];
    }
    
    if (_type == 1) {
        
        [MicroTravelData getMicroTravelDataOfCountryByCountryId:_key pageSize:reqPageSize page:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array_microTravelData) {
            
            [super setNotReachableView:NO];
            
            if (array_microTravelData.count == 0) {
                
                
                _notDataImageView.hidden = NO;
                _notDataImageView.image = [UIImage imageNamed:@"not_travel"];
                [self.view bringSubviewToFront:_notDataImageView];
                
                
            }else{
                if (array_microTravelData.count < [reqPageSize intValue]) {
                    footView.hidden = YES;
                }else{
                    footView.hidden = NO;
                }
                page ++;
                [travelsListArray addObjectsFromArray:array_microTravelData];
                [mainTable reloadData];
            }
            
            
            
            [self.view hideToastActivity];
            
        } failed:^{
            
            [super setNotReachableView:YES];
            [self.view hideToastActivity];
            NSLog(@"error");
        }];
        
        
    }else if(_type == 2){
        
        
        [MicroTravelData getMicroTravelDataOfCityByCityId:_key pageSize:reqPageSize page:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array_microTravelData) {
            [super setNotReachableView:NO];
            
            
            if (array_microTravelData.count == 0) {
                
                
                _notDataImageView.hidden = NO;
                _notDataImageView.image = [UIImage imageNamed:@"not_travel"];
                [self.view bringSubviewToFront:_notDataImageView];
                
                
            }else{
                if (array_microTravelData.count < [reqPageSize intValue]) {
                    footView.hidden = YES;
                }else{
                    footView.hidden = NO;
                }
                page ++;
                [travelsListArray addObjectsFromArray:array_microTravelData];
                [mainTable reloadData];
            }
            
            [self.view hideToastActivity];
            
        } failed:^{
            NSLog(@"error");
            [super setNotReachableView:YES];
            [self.view hideToastActivity];
        }];
        
    }

}

#pragma mark
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 140;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return travelsListArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *strInd = @"cell";
    TravelsCell *cell = [tableView dequeueReusableCellWithIdentifier:strInd];
    if (cell == nil) {
        cell = [[[TravelsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strInd] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell updateCell:[travelsListArray objectAtIndex:indexPath.row]];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSDetailViewController * bbsDetailVC = [[BBSDetailViewController alloc]init];
        
    MicroTravel * travalll = [travelsListArray objectAtIndex:indexPath.row];
    bbsDetailVC.bbsAllUserLink = travalll.str_travelUrl_all;
//    bbsDetailVC.bbsAuthorLink = travalll.str_travelUrl_onlyauthor;
    [self.navigationController pushViewController:bbsDetailVC animated:YES];
    [bbsDetailVC release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    if (footView.hidden == YES || page == 1) {
        
        return;
    }
    
    if(mainTable.contentOffset.y + mainTable.frame.size.height - mainTable.contentSize.height >= 5 && isLoading == NO)
    {
        //NSLog(@"再去网上加载数据 ^ ^ ");
        isLoading = YES;
        
        [footView changeLoadingStatus:isLoading];

       
        
        if (_type == 1) {
            
            [MicroTravelData getMicroTravelDataOfCountryByCountryId:_key pageSize:reqPageSize page:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array_microTravelData) {
                
                if (array_microTravelData.count < [reqPageSize intValue]) {
                    footView.hidden = YES;
                }else{
                    footView.hidden = NO;
                }
                page ++;
                [travelsListArray addObjectsFromArray:array_microTravelData];
                [mainTable reloadData];
                
                isLoading = NO;
                [footView changeLoadingStatus:isLoading];
                
            } failed:^{
                
                isLoading = NO;
                [footView changeLoadingStatus:isLoading];
                NSLog(@"error");
            }];
        }else if(_type == 2){
        
            [MicroTravelData getMicroTravelDataOfCityByCityId:_key pageSize:reqPageSize page:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array_microTravelData) {
                
                
                
                if (array_microTravelData.count < [reqPageSize intValue]) {
                    footView.hidden = YES;
                }else{
                    footView.hidden = NO;
                }
                page ++;
                [travelsListArray addObjectsFromArray:array_microTravelData];
                [mainTable reloadData];
                
                isLoading = NO;
                [footView changeLoadingStatus:isLoading];
                
            } failed:^{
                
                isLoading = NO;
                [footView changeLoadingStatus:isLoading];
                NSLog(@"error");
                
            }];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
    [travelsListArray release];
    [super dealloc];
}

- (void)touchesView
{
    [super touchesView];
    
    [self queryData];
}
@end
