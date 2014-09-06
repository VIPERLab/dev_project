//
//  AddBoardMessgeViewController.h
//  QYER
//
//  Created by Leno on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"

#import "PhotoListController.h"

#import "UIPlaceHolderTextView.h"
#import "CustomPickerImageDelegate.h"
#import "CCActiotSheet.h"

@protocol AddBoardMessgaeSuccessDelegate;


@interface AddBoardMessgeViewController : BaseViewController<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CustomPickerImageDelegate, CCActiotSheetDelegate>
{
    UITextField     * _titleTextField;
    
    UIView          * _textViewBackGroundView;
    
    UIPlaceHolderTextView      * _detailTextView;

//    UIView          * _keyBoardAccessoryView;
    
    UIButton        * _keyBoardPhotoBtn;
    
    BOOL              _hasPhoto;//判断是否已有照片

    NSMutableData   * _photoData;
    
    UIImage         * _photoImage;
    
    NSString        *_blackBoardToken;
    
    float           _textFieldSizeHeight;
        
}

@property (assign, nonatomic) id<AddBoardMessgaeSuccessDelegate> delegate;

@property (retain, nonatomic)NSString * roomNumber;

@end

@protocol AddBoardMessgaeSuccessDelegate<NSObject>

-(void)didAddMessageSuccess:(NSString*)token;//添加黑板留言成功

@end
