//
//  CityListViewController.m
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CityListViewController.h"
#import "CityListData.h"
#import "Toast+UIView.h"
#import "CityList.h"
#import "SearchViewController.h"
#import "CountryViewController.h"


#define     positionY_button_search         (ios7 ? (3+20) : 3)

@interface CityListViewController ()

@end

@implementation CityListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        cityListArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [MobClick beginLogPageView:@"城市地区列表"];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
   
    [MobClick endLogPageView:@"城市地区列表"];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    page = 1;
    _titleLabel.text = @"城市地区";
    
    
    
    mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, UIHeight - height_need_reduce)];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.backgroundColor = [UIColor clearColor];
    mainTable.separatorColor = [UIColor clearColor];
    [self.view addSubview:mainTable];
    [mainTable release];
    
    [self.view sendSubviewToBack:mainTable];
    [ChangeTableviewContentInset changeTableView:mainTable withOffSet:0];
    
    
    footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    footView.hidden = YES;
    [mainTable setTableFooterView:footView];
    [footView release];
    
    
    
    
    [self queryData];
    
	// Do any additional setup after loading the view.
}

//************ Insert By ZhangDong 2014.3.31 Start ***********
- (void)queryData
{
    [self.view performSelector:@selector(makeToastActivity) withObject:nil afterDelay:0];
    
    if (isNotReachable) {
        [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
        [super setNotReachableView:YES];
        return;
    }else{
        
        [super setNotReachableView:NO];
    }
    
    [CityListData getCityListDataByCountryId:self.key pageSize:reqNumber page:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array_cityList) {
        [super setNotReachableView:NO];
        
        if (array_cityList.count < [reqNumber integerValue]) {
            footView.hidden = YES;
        }else{
            footView.hidden = NO;
        }
        page ++;
        [cityListArray addObjectsFromArray:array_cityList];
        
        [mainTable reloadData];
        
        [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
        
    } failed:^{
        
        [super setNotReachableView:YES];
        NSLog(@"getCityListDataByCountryId Error");
        [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
    }];
}



//************ Insert By ZhangDong 2014.3.31 End ***********
#pragma mark
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 89;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return cityListArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *strInd = @"cell";
    CityCell *cell = [tableView dequeueReusableCellWithIdentifier:strInd];
    if (cell == nil) {
        cell = [[[CityCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strInd] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //************ Insert By ZhangDong 2014.3.31 Start ***********
    CityList *cityList = [cityListArray objectAtIndex:indexPath.row];
    [cell configData:cityList];
    
    //************ Insert By ZhangDong 2014.3.31 End ***********
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CityList *cityList = cityListArray[indexPath.row];
    CountryViewController *countryVc = [[CountryViewController alloc]init];
    countryVc.type = 2;
    countryVc.key = cityList.str_id;
    [self.navigationController pushViewController:countryVc animated:YES];
    [countryVc release];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"----------- 点击城市 ------------");
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
        
        
        [CityListData getCityListDataByCountryId:self.key pageSize:reqNumber page:[NSString stringWithFormat:@"%d",page] success:^(NSArray *array_cityList) {
            
            
            if (array_cityList.count < [reqNumber integerValue]) {
                footView.hidden = YES;
            }else{
                footView.hidden = NO;
            }
            page ++;
            [cityListArray addObjectsFromArray:array_cityList];
            
            
            isLoading = NO;
            [footView changeLoadingStatus:isLoading];
            
            [mainTable reloadData];
            
            
        } failed:^{
            
            isLoading = NO;
            [footView changeLoadingStatus:isLoading];
            
            
            NSLog(@"getCityListDataByCountryId Error");
        }];
        
        
       
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
    
    [cityListArray release];
    
    [super dealloc];
}

- (void)touchesView
{
    [super touchesView];
    
    [self queryData];
}
@end
