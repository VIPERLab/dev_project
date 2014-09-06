//
//  PhotoListController.m
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PhotoListController.h"
#import "PhotoListCell.h"
#import "PictureListController.h"
@interface PhotoListController ()

@end

@implementation PhotoListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _photoData = [[NSMutableData alloc]init];
    }
    return self;
}
-(void)dealloc
{
    [_photoData release];
    [muArrPhotoes release];
    [assetLibrary release];
    
    [_selectedImageName release];
    _selectedImageName = nil;
    
    [super dealloc];
}

- (void)clickBackButton:(UIButton *)btn{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = @"相册列表";

    
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
    
    
    muArrPhotoes = [[NSMutableArray alloc] init];
    assetLibrary = [[ALAssetsLibrary alloc] init];

    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
        
        NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
        if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location !=  NSNotFound) {
            
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"无法访问相册.请在\"设置->隐私->照片设置为打开状态\"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    };
    
    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        if (result!=NULL) {
            
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                
                NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url'
                
                /*result.defaultRepresentation.fullScreenImage//图片的大图
                 result.thumbnail                             //图片的缩略图小图
                 //                    NSRange range1=[urlstr rangeOfString:@"id="];
                 //                    NSString *resultName=[urlstr substringFromIndex:range1.location+3];
                 //                    resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
                 */
                
                NSMutableDictionary *muDict = [muArrPhotoes lastObject];
                NSMutableArray *tempMuarr=[muDict objectForKey:@"photosArr"];
                [tempMuarr addObject:urlstr];
                
                
            }
        }
        
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock
    libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
        
        if (group!=nil) {
            NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
            NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
            
            NSString *g1 = [g substringFromIndex:16];
            NSArray *arr = [g1 componentsSeparatedByString:@","];
            NSString *g2 = [[arr objectAtIndex:0] substringFromIndex:5];
            
            if ([g2 isEqualToString:@"Camera Roll"]) {
                g2 = @"相机胶卷";
            }
            NSString *groupName = g2;//组的name
            NSLog(@"groupName is %@",groupName);
            
            NSString *strCount = [[arr objectAtIndex:2] substringFromIndex:14];
            
            NSMutableDictionary *muDict=[[NSMutableDictionary alloc]init];
            
            [muDict setObject:groupName forKey:@"photosName"];
            [muDict setObject:strCount forKey:@"photosNumber"];
            
            NSMutableArray *muArr=[[NSMutableArray alloc]init];
            
        
            [muDict setObject:muArr forKey:@"photosArr"];
        
            if ([strCount intValue] != 0) {
                
                [muArrPhotoes addObject:muDict];
                
                
                if ([g2 isEqualToString:@"相机胶卷"]) {
                    index = muArrPhotoes.count - 1;
                }
            }
          
            [muArr release];
            [muDict release];
            
            [group enumerateAssetsUsingBlock:groupEnumerAtion];
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (muArrPhotoes.count > 1) {
                    [muArrPhotoes exchangeObjectAtIndex:0 withObjectAtIndex:index];
                }
                
                [mainTable reloadData];

            });
            
            
        }
        
    };
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                usingBlock:libraryGroupsEnumeration
                              failureBlock:failureblock];
    
  
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
    
    return muArrPhotoes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *CellIdentifier = @"Cell";
    
    PhotoListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PhotoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    
    NSDictionary *dict = [muArrPhotoes objectAtIndex:indexPath.row];
    BOOL isShowad;
    if (indexPath.row < muArrPhotoes.count-1) {
        isShowad = NO;
    }else{
        isShowad = YES;
    }
    [cell upDateUIWithDict:dict isShowd:isShowad];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PictureListController *picvc = [[PictureListController alloc]init];
    picvc.photoDict = [muArrPhotoes objectAtIndex:indexPath.row];
    picvc.delegate = self;
    [self.navigationController pushViewController:picvc animated:YES];
    [picvc release];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark 
#pragma mark photoPickerDelegate
-(void)customImagePickerController:(UIViewController *)picker image:(UIImage *)image imageName:(NSString *)imageName
{
    NSData * data = UIImageJPEGRepresentation(image, 0.8);
 
    _photoData.length = 0;
    [_photoData appendData:data];
    
    if (_selectedImageName) {
        [_selectedImageName release];
        _selectedImageName = nil;
    }
    _selectedImageName = [imageName retain];
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"选择此张图片？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
    [alert release];
}


-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        UIImage * image = [UIImage imageWithData:_photoData];
        
        [self.delegate customImagePickerController:self image:image imageName:_selectedImageName];
    }
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
