//
//  picturePickerView.m
//  playPictures
//
//  Created by 改 熊 on 12-7-26.
//  Copyright (c) 2012年 kuwo. All rights reserved.
//

#import "picturePickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageMgr.h"
#import "KwTools.h"
#import "globalm.h"
#import "ImageProcessingViewController.h"
#import "KSAppDelegate.h"

#pragma mark
#pragma mark  imageItem

@protocol imageItemDelegate

-(void)reLoad:(NSInteger)index;
-(void)moveAnimation:(NSInteger)index;
-(void)imageSelected:(NSInteger)index;

@end

@interface imageItem : UIView
{
    int countItem;  //表示自己是几个Item，发送重绘消息时需要传递回
}
@property (nonatomic,assign) id<imageItemDelegate> delegate;
@property (nonatomic) int countItem;

-(void)buttonClicked;
-(id)initWithImage:(UIImage*)setImage Frame:(CGRect)rect Count:(NSInteger)countNum;

@end

@implementation imageItem
@synthesize delegate,countItem;


-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)buttonClicked
{
    [[self delegate] moveAnimation:countItem];
}

-(id)initWithImage:(UIImage *)setImage Frame:(CGRect)rect Count:(NSInteger)countNum
{
    self=[super init];
    if (self) {
        [self setFrame:rect];
        countItem=countNum;
        UIButton* imageField =[[[UIButton alloc] initWithFrame:CGRectMake(GAP, UPGAP, WIDTH, HEIGHT)] autorelease];
        [imageField addTarget:self action:@selector(onImageSelect) forControlEvents:UIControlEventTouchUpInside];
        CALayer *layer=[imageField layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:10.0];
        [layer setBorderWidth:0.5];
        [layer setBorderColor:[[UIColor clearColor] CGColor]];
        
        UIImageView* imageEdge=[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx(EDGE)] autorelease];
        [imageEdge setFrame:CGRectMake(GAP-EDGE_WIDTH, UPGAP-EDGE_WIDTH, WIDTH+2*EDGE_WIDTH, HEIGHT+2*EDGE_WIDTH)];
        [self addSubview:imageEdge];
        
        [imageField setImage:setImage forState:UIControlStateNormal];
        
        UIButton* buttonField=[[[UIButton alloc] initWithFrame:CGRectMake(GAP+WIDTH-BUTTON_WIDTH/2, UPGAP-BUTTON_HEIGHT/2, BUTTON_WIDTH, BUTTON_HEIGHT)] autorelease];
        [buttonField setFrame:CGRectMake(GAP+WIDTH-BUTTON_WIDTH/2, UPGAP-BUTTON_HEIGHT/2, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [buttonField setBackgroundImage:CImageMgr::GetImageEx(CLOSE_X) forState:UIControlStateNormal];
        [buttonField setEnabled:YES];
        [buttonField addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [buttonField setHidden:NO];
        
        [self addSubview:imageField];
        [self addSubview:buttonField];
    }
    return self;
}
-(void)onImageSelect
{
    //[imageField setEnabled:YES];
    [[self delegate] imageSelected:[self countItem]];
}
-(void)dealloc
{
    [super dealloc];
}
@end

#pragma mark 
#pragma mark picturePickerView

@interface picturePickerView() <imageItemDelegate>
{
    int count;
    int selectNum;//当前的焦点，为vec中的下标，-1为默认
}
-(void)addImage:(UIImage*)image;
-(void)onAdd:(id)sender;
-(UIViewController *)viewController; 
-(void)reLoad:(NSInteger)index;
-(BOOL)writeImage:(UIImage*)image ToFilePath:(NSString *)aPath;
-(BOOL)deleteImageFromFilePath:(NSString *)aPath;
-(NSString*)CurTimeToString;
@end


@implementation picturePickerView
@synthesize position,sview,allRect,deletaButton,addButton,addImageEdge,delegate;
@synthesize imageList=_imageList;
@synthesize imagePathList=_imagePathList;

#pragma mark init


- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        if (_imageList.size()>MAX_NUM_IMAGES) {
            //NSLog(@"too many pistures");
            return self;
        }
        selectNum=-1;
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
        [self setPosition:CGPointZero];//初始化posiotion
        isReLoad=false;
        
        CGRect rect = [self bounds];
        
        double wholeWidth=WIDTH+2*GAP;
        allRect=CGRectMake(rect.origin.x, rect.origin.y, wholeWidth, rect.size.height);
        
        sview=[[[UIScrollView alloc] initWithFrame:allRect] autorelease];
        [sview setContentOffset:position];
        [sview setContentSize:CGSizeMake(allRect.size.width*2-[[UIScreen mainScreen] bounds].size.width, allRect.size.height)];
        sview.showsVerticalScrollIndicator=NO;
        sview.showsHorizontalScrollIndicator=NO;
        
        addButton=[[[UIButton alloc] init] autorelease];
        [addButton setImage:CImageMgr::GetImageEx(ADD_IMAGE_BUTTON) forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setFrame:CGRectMake(GAP, UPGAP, WIDTH, HEIGHT)];
        [sview addSubview:addButton];

        addImageEdge=[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx(EDGE)] autorelease];
        [addImageEdge setFrame:CGRectMake(GAP-EDGE_WIDTH, UPGAP-EDGE_WIDTH, WIDTH+EDGE_WIDTH*2, HEIGHT+EDGE_WIDTH*2)];
        [sview addSubview:addImageEdge];

        addButton.hidden=NO;
        addImageEdge.hidden=NO;

        [self addSubview:sview];
        
    }
    return self;
}

-(void)onAdd:(id)sender
{
    UIActionSheet *sheet=[[[UIActionSheet alloc] initWithTitle:@"选取图片" 
                                                      delegate:self 
                                             cancelButtonTitle:@"取消" 
                                        destructiveButtonTitle:nil 
                                             otherButtonTitles:@"立刻拍照",@"上传相册照片", nil] autorelease];
    [sheet showInView:self];
}
-(void)addImage:(UIImage *)image
{
    _imageList.push_back([image retain]);
}

-(std::vector<UIImage *>)getImageList
{
    return _imageList;
}

- (UIViewController*)viewController
{   
    for (UIView* next = [self superview]; next; next = next.superview) {    
        UIResponder* nextResponder = [next nextResponder];     
        if ([nextResponder isKindOfClass:[UIViewController class]]) {      
            return (UIViewController*)nextResponder;
        }   
    }
    return nil; 
}
-(BOOL)writeImage:(UIImage *)image ToFilePath:(NSString *)aPath
{
    //NSLog(@"write %@",aPath);
    if ((image==nil) || (aPath==nil) ||[aPath isEqualToString:@""]) {
        return FALSE;
    }
    NSData *imageData=UIImagePNGRepresentation(image);
    if ((imageData == nil) || ([imageData length] <= 0)) {
        return FALSE;
    }
    [imageData writeToFile:aPath atomically:YES];
    return TRUE;
}
-(BOOL)deleteImageFromFilePath:(NSString *)aPath
{
//    NSLog(@"delete %@",aPath);
    NSFileManager *fileMgr=[NSFileManager defaultManager];
    NSError *error;
    if (![fileMgr removeItemAtPath:aPath error:&error]) {
        //NSLog(@"delete error:%@",[error localizedDescription]);
        return FALSE;
    }
    [_playView deleleImage:aPath];
    return TRUE;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
            
        case 1:
        {
            UIImagePickerController * imagePicker=[[[UIImagePickerController alloc] init] autorelease];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [imagePicker setDelegate:self];
            imagePicker.allowsEditing=YES;
            
            [[self viewController] presentModalViewController:imagePicker animated:YES];
            break;
        }
        case 0:
        {
            UIImagePickerController* imagePicker=[[[UIImagePickerController alloc] init] autorelease];
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                [imagePicker setDelegate:self];
                
                imagePicker.allowsEditing=YES;
                [[self viewController] presentModalViewController:imagePicker animated:YES];
            }
            break;
        }
        default:
            break;
    }
}
-(void)imageSelected:(NSInteger)index
{
    //需要参数index，button——click的时候传递的button的count，
    //删除的时候需要下一张图片的count
    //新增加图片的时候直接传入1
    UIImage *selectImage=nil;
    if (index==-1)
    {
        //删除了最后一张
        selectNum=-1;
    }
    else 
    {
        index=_imageList.size()-index;
        selectNum=index;
        selectImage=_imageList.at(index);
    }
    [[self delegate] onImageSelected:selectImage];
}
-(void)setImagePathList:(std::vector<NSString *>)imagePathList
{
    for (std::vector<NSString *>::iterator i=imagePathList.begin(); i!=imagePathList.end(); i++) {
        //NSLog(@"set image:%@",*i);
        //UIImage *image=CImageMgr::GetImageEx([*i UTF8String]);
        UIImage *image=[UIImage imageWithContentsOfFile:*i];
        [self addImage:[image retain]];
        [image release];
        _imagePathList.push_back([*i retain]);
        [self reLoad:MAX_NUM_IMAGES+1];
    }
    if (_imageList.size()>MAX_NUM_IMAGES) {
        //NSLog(@"too many pistures");
        return;
    }
    
}
-(void)reLoad:(NSInteger)index
{
    if (index<=_imageList.size()){
        //remove item
        addButton.hidden=NO;
        [[sview viewWithTag:index] removeFromSuperview];
        
        for (int i=index+1; i<=_imageList.size(); i++) {
            imageItem *item=(imageItem*)[sview viewWithTag:i];
            
            [item setCountItem:(i-1)];
            [item setTag:(item.tag-1)];
        }
        
        //从imageItem的count计算出需要删除的图片
        int i=1;
        int imageIndex=_imageList.size()-index+1;
        std::vector<UIImage*>::iterator reMoveiter=_imageList.begin();
        std::vector<NSString*>::iterator reMoveListiter=_imagePathList.begin();
        while (i<imageIndex) {
            i++;
            reMoveiter++;
            reMoveListiter++;
        }
        _imageList.erase(reMoveiter);
        [self deleteImageFromFilePath:*reMoveListiter];
        _imagePathList.erase(reMoveListiter);

        if (_imageList.size()==MAX_NUM_IMAGES-1) {
            addButton=[[[UIButton alloc] init] autorelease];
            [addButton setImage:CImageMgr::GetImageEx(ADD_IMAGE_BUTTON) forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
            [addButton setFrame:CGRectMake(GAP, UPGAP, WIDTH, HEIGHT)];
            addImageEdge=[[[UIImageView alloc] init] autorelease];
            [addImageEdge setImage:CImageMgr::GetImageEx(EDGE)];
            [addImageEdge setFrame:CGRectMake(GAP-EDGE_WIDTH, UPGAP-EDGE_WIDTH, WIDTH+EDGE_WIDTH*2, HEIGHT+EDGE_WIDTH*2)];
            [sview addSubview:addImageEdge];
            [sview addSubview:addButton];
        }
        
        [self setPosition:[sview contentOffset]];
        CGRect rect=[self bounds];
        int numOfImage=_imageList.size();
        
        double wholeWidth=(WIDTH+2*GAP)*(numOfImage+1);
        
        allRect=CGRectMake(rect.origin.x, rect.origin.y, wholeWidth, rect.size.height);
        [sview setFrame:allRect];

        
        [sview setContentSize:CGSizeMake(allRect.size.width*2-[[UIScreen mainScreen] bounds].size.width, allRect.size.height)];
    }
    else{
        //add item
        for (UIView* views in [sview subviews]) {
            [views removeFromSuperview];
        }
        
        CGRect rect=[self bounds];
        int numOfImage=_imageList.size();
        
        double wholeWidth=(WIDTH+2*GAP)*(numOfImage+1);
        
        allRect=CGRectMake(rect.origin.x, rect.origin.y, wholeWidth, rect.size.height);
        [sview setFrame:allRect];
        if (numOfImage==MAX_NUM_IMAGES) {
            [sview setContentSize:CGSizeMake(allRect.size.width*2-[[UIScreen mainScreen] bounds].size.width-WIDTH-2*GAP, allRect.size.height)];
            addButton.hidden=YES;
        }
        else {
            [sview setContentSize:CGSizeMake(allRect.size.width*2-[[UIScreen mainScreen] bounds].size.width, allRect.size.height)];
        }
        sview.showsVerticalScrollIndicator=NO;
        sview.showsHorizontalScrollIndicator=NO;
        
        std::vector<UIImage *>::reverse_iterator iter=_imageList.rbegin();//新增加的图片在前面，反向显示list中的图片
        
        addButton=[[[UIButton alloc] init] autorelease];
        [addButton setImage:CImageMgr::GetImageEx(ADD_IMAGE_BUTTON) forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setFrame:CGRectMake(GAP, UPGAP, WIDTH, HEIGHT)];
        addImageEdge=[[[UIImageView alloc] init] autorelease];
        [addImageEdge setImage:CImageMgr::GetImageEx(EDGE)];
        [addImageEdge setFrame:CGRectMake(GAP-EDGE_WIDTH, UPGAP-EDGE_WIDTH, WIDTH+EDGE_WIDTH*2, HEIGHT+EDGE_WIDTH*2)];
        [sview addSubview:addImageEdge];
        [sview addSubview:addButton];
        
        if (numOfImage<MAX_NUM_IMAGES) {
            count=1;
            addButton.hidden=NO;
            addImageEdge.hidden=NO;
        }
        else {
            addButton.hidden=YES;
            addImageEdge.hidden=YES;
            count=0;
        }
        for (; iter!=_imageList.rend(); iter++,count++) {
            if (_imageList.size()==MAX_NUM_IMAGES) {
                imageItem *item=[[imageItem alloc] initWithImage:*iter Frame:CGRectMake(count*(WIDTH+2*GAP), 0, WIDTH*2*GAP, HEIGHT+2*GAP) Count:count+1];
                [item setDelegate:self];
                item.tag=count+1;
                [sview addSubview:item];
                [item release];
            }
            else {
                imageItem *item=[[imageItem alloc] initWithImage:*iter Frame:CGRectMake(count*(WIDTH+2*GAP), 0, WIDTH*2*GAP, HEIGHT+2*GAP) Count:count];
                [item setDelegate:self];
                item.tag=count;
                [sview addSubview:item];
                [item release];
            }
        }
        [self addSubview:sview];
    }
}

-(void)moveAnimation:(NSInteger)index
{
    //index为图片的count
    int temp=index;
    if (index>_imageList.size()-selectNum) {
        selectNum--;
    }
    if (temp==_imageList.size()-selectNum) {
        //删除正好选中的
        if (_imageList.size()==1) {
            //删除的正好是最后一张
            temp=-1;
        }
        else if(temp==_imageList.size())
        {
            
            //删除的是排在最后的图片，默认选中前一张
            temp=temp-1;
        }
        else {
            //一般情况直接默认下一张
            temp++;
        }
        [self imageSelected:temp];
    }
    if (_imageList.size()<MAX_NUM_IMAGES) {
        [UIView animateWithDuration:0.5f animations:^(void)
         {
             imageItem* removeItem=(imageItem*)[self viewWithTag:index];
             removeItem.alpha=0.0f;
             for (int i=index+1; i<=_imageList.size(); i++) {
                 UIView* moveView=[self viewWithTag:i];
                 moveView.center=CGPointMake(moveView.center.x-WIDTH-2*GAP,moveView.center.y);
             } 
         }completion:^(BOOL finished)
         {
             [self reLoad:index];
         }];
    }
    else {
        [UIView animateWithDuration:0.5f animations:^(void)
         {
             for (int i=1; i<index; i++) {
                 UIView* moveView=[self viewWithTag:i];
                 moveView.center=CGPointMake(moveView.center.x+WIDTH+2*GAP, moveView.center.y);
             }
         } completion:^(BOOL finished)
         {
             [self reLoad:index];
         }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[self viewController] dismissModalViewControllerAnimated:YES];
    NSLog(@"nava:%@",ROOT_NAVAGATION_CONTROLLER.view);
     UIImage* addImage=[info objectForKey:UIImagePickerControllerEditedImage];
    [[self delegate] onAddImage:addImage];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picke
{
    NSLog(@"nava:%@",ROOT_NAVAGATION_CONTROLLER.view);
    [[self viewController] dismissModalViewControllerAnimated:YES];
    //[ROOT_NAVAGATION_CONTROLLER.view setFrame:CGRectMake(0, 20, 320, 548)];
    
}
- (void)onImageProsessingDone:(UIImage *)image
{
    [image retain];
    _imageList.push_back(image);
    NSString *imagePath=[NSString stringWithFormat:@"%@/%@.jpg",KwTools::Dir::GetPath(KwTools::Dir::PATH_BKIMAGE),[self CurTimeToString]];
//    NSLog(@"add imagepath:%@",imagePath);
    [self writeImage:image ToFilePath: imagePath];
    [_playView addImage:imagePath];
    [imagePath retain];
    _imagePathList.push_back(imagePath);
    
    [self reLoad:MAX_NUM_IMAGES+1];
    [self imageSelected:1];
}
-(NSString*)CurTimeToString
{
    //都以“-”间隔
    NSDate* date = [NSDate date];
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
	NSString* tmString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return tmString;
}
-(void)dealloc
{
    for (std::vector<NSString*>::iterator i=_imagePathList.begin(); i!=_imagePathList.end(); i++) {
        [*i release];
    }
    for (std::vector<UIImage*>::iterator i=_imageList.begin(); i!=_imageList.end(); i++) {
        [*i release];
    }
    [super dealloc];
}

@end
