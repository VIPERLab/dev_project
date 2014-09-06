//
//  CorrectErrorsViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-8-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYGuide.h"

@interface CorrectErrorsViewController : UIViewController <UITextViewDelegate>
{
    UIButton        *_sendButton;
    UITextView      *_textView_correctErrors;
    UILabel         *_label_textViewPlaceholder;
}

@property(nonatomic, assign) NSInteger pageNumber;
@property(nonatomic, retain) QYGuide *guide;

@end
