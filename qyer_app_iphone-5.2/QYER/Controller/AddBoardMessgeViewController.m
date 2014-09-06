//
//  AddBoardMessgeViewController.m
//  QYER
//
//  Created by Leno on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "AddBoardMessgeViewController.h"
#import "Toast+UIView.h"
#import "QYAPIClient.h"

#define     height_headerview           (ios7 ? (44+20) : 44)

@interface AddBoardMessgeViewController ()

@end

@implementation AddBoardMessgeViewController

@synthesize delegate = _delegate;
@synthesize roomNumber = _roomNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.roomNumber = [NSString string];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setMultipleTouchEnabled:NO];

    [self initRootView];

}

-(void)initRootView
{
    
    UIView * backView = [[UIView alloc]initWithFrame:self.view.frame];
    [backView setBackgroundColor:RGB(247, 248, 249)];
    [self.view addSubview:backView];
    [backView release];
    
    
    float height_naviViewHeight = (ios7 ? 20+44 : 44);
    
    UIView * naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_naviViewHeight)];
    naviView.backgroundColor = RGB(43, 171, 121);
    [self.view addSubview:naviView];
    [naviView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 240, 20)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(50, 12+20, 220, 20);
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"发布约伴";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.frame = CGRectMake(6, 2, 40, 40);
    if(ios7)
    {
        backButton.frame = CGRectMake(6, 2+20, 40, 40);
    }
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:backButton];
    
    
    UIButton * sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTag:789789];
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.frame = CGRectMake(274, 2, 40, 40);
    if(ios7)
    {
        sendButton.frame = CGRectMake(274, 2+20, 40, 40);
    }
    [sendButton setEnabled:NO];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [sendButton setTitle:@"发布" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(addMassage:) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:sendButton];
    
    
    UIView * txfBackView = [[UIView alloc]initWithFrame:CGRectMake(0, height_naviViewHeight, 320, 45)];
    [txfBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:txfBackView];
    [txfBackView release];
    
    
    if (ios7) {
        _textFieldSizeHeight = 0;
    }
    else{
        _textFieldSizeHeight = 4;
    }
    
    
    _titleTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, height_naviViewHeight +11, 300, 20)];
    [_titleTextField setBackgroundColor:[UIColor clearColor]];
    [_titleTextField setReturnKeyType:UIReturnKeyDone];
    [_titleTextField setPlaceholder:@"简明清晰的标题能更快获得回应"];
    [_titleTextField setTextColor:RGB(68, 68, 68)];
    [_titleTextField becomeFirstResponder];
    [_titleTextField setTextAlignment:NSTextAlignmentLeft];
    [_titleTextField setFont:[UIFont systemFontOfSize:15]];
    [_titleTextField setDelegate:self];
    [self.view addSubview:_titleTextField];
    
    
    UIImageView * gapLineImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, height_naviViewHeight +43, 310, 1)];
    [gapLineImgView setBackgroundColor:[UIColor clearColor]];
    UIImage * imageee = [UIImage imageNamed:@"Board_Line"];
    imageee = [imageee stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [gapLineImgView setImage:imageee];
    [self.view addSubview:gapLineImgView];
    [gapLineImgView release];
    
    
    
    float totalHeight = self.view.frame.size.height;
    
    _textViewBackGroundView = [[UIView alloc]initWithFrame:CGRectMake(0,  height_naviViewHeight +45, 320, totalHeight - 216 - 45 - height_naviViewHeight - 44)];
    [_textViewBackGroundView setBackgroundColor:[UIColor whiteColor]];
//    [_textViewBackGroundView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
//    [_textViewBackGroundView.layer setShadowOffset:CGSizeMake(0, 1)];
//    [_textViewBackGroundView.layer setShadowOpacity:0.2];
    [self.view addSubview:_textViewBackGroundView];
    
    
    _detailTextView = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(6, 6, 308,  totalHeight - 216 - 45 - height_naviViewHeight - 44 - 12)];
    [_detailTextView setPlaceholder:@"如果需要更详细说明的请写在这里，比如自己的信息，对同伴的要求等"];
    [_detailTextView setBackgroundColor:[UIColor clearColor]];
    [_detailTextView setFont:[UIFont systemFontOfSize:14]];
    [_detailTextView setTextColor:RGB(68, 68, 68)];
    [_detailTextView setDelegate:self];
    [_textViewBackGroundView addSubview:_detailTextView];


    _keyBoardPhotoBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_keyBoardPhotoBtn setFrame:CGRectMake(10,height_naviViewHeight +45 + _textViewBackGroundView.frame.size.height + 6, 33, 33)];
    [_keyBoardPhotoBtn setBackgroundColor:[UIColor clearColor]];
    [_keyBoardPhotoBtn setBackgroundImage:[UIImage imageNamed:@"Board_addPhoto"] forState:UIControlStateNormal];
    [_keyBoardPhotoBtn setBackgroundImage:[UIImage imageNamed:@"Board_addPhoto_hl"] forState:UIControlStateHighlighted];
    [_keyBoardPhotoBtn addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_keyBoardPhotoBtn];
    
    _photoImage = [[UIImage alloc]init];
    _hasPhoto = NO;//初始时没有照片

    
    //添加对键盘Frame的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
}


-(void)keyboardWasChange:(NSNotification *)notification
{
    float height_naviViewHeight = (ios7 ? 20+44 : 44);
    float totalHeight = self.view.frame.size.height;
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float keyboardHeight = kbSize.height;

    [_textViewBackGroundView setFrame:CGRectMake(0,  height_naviViewHeight +45, 320, totalHeight - keyboardHeight - 45 - height_naviViewHeight - 44)];
    
    [_detailTextView setFrame:CGRectMake(6, 6, 308,  totalHeight - keyboardHeight - 45 - height_naviViewHeight - 44 - 12)];

    [_keyBoardPhotoBtn setFrame:CGRectMake(10,height_naviViewHeight +45 + _textViewBackGroundView.frame.size.height + 6, 33, 33)];
}



-(void)addPhoto:(id)sender
{
    [_titleTextField resignFirstResponder];
    [_detailTextView resignFirstResponder];
    
    if (_hasPhoto == NO) {
        NSArray *array = [NSArray arrayWithObjects:@"从相册选择",@"拍照",nil];
        CCActiotSheet *sheet = [[CCActiotSheet alloc] initWithTitle:nil andDelegate:self andArrayData:array];
        [sheet setTag:500001];
        [sheet show];
        [sheet release];
    }
    
    else
    {
        NSArray *array = [NSArray arrayWithObjects:@"从相册选择",@"拍照",@"删除照片",nil];
        CCActiotSheet *sheet = [[CCActiotSheet alloc] initWithTitle:nil andDelegate:self andArrayData:array];
        [sheet setTag:500002];
        [sheet show];
        [sheet release];
    }
}

- (void)ccActionSheet:(CCActiotSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 500001) {
        if (buttonIndex == 0) {
            [_detailTextView becomeFirstResponder];
            NSLog(@"000000");
        }
        if (buttonIndex == 1) {
            [self choosePhoto];
            NSLog(@"1111111");
        }
        if (buttonIndex == 2) {
            [self takePhoto];
            NSLog(@"2222222");
        }
    }
    
    else if (actionSheet.tag == 500002){
    
        if (buttonIndex == 0) {
            [_detailTextView becomeFirstResponder];
        }
        if (buttonIndex == 1) {
            [self choosePhoto];
        }
        if (buttonIndex == 2) {
            [self takePhoto];
        }
        if (buttonIndex == 3) {
            [self deletePhoto];
        }
    }
    
    
//    if (buttonIndex == 1) { //从相册选择
//        //自定义相册调用方法
//        PhotoListController *photoVc = [[PhotoListController alloc]init];
//        photoVc.delegate = self.delegate;
//        UINavigationController *navPhoto = [[UINavigationController alloc]initWithRootViewController:photoVc];
//        navPhoto.navigationBar.hidden = YES;
//        [self presentViewController:navPhoto animated:YES completion:nil];
//
//    }else if (buttonIndex == 2){ //拍照
//        [QYToolObject transferSystemPicture:self.delegate type:1 isPermitEdit:NO];
//    }
    
}


-(void)deletePhoto
{
    _hasPhoto = NO;
    
    [_detailTextView becomeFirstResponder];
    
    [_keyBoardPhotoBtn setBackgroundImage:[UIImage imageNamed:@"Board_addPhoto"] forState:UIControlStateNormal];
    [_keyBoardPhotoBtn setBackgroundImage:[UIImage imageNamed:@"Board_addPhoto_hl"] forState:UIControlStateHighlighted];
}


-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
        [imagePickerController release];
    }
    
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的设备不支持拍照!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_detailTextView becomeFirstResponder];
}


-(void)choosePhoto
{
    PhotoListController *photoVc = [[PhotoListController alloc]init];
    photoVc.delegate = self;
    UINavigationController *navPhoto = [[UINavigationController alloc]initWithRootViewController:photoVc];
    navPhoto.navigationBar.hidden = YES;
    [self presentViewController:navPhoto animated:YES completion:nil];
    
    [photoVc release];
    [navPhoto release];
}


//实现CustomPickerImageDelegate方法
-(void)customImagePickerController:(UIViewController *)picker image:(UIImage *)image imageName:(NSString *)imageName
{
    _photoImage = image;

    [picker dismissViewControllerAnimated:YES completion:
     ^{
        [_detailTextView becomeFirstResponder];
        _hasPhoto = YES;
        [_keyBoardPhotoBtn setBackgroundImage:image forState:UIControlStateNormal];
        [_keyBoardPhotoBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
    }];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    _photoImage = image;
    
    //隐藏 拍照picker
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [_detailTextView becomeFirstResponder];
        _hasPhoto = YES;
        [_keyBoardPhotoBtn setBackgroundImage:image forState:UIControlStateNormal];
        [_keyBoardPhotoBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
    }];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@"\n"])
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UIButton * sendBtn = (UIButton *)[self.view viewWithTag:789789];
    if ([toBeString length] > 0) {
        [sendBtn setEnabled:YES];
    }
    else{
        [sendBtn setEnabled:NO];
    }
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    UIButton * sendBtn = (UIButton *)[self.view viewWithTag:789789];
    [sendBtn setEnabled:NO];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 30)
    {
        [self.view makeToast:@"小黑板标题最多30字" duration:1.2f position:@"center" isShadow:NO];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [_detailTextView becomeFirstResponder];
    
    return YES;
}

-(void)countTxvLength
{
    int describLength = _detailTextView.text.length;
    
    if (describLength > 300) {
        [_detailTextView.text substringToIndex:299];
        [self.view makeToast:@"内容不能超过300字" duration:0.6f position:@"center" isShadow:NO];
    }
    else{
    }
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self countTxvLength];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)addMassage:(id)sender
{
    NSString * titleee = _titleTextField.text;
    NSString * describtion = _detailTextView.text;
    
    if ([self isEmpty:titleee]) {
        [self.view makeToast:@"标题不能为空" duration:1.2f position:@"center" isShadow:NO];
    }
    else{
        
        if (titleee.length > 30 || titleee.length < 10) {
            [self.view makeToast:@"标题需在10-30字以内" duration:1.2f position:@"center" isShadow:NO];
        }
        else{
            if (describtion.length == 0 || [self isEmpty:describtion]) {
                [self.view makeToast:@"内容不能为空" duration:1.2f position:@"center" isShadow:NO];
            }
            
            if (describtion.length > 300) {
                [self.view makeToast:@"内容不能超过300字" duration:1.2f position:@"center" isShadow:NO];
            }
            else if(![self isEmpty:describtion] && describtion.length <=300){
                [self postImgToServe];
            }
        }
    }
}


-(BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}


-(void)postImgToServe
{
    [_titleTextField resignFirstResponder];
    [_detailTextView resignFirstResponder];
    
    NSString * titleee = _titleTextField.text;
    NSString * describtion = _detailTextView.text;
    
    NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];

    _blackBoardToken = [[NSString stringWithFormat:@"%@%@", titleee, describtion] retain];
    
    
    UIButton * sendBtn = (UIButton *)[self.view viewWithTag:789789];
    [sendBtn setEnabled:YES];
    
    if (_hasPhoto) {
        
        [self.view makeToastActivity];
        
        float imgWidth = _photoImage.size.width;
        float imgHeight = _photoImage.size.height;
        
        if (imgWidth > 1080) {
            
//            NSData * data1 = [NSData dataWithData:UIImageJPEGRepresentation(_photoImage, 1)];
            
            float newWidth = 1080;
            float newHeight = imgHeight / (imgWidth/1080);
            
            CGSize sizeee = CGSizeMake(newWidth, newHeight);
            _photoImage = [self scaleToSize:_photoImage size:sizeee];
            
//            NSData * data2 = [NSData dataWithData:UIImageJPEGRepresentation(_photoImage, 1)];
        }
        
        NSData * dataaa = [NSData dataWithData:UIImageJPEGRepresentation(_photoImage, 0.7)];
        
        [sendBtn setEnabled:NO];
        
        [[QYAPIClient sharedAPIClient]postBoardToServerWithTitle:titleee
                                                         content:describtion
                                                       imageData:dataaa
                                                      chatRoomID:self.roomNumber
                                                           token:token
                                                         success:^(NSDictionary *dic) {
                                                             
                                                             [self.view hideToastActivity];
                                                             
                                                             NSLog(@"\n>>>>>>>>\n%@\n>>>>>>>>>>>\n",dic);
                                                             
                                                             if ([[dic objectForKey:@"status"] integerValue] == 1) {
                                                                 [self.view makeToast:@"发布成功" duration:1.2f position:@"center" isShadow:NO];
                                                                 [self performSelector:@selector(addSuccess) withObject:nil afterDelay:1.5f];
                                                             }
                                                             
                                                             else{
                                                                 NSString * infooo = [dic objectForKey:@"info"];
                                                                 [self.view makeToast:infooo duration:1.2f position:@"center" isShadow:NO];
                                                                 
                                                                 [sendBtn setEnabled:YES];
                                                             }
                                                             
                                                         }
                                                         failure:^{
                                                             
                                                             [sendBtn setEnabled:YES];

                                                             [_titleTextField becomeFirstResponder];
                                                             
                                                             [self.view hideToastActivity];
                                                             [self.view makeToast:@"网络错误" duration:1.2f position:@"center" isShadow:NO];
                                                             
                                                         }];
    }
    
    else{

        [self.view makeToastActivity];
        
        [sendBtn setEnabled:NO];

        [[QYAPIClient sharedAPIClient]postBoardToServerWithTitle:titleee
                                                         content:describtion
                                                       imageData:nil
                                                      chatRoomID:self.roomNumber
                                                           token:token
                                                         success:^(NSDictionary *dic) {
                                                             
                                                             [self.view hideToastActivity];
                                                             
                                                             if ([[dic objectForKey:@"status"] integerValue] == 1) {
                                                                 [self.view makeToast:@"发布成功" duration:1.2f position:@"center" isShadow:NO];
                                                                 [self performSelector:@selector(addSuccess) withObject:nil afterDelay:1.5f];
                                                             }
                                                             else{
                                                                 NSString * infooo = [dic objectForKey:@"info"];
                                                                 [self.view makeToast:infooo duration:1.2f position:@"center" isShadow:NO];
                                                                 
                                                                 [sendBtn setEnabled:YES];
                                                             }
                                                             
                                                         }
                                                         failure:^{
                                                             [sendBtn setEnabled:YES];

                                                             [_titleTextField becomeFirstResponder];
                                                             
                                                             [self.view hideToastActivity];
                                                             [self.view makeToast:@"网络错误" duration:1.2f position:@"center" isShadow:NO];
                                                         }];
    }
    
}



- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}


-(void)addSuccess
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (_delegate && [_delegate respondsToSelector:@selector(didAddMessageSuccess:)]) {
            [_delegate didAddMessageSuccess:_blackBoardToken];
        }
    }];
}



-(void)clickBackButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
//    QY_SAFE_RELEASE(_photoData);
    QY_VIEW_RELEASE(_titleTextField);
    QY_VIEW_RELEASE(_detailTextView);
    QY_VIEW_RELEASE(_keyBoardPhotoBtn);
    
    [_blackBoardToken release];
    _blackBoardToken = nil;
    
    [super dealloc];
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
