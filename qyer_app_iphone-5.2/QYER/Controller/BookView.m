//
//  BookView.m
//  LastMinute
//
//  Created by lide on 13-5-28.
//
//

#import "BookView.h"
#import "AppDelegate.h"

#define Height_Max       385.0f
#define Height_Code_Max  385.0+40.0

@interface BookView()

@property (nonatomic, retain) UIScrollView  *backgroundScrollView;

@end

@implementation BookView

@synthesize orderArray = _orderArray;
@synthesize orderTitleArray = _orderTitleArray;

@synthesize delegate = _delegate;

#pragma mark - private

- (void)hide
{
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundImageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _backgroundImageView.frame.size.height);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

- (void)clickCancelButton:(id)sender
{
    [self hide];
}

- (void)clickButton:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(bookViewButtonDidClicked:)])
    {
        [self hide];
        [_delegate bookViewButtonDidClicked:sender];
    }
}

#pragma mark - super

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (id)initWithOrderArray:(NSArray *)orderArray
              titleArray:(NSArray *)titleArray
               orderType:(NSUInteger)orderType
{
    self = [super init];
    {
        self.orderArray = orderArray;
        self.orderTitleArray = titleArray;
        
        self.frame = [[UIScreen mainScreen] bounds];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        UIView *tapView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:tapView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [tapView addGestureRecognizer:tap];
        [tap release];
        
        //BY Jessica
        CGFloat originHeight = 13 + 43 * [orderArray count] + 10 * ([orderArray count] - 1);//134 + 43 * [orderArray count] + 10 * ([orderArray count] - 1);
        CGFloat realHeight = MIN(originHeight+43+69+5, Height_Max);
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, realHeight)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.image = [[UIImage imageNamed:@"bg_actionsheet@2x.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:40];
        _backgroundImageView.userInteractionEnabled = YES;
        [self addSubview:_backgroundImageView];
        
        //BY Jessica
        CGRect frame = _backgroundImageView.bounds;
        frame.origin.y = 43;
        frame.size.height = frame.size.height-frame.origin.y-69;
        
        _backgroundScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _backgroundScrollView.backgroundColor = [UIColor clearColor];
        _backgroundScrollView.contentSize = CGSizeMake(_backgroundScrollView.frame.size.width, originHeight);
        [_backgroundImageView addSubview:_backgroundScrollView];
        
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(21, 13, 20, 20)];
        _iconImageView.backgroundColor = [UIColor clearColor];
        
        [_backgroundImageView addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 13, 80, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0];
        _titleLabel.font = [UIFont systemFontOfSize:17.0];
        _titleLabel.shadowColor = [UIColor whiteColor];
        _titleLabel.shadowOffset = CGSizeMake(0, 1);
        
        [_backgroundImageView addSubview:_titleLabel];
        
        UIImageView *line = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 320, 1)] autorelease];
        line.backgroundColor = [UIColor clearColor];
        line.image = [UIImage imageNamed:@"actionsheet_line@2x.png"];
        [_backgroundImageView addSubview:line];
        
        if(orderType == 0)
        {
            _iconImageView.image = [UIImage imageNamed:@"icon_online@2x.png"];
            _titleLabel.text = @"在线预订";
        }
        else
        {
            _iconImageView.image = [UIImage imageNamed:@"icon_phone@2x.png"];
            _titleLabel.text = @"拨打电话";
        }
        
        _cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _cancelButton.frame = CGRectMake(21, _backgroundImageView.frame.size.height - 62, 278, 43);
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"actionsheet_cancel@2x.png"] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"actionsheet_cancel_highlight@2x.png"] forState:UIControlStateHighlighted];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        _cancelButton.titleLabel.shadowColor = [UIColor colorWithRed:106.0 / 255.0 green:107.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
//        _cancelButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
        [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundImageView addSubview:_cancelButton];
        
        for(NSUInteger i = 0; i < [orderArray count]; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(21, 13 + i * 53, 278, 43);//CGRectMake(21, 56 + i * 53, 278, 43)
            button.backgroundColor = [UIColor clearColor];
            button.tag = i;
            [button setBackgroundImage:[UIImage imageNamed:@"btn_actionsheet.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"btn_actionsheet_highlight@2x.png"] forState:UIControlStateHighlighted];
            
            [button setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            UIFont *font = [UIFont systemFontOfSize:18.0];
            button.titleLabel.font = font;
            button.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            button.titleLabel.shadowOffset = CGSizeMake(0, 1);
            [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [_backgroundScrollView addSubview:button];
        }
        
        _backgroundImageView.frame = CGRectMake(_backgroundImageView.frame.origin.x, self.frame.size.height - _backgroundImageView.frame.size.height, _backgroundImageView.frame.size.width, _backgroundImageView.frame.size.height);
    }
    
    return self;
}

- (id)initWithOrderArray:(NSArray *)orderArray
              titleArray:(NSArray *)titleArray
             dicountCode:(NSString *)discountCode
               orderType:(NSUInteger)orderType
{
    self = [super init];
    {
        self.orderArray = orderArray;
        self.orderTitleArray = titleArray;
        
        self.frame = [[UIScreen mainScreen] bounds];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        UIView *tapView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:tapView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [tapView addGestureRecognizer:tap];
        [tap release];
        
        //BY Jessica
        CGFloat originHeight = 13 + 43 * [orderArray count] + 10 * ([orderArray count] - 1);//134 + 43 * [orderArray count] + 10 * ([orderArray count] - 1);
        CGFloat realHeight = MIN(originHeight+96-13+69+5, Height_Code_Max);
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, realHeight)];//134 + 43 * [orderArray count] + 10 * ([orderArray count] - 1) + 40
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.image = [[UIImage imageNamed:@"bg_actionsheet@2x.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:40];
        _backgroundImageView.userInteractionEnabled = YES;
        [self addSubview:_backgroundImageView];
        
        //BY Jessica
        CGRect frame = _backgroundImageView.bounds;
        frame.origin.y = 96-13-3;
        frame.size.height = frame.size.height-frame.origin.y-69-3;
        
        _backgroundScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _backgroundScrollView.backgroundColor = [UIColor clearColor];
        _backgroundScrollView.contentSize = CGSizeMake(_backgroundScrollView.frame.size.width, originHeight);
        [_backgroundImageView addSubview:_backgroundScrollView];

        
        
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(21, 13, 20, 20)];
        _iconImageView.backgroundColor = [UIColor clearColor];
        
        [_backgroundImageView addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 13, 80, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0];
        _titleLabel.font = [UIFont systemFontOfSize:17.0];
        _titleLabel.shadowColor = [UIColor whiteColor];
        _titleLabel.shadowOffset = CGSizeMake(0, 1);
        
        [_backgroundImageView addSubview:_titleLabel];
        
        UIImageView *line = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 320, 1)] autorelease];
        line.backgroundColor = [UIColor clearColor];
        line.image = [UIImage imageNamed:@"actionsheet_line.png"];
        [_backgroundImageView addSubview:line];
        
        UILabel *discountLabel = [[[UILabel alloc] initWithFrame:CGRectMake(21, 53, 80, 15)] autorelease];
        discountLabel.backgroundColor = [UIColor clearColor];
        discountLabel.textColor = [UIColor colorWithRed:109.0 / 255.0 green:109.0 / 255.0 blue:109.0 / 255.0 alpha:1.0];
        discountLabel.font = [UIFont systemFontOfSize:13.0f];
        discountLabel.text = @"折扣代码：";
        discountLabel.shadowColor = [UIColor whiteColor];
        discountLabel.shadowOffset = CGSizeMake(0, 1);
        [_backgroundImageView addSubview:discountLabel];
        
        UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:13.0];
        if(font == nil)
        {
            font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13.0];
        }
        
        CGSize fontSize = [@"888" sizeWithFont:font forWidth:200 lineBreakMode:NSLineBreakByWordWrapping];
        
        
        UILabel *codeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(91, 67 - fontSize.height, 200, fontSize.height)] autorelease];
        if(ios7)
        {
            codeLabel.frame = CGRectMake(91, 67 - fontSize.height, 200, fontSize.height);
        }
        else
        {
            codeLabel.frame = CGRectMake(91, 74 - fontSize.height, 200, fontSize.height);
        }
        codeLabel.backgroundColor = [UIColor clearColor];
        codeLabel.textColor = [UIColor colorWithRed:250.0/255.0f green:79.0/255.0f blue:62.0/255.0f alpha:1.0f];
        
        codeLabel.font = font;
        codeLabel.text = discountCode;
        [_backgroundImageView addSubview:codeLabel];
        
        UIImageView *secondLine = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 79, 320, 1)] autorelease];
        secondLine.backgroundColor = [UIColor clearColor];
        secondLine.image = [UIImage imageNamed:@"actionsheet_line@2x.png"];
        [_backgroundImageView addSubview:secondLine];
        
        if(orderType == 0)
        {
            _iconImageView.image = [UIImage imageNamed:@"icon_online@2x.png"];
            _titleLabel.text = @"在线预订";
        }
        else
        {
            _iconImageView.image = [UIImage imageNamed:@"icon_phone@2x.png"];
            _titleLabel.text = @"拨打电话";
        }
        
        
        
        _cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _cancelButton.frame = CGRectMake(21, _backgroundImageView.frame.size.height - 62, 278, 43);
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"actionsheet_cancel@2x.png"] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"actionsheet_cancel_highlight@2x.png"] forState:UIControlStateHighlighted];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        _cancelButton.titleLabel.shadowColor = [UIColor colorWithRed:106.0 / 255.0 green:107.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
        //        _cancelButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
        [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundImageView addSubview:_cancelButton];
        
        for(NSUInteger i = 0; i < [orderArray count]; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(21, 13 + i * 53, 278, 43);
            button.backgroundColor = [UIColor clearColor];
            button.tag = i;
            [button setBackgroundImage:[UIImage imageNamed:@"btn_actionsheet.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"btn_actionsheet_highlight@2x.png"] forState:UIControlStateHighlighted];
            
            [button setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            UIFont *font = [UIFont systemFontOfSize:18.0];
            button.titleLabel.font = font;
            button.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            button.titleLabel.shadowOffset = CGSizeMake(0, 1);
            [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [_backgroundScrollView addSubview:button];
        }
        
        _backgroundImageView.frame = CGRectMake(_backgroundImageView.frame.origin.x, self.frame.size.height - _backgroundImageView.frame.size.height, _backgroundImageView.frame.size.width, _backgroundImageView.frame.size.height);
    }
    
    return self;
}

- (void)dealloc
{
    QY_VIEW_RELEASE(_backgroundImageView);
    QY_VIEW_RELEASE(_backgroundScrollView);
    QY_VIEW_RELEASE(_iconImageView);
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_cancelButton);
    
    QY_SAFE_RELEASE(_orderArray);
    QY_SAFE_RELEASE(_orderTitleArray);
    
    _delegate = nil;
    
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - public

- (void)show
{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [self addSubview:_backgroundImageView];
    
    self.alpha = 0.0;
    _backgroundImageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _backgroundImageView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundImageView.transform = CGAffineTransformIdentity;
        self.alpha = 1.0;
    }];
}

#pragma mark - UIGestureRecognizer

- (void)tap:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self hide];
    }
}

@end
