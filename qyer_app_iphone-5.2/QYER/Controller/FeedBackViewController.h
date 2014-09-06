//
//  FeedBackViewController.h
//  QyGuide
//
//  Created by 你猜你猜 on 13-9-4.
//
//

#import <UIKit/UIKit.h>

@interface FeedBackViewController : UIViewController <UITextViewDelegate>
{
    UIImageView         *_headView;
    UIButton            *_button_back;
    UIButton            *_button_send;
    
    UITextView          *_textView_feedBack;
    UILabel             *_placeholderLabel_textView;
    UIView              *_backGroundView_mail;
    UITextField         *_textfield_mail;
}

@end
