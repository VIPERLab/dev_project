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

#import <UIKit/UIKit.h>
#import "JSBubbleImageViewFactory.h"


#define kJSOtherViewHeight 109.0f
#define kJSOtherViewWidth 220.0f
#define kJSImageViewHeight 139.0f
#define kJSImageViewWidth 88.0f


@class QYIMOtherView;
@class JSBubbleView;


@protocol JSBubbleViewDelegate <NSObject>
- (void)changeMessageSendStatus:(NSIndexPath*)indexPath;
- (void)sendAgainWithIndexPath:(NSIndexPath*)indexPath;
@end

/**
 *  An instance of JSBubbleView is a means for displaying text in a speech bubble image to be placed in a JSBubbleMessageCell.
 *  @see JSBubbleMessageCell.
 */
@interface JSBubbleView : UIView

/**
 *  Returns the message type for this bubble view.
 *  @see JSBubbleMessageType for descriptions of the constants used to specify bubble message type.
 */
@property (assign, nonatomic, readonly) JSBubbleMessageType type;

/**
 *  Returns the image view containing the bubble image for this bubble view.
 */
@property (weak, nonatomic, readonly) UIImageView *bubbleImageView;

/**
 *  Returns the text view containing the message text for this bubble view.
 *
 *  @warning You may customize the propeties of textView, however you *must not* change its `font` property directly. Please use the `JSBubbleView` font property instead.
 */
@property (weak, nonatomic, readonly) UITextView *textView;

/**
 *  The font for the text contained in the bubble view. The default value is `[UIFont systemFontOfSize:16.0f]`.
 *
 *  @warning You must set this propety via `UIAppearance` only. *DO NOT set this property directly*.
 *  @bug Setting this property directly, rather than via `UIAppearance` will cause the message bubbles and text to be laid out incorrectly.
 */
@property (strong, nonatomic) UIFont *font UI_APPEARANCE_SELECTOR;

//************ Insert By ZhangDong 2014.4.29 Start ************

@property (weak, nonatomic, readonly) UIImageView *imageView;
/**
 *  自定义视图
 */
@property (nonatomic, weak, readonly) QYIMOtherView *otherView;
/**
 *  用户加入Label
 */
@property (nonatomic, weak, readonly) UILabel *userLabel;
/**
 *  提示Label
 */
@property (nonatomic, weak, readonly) UILabel *tipsLabel;
/**
 *  消息类型
 */
@property (assign, nonatomic) JSBubbleMediaType mediaType;
/**
 *  发送状态的菊花视图
 */
@property (weak, nonatomic, readonly) UIActivityIndicatorView *activityView;
/**
 *  发送失败按钮
 */
@property (weak, nonatomic, readonly) UIButton *sendAgainButton;
/**
 *  是否显示时间
 */
@property (assign, nonatomic) BOOL displaysTimestamp;
/**
 *  当前行的NSIndexPath
 */
@property (nonatomic, retain) NSIndexPath *indexPath;

@property (assign, nonatomic) id<JSBubbleViewDelegate> delegate;
/**
 *  图片
 */
@property (strong, nonatomic) id data;
#pragma mark - Initialization

/**
 *  Initializes and returns a bubble view object having the given frame, bubble type, and bubble image view.
 *
 *  @param frame           A rectangle specifying the initial location and size of the bubble view in its superview's coordinates.
 *  @param bubleType       A constant that specifies the type of the bubble view. @see JSBubbleMessageType.
 *  @param bubbleImageView An image view initialized with an image and highlighted image for this bubble view. @see JSBubbleImageViewFactory.
 *
 *  @return An initialized `JSBubbleView` object or `nil` if the object could not be successfully initialized.
 */
- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(JSBubbleMessageType)bubleType
              bubbleImageView:(UIImageView *)bubbleImageView
                    mediaType:(JSBubbleMediaType)bubbleMediaType
            displaysTimestamp:(BOOL)displaysTimestamp;
//************ Insert By ZhangDong 2014.4.29 End ************

#pragma mark - Getters

/**
 *  The bubble view's frame rectangle is computed and set based on the size of the text that it needs to display.
 *
 *  @return The frame of the bubble view.
 */
- (CGRect)bubbleFrame;

#pragma mark - Class methods

/**
 *  Computes and returns the minimum necessary height of a `JSBubbleView` needed to display the given text.
 *
 *  @param text The text to display in the bubble view.
 *
 *  @return The height required for the frame of the bubble view in order to display the given text.
 */
+ (CGFloat)neededHeightForText:(NSString *)text;

//********* Insert By ZhangDong 2014.4.29 Start **********
+ (CGFloat)neededHeightForImage;
+ (CGFloat)neededHeightForOtherView;
//********* Insert By ZhangDong 2014.4.29 End **********

@end