//
//  PictureListController.m
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PictureListController.h"
#import "PictureListCell.h"
@interface PictureListController ()

@end

@implementation PictureListController

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
    
    _titleLabel.text = [self.photoDict objectForKey:@"photosName"];
    
    
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
    
    
    
    NSMutableArray *tempMuarr2 = [self.photoDict objectForKey:@"photosArr"];
    if (tempMuarr2.count <= 4) {
        
        rowCount = 1;
        
    }else{
        if (tempMuarr2.count%4 == 0) {
            
            rowCount = tempMuarr2.count/4;
            
        }else{
            
            rowCount = tempMuarr2.count/4 + 1;
        }
    }
    
    
    if (rowCount > 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: rowCount - 1 inSection:0];
        
        [mainTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark UItabelDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return rowCount;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *CellIdentifier = @"Cell";
    
    PictureListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PictureListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    cell.delegate = self;
    [cell upDateUIWithDict:[self.photoDict objectForKey:@"photosArr"] index:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)customImagePickerController:(UIViewController *)picker image:(UIImage *)image imageName:(NSString *)imageName{

    [self.delegate customImagePickerController:nil image:image imageName:imageName];
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
