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

#import "JSBubbleView.h"

#import "JSMessageInputView.h"
#import "JSAvatarImageFactory.h"
#import "NSString+JSMessagesView.h"
#import "UIColor+JSMessagesView.h"

#import "QYIMOtherView.h"
#import "OtherMessage.h"


#define kMarginTop 35.0f
#define kMarginBottom 0.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 20.0f

static const CGFloat kActivityViewWidth = 35.0f;
static const CGFloat kActivityViewHeight = 35.0f;
static const CGFloat kSendErrorBtnWidth = 18.0f;
static const CGFloat kSendErrorBtnHeight = 18.0f;


@interface JSBubbleView()

- (void)setup;

- (void)addTextViewObservers;
- (void)removeTextViewObservers;

+ (CGSize)textSizeForText:(NSString *)txt;
+ (CGSize)neededSizeForText:(NSString *)text;
+ (CGFloat)neededHeightForText:(NSString *)text;

@end


@implementation JSBubbleView

@synthesize font = _font;

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(JSBubbleMessageType)bubleType
              bubbleImageView:(UIImageView *)bubbleImageView
                    mediaType:(JSBubbleMediaType)bubbleMediaType
            displaysTimestamp:(BOOL)displaysTimestamp
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
        _type = bubleType;
        
        self.displaysTimestamp = displaysTimestamp;
        
        bubbleImageView.userInteractionEnabled = YES;
        [self addSubview:bubbleImageView];
        _bubbleImageView = bubbleImageView;
        
        //************ Insert By ZhangDong 2014.4.29 Start ************
        self.mediaType = bubbleMediaType;
        
        switch (bubbleMediaType) {
            case JSBubbleMediaTypeText:
                [self configTextView];
                break;
            case JSBubbleMediaTypeImage:
                [self configImageView];
                break;
            case JSBubbleMediaTypeNewUserJoin:
                [self configUserNameLabel];
                break;
            case JSBubbleMediaTypeTips:
                [self configTipsLabel];
                break;
            case JSBubbleMediaTypeRichText:
                [self configOtherView];
                break;
            default:
                
                break;
        }
        
        if (_type == JSBubbleMessageTypeOutgoing) {
            [self configActivityIndicatorView];
        }
        
        //************ Insert By ZhangDong 2014.4.29 End ************
    }
    return self;
}

/**
 *  配置普通的单元格
 */
- (void)configTextView
{
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.textColor = [UIColor blackColor];
    textView.editable = NO;
    textView.userInteractionEnabled = YES;
    textView.showsHorizontalScrollIndicator = NO;
    textView.showsVerticalScrollIndicator = NO;
    textView.scrollEnabled = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.contentInset = UIEdgeInsetsZero;
    textView.scrollIndicatorInsets = UIEdgeInsetsZero;
    textView.contentOffset = CGPointZero;
//    textView.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;

    [self addSubview:textView];
    [self bringSubviewToFront:textView];
    _textView = textView;
    
    if ([_textView respondsToSelector:@selector(textContainerInset)]) {
        _textView.textContainerInset = UIEdgeInsetsMake(8.0f, 4.0f, 2.0f, 4.0f);
    }
    
    [self addTextViewObservers];
}

/**
 *  配置图片单元格
 */
- (void)configImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.exclusiveTouch = YES;
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    [self bringSubviewToFront:imageView];
    _imageView = imageView;
}

/**
 *  配置其他视图，图文混排、POI、APP
 */
- (void)configOtherView
{
    QYIMOtherView *otherView = [[QYIMOtherView alloc] init];
    otherView.exclusiveTouch = YES;
    [self addSubview:otherView];
    [self bringSubviewToFront:otherView];
    _otherView = otherView;
}

- (void)configUserNameLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = RGB(202, 217, 227);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:12.0f];
    label.textColor = [UIColor js_messagesTimestampColorClassic];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 4;
    
    [self addSubview:label];
    [self bringSubviewToFront:label];
    _userLabel = label;
}

- (void)configTipsLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = RGB(202, 217, 227);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:12.0f];
    label.textColor = [UIColor js_messagesTimestampColorClassic];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 4;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self addSubview:label];
    [self bringSubviewToFront:label];
    _tipsLabel = label;
}

/**
 *  配置发送状态的菊花视图和发送失败按钮
 */
- (void)configActivityIndicatorView
{
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] init];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _activityView = activityView;
    [self addSubview:activityView];
    [self bringSubviewToFront:activityView];
    
    _sendAgainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendAgainButton.hidden = YES;
    UIImage *image = [UIImage imageNamed:@"IM_Send_Error"];
    [_sendAgainButton setBackgroundImage:image forState:UIControlStateNormal];
    [_sendAgainButton addTarget:self action:@selector(sendAgainButtonHandler) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendAgainButton];
    [self bringSubviewToFront:_sendAgainButton];
}

/**
 *  点击重新发送按钮，触发的方法
 */
- (void)sendAgainButtonHandler{
    if ([self.delegate respondsToSelector:@selector(sendAgainWithIndexPath:)]) {
        [self.delegate sendAgainWithIndexPath:self.indexPath];
    }
}

- (void)dealloc
{
    [self removeTextViewObservers];
    _bubbleImageView = nil;
    _textView = nil;
}

#pragma mark - KVO

- (void)addTextViewObservers
{
    [_textView addObserver:self
                forKeyPath:@"text"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [_textView addObserver:self
                forKeyPath:@"font"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [_textView addObserver:self
                forKeyPath:@"textColor"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
}

- (void)removeTextViewObservers
{
    [_textView removeObserver:self forKeyPath:@"text"];
    [_textView removeObserver:self forKeyPath:@"font"];
    [_textView removeObserver:self forKeyPath:@"textColor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.textView) {
        if ([keyPath isEqualToString:@"text"]
            || [keyPath isEqualToString:@"font"]
            || [keyPath isEqualToString:@"textColor"]) {
            [self setNeedsLayout];
        }
    }
}

#pragma mark - Setters

- (void)setFont:(UIFont *)font
{
    _font = font;
    _textView.font = font;
}

//************ Insert By ZhangDong 2014.4.29 Start ************
- (void)setMediaType:(JSBubbleMediaType)newMediaType{
    _mediaType = newMediaType;
    [self setNeedsLayout];
}

- (void)setData:(id)newData{
    _data = newData;
    [self setNeedsLayout];
}
//************ Insert By ZhangDong 2014.4.29 End ************

#pragma mark - UIAppearance Getters

- (UIFont *)font
{
    if (_font == nil) {
        _font = [[[self class] appearance] font];
    }
    
    if (_font != nil) {
        return _font;
    }
    
    return [UIFont systemFontOfSize:16.0f];
}

#pragma mark - Getters

//************ Insert By ZhangDong 2014.4.29 Start ************
- (CGRect)bubbleFrame
{
    if(self.mediaType == JSBubbleMediaTypeText){
        CGSize bubbleSize = [JSBubbleView neededSizeForText:self.textView.text];
        
        return CGRectMake((self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width - 25.0f: 15.0f),
                          floorf(kMarginTop),
                          bubbleSize.width + 10,
                          bubbleSize.height + 5);
    }else if (self.mediaType == JSBubbleMediaTypeImage){
        CGSize bubbleSize = [JSBubbleView imageSizeForImage];
        return CGRectMake(floorf(self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width - 25.0f: 15.0f),
                          floorf(kMarginTop),
                          floorf(bubbleSize.width),
                          floorf(bubbleSize.height));
    }else  if (self.mediaType == JSBubbleMediaTypeRichText){
        CGSize bubbleSize = [JSBubbleView otherSizeForOtherView];
        return CGRectMake(floorf(self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width - 25.0f : 15.0f),
                          floorf(kMarginTop),
                          floorf(bubbleSize.width),
                          floorf(bubbleSize.height));
    }
    return CGRectZero;
}

//************ Insert By ZhangDong 2014.4.29 End ************

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bubbleImageView.frame = [self bubbleFrame];
    
    CGFloat textX = self.bubbleImageView.frame.origin.x;
    CGFloat x = 0;
    
    if (self.mediaType == JSBubbleMediaTypeText) {
        
        if (self.type == JSBubbleMessageTypeIncoming) {
            textX += 8;
        }
        
        CGRect textFrame = CGRectMake(textX,
                                      self.bubbleImageView.frame.origin.y,
                                      self.bubbleImageView.frame.size.width - 10,
                                      self.bubbleImageView.frame.size.height);
        self.textView.frame = CGRectIntegral(textFrame);
        
        x = self.textView.frame.origin.x;
    }
    else if (self.mediaType == JSBubbleMediaTypeImage)
    {
        if (self.type == JSBubbleMessageTypeIncoming) {
            textX += 8;
        }
        CGRect imageFrame = CGRectMake(textX, 34, kJSImageViewWidth, kJSImageViewHeight);
        
        self.imageView.frame = CGRectIntegral(imageFrame);
        self.imageView.layer.borderColor = RGB(224, 224, 224).CGColor;
        self.imageView.layer.borderWidth = 2;
        self.imageView.layer.cornerRadius = 4;
        self.imageView.layer.masksToBounds = YES;
        if ([self.data isKindOfClass:[NSData class]]) {
            self.imageView.image = [UIImage imageWithData:self.data];
        }
        x = self.imageView.frame.origin.x;
    }
    else if (self.mediaType == JSBubbleMediaTypeNewUserJoin)
    {
        self.userLabel.text = [NSString stringWithFormat:@"%@", self.data];
        CGFloat maxX = self.bounds.size.width;
        CGSize textSize = [self textSizeForText:self.userLabel.text withMaxWidth:maxX withMaxHeight:50 withFont:[UIFont systemFontOfSize:12]];
        CGFloat width = textSize.width + 20;
        CGFloat x = (maxX - width) / 2;
        CGFloat y = (self.bounds.size.height - 22) / 2;
        self.userLabel.frame = CGRectMake(x, y, width, 22);
    }
    else if (self.mediaType == JSBubbleMediaTypeTips)
    {
        self.tipsLabel.text = [NSString stringWithFormat:@"%@", self.data];
        CGFloat maxX = self.bounds.size.width;
        CGSize textSize = [self textSizeForText:self.tipsLabel.text withMaxWidth:maxX withMaxHeight:100 withFont:[UIFont systemFontOfSize:12]];
        CGFloat width = textSize.width + 20;
        CGFloat x = (maxX - width) / 2;
        CGFloat y = (self.bounds.size.height - 22) / 2;
        self.tipsLabel.frame = CGRectMake(x, y, width, textSize.height + 10);
    }
    else if (self.mediaType == JSBubbleMediaTypeRichText)
    {
        if (self.type == JSBubbleMessageTypeIncoming) {
            textX += (self.bubbleImageView.image.capInsets.left / 2.0f);
        }
        
        OtherMessage *otherMsg = (OtherMessage *)self.data;
        NSString *content = otherMsg.content;
        NSString *photoUrl = otherMsg.photo;
        CGFloat maxWidth = (photoUrl && ![photoUrl isEqualToString:@""]) ? 132 : 203;
        CGSize contentSize = [self textSizeForText:content withMaxWidth:maxWidth withMaxHeight:60 withFont:[UIFont systemFontOfSize:13]];
        CGFloat height = contentSize.height + 55;
        if (photoUrl) {
            height = kJSOtherViewHeight;
        }
        CGRect viewFrame = CGRectMake(textX, 38, kJSOtherViewWidth, height);
        
        self.otherView.frame = viewFrame;
        self.otherView.otherMessage = otherMsg;
        
        x = self.otherView.frame.origin.x;
    }
    
    if (_type == JSBubbleMessageTypeOutgoing) {
        if (self.mediaType == JSBubbleMediaTypeText || self.mediaType == JSBubbleMediaTypeImage) {
            CGFloat btX = x - kSendErrorBtnWidth - 5;
            CGFloat acX = x - kActivityViewWidth;
            
            CGFloat textHeight = self.bubbleImageView.frame.size.height;
            //如果是单行消息，那么重新发送按钮显示在消息中间，如果是多行消息，显示在最下面。
            CGFloat activityViewY = (textHeight == 35) ? (textHeight - kActivityViewHeight) / 2 : (textHeight - kActivityViewHeight);
            CGFloat sendBtnY = (textHeight == 35) ? (textHeight - kSendErrorBtnHeight) / 2 : (textHeight - kSendErrorBtnHeight);
            CGFloat btY = self.bubbleImageView.frame.origin.y + sendBtnY ;
            CGFloat acY = self.bubbleImageView.frame.origin.y + activityViewY ;
            
            self.activityView.frame = CGRectMake(acX, acY, kActivityViewWidth, kActivityViewHeight);
            self.sendAgainButton.frame = CGRectMake(btX, btY, kSendErrorBtnWidth, kSendErrorBtnHeight);
            
            if ([self.delegate respondsToSelector:@selector(changeMessageSendStatus:)]) {
                [self.delegate changeMessageSendStatus:self.indexPath];
            }
        }
    }
}

/**
 *  计算字符串的size
 *
 *  @param txt       字符串
 *  @param maxWidth  最大宽度
 *  @param maxHeight 最大高度
 *  @param font      字体
 *
 *  @return size
 */
- (CGSize)textSizeForText:(NSString *)txt withMaxWidth:(CGFloat)maxWidth withMaxHeight:(CGFloat)maxHeight withFont:(UIFont*)font
{
    CGSize stringSize;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_0) {
        CGRect stringRect = [txt boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{ NSFontAttributeName : font }
                                              context:nil];
        
        stringSize = CGRectIntegral(stringRect).size;
    }
    else {
        stringSize = [txt sizeWithFont:font
                     constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
    }
    
    return CGSizeMake(roundf(stringSize.width), roundf(stringSize.height));
}

#pragma mark - Bubble view

+ (CGSize)textSizeForText:(NSString *)txt
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.65f;
    CGFloat maxHeight = MAX([JSMessageTextView numberOfLinesForMessage:txt],
                            [txt js_numberOfLines]) * [JSMessageInputView textViewLineHeight];
    maxHeight += kJSAvatarImageSize;
    
    CGSize stringSize;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_0) {
        CGRect stringRect = [txt boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{ NSFontAttributeName : [[JSBubbleView appearance] font] }
                                              context:nil];
        
        stringSize = CGRectIntegral(stringRect).size;
    }
    else {
        stringSize = [txt sizeWithFont:[[JSBubbleView appearance] font]
                     constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
    }
    
    return CGSizeMake(roundf(stringSize.width), roundf(stringSize.height));
}

//************ Insert By ZhangDong 2014.4.29 Start ************
+ (CGSize)imageSizeForImage{
    return CGSizeMake(kJSImageViewWidth, kJSImageViewHeight);
}

+ (CGSize)otherSizeForOtherView{
    return CGSizeMake(kJSOtherViewWidth, kJSOtherViewHeight);
}

+ (CGSize)neededSizeForImage
{
    return [JSBubbleView imageSizeForImage];
}

+ (CGSize)neededSizeForOtherView
{
	return CGSizeMake(220, 150);
}
//************ Insert By ZhangDong 2014.4.29 End ************

+ (CGSize)neededSizeForText:(NSString *)text
{
    CGSize textSize = [JSBubbleView textSizeForText:text];
    
    CGFloat width = textSize.width + kBubblePaddingRight;
    if (width > 230) {
        width = 227;
    }
	return CGSizeMake(width,
                      textSize.height + kPaddingTop + kPaddingBottom);
}

+ (CGFloat)neededHeightForText:(NSString *)text
{
    CGSize size = [JSBubbleView neededSizeForText:text];
    return size.height + kMarginTop + kMarginBottom;
}

//********* Insert By ZhangDong 2014.4.29 Start **********
+ (CGFloat)neededHeightForImage{
    return [JSBubbleView neededSizeForImage].height + kMarginTop + kMarginBottom;
}

+ (CGFloat)neededHeightForOtherView{
    return [JSBubbleView neededSizeForOtherView].height;
}
//********* Insert By ZhangDong 2014.4.29 End **********

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.textView resignFirstResponder];
}
@end
