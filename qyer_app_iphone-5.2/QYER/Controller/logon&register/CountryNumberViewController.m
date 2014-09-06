//
//  CountryNumberViewController.m
//  QYER
//
//  Created by Leno on 14-6-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CountryNumberViewController.h"

#define     height_headerview           (ios7 ? (44+20) : 44)

@interface CountryNumberViewController ()

@end

@implementation CountryNumberViewController

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

    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.userInteractionEnabled = YES;
    _headView.image = [UIImage imageNamed:@"home_head"];
    [self.view addSubview:_headView];

    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.backgroundColor = [UIColor clearColor];
    _cancelButton.frame = CGRectMake(0, 3, 40, 40);
    if(ios7)
    {
        _cancelButton.frame = CGRectMake(0, 3+20, 40, 40);
    }
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_cancelButton];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 200, 30)];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(60, 10+20, 200, 26);
    }
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    _titleLabel.text = @"国家和地区";


    _countryTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, self.view.frame.size.height - height_headerview)];
    [_countryTableView setBackgroundView:nil];
    [_countryTableView setBackgroundColor:[UIColor clearColor]];
    [_countryTableView setBounces:NO];
    [_countryTableView setDataSource:self];
    [_countryTableView setDelegate: self];
    [self.view addSubview:_countryTableView];
    
}

#pragma mark -
#pragma mark --- UITableView - datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)]autorelease];
    headerView.backgroundColor = RGB(232, 243, 248);
    
    UILabel * sectionLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)]autorelease];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setTextAlignment:NSTextAlignmentLeft];
    [sectionLabel setTextColor:RGB(68, 68, 68)];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [sectionLabel setText:@"  热门"];
    [headerView addSubview:sectionLabel];
    
    return headerView ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell_moreSetting = [tableView dequeueReusableCellWithIdentifier:@"CountryCell"];
    if(cell_moreSetting == nil)
    {
        cell_moreSetting = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CountryCell"] autorelease];
        cell_moreSetting.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell_moreSetting;
}


#pragma mark -
#pragma mark --- UITableView - delegate
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}




-(void)clickCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
