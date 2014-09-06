//
//  CommentGuideViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentGuideViewController : UIViewController <UITextViewDelegate>
{
    UIImageView         *_headView;
    NSString            *_str_title;
    UIButton            *_sendButton;
    
    UITextView          *_textView;
    UILabel             *_label_placeholder;
    
}
@property(nonatomic,retain) NSString       *str_title;
@property(nonatomic,retain) NSString       *str_guideId;

@end
