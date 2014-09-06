//
//  HotelListViewController.m
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import "HotelListViewController.h"
#import "HotelCell.h"
@interface HotelListViewController ()

@end

@implementation HotelListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        hotelListArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = @"酒店";
    
    for (int i = 0; i<5; i++) {
        [hotelListArray addObject:@"1"];
    }
    
    mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, height_headerview, UIWidth, UIHeight - height_need_reduce)];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.backgroundColor = [UIColor clearColor];
    mainTable.separatorColor = [UIColor clearColor];
    [self.view addSubview:mainTable];
    [mainTable release];

    self.view.backgroundColor = [UIColor whiteColor];
    UIEdgeInsets inset = UIEdgeInsetsMake(8, 0, 0, 0);
    [mainTable setContentInset:inset];
       
//    footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
//    [mainTable setTableFooterView:footView];
//    [footView release];
//    

	// Do any additional setup after loading the view.
}
#pragma mark 
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 96;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 20)] autorelease];
   
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, UIWidth-20, 20)];
    lbl.font = [UIFont boldSystemFontOfSize:14.0];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = NSTextAlignmentLeft;
    [headView addSubview:lbl];
    [lbl release];
    
    switch (section) {
        case 0:
            lbl.text = @"曼谷超值特惠酒店";
            break;
        case 1:
            lbl.text = @"曼谷最受穷游网友欢迎酒店";
            break;
        default:
            break;
    }
    
    return headView;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return hotelListArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *strInd = @"cell";
    HotelCell *cell = [tableView dequeueReusableCellWithIdentifier:strInd];
    if (cell == nil) {
        cell = [[[HotelCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strInd] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark 
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    /*
    
    if(mainTable.contentOffset.y + mainTable.frame.size.height - mainTable.contentSize.height >= 5 && isLoading == NO)
    {
        //NSLog(@"再去网上加载数据 ^ ^ ");
        isLoading = YES;
       
        [footView changeLoadingStatus:isLoading];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            for (int i = 0; i<3; i++) {
                [hotelListArray addObject:@"1"];
            }
            [mainTable reloadData];
            isLoading = NO;
            [footView changeLoadingStatus:isLoading];

            
        });
    }
    
    */
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
    [super dealloc];
}
@end
