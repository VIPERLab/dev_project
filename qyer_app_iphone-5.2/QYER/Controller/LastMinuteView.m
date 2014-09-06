//
//  LastMinuteView.m
//  LastMinute
//
//  Created by lide on 13-6-24.
//
//

#import "LastMinuteView.h"
#import "UIImageView+WebCache.h"

typedef enum {
    QyerFlagTypeNone = 0,//无标签
    QyerFlagTypeOnly = 1,//穷游儿独享
    QyerFlagTypeFirstPub = 2,//穷游首发
    QyerFlagTypeLabAuth = 3,//穷游实验室认证
} QyerFlagType;

@interface LastMinuteView()

@property (retain, nonatomic) UILabel *lastminuteLabel;

@end

@implementation LastMinuteView

@synthesize lastMinute = _lastMinute;

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//        tap.delegate = self;
//        [self addGestureRecognizer:tap];
//        [tap release];
//        
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//        longPress.delegate = self;
//        longPress.minimumPressDuration = 0.05;
//        [self addGestureRecognizer:longPress];
//        [longPress release];
        
        
//        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-2, -2, frame.size.width + 4, frame.size.height + 4)];
//        _backgroundImageView.backgroundColor = [UIColor orangeColor];
//        _backgroundImageView.image = [[UIImage imageNamed:@"bg_lastminute_view.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:20];
//        [self addSubview:_backgroundImageView];
        
        
        _lastMinuteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 145, 97)];
        _lastMinuteImageView.backgroundColor = [UIColor clearColor];
        _lastMinuteImageView.layer.cornerRadius = 2;
        _lastMinuteImageView.layer.masksToBounds = YES;
        [self addSubview:_lastMinuteImageView];
        
        _redCard = [[UIImageView alloc] initWithFrame:CGRectMake(63, 65, 85, 25)];
        _redCard.backgroundColor = [UIColor clearColor];
        _redCard.image = [UIImage imageNamed:@"redCard.png"];
        [self addSubview:_redCard];
        
        _prefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 171, 30, 13)];
        _prefixLabel.backgroundColor = [UIColor clearColor];
        _prefixLabel.textColor = [UIColor whiteColor];
        _prefixLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        [self addSubview:_prefixLabel];
        
        UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
        
        CGSize fontSize = [@"888" sizeWithFont:font forWidth:200 lineBreakMode:NSLineBreakByWordWrapping];
        
        if(ios7)
        {
            _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 184 - fontSize.height, 100, fontSize.height)];
        }
        else
        {
            _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 192 - fontSize.height, 100, fontSize.height)];
        }
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.font = font;
        _priceLabel.text = @"4855";
        [self addSubview:_priceLabel];
        
        CGSize size = [@"4855" sizeWithFont:font forWidth:100 lineBreakMode:NSLineBreakByWordWrapping];
        _suffixLabel = [[UILabel alloc] initWithFrame:CGRectMake(_priceLabel.frame.origin.x + size.width, 171, 30, 13)];
        _suffixLabel.backgroundColor = [UIColor clearColor];
        _suffixLabel.textColor = [UIColor whiteColor];
        _suffixLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        _suffixLabel.text = @"元起";
        [self addSubview:_suffixLabel];

        
        
        _bottomImgView = [[UIImageView alloc]initWithFrame:CGRectMake(-4, 94, 153, 75)];
        [_bottomImgView setBackgroundColor:[UIColor clearColor]];
        [_bottomImgView setImage:[UIImage imageNamed:@"lastMinute_Bottom"]];
        [self addSubview:_bottomImgView];
        
        
        
        
        _lastMinuteTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, 105, 129, 36)];
        _lastMinuteTitle.backgroundColor = [UIColor clearColor];
        _lastMinuteTitle.textColor = [UIColor colorWithRed:62.0 / 255.0 green:74.0 / 255.0 blue:89.0 / 255.0 alpha:1.0];
        _lastMinuteTitle.font = [UIFont boldSystemFontOfSize:13.0f];
        _lastMinuteTitle.numberOfLines = 0;
        [self addSubview:_lastMinuteTitle];
        
        _iconTime = [[UIImageView alloc] initWithFrame:CGRectMake(8, 147, 11, 11)];
        _iconTime.backgroundColor = [UIColor clearColor];
        _iconTime.image = [UIImage imageNamed:@"icon_time.png"];
        [self addSubview:_iconTime];
        
        _finishDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 146, 120, 13)];
        _finishDateLabel.backgroundColor = [UIColor clearColor];
        _finishDateLabel.textColor = [UIColor colorWithRed:150.0 / 255.0 green:150.0 / 255.0 blue:150.0 / 255.0 alpha:1.0];
        _finishDateLabel.font = [UIFont systemFontOfSize:11.0f];
        [self addSubview:_finishDateLabel];
        
        
        //2.8折
        _lastminuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60-7, 146, 60, 13)];
        _lastminuteLabel.text = @"2.8折";
        _lastminuteLabel.textAlignment = NSTextAlignmentRight;
        _lastminuteLabel.font = [UIFont systemFontOfSize:11];
        _lastminuteLabel.textColor = [UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0];
        _lastminuteLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_lastminuteLabel];
        
        
        //是否穷游儿独享1-是0-否
        _qyerOnlyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 15)];//CGRectMake(0, 0, 43, 43)
        _qyerOnlyImageView.backgroundColor = [UIColor clearColor];
        _qyerOnlyImageView.image = [UIImage imageNamed:@"perperty_self_use.png"];//@"icon_only.png"
        [self addSubview:_qyerOnlyImageView];
        _qyerOnlyImageView.hidden = YES;
        
        //是否穷游首发1-是0-否
        _qyerFirstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 15)];//CGRectMake(0, 0, 43, 43)
        _qyerFirstImageView.backgroundColor = [UIColor clearColor];
        _qyerFirstImageView.image = [UIImage imageNamed:@"perperty_first_pub.png"];//@"icon_first.png"
        [self addSubview:_qyerFirstImageView];
        _qyerFirstImageView.hidden = YES;
        
        //是否穷游实验室认证1-是0-否
        _qyerLabAuthImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 15)];//CGRectMake(0, 0, 43, 43)
        _qyerLabAuthImageView.backgroundColor = [UIColor clearColor];
        _qyerLabAuthImageView.image = [UIImage imageNamed:@"perperty_lab_auth.png"];//@"icon_first.png"
        [self addSubview:_qyerLabAuthImageView];
        _qyerLabAuthImageView.hidden = YES;
        
        ////是否今日首发1-是0-否
        _qyerTodayNewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 15)];//CGRectMake(0, 0, 43, 43)
        _qyerTodayNewImageView.backgroundColor = [UIColor clearColor];
        _qyerTodayNewImageView.image = [UIImage imageNamed:@"perperty_today_new.png"];//@"icon_first.png"
        [self addSubview:_qyerTodayNewImageView];
        _qyerTodayNewImageView.hidden = YES;
        
//        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        _maskView.backgroundColor = [UIColor clearColor];
        
        
//        UIView * bigAlphaView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 145, 167)]autorelease];
//        [bigAlphaView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
//        bigAlphaView.layer.cornerRadius = 2;
//        bigAlphaView.layer.masksToBounds = YES;
//        [_maskView addSubview:bigAlphaView];
//        UIView * smasllAlphaView = [[[UIView alloc]initWithFrame:CGRectMake(145, 65, 3, 25)]autorelease];
//        [smasllAlphaView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
//        [_maskView addSubview:smasllAlphaView];
        
        //点击遮罩
        UIButton *maskButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 148, 167)];
        [maskButton setExclusiveTouch:YES];
        [maskButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_mask.png"] forState:UIControlStateHighlighted];
        [maskButton addTarget:self action:@selector(maskButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:maskButton];
        [maskButton release];

        
    }
    return self;
}

- (void)dealloc
{
    QY_VIEW_RELEASE(_bottomImgView);
//    QY_VIEW_RELEASE(_maskView);
    QY_VIEW_RELEASE(_lastMinuteImageView);
    QY_VIEW_RELEASE(_redCard);
    QY_VIEW_RELEASE(_lastMinuteTitle);
    QY_VIEW_RELEASE(_qyerOnlyImageView);
    QY_VIEW_RELEASE(_qyerFirstImageView);
    QY_VIEW_RELEASE(_qyerLabAuthImageView);
    QY_VIEW_RELEASE(_qyerTodayNewImageView);
    QY_VIEW_RELEASE(_iconTime);
    QY_VIEW_RELEASE(_finishDateLabel);
    QY_VIEW_RELEASE(_prefixLabel);
    QY_VIEW_RELEASE(_priceLabel);
    QY_VIEW_RELEASE(_suffixLabel);
    
    QY_SAFE_RELEASE(_lastMinute);
    QY_VIEW_RELEASE(_lastminuteLabel);
    
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

- (void)setLastMinute:(LastMinuteDeal *)aLastMinute
{
    if(_lastMinute != nil)
    {
        QY_SAFE_RELEASE(_lastMinute);
    }
    
    _lastMinute = [aLastMinute retain];
    
    _lastMinuteImageView.image = nil;
    _lastMinuteTitle.text = @"";
    
    NSDictionary * dictttt = (NSDictionary *)aLastMinute;
    
    [_lastMinuteImageView setImageWithURL:[NSURL URLWithString:[dictttt objectForKey:@"pic"]]placeholderImage:[UIImage imageNamed:@"lastMinuteNormalPic.png"]];
    
    _lastMinuteTitle.text = [dictttt objectForKey:@"title"];
    _lastminuteLabel.text = [dictttt objectForKey:@"lastminute_des"];//lastMinute.lastMinuteDes;
    
    CGSize size = [[dictttt objectForKey:@"title"] sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:CGSizeMake(105, 200) lineBreakMode:NSLineBreakByWordWrapping];
    
    
    if(size.height < 20)
    {
        _lastMinuteTitle.frame = CGRectMake(0, 101, 129, size.height);
    }
    else
    {
        _lastMinuteTitle.frame = CGRectMake(8, 101, 129, 40);
    }
    
    _finishDateLabel.text = [dictttt objectForKey:@"end_date"];
    
    
    _prefixLabel.text = nil;
    _priceLabel.text = nil;
    _suffixLabel.text = nil;
    
    
    NSString *string = [dictttt objectForKey:@"price"];
    
    if (![string isEqualToString:@""] && string.length >0) {
        
        [_redCard setHidden:NO];
        
        NSArray *array = [string componentsSeparatedByString:@"<em>"];
        
        if([array count] > 1)
        {
            //价格前的宽度
            float beforeSizeWidth = 0;
            
            if ([[array objectAtIndex:0]isKindOfClass:[NSString class]] && ![[array objectAtIndex:0]isEqualToString:@""]) {
                beforeSizeWidth = [(NSString *)[array objectAtIndex:0] sizeWithFont:[UIFont boldSystemFontOfSize:11.0f] constrainedToSize:CGSizeMake(100, 15) lineBreakMode:NSLineBreakByWordWrapping].width + 3;
            }
            
            //价格的宽度
            NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];
            UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
            float priceSizeWidth = [(NSString *)[anotherArray objectAtIndex:0] sizeWithFont:font constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping].width;
            
            //后面的宽度
            float afterSizeWidth = 0;
            if([anotherArray count] > 1)
            {
                afterSizeWidth = [(NSString *)[anotherArray objectAtIndex:1] sizeWithFont:[UIFont boldSystemFontOfSize:11.0f] constrainedToSize:CGSizeMake(100, 15) lineBreakMode:NSLineBreakByWordWrapping].width +3;
            }
            //全部价格的宽度
            float  totalPriceWidth = beforeSizeWidth + priceSizeWidth + afterSizeWidth;
            
            _suffixLabel.frame = CGRectMake(143 - afterSizeWidth, 72, afterSizeWidth, 13);
            if([anotherArray count] > 1){
                _suffixLabel.text = [anotherArray objectAtIndex:1];

            }
            [_suffixLabel setTextAlignment:NSTextAlignmentRight];
            
            _priceLabel.frame = CGRectMake(143 - afterSizeWidth - priceSizeWidth, 68, priceSizeWidth, (ios7 ? 20 : 27));
            _priceLabel.text = [anotherArray objectAtIndex:0];
            
            _prefixLabel.frame = CGRectMake(143 - afterSizeWidth - priceSizeWidth - beforeSizeWidth, 70, beforeSizeWidth, 13);
            _prefixLabel.text = [array objectAtIndex:0];
            [_prefixLabel setTextAlignment:NSTextAlignmentLeft];
            
            UIImage * redCardImg = [UIImage imageNamed:@"redCard.png"];
            redCardImg = [redCardImg stretchableImageWithLeftCapWidth:10 topCapHeight:5];
            [_redCard setFrame:CGRectMake(146 -totalPriceWidth -10, 65, totalPriceWidth+12, 25)];
            [_redCard setImage:redCardImg];
        }
        
        else
        {
            UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15.0];
            CGSize priceSize = [[dictttt objectForKey:@"price"] sizeWithFont:font constrainedToSize:CGSizeMake(140, 17) lineBreakMode:NSLineBreakByWordWrapping];
            
            _priceLabel.text = [dictttt objectForKey:@"price"];
            [_priceLabel setFrame:CGRectMake(146 -priceSize.width, 69, priceSize.width,(ios7 ? 17 : 24))];
            [_priceLabel setTextAlignment:NSTextAlignmentRight];
            
            UIImage * redCardImg = [UIImage imageNamed:@"redCard.png"];
            redCardImg = [redCardImg stretchableImageWithLeftCapWidth:10 topCapHeight:5];
            [_redCard setFrame:CGRectMake(148 - priceSize.width -4, 65, priceSize.width + 4, 25)];
            [_redCard setImage:redCardImg];
        }
    }
    
    else{
    
        [_redCard setHidden:YES];
    }

    NSNumber *qyerOnlyFlag = [NSNumber numberWithInt:[[dictttt objectForKey:@"self_use"] intValue]];//是否穷游儿独享1-是0-否
    NSNumber *qyerFirstFlag = [NSNumber numberWithInt:[[dictttt objectForKey:@"first_pub"] intValue]];//是否穷游首发1-是0-否
    NSNumber *qyerLabAuthFlag = [NSNumber numberWithInt:[[dictttt objectForKey:@"perperty_lab_auth"] intValue]];//是否穷游实验室认证1-是0-否
    NSNumber *qyerTodayNewFlag = [NSNumber numberWithInt:[[dictttt objectForKey:@"perperty_today_new"] intValue]];//是否今日新单1-是0-否
    
    if ([qyerFirstFlag intValue]) {//穷游首发
        [self showQyerFlayWithType:QyerFlagTypeFirstPub isToday:[qyerTodayNewFlag intValue]];
        
    }else if([qyerOnlyFlag intValue]){//穷游er独享
        [self showQyerFlayWithType:QyerFlagTypeOnly isToday:[qyerTodayNewFlag intValue]];
        
    }else if ([qyerLabAuthFlag intValue]){//穷游实验室认证
        [self showQyerFlayWithType:QyerFlagTypeLabAuth isToday:[qyerTodayNewFlag intValue]];
        
    }else{
        [self showQyerFlayWithType:QyerFlagTypeNone isToday:[qyerTodayNewFlag intValue]];
    }

        
//    if([[dictttt objectForKey:@"self_use"] intValue] == 1)
//    {
//        _qyerOnlyImageView.hidden = NO;
//    }
//    else
//    {
//        _qyerOnlyImageView.hidden = YES;
//    }
//    
//    if([[dictttt objectForKey:@"first_pub"] intValue] == 1)
//    {
//        _qyerFirstImageView.hidden = NO;
//    }
//    else
//    {
//        _qyerFirstImageView.hidden = YES;
//    }
    
    
}

//根据类型显示标签
- (void)showQyerFlayWithType:(QyerFlagType)aQyerFlagType isToday:(BOOL)isToday
{
    if (aQyerFlagType == QyerFlagTypeOnly) {//穷游儿独享
        _qyerOnlyImageView.hidden = NO;
        _qyerFirstImageView.hidden = YES;
        _qyerLabAuthImageView.hidden = YES;
        
    }else if (aQyerFlagType == QyerFlagTypeFirstPub) {//穷游首发
        _qyerOnlyImageView.hidden = YES;
        _qyerFirstImageView.hidden = NO;
        _qyerLabAuthImageView.hidden = YES;
        
    }else if (aQyerFlagType == QyerFlagTypeLabAuth){//穷游实验室认证
        _qyerOnlyImageView.hidden = YES;
        _qyerFirstImageView.hidden = YES;
        _qyerLabAuthImageView.hidden = NO;
        
    }else if (aQyerFlagType == QyerFlagTypeNone){//无标签
        _qyerOnlyImageView.hidden = YES;
        _qyerFirstImageView.hidden = YES;
        _qyerLabAuthImageView.hidden = YES;
    }
    
    _qyerTodayNewImageView.hidden = !isToday;
    
    CGFloat originX = isToday?_qyerTodayNewImageView.frame.size.width:0;
    
    //穷游儿独享
    CGRect frame = _qyerOnlyImageView.frame;
    frame.origin.x = originX;
    _qyerOnlyImageView.frame = frame;
    
    //穷游首发
    frame = _qyerFirstImageView.frame;
    frame.origin.x = originX;
    _qyerFirstImageView.frame = frame;
    
    //穷游实验室认证
    frame = _qyerLabAuthImageView.frame;
    frame.origin.x = originX;
    _qyerLabAuthImageView.frame = frame;
    
    
}


//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    
//    [self addSubview:_maskView];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesCancelled:touches withEvent:event];
//    
//    [_maskView removeFromSuperview];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//    
//    if(_delegate && [_delegate respondsToSelector:@selector(lastMinuteViewDidTap:)])
//    {
//        [_delegate lastMinuteViewDidTap:_lastMinute];
//    }
//
//    [_maskView removeFromSuperview];
//}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

#pragma mark - click
- (void)maskButtonClickAction:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(lastMinuteViewDidTap:)])
    {
        [_delegate lastMinuteViewDidTap:_lastMinute];
    }

}

//#pragma mark - UIGestureRecognizer
//
//- (void)tap:(UITapGestureRecognizer *)gestureRecognizer
//{
//    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
//    {
//        if(_delegate && [_delegate respondsToSelector:@selector(lastMinuteViewDidTap:)])
//        {
//            [_delegate lastMinuteViewDidTap:_lastMinute];
//        }
//    }
//}
//
//- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
//{
//    switch(gestureRecognizer.state)
//    {
//        case UIGestureRecognizerStateBegan:
////        case UIGestureRecognizerStateChanged:
//        {
//            [self addSubview:_maskView];
//        }
//            break;
////        case UIGestureRecognizerStateEnded:
////        {
////            [_maskView removeFromSuperview];
////            
////            if(_delegate && [_delegate respondsToSelector:@selector(lastMinuteViewDidTap:)])
////            {
////                [_delegate lastMinuteViewDidTap:_lastMinute];
////            }
////        }
////            break;
//        default:
//        {
//            [_maskView removeFromSuperview];
//        }
//            break;
//    }
//}



@end
