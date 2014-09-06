//
//  AllSpotViewController.m
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import "AllSpotViewController.h"
#import "SpotCell.h"
#import "PoiDetailViewController.h"
#import "GoogleMapViewController.h"

@interface AllSpotViewController ()

@end

@implementation AllSpotViewController

@synthesize select = _select;
@synthesize cityName;
@synthesize cityId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
/*
 景点分类ID，默认0，获取全部分类poi。32：景点、77：交通、78：餐饮、147：购物、148：活动、149：住宿、 150：实用信息、151：路线
 
 */
-(void)initData{
    
    btnsArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i = 0; i<5; i++) {
        
        NSMutableDictionary *muDict = [[NSMutableDictionary alloc]init];
        switch (i) {
            case 0:
                [muDict setObject:@"全部" forKey:@"name"];
                [muDict setObject:@"0" forKey:@"type"];
                [muDict setObject:@"spot_all.png" forKey:@"image"];
                [muDict setObject:@"spot_all_click.png" forKey:@"clickImage"];
                
                break;
            case 1:
                [muDict setObject:@"景点" forKey:@"name"];
                [muDict setObject:@"32" forKey:@"type"];
                [muDict setObject:@"spot_景点.png" forKey:@"image"];
                [muDict setObject:@"spot_景点_click.png" forKey:@"clickImage"];
                
                break;
            case 2:
                [muDict setObject:@"美食" forKey:@"name"];
                [muDict setObject:@"78" forKey:@"type"];
                [muDict setObject:@"spot_food.png" forKey:@"image"];
                [muDict setObject:@"spot_food_click.png" forKey:@"clickImage"];
                
                break;
            case 3:
                [muDict setObject:@"购物" forKey:@"name"];
                [muDict setObject:@"147" forKey:@"type"];
                [muDict setObject:@"spot_shopping.png" forKey:@"image"];
                [muDict setObject:@"spot_shopping_click.png" forKey:@"clickImage"];
                
                break;
            case 4:
                [muDict setObject:@"娱乐" forKey:@"name"];
                [muDict setObject:@"148" forKey:@"type"];
                [muDict setObject:@"spot_娱乐.png" forKey:@"image"];
                [muDict setObject:@"spot_娱乐_click.png" forKey:@"clickImage"];
                
                break;
                
            default:
                break;
        }
        
        [muDict setObject:RGB(44, 171, 121) forKey:@"clickTextColor"];
        [muDict setObject:RGB(130, 153, 165) forKey:@"textColor"];

        [btnsArray addObject:muDict];
        [muDict release];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"旅行地"];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"旅行地"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = @"旅行地";
    
    [_rightButton setBackgroundImage:[UIImage imageNamed:@"地图button_icon.png"] forState:UIControlStateNormal];
    
    [self initData];
    
    categoryBackImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, height_headerview, UIWidth, 38)];
    categoryBackImage.backgroundColor =  [UIColor whiteColor];
    categoryBackImage.userInteractionEnabled = YES;
    [self.view addSubview:categoryBackImage];
    [categoryBackImage release];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,height_headerview + 38, UIWidth, 1)];
    line.backgroundColor = RGB(231, 231, 231);
    [self.view addSubview:line];
    [line release];
    
    statueImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 36, 63, 2)];
    statueImageView.backgroundColor = RGB(0, 171, 125);
    [categoryBackImage addSubview:statueImageView];
    [statueImageView release];
    
    
    for (int i = 0; i< btnsArray.count; i++) {
        
        NSDictionary *dict = [btnsArray objectAtIndex:i];
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i*64, 0, 63, 38)];
        btn.tag = 10+i;
        [btn setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
      
        if (i == _select) {
            
            [btn setTitleColor:[dict objectForKey:@"clickTextColor"] forState:UIControlStateNormal];
            
        }else{
            
            [btn setTitleColor:[dict objectForKey:@"textColor"] forState:UIControlStateNormal];
        }
        
        [btn addTarget:self action:@selector(selectCategory:) forControlEvents:UIControlEventTouchUpInside];
        [categoryBackImage addSubview:btn];
        [btn release];
        
        if ( i != btnsArray.count-1) {
            
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(63+i*64, 11, 1, 15)];
            lineView.backgroundColor = RGB(231, 231, 231);
            [categoryBackImage addSubview:lineView];
            [lineView release];
        }
        
        SpotTableView * mainTable = [[SpotTableView alloc]initWithFrame:CGRectMake(0,0 ,UIWidth,UIHeight - height_need_reduce) cityId:self.cityId cateType:[dict objectForKey:@"type"]];
        mainTable.tag = i+100;
        mainTable.spotTableDelegate = self;
        mainTable.hidden = YES;
        [self.view addSubview:mainTable];
        [self.view sendSubviewToBack:mainTable];
        
        [mainTable release];

        [ChangeTableviewContentInset changeTableView:mainTable withOffSet:39];
    }
    
    UIButton *btn = (UIButton *)[categoryBackImage viewWithTag:11+_select];
    
    [self selectCategory:btn];
}


-(void)touchesView{
    
    UIButton *btn = nil;
    
    if (_select == -1) {
       
        btn = (UIButton *)[categoryBackImage viewWithTag:10];

    }else{
        
        btn = (UIButton *)[categoryBackImage viewWithTag:_select + 10];
    }
    [self selectCategory:btn];

}

#pragma mark
#pragma mark selectCategory
-(void)selectCategory:(UIButton *)btn{
    
    if (isNotReachable) {
        
        [super setNotReachableView:YES];
        return;
        
    }else{
        
        [super setNotReachableView:NO];
    }
    
    NSLog(@"__________%d_________%d___________",btn.tag,_select);
    
    
//    if (btn.tag - 10 != _select) {
    
        if (_select != -1) {
            
            NSDictionary *preDict = [btnsArray objectAtIndex:_select];
            UIButton *preBtn = (UIButton *)[categoryBackImage viewWithTag:_select + 10];
            [preBtn setTitleColor:[preDict objectForKey:@"textColor"] forState:UIControlStateNormal];
            
            SpotTableView *preTableView = (SpotTableView *)[self.view viewWithTag:_select + 100];
            preTableView.hidden = YES;
        }
       
        NSDictionary *nowDict = [btnsArray objectAtIndex:btn.tag - 10];
        [btn setTitleColor:[nowDict objectForKey:@"clickTextColor"] forState:UIControlStateNormal];
       
        SpotTableView *curTableView =  (SpotTableView *)[self.view viewWithTag:btn.tag - 10 + 100];
        curTableView.hidden = NO;
        
        [curTableView requestData];
        
        _select = btn.tag -10;
     
        statueImageView.frame = CGRectMake(btn.frame.origin.x, 36, 63, 2);
//    }

}

#pragma mark
#pragma mark clickRightButton
/**
 *  点击右上角地图按钮
 *
 *  @param btn nil
 */
-(void)clickRightButton:(UIButton *)btn{
    
    GoogleMapViewController *googleMapVC = [[GoogleMapViewController alloc] init];
    googleMapVC.array_in = nil;
    googleMapVC.dic_in = nil;
    googleMapVC.str_cityId = self.cityId;
    googleMapVC.title_navigation = self.cityName;
    [self.navigationController pushViewController:googleMapVC animated:YES];
    [googleMapVC release];
    
    NSLog(@"click 地图");
}

#pragma mark 
#pragma mark SpotTableViewDelegate

-(void)changeAllSpotWithIsHaveData:(BOOL)flag{
    
    if (flag == NO) {
        
        _notDataImageView.image = [UIImage imageNamed:@"place_searchNoResult"];
        _notDataImageView.hidden = NO;
        [self.view bringSubviewToFront:_notDataImageView];
        
    }else{
        
        _notDataImageView.hidden = YES;
    }
}
-(void)changeNotReachableView:(BOOL)flag{
    
    [super setNotReachableView:flag];
}

-(void)showMapBtn:(BOOL)flag{
    
    _rightButton.hidden = flag;
}

#pragma mark
#pragma mark tableDidSelect
-(void)spotTableViewdidSelectRowAtIndexPath:(CityPoi *)citypoi{
    
    PoiDetailViewController *poiDetailVc = [[PoiDetailViewController alloc]init];
    poiDetailVc.poiId = [citypoi.str_poiId intValue];
    [self.navigationController pushViewController:poiDetailVc animated:YES];
    [poiDetailVc release];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
    self.cityId = nil;
    self.cityName = nil;
    
    
    [btnsArray release];
    [super dealloc];
}
@end