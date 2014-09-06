//
//  RegistMissingSongViewController.m
//  KwSing
//
//  Created by 熊 改 on 13-5-21.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "RegistMissingSongViewController.h"
#import "globalm.h"
#import "KSAppDelegate.h"
#import "ImageMgr.h"
#import "iToast.h"
#import "UMengLog.h"
#import "KwUMengElement.h"

@interface RegistMissingSongViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (retain,nonatomic) NSArray *dataSource;
@property (retain,nonatomic) UITextField *ArtistName;
@property (retain,nonatomic) UITextField *SongName;

-(void)ReturnBtnClick:(id)sender;
-(void)RegistBtnClick:(id)sender;
@end

@implementation RegistMissingSongViewController

const int ViewTag=1;

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
	// Do any additional setup after loading the view.
    [self setTitle:@"缺歌登记"];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    self.dataSource=[NSArray arrayWithObjects:self.ArtistName,self.SongName, nil];
    UIImageView * imageView=[[UIImageView alloc] init];
    [imageView setFrame:ROOT_NAVAGATION_CONTROLLER_BOUNDS];
    [imageView setImage:CImageMgr::GetImageEx("topBk.png")];
    [[self view] addSubview:imageView];
    [imageView release];
    
    UIButton* returnButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [returnButton setTag:1];
    [returnButton setTitle:@"返回" forState: UIControlStateNormal];
    [returnButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
    [returnButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
    [returnButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [returnButton.titleLabel setShadowColor:[UIColor blackColor]];
    [returnButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    returnButton.frame = CGRectMake(10, 9, 47,28);
    [returnButton addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:returnButton];
    
    
    UIButton* registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton setTag:1];
    [registerButton setTitle:@"提交" forState: UIControlStateNormal];
    [[registerButton titleLabel] setShadowColor:[UIColor blackColor]];
    [[registerButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
    [registerButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
    [registerButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
    [registerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    registerButton.frame = CGRectMake(260, 9, 47,28);
    [registerButton addTarget:self action:@selector(RegistBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:registerButton];
    
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(60, 15, self.navigationController.navigationBar.bounds.size.width-120,18)];
    lable.textAlignment = UITextAlignmentCenter;
    lable.text = [self title];
    lable.Font = [UIFont systemFontOfSize:18];
    [lable setShadowColor:UIColorFromRGBAValue(0x000000,50)];
    [lable setShadowOffset:CGSizeMake(1, 1)];
    lable.backgroundColor = [UIColor clearColor];
    lable.textColor = [UIColor whiteColor];
    [[self view] addSubview:lable];
    [lable release];
    
    
    UIImageView * topshadow=[[[UIImageView alloc] init] autorelease];
    CGRect rcshadow=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    rcshadow.origin.y+=rcshadow.size.height;
    rcshadow.size.height=5;
    [topshadow setFrame:rcshadow];
    [topshadow setImage:CImageMgr::GetImageEx("topShadow.png")];
    [[self view] addSubview:topshadow];
    
    CGRect rc=[self view].bounds;
    CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    rc=BottomRect(rc, rc.size.height-rcna.size.height,0);
    
    UITableView *_TableView=[[UITableView alloc] initWithFrame:rc style:UITableViewStyleGrouped];;
    _TableView.delegate=self;
    _TableView.dataSource=self;
    _TableView.backgroundColor=[UIColor clearColor];
    _TableView.backgroundView.alpha=0;
    _TableView.scrollEnabled=NO;
    _TableView.sectionFooterHeight=100;
    [[self view] addSubview:_TableView];
    [_TableView release];
    _TableView = nil;
    
    [self.view setUserInteractionEnabled:YES];
}

-(void)ReturnBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)RegistBtnClick:(id)sender
{
    //去除空格
    NSString* SongNameText=[[(UITextField*)self.SongName.rightView text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([SongNameText length]==0) {
        return;
    }
    std::string lackSongStr=[[NSString stringWithFormat:@"%@ : %@",SongNameText,[(UITextField*)self.ArtistName.rightView text]] UTF8String];
    UMengLog(KS_SONG_LACK, lackSongStr);
    [[[[iToast makeText:NSLocalizedString(@"提交成功", @"")]setGravity:iToastGravityCenter] setDuration:3000] show];
    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"registMissingSongCell"];
    if (cell==nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"registMissingSongCell"] autorelease];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    else {
        UIView * viewToCheck=[cell.contentView viewWithTag:ViewTag];
        if (viewToCheck) {
            [viewToCheck removeFromSuperview];
        }
    }
    UITextField *textField=[self.dataSource objectAtIndex:[indexPath row]];
    [cell.contentView addSubview:textField];
    return cell;

}


-(UITextField*)ArtistName{
    if (_ArtistName == nil) {
        CGRect frame = CGRectMake(10,10, 285, 30);
		_ArtistName = [[UITextField alloc] initWithFrame:frame];
		
        UITextField* CoverText = [[[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, 30)] autorelease];
		CoverText.borderStyle = UITextBorderStyleNone;//UITextBorderStyleLine;
		CoverText.textColor = [UIColor blackColor];
		CoverText.font = [UIFont systemFontOfSize:16.0];
        CoverText.textAlignment = UITextAlignmentLeft;
        CoverText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		CoverText.placeholder = @"请输入歌手名";
		CoverText.backgroundColor = [UIColor clearColor];
		CoverText.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		CoverText.autocapitalizationType = UITextAutocapitalizationTypeNone;
		CoverText.keyboardType = UIKeyboardTypeDefault;
		CoverText.returnKeyType = UIReturnKeyDone;
		
		CoverText.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		CoverText.tag = ViewTag;		// tag this control so we can remove it later for recycled cells
		
		CoverText.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		[CoverText becomeFirstResponder];
        
//        [_ArtistName addSubview:CoverText];
        _ArtistName.rightView = CoverText;
        _ArtistName.rightViewMode = UITextFieldViewModeAlways;
        
        CGRect rect = CGRectMake(0, 0, 85, 44);
        UILabel* tmp = [[[UILabel alloc] initWithFrame:rect] autorelease ];
        tmp.backgroundColor = [UIColor clearColor];
        //tmp.font = [UIFont skinFontOfSize:16];
        [tmp setText:@"歌手:"];
        
        _ArtistName.leftView = tmp;
        _ArtistName.leftViewMode = UITextFieldViewModeAlways;
    }
    return _ArtistName;
}
-(UITextField*)SongName{
    if (_SongName == nil) {
        CGRect frame = CGRectMake(10 ,10, 285, 30);
		_SongName = [[UITextField alloc] initWithFrame:frame];
        
        UITextField* CoverText = [[[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, 30)] autorelease];
		
		CoverText.borderStyle = UITextBorderStyleNone;//UITextBorderStyleRoundedRect;
		CoverText.textColor = [UIColor blackColor];
		CoverText.font = [UIFont systemFontOfSize:16.0];
        CoverText.textAlignment = UITextAlignmentLeft;
        CoverText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		CoverText.placeholder = @"请输入歌曲名";
		CoverText.backgroundColor = [UIColor clearColor];
		CoverText.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		CoverText.autocapitalizationType = UITextAutocapitalizationTypeNone;
		CoverText.keyboardType = UIKeyboardTypeDefault;
		CoverText.returnKeyType = UIReturnKeyDone;
		CoverText.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		CoverText.tag = ViewTag;		// tag this control so we can remove it later for recycled cells
		
		CoverText.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		_SongName.rightView = CoverText;
        _SongName.rightViewMode = UITextFieldViewModeAlways;
        
        CGRect rect = CGRectMake(0, 0, 85, 44);
        UILabel* tmp = [[[UILabel alloc] initWithFrame:rect] autorelease ];
        tmp.backgroundColor = [UIColor clearColor];
        //tmp.font = [UIFont skinFontOfSize:16];
        [tmp setText:@"歌名:"];
        _SongName.leftView = tmp;
        _SongName.leftViewMode = UITextFieldViewModeAlways;
        
    }
    return _SongName;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (_ArtistName) {
        [_ArtistName resignFirstResponder];
    }
    if (_SongName) {
        [_SongName resignFirstResponder];
    }
    return true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
