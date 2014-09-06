//
//  TestListViewController.m
//  QYER
//
//  Created by 张伊辉 on 14-6-24.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "TestListViewController.h"
#import "JSON.h"
#import "AppDelegate.h"
#import "QYIMObject.h"
@interface TestListViewController ()

@end

@implementation TestListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    select = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Test_POI_INDEX"] integerValue];
    
    _titleLabel.text = @"测试数据";
    
    muArrdata = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"geo" ofType:@"json"];
    NSString *stringData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *tempArr = [stringData JSONValue];
    [muArrdata addObjectsFromArray:tempArr];
    
    mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, UIHeight - height_need_reduce)];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainTable];
    [mainTable release];
    
    [self.view sendSubviewToBack:mainTable];
    [ChangeTableviewContentInset changeTableView:mainTable withOffSet:0];

    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    testBtn.backgroundColor = [UIColor clearColor];
    [testBtn setTitle:@"确定" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    testBtn.frame = CGRectMake(270, 3, 40, 40);
    if(ios7)
    {
        testBtn.frame = CGRectMake(270, 3+20, 40, 40);
    }
    [testBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:testBtn];
    
    // Do any additional setup after loading the view.
}
-(void)sureAction{
    
    if (select != -1) {
        
        [GlobalObject share].isAuto = YES;
        
        [GlobalObject share].isInPublicRoom = NO;
        
        [[QYIMObject getInstance] disConnectWithBlock:nil];
        [QYIMObject getInstance].connectStatus = QYIMConnectStatusOffLine;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationFailed" object:nil userInfo:nil];
        
        
        
        NSDictionary *dict = [muArrdata objectAtIndex:select];
        
        float lat = [[dict objectForKey:@"lat"] floatValue];
        float lon = [[dict objectForKey:@"lon"] floatValue];
        
        [GlobalObject share].lat = lat;
        [GlobalObject share].lon = lon;
        
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setFlag_getLocation:NO];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] performSelector:@selector(initLocationManager) withObject:nil afterDelay:0];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return muArrdata.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *strInd = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strInd];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strInd] autorelease];
    }
    NSDictionary *dict = [muArrdata objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"chatroom"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (select == indexPath.row) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    select = indexPath.row;
    [tableView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(indexPath.row) forKey:@"Test_POI_INDEX"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"----------- 点击城市 ------------");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
