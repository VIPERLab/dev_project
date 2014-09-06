//
//  ErrorCorrectionViewController.h
//  QYGuide
//
//  Created by 我去 on 14-2-8.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface ErrorCorrectionViewController : UIViewController <ASIHTTPRequestDelegate,UIAlertViewDelegate,UITextViewDelegate>
{
    UITextView      *myTextView;
    NSMutableData   *receiveData;
    UIView          *smallBlackView;
    UILabel         *alertLabel;
    UIView          *_banView;
    UIImageView     *_headView;
    UIButton        *_cancelButton;
    UIButton        *_sendButton;
    UILabel         *_titleLabel;
    UILabel         *_label_placeholder;
}

@property(nonatomic,retain) UITextView  *myTextView;
@property(nonatomic,retain) NSString    *updateTime;
@property(nonatomic,retain) NSString    *guideName;
@property(nonatomic,retain) NSString    *strPageNumber;

@end
