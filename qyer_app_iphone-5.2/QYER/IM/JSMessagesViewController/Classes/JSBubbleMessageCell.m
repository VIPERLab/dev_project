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

#import "JSBubbleMessageCell.h"

#import "JSAvatarImageFactory.h"
#import "UIColor+JSMessagesView.h"
#import "NSDateUtil.h"
#import "JSBubbleView.h"
#import "QYIMOtherView.h"
#import "UIImageView+WebCache.h"
#import "Toast+UIView.h"


static NSString *kBlockboardTipText = @"发布了一条信息";

static const CGFloat kJSTimeStampLabelPadding = 10.0f;
static const CGFloat kJSLabelPadding = 10.0f;
static const CGFloat kJSTimeStampLabelHeight = 22.0f;
static const CGFloat kJSSubtitleLabelHeight = 15.0f;

static const CGFloat kAvatarX = 10.0f;
static const CGFloat kAvatarY = 10.0f;

@interface JSBubbleMessageCell()

- (void)setup;
- (void)configureTimestampLabel;
- (void)configureAvatarImageViewForMessageType:(JSBubbleMessageType)type;
- (void)configureSubtitleLabelForMessageType:(JSBubbleMessageType)type;

- (void)configureWithType:(JSBubbleMessageType)type
                mediaType:(JSBubbleMediaType)bubbleMediaType
          bubbleImageView:(UIImageView *)bubbleImageView
                  message:(id<JSMessageData>)message
        displaysTimestamp:(BOOL)displaysTimestamp
                   avatar:(BOOL)hasAvatar;

- (void)setText:(NSString *)text;
- (void)setTimestamp:(NSDate *)date;
- (void)setSubtitle:(NSString *)subtitle;

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress;

- (void)handleMenuWillHideNotification:(NSNotification *)notification;
- (void)handleMenuWillShowNotification:(NSNotification *)notification;

@end



@implementation JSBubbleMessageCell

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.text = nil;
    self.textLabel.hidden = YES;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleLongPressGesture:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self addGestureRecognizer:recognizer];
}

- (void)configureTimestampLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kJSLabelPadding,
                                                               kJSTimeStampLabelPadding,
                                                               self.contentView.frame.size.width - (kJSLabelPadding * 2.0f),
                                                               kJSTimeStampLabelHeight)];
    label.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor js_messagesTimestampColorClassic];
    label.font = [UIFont systemFontOfSize:12];
    
    [self.contentView addSubview:label];
    [self.contentView bringSubviewToFront:label];
    _timestampLabel = label;
}

- (void)configureTimestampBackImageView
{
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = RGB(202, 217, 227);
    backView.layer.masksToBounds = YES;
    backView.layer.cornerRadius = 4;
    [self.contentView addSubview:backView];
    [self.contentView bringSubviewToFront:backView];
    _timestampBackView = backView;
}

- (void)configureAvatarImageViewForMessageType:(JSBubbleMessageType)type
{
    if (!_avatarImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.exclusiveTouch = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
        
        UIImageView *avatarMaskView = [[UIImageView alloc] init];
        avatarMaskView.userInteractionEnabled = YES;
        avatarMaskView.image = [UIImage imageNamed:@"IM_Avatar_Mask"];
        _avatarMaskImageView = avatarMaskView;
        [self.contentView addSubview:avatarMaskView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUserAvatarHandler:)];
        [avatarMaskView addGestureRecognizer:tapGesture];
        
        CGFloat avatarX = kAvatarX;
        if (type == JSBubbleMessageTypeOutgoing) {
            avatarX = (self.contentView.frame.size.width - kJSAvatarImageSize - 10.f);
        }
        
        CGFloat avatarY = kAvatarY + _timestampBackView.frame.origin.y + _timestampBackView.frame.size.height;
        imageView.frame = CGRectMake(avatarX, avatarY, kJSAvatarImageSize, kJSAvatarImageSize);
        avatarMaskView.frame = imageView.frame;
        
        _avatarImageView = imageView;
    }
}

- (void)configureSubtitleLabelForMessageType:(JSBubbleMessageType)type
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];//IMCOLOR [UIColor brownColor]
    label.textAlignment = (type == JSBubbleMessageTypeOutgoing) ? NSTextAlignmentRight : NSTextAlignmentLeft;
    label.textColor = [UIColor js_messagesSubtitleColorClassic];
    label.font = [UIFont systemFontOfSize:13.f];
    
    [self.contentView addSubview:label];
    _subtitleLabel = label;
}

- (void)configOtherViewTipLabelForMessageType:(JSBubbleMessageType)type
{
    CGSize size = [kBlockboardTipText sizeWithFont:[UIFont systemFontOfSize:12]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = (type == JSBubbleMessageTypeOutgoing) ? NSTextAlignmentRight : NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = RGB(158, 163, 171);
    label.text = kBlockboardTipText;
    
    [self.contentView addSubview:label];
    
    _otherViewTipLabel = label;
}

- (void)configureWithType:(JSBubbleMessageType)type
                mediaType:(JSBubbleMediaType)bubbleMediaType
          bubbleImageView:(UIImageView *)bubbleImageView
                  message:(id<JSMessageData>)message
        displaysTimestamp:(BOOL)displaysTimestamp
                   avatar:(BOOL)hasAvatar

{
    CGFloat bubbleY = 0.0f;
    CGFloat bubbleX = 0.0f;
    
    CGFloat offsetX = 0.0f;
    
    self.displaysTimestamp = displaysTimestamp;
    if (displaysTimestamp) {
        [self configureTimestampBackImageView];
        [self configureTimestampLabel];
        
        bubbleY = kJSTimeStampLabelPadding + 20.0f;
    }
    
    if ([message sender]) {
		[self configureSubtitleLabelForMessageType:type];
	}
    
    if (hasAvatar) {
        offsetX = 4.0f;
        bubbleX = kJSAvatarImageSize;
        if (type == JSBubbleMessageTypeOutgoing) {
            offsetX = kJSAvatarImageSize - 4.0f;
        }
        
        [self configureAvatarImageViewForMessageType:type];
    }
    
    if (bubbleMediaType == JSBubbleMediaTypeRichText) {
        [self configOtherViewTipLabelForMessageType:type];
    }
    
    CGRect frame = CGRectMake(bubbleX - offsetX,
                              bubbleY,
                              self.contentView.frame.size.width - bubbleX,
                              self.contentView.frame.size.height - _timestampLabel.frame.origin.y - _timestampLabel.frame.size.height - _subtitleLabel.frame.size.height);
    
    JSBubbleView *bubbleView = [[JSBubbleView alloc] initWithFrame:frame
                                                        bubbleType:type
                                                   bubbleImageView:bubbleImageView
                                                         mediaType:bubbleMediaType
                                                 displaysTimestamp:displaysTimestamp];
    [self.contentView addSubview:bubbleView];
    [self.contentView sendSubviewToBack:bubbleView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewHandler)];
    if (bubbleMediaType == JSBubbleMediaTypeImage) {
        [bubbleView.imageView addGestureRecognizer:tapGesture];
    }else if (bubbleMediaType == JSBubbleMediaTypeRichText){
        [bubbleView.otherView addGestureRecognizer:tapGesture];
    }
    
    _bubbleView = bubbleView;
    _mediaType = bubbleMediaType;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithBubbleType:(JSBubbleMessageType)type
                         mediaType:(JSBubbleMediaType)bubbleMediaType
                   bubbleImageView:(UIImageView *)bubbleImageView
                           message:(id<JSMessageData>)message
                 displaysTimestamp:(BOOL)displaysTimestamp
                         hasAvatar:(BOOL)hasAvatar
                   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureWithType:type
                      mediaType:bubbleMediaType
                bubbleImageView:bubbleImageView
                        message:message
              displaysTimestamp:displaysTimestamp
                         avatar:hasAvatar];
    }
    return self;
}

- (void)dealloc
{
    _bubbleView = nil;
    _timestampLabel = nil;
    _avatarImageView = nil;
    _subtitleLabel = nil;
    _timestampBackView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TableViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.bubbleView.textView.text = nil;
    self.timestampLabel.text = nil;
    self.subtitleLabel.text = nil;
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
    [self.contentView setBackgroundColor:color];
    
    _bubbleView.delegate = self.bubbleViewDelegate;
    _bubbleView.indexPath = self.indexPath;
    [self.bubbleView setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    self.bubbleView.textView.text = text;
}

//********** Mod By ZhangDong 2014.5.7 Start ************
- (void)setTimestamp:(NSDate *)date
{
    self.timestampLabel.text = [NSDateUtil formatDate:date];
    CGFloat width = [_timestampLabel.text sizeWithFont:_timestampLabel.font].width + 20;
    CGFloat x = (self.bounds.size.width - width) / 2;
    _timestampBackView.frame = CGRectMake(x, kJSTimeStampLabelPadding, width, 22);
}
//********** Mod By ZhangDong 2014.5.7 End ************

- (void)setSubtitle:(NSString *)subtitle
{
	self.subtitleLabel.text = subtitle;
}

- (void)setMessage:(id<JSMessageData>)message
{
    [self setText:[message text]];
    [self setTimestamp:[message date]];
    [self setSubtitle:[message sender]];
}

- (void)setAvatarImageUrl:(NSString *)avatarImageUrl
{
    if (![_avatarImageUrl isEqualToString:avatarImageUrl]) {
        [_avatarImageView setImageWithURL:[NSURL URLWithString:avatarImageUrl] placeholderImage:[UIImage imageNamed:@"IM_Avatar"]];
        _avatarMaskImageView.tag = self.indexPath.row + kUserAvatarTag;
    }
}

//- (void)setAvatarImageView:(UIImageView *)imageView
//{
//    [_avatarImageView removeFromSuperview];
//    _avatarImageView = nil;
//}

//********* Insert By ZhangDong 2014.4.29 Start ***********
- (void)setMedia:(id)data
{
	self.bubbleView.data = data;
}

- (void)setUserName:(NSString*)userName
{
    self.bubbleView.data = userName;
}
//********* Insert By ZhangDong 2014.4.29 End ***********

#pragma mark - Getters

- (JSBubbleMessageType)messageType
{
    return _bubbleView.type;
}

#pragma mark - Class methods

+ (CGFloat)neededHeightForBubbleWithMessage:(id<JSMessageData>)message
                             displaysAvatar:(BOOL)displaysAvatar
                          displaysTimestamp:(BOOL)displaysTimestamp
                               bubbleHeight:(CGFloat)bubbleHeight
{
    CGFloat timestampHeight = displaysTimestamp ? kJSTimeStampLabelPadding + kJSTimeStampLabelHeight : 0.0f;
    CGFloat avatarHeight = displaysAvatar ? kJSAvatarImageSize : 0.0f;
	CGFloat subtitleHeight = [message sender] ? kJSSubtitleLabelHeight : 0.0f;
    
    CGFloat subviewHeights = timestampHeight + subtitleHeight;
    
    return subviewHeights + MAX(avatarHeight, bubbleHeight);
}

+ (CGFloat)neededHeightForBubbleMessageCellWithMessage:(id<JSMessageData>)message
                                        displaysAvatar:(BOOL)displaysAvatar
                                     displaysTimestamp:(BOOL)displaysTimestamp
{
    CGFloat bubbleHeight = [JSBubbleView neededHeightForText:[message text]];
    return [JSBubbleMessageCell neededHeightForBubbleWithMessage:message displaysAvatar:displaysAvatar displaysTimestamp:displaysTimestamp bubbleHeight:bubbleHeight];
}

+ (CGFloat)neededHeightForBubbleImageCellWithMessage:(id<JSMessageData>)message
                                      displaysAvatar:(BOOL)displaysAvatar
                                   displaysTimestamp:(BOOL)displaysTimestamp
{
    CGFloat bubbleHeight = [JSBubbleView neededHeightForImage];
    return [JSBubbleMessageCell neededHeightForBubbleWithMessage:message displaysAvatar:displaysAvatar displaysTimestamp:displaysTimestamp bubbleHeight:bubbleHeight];
}

+ (CGFloat)neededHeightForBubbleImageTextCellWithMessage:(id<JSMessageData>)message
                                          displaysAvatar:(BOOL)displaysAvatar
                                       displaysTimestamp:(BOOL)displaysTimestamp
{
    CGFloat bubbleHeight = [JSBubbleView neededHeightForOtherView];
    return [JSBubbleMessageCell neededHeightForBubbleWithMessage:message displaysAvatar:displaysAvatar displaysTimestamp:displaysTimestamp bubbleHeight:bubbleHeight];
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_timestampBackView) {
        CGRect rect = _avatarImageView.frame;
        rect.origin.y = kAvatarY + _timestampBackView.frame.origin.y + _timestampBackView.frame.size.height;
        _avatarImageView.frame = rect;
        _avatarMaskImageView.frame = rect;
    }
    
    if (self.subtitleLabel) {
        CGSize size = [self.subtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:13.f]];
        CGFloat width = size.width;
        CGFloat height = kJSSubtitleLabelHeight;
        
        CGFloat y = _avatarImageView.frame.origin.y + 5;
        CGFloat x = kJSLabelPadding + self.avatarImageView.frame.size.width + 10;
        CGFloat tipLabelX = x + width + 10;
        
        if (self.messageType == JSBubbleMessageTypeOutgoing) {
            x = self.avatarImageView.frame.origin.x - width - 10;
            tipLabelX = x - 100 - 10;
        }
        
        self.subtitleLabel.frame = CGRectMake(x, y, width, height);
        
        if (self.mediaType == JSBubbleMediaTypeRichText) {
            CGSize size = _otherViewTipLabel.frame.size;
            _otherViewTipLabel.frame = CGRectMake(tipLabelX, y + 1, size.width, size.height);
        }
    }
    
    CGRect frame = self.bubbleView.frame;
    frame.size.height = self.contentView.bounds.size.height - 20;
    self.bubbleView.frame = frame;
}

#pragma mark - Copying

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

//********* Mod By ZhangDong 2014.4.29 Start **********
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(self.bubbleView.data){
        return (action == @selector(saveImage:));
    }else{
        return (action == @selector(copy:));
    }
    return [super canPerformAction:action withSender:sender];
}
//********* Mod By ZhangDong 2014.4.29 End **********

- (void)copy:(id)sender
{
    NSString *text = self.bubbleView.textView.text;
    if (text && ![text isEqualToString:@""]) {
        [[UIPasteboard generalPasteboard] setString:self.bubbleView.textView.text];
        [self resignFirstResponder];
    }
}

//********* Mod By ZhangDong 2014.4.29 Start **********
#pragma mark - Save Image

-(void)saveImage:(id)sender{
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:self.bubbleView.data], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL){
        [self makeToast:@"保存图片成功" duration:1.2f position:@"center" isShadow:NO];
    }else{
        [self makeToast:@"保存图片失败" duration:1.2f position:@"center" isShadow:NO];
    }
}
//********* Mod By ZhangDong 2014.4.29 End **********

#pragma mark - Gestures

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    
    if (self.mediaType != JSBubbleMediaTypeText) {
        return;
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    //********** Insert By ZhangDong 2014.4.29 Start ************
    UIMenuItem *saveItem = nil;
    
    if(self.bubbleView.data){
        saveItem = [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(saveImage:)];
    }
    
    [menu setMenuItems:[NSArray arrayWithObjects:saveItem, nil]];
    //********** Insert By ZhangDong 2014.4.29 End ************
    
    CGRect targetRect = [self convertRect:[self.bubbleView bubbleFrame]
                                 fromView:self.bubbleView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    self.bubbleView.bubbleImageView.highlighted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}

/**
 *  触摸图片或者自定义视图触发的方法
 */
- (void)tapViewHandler
{
    if ([self.delegate respondsToSelector:@selector(tapViewWithIndexPath:)]) {
        [self.delegate tapViewWithIndexPath:self.indexPath];
    }
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    self.bubbleView.bubbleImageView.highlighted = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

/**
 *  触摸单元格触发的方法
 *
 *  @param touches
 *  @param event
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(touchesCell)]) {
        [self.delegate touchesCell];
    }
}

/**
 *  触摸头像，调用代理的触摸头像方法
 *
 *  @param gesture
 */
- (void)touchUserAvatarHandler:(UIGestureRecognizer*)gesture{
    if ([self.delegate respondsToSelector:@selector(touchUserAvatarHandler:)]) {
        [self.delegate touchUserAvatarHandler:gesture];
    }
};


@end