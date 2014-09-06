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

#import "JSMessagesViewController.h"
#import "JSMessageTextView.h"
#import "NSString+JSMessagesView.h"
#import "PhotoListController.h"
#import "JSBubbleView.h"

static NSInteger const kTextViewMaxLength = 200;

@interface JSMessagesViewController () <JSDismissiveTextViewDelegate>

@property (assign, nonatomic) CGFloat previousTextViewContentHeight;


- (void)setup;

- (void)sendPressed:(UIButton *)sender;

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tap;

- (BOOL)shouldAllowScroll;

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView;
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom;
- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom;

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification;
- (void)handleWillHideKeyboardNotification:(NSNotification *)notification;
- (void)keyboardWillShowHide:(NSNotification *)notification;

- (void)animationForMessageInputViewAtPoint:(CGPoint)point;

@end



@implementation JSMessagesViewController

#pragma mark - Initialization

- (void)setup
{
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        // FIXME: hack-ish fix for ipad modal form presentations
        ((UIScrollView *)self.view).scrollEnabled = NO;
    }
    
	_isUserScrolling = NO;
    
    JSMessageInputViewStyle inputViewStyle = [self.delegate inputViewStyle];
    //*********** Mod By ZhangDong 2014.4.29 Start *************
    CGFloat inputViewHeight = 44.0f;
    
    CGRect frame = self.view.frame;
    
    if ([self.delegate respondsToSelector:@selector(tableViewFrame)]) {
        frame = [self.delegate tableViewFrame];
    }
    //*********** Mod By ZhangDong 2014.4.29 End *************
    
	JSMessageTableView *tableView = [[JSMessageTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.dataSource = self;
	tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([self.delegate respondsToSelector:@selector(tableViewSuperView)]) {
        UIView *view = [self.delegate tableViewSuperView];
        [view addSubview:tableView];
    }else{
        [self.view addSubview:tableView];
    }
	//*********** Mod By ZhangDong 2014.4.29 End *************
    
	_tableView = tableView;
    
    [self setTableViewInsetsWithBottomValue:inputViewHeight];
    
    [self setBackgroundColor:[UIColor js_backgroundColorClassic]];
    
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.frame.size.height - inputViewHeight,
                                   self.view.frame.size.width,
                                   inputViewHeight);
    
    BOOL allowsPan = YES;
    if ([self.delegate respondsToSelector:@selector(allowsPanToDismissKeyboard)]) {
        allowsPan = [self.delegate allowsPanToDismissKeyboard];
    }
    
    UIPanGestureRecognizer *pan = allowsPan ? _tableView.panGestureRecognizer : nil;
    
    JSMessageInputView *inputView = [[JSMessageInputView alloc] initWithFrame:inputFrame
                                                                        style:inputViewStyle
                                                                     delegate:self
                                                         panGestureRecognizer:pan];
    
    if (!allowsPan) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [_tableView addGestureRecognizer:tap];
    }
    
    //*********** Mod By ZhangDong 2014.4.29 Start **********
    
    if (inputViewStyle == JSMessageInputViewStylePhoto) {
        if ([self.delegate respondsToSelector:@selector(mediaButtonForInputView)]) {
            UIButton *mediaButton = [self.delegate mediaButtonForInputView];
            [inputView setMediaButton:mediaButton];
        }else{
            [inputView.mediaButton addTarget:self
                                      action:@selector(mediaPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
        }
        inputView.textView.returnKeyType = UIReturnKeySend;
        inputView.textView.enablesReturnKeyAutomatically = NO;
        inputView.textView.delegate = self;
    }
    //*********** Del By ZhangDong 2014.4.29 End **********
    [self.view addSubview:inputView];
    _messageInputView = inputView;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:15.0f]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboardNotification:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboardNotification:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.messageInputView.textView addObserver:self
                                     forKeyPath:@"contentSize"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self.messageInputView resignFirstResponder];
//    [self setEditing:NO animated:YES];
    
    [self.messageInputView.textView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"*** %@: didReceiveMemoryWarning ***", [self class]);
}

- (void)dealloc
{
    _delegate = nil;
    _dataSource = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _messageInputView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - View rotation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
}

#pragma mark - Actions

- (void)sendPressed:(UIButton *)sender
{
    //  add a space to accept any auto-correct suggestions
    NSString *text = [self.messageInputView.textView.text js_stringByTrimingWhitespace];
    if (!text || [text isEqualToString:@""]) {
        return;
    }
    text = self.messageInputView.textView.text;
    self.messageInputView.textView.text = [text stringByAppendingString:@" "];
    
    [self.delegate didSendText:self.messageInputView.textView.text
                    fromSender:self.sender
                        onDate:[NSDate date].timeIntervalSince1970 * 1000];
}

//*********** Insert By ZhangDong 2014.4.29 Start *************
//modey by zhangyihui
- (void)mediaPressed:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self.delegate;
    //    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}
//*********** Insert By ZhangDong 2014.4.29 End *************

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tap
{
    [self.messageInputView.textView resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSBubbleMessageType type = [self.delegate messageTypeForRowAtIndexPath:indexPath];
    
    UIImageView *bubbleImageView = [self.delegate bubbleImageViewWithType:type
                                                        forRowAtIndexPath:indexPath];
    
    id<JSMessageData> message = [self.dataSource messageForRowAtIndexPath:indexPath];
    
    NSString *avatarUrl = [self.delegate avatarImageUrlForRowAtIndexPath:indexPath];
    
    BOOL displayTimestamp = YES;
    if ([self.delegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.delegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    
    NSString *CellIdentifier = nil;
    if ([self.delegate respondsToSelector:@selector(customCellIdentifierForRowAtIndexPath:)]) {
        CellIdentifier = [self.delegate customCellIdentifierForRowAtIndexPath:indexPath];
    }
    
    //********** Mod By ZhangDong 2014.4.29 Start *************
    JSBubbleMediaType mediaType = [self.delegate messageMediaTypeForRowAtIndexPath:indexPath];
    
    if (!CellIdentifier) {
        CellIdentifier = [NSString stringWithFormat:@"JSMessageCell_%d_%d_%d_%d_%d", (int)mediaType, (int)type, displayTimestamp, avatarUrl != nil, [message sender] != nil];
    }
    
    JSBubbleMessageCell *cell = (JSBubbleMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[JSBubbleMessageCell alloc] initWithBubbleType:type
                                                     mediaType:mediaType
                                               bubbleImageView:bubbleImageView
                                                       message:message
                                             displaysTimestamp:displayTimestamp
                                                     hasAvatar:avatarUrl != nil
                                               reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        cell.bubbleViewDelegate = self;
    }
    
    cell.indexPath = indexPath;
    
    if (mediaType == JSBubbleMediaTypeNewUserJoin || mediaType == JSBubbleMediaTypeTips) {
        [cell setUserName:[self.dataSource dataForRowAtIndexPath:indexPath]];
    }else{
        if (mediaType == JSBubbleMediaTypeImage || mediaType == JSBubbleMediaTypeRichText) {
            [cell setMedia:[self.dataSource dataForRowAtIndexPath:indexPath]];
        }
        [cell setMessage:message];
        [cell setAvatarImageUrl:avatarUrl];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        if ([self.delegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
            [self.delegate configureCell:cell atIndexPath:indexPath];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //********** Mod By ZhangDong 2014.4.29 Start *************
    JSBubbleMediaType mediaType = [self.delegate messageMediaTypeForRowAtIndexPath:indexPath];
    if (mediaType == JSBubbleMediaTypeNewUserJoin){
        return 50;
    }else if (mediaType == JSBubbleMediaTypeTips) {
        return 100;
    }
    
    id<JSMessageData> message = [self.dataSource messageForRowAtIndexPath:indexPath];
    
    NSString *avatarUrl = [self.delegate avatarImageUrlForRowAtIndexPath:indexPath];
    
    BOOL displayTimestamp = YES;
    if ([self.delegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.delegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    
    if (mediaType == JSBubbleMediaTypeText) {
        return [JSBubbleMessageCell neededHeightForBubbleMessageCellWithMessage:message
                                                                 displaysAvatar:avatarUrl != nil
                                                              displaysTimestamp:displayTimestamp];
    } else if (mediaType == JSBubbleMediaTypeImage){
        return [JSBubbleMessageCell neededHeightForBubbleImageCellWithMessage:message
                                                               displaysAvatar:avatarUrl != nil
                                                            displaysTimestamp:displayTimestamp];
    } else if (mediaType == JSBubbleMediaTypeRichText){
        return [JSBubbleMessageCell neededHeightForBubbleImageTextCellWithMessage:message
                                                                   displaysAvatar:avatarUrl != nil
                                                                displaysTimestamp:displayTimestamp];
    }
    return 0;
    //********** Mod By ZhangDong 2014.4.29 End *************
}

//*********** Mod By ZhangDong 2014.4.29 Start *************
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
//        [self.delegate didSelectRowAtIndexPath:indexPath];
//    }
//}
//*********** Mod By ZhangDong 2014.4.29 End *************

#pragma mark - Messages view controller
- (void)finishSend
{
    [self.messageInputView.textView setText:nil];
    [self.tableView reloadData];
}

- (void)setBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
    _tableView.backgroundColor = color;
    _tableView.separatorColor = color;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
	if (![self shouldAllowScroll])
        return;
	
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
			  atScrollPosition:(UITableViewScrollPosition)position
					  animated:(BOOL)animated
{
	if (![self shouldAllowScroll])
        return;
	
	[self.tableView scrollToRowAtIndexPath:indexPath
						  atScrollPosition:position
								  animated:animated];
}

- (BOOL)shouldAllowScroll
{
    if (self.isUserScrolling) {
        if ([self.delegate respondsToSelector:@selector(shouldPreventScrollToBottomWhileUserScrolling)]
            && [self.delegate shouldPreventScrollToBottomWhileUserScrolling]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	self.isUserScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isUserScrolling = NO;
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
	
    if (!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = textView.contentSize.height;
    
    [self scrollToBottomAnimated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

//*********** Mod By ZhangDong 2014.4.29 Start *************
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    JSMessageInputViewStyle inputViewStyle = [self.delegate inputViewStyle];
    if (inputViewStyle == JSMessageInputViewStylePhoto) {
        if([text isEqualToString:@"\n"]) {  //禁止换行
            [self sendPressed:nil];
            return NO;
        }
        //输入最大字数是200
        NSUInteger newLength = [textView.text length] + [text length] - range.length;
        return newLength > kTextViewMaxLength ? NO : YES;
    }
    return YES;
}
//*********** Mod By ZhangDong 2014.4.29 End *************

#pragma mark - Layout message input view

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView
{
    CGFloat maxHeight = [JSMessageInputView maxHeight];
    
    BOOL isShrinking = textView.contentSize.height < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textView.contentSize.height - self.previousTextViewContentHeight;
    
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self setTableViewInsetsWithBottomValue:self.tableView.contentInset.bottom + changeInHeight];
                             
                             [self scrollToBottomAnimated:NO];
                             
                             if (isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageInputView.frame;
                             self.messageInputView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             
                             if (!isShrinking) {
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(textView.contentSize.height, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, textView.contentSize.height - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.bottom = bottom;
    return insets;
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.messageInputView.textView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
{
    _keyboardIsVisible = YES;
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification
{
    _keyboardIsVisible = NO;
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSInteger animationCurveOption = (curve << 16);
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                         
                         CGRect inputViewFrame = self.messageInputView.frame;
                         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                         
                         // for ipad modal form presentations
                         CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
                         if (inputViewFrameY > messageViewFrameBottom)
                             inputViewFrameY = messageViewFrameBottom;
						 
                         self.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
																  inputViewFrameY,
																  inputViewFrame.size.width,
																  inputViewFrame.size.height);
                         
                         [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
                         
                         
                         
                         [self scrollToBottomAnimated:NO];

                     }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark - Dismissive text view delegate

- (void)keyboardDidScrollToPoint:(CGPoint)point
{
    [self animationForMessageInputViewAtPoint:point];
}

//********* Del By ZhangDong 2014.4.29 Start **********
//- (void)keyboardWillSnapBackToPoint:(CGPoint)point
//{
//    [self animationForMessageInputViewAtPoint:point];
//}
//********* Del By ZhangDong 2014.4.29 End **********

- (void)keyboardWillBeDismissed
{
    CGRect inputViewFrame = self.messageInputView.frame;
    inputViewFrame.origin.y = self.view.bounds.size.height - inputViewFrame.size.height;
    self.messageInputView.frame = inputViewFrame;
}

- (void)animationForMessageInputViewAtPoint:(CGPoint)point
{
    CGRect inputViewFrame = self.messageInputView.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:point fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    self.messageInputView.frame = inputViewFrame;
}

- (void)sendAgainWithIndexPath:(NSIndexPath *)indexPath{}
- (void)changeMessageSendStatus:(NSIndexPath *)indexPath{}
- (void)tapViewWithIndexPath:(NSIndexPath *)indexPath{}
- (void)touchesCell{};
- (void)touchUserAvatarHandler:(UIGestureRecognizer *)gesture{};
@end
