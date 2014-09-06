//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSMessageInputView.h"

#import <QuartzCore/QuartzCore.h>
#import "JSBubbleView.h"
#import "NSString+JSMessagesView.h"
#import "UIColor+JSMessagesView.h"

@interface JSMessageInputView ()

- (void)setup;
- (void)configureInputBarWithStyle:(JSMessageInputViewStyle)style;

@end



@implementation JSMessageInputView

#define INPUT_HEIGHT 46.0f

#pragma mark - Initialization

- (void)setup
{
    //************ Mod By ZhangDong 2014.5.13 Start ************
    //修改背景颜色
    self.backgroundColor = [UIColor colorWithRed:69/255. green:79/255. blue:97/255. alpha:1];;
    //************ Mod By ZhangDong 2014.5.13 End ************
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
}

- (void)configureInputBarWithStyle:(JSMessageInputViewStyle)style
{
    //************ Mod By ZhangDong 2014.4.29 Start ************
    CGFloat textViewX = 54.0f;
    CGFloat sendButtonWidth = 10.0f + textViewX;
    //************ Mod By ZhangDong 2014.4.29 Start ************
    
    CGFloat width = self.frame.size.width - sendButtonWidth;
    CGFloat height = [JSMessageInputView textViewLineHeight];
    
    JSMessageTextView *textView = [[JSMessageTextView  alloc] initWithFrame:CGRectZero];
    [self addSubview:textView];
	_textView = textView;
    
    //************ Mod By ZhangDong 2014.5.13 Start ************
    _textView.frame = CGRectMake(textViewX, 5.0f, width, height);
    _textView.layer.cornerRadius = 4.0f;
    //        _textView.backgroundColor = [UIColor clearColor];
    //        _textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    //        _textView.layer.borderWidth = 0.65f;
    
    //************ Mod By ZhangDong 2014.5.13 End ************
}

//*********** Mod By ZhangDong 2014.4.29 Start **********
/**
 *  配置相机按钮
 */
- (void)configureMediaButton
{
    // set up the image and button frame
    UIImage* image = [UIImage imageNamed:@"button-photo"];
    UIImage* imagePress = [UIImage imageNamed:@"button-photo-press"];
    CGRect frame = CGRectMake(7.0f, 4.0f, image.size.width, image.size.height);
    CGFloat yHeight = (INPUT_HEIGHT - frame.size.height) / 2.0f;
    frame.origin.y = yHeight;
    
    // make the button
    UIButton* mediaButton = [[UIButton alloc] initWithFrame:frame];
    [mediaButton setBackgroundImage:image forState:UIControlStateNormal];
    [mediaButton setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    [self setMediaButton:mediaButton];
}
//*********** Mod By ZhangDong 2014.4.29 End **********

- (instancetype)initWithFrame:(CGRect)frame
                        style:(JSMessageInputViewStyle)style
                     delegate:(id<UITextViewDelegate, JSDismissiveTextViewDelegate>)delegate
         panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        [self setup];
        [self configureInputBarWithStyle:style];
        //*********** Mod By ZhangDong 2014.4.29 Start **********
        [self configureMediaButton];
        //*********** Mod By ZhangDong 2014.4.29 End **********
        
        _textView.delegate = delegate;
        _textView.keyboardDelegate = delegate;
        _textView.dismissivePanGestureRecognizer = panGestureRecognizer;
    }
    return self;
}



- (void)dealloc
{
    _textView = nil;
}

#pragma mark - UIView

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - Setters

- (void)setMediaButton:(UIButton *)btn
{
    if (_mediaButton)
        [_mediaButton removeFromSuperview];
    
    [self addSubview:btn];
    _mediaButton = btn;
}

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.textView.frame;
    
    NSUInteger numLines = MAX([self.textView numberOfLinesOfText],
                              [self.textView.text js_numberOfLines]);
    
    //  below iOS 7, if you set the text view frame programmatically, the KVO will continue notifying
    //  to avoid that, we are removing the observer before setting the frame and add the observer after setting frame here.
    [self.textView removeObserver:_textView.keyboardDelegate
                       forKeyPath:@"contentSize"];
    
    self.textView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    
    [self.textView addObserver:_textView.keyboardDelegate
                    forKeyPath:@"contentSize"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.textView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length - 2, 1)];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 34.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 4.0f : 8.0f;
}

+ (CGFloat)maxHeight
{
    return ([JSMessageInputView maxLines] + 1.0f) * [JSMessageInputView textViewLineHeight];
}

- (void)setEnable:(BOOL)isEnable
{
    self.mediaButton.enabled = isEnable;
    self.textView.editable = isEnable;
}

@end
