//
//  ProduceMyImage.m
//  PackingList
//
//  Created by 安庆 安庆 on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ProduceMyImage.h"
#import "UserAvatarData.h"

@implementation ProduceMyImage
@synthesize myImage;

-(id)init
{
    if (self = [super init]) 
    {
        
    }
    return self;
}

-(void)dealloc
{
    //[VC release];
    //[myImage release];
    [myPicker release];
    [super dealloc];
}

-(void)getVC:(UIViewController *)vc
{
    VC = vc;
//    if(![VC isEqual:vc])
//    {
//        [VC release];
//        VC = [vc retain];
//    }
}

-(void)produceImage:(NSInteger)flag
{
    myFlag = flag;
    if(flag == 0 || flag == 2)
    {
        [self selectImageFromAlbum];
    }
    else if(flag == 1 || flag == 3)
    {
        [self takePhoto];
    }
}

-(void)selectImageFromAlbum //从相册库选取
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) //如果照片库可用
    {
        if(!myPicker)
        {
            myPicker = [[UIImagePickerController alloc] init];
        }
        myPicker.delegate = self;
        [myPicker.navigationBar setTintColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
        
        
        //注意:照片库里的图片要想设为可编辑,那么图片的实例变量必须命名为‘UIImageView *imageView’;
        //其它命名方式是不行的,例:'UIImageView *imageView;'
        //myPicker.allowsImageEditing = YES;
        [myPicker setAllowsEditing:YES];
        
        
        myPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //设为照片库
        [VC presentModalViewController:myPicker animated:YES];
        
    }
    else 
    {
        UIAlertView *alert = [[UIAlertView alloc] 
                               initWithTitle:@"获取照片失败" 
                               message:@"没有可用照片库!" 
                               delegate:VC
                               cancelButtonTitle:@"确定"
                               otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void)takePhoto //拍照
{
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType 
{
    NSArray *mediaTypes = [UIImagePickerController
						   availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType] && [mediaTypes count] > 0) 
    {
        NSArray *mediaTypes = [UIImagePickerController
							   availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [VC presentModalViewController:picker animated:YES];
        [picker release];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] 
                               initWithTitle:@"操作失败" 
                               message:@"没有可用拍摄设备!" 
                               delegate:VC 
                               cancelButtonTitle:@"确定" 
                               otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

//取消选取照片或拍照:
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    
    NSLog(@" ------------- ");
}

//当选取照片后执行该方法
- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo 
{
    myImage = image;
    [picker dismissModalViewControllerAnimated:YES];
    
    NSLog(@" ============== ");
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"produceImage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:image,@"image", nil]];
}

@end

