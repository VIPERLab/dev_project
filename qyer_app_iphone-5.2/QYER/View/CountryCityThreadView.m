//
//  CountryCityThreadView.m
//  QYER
//
//  Created by Leno on 14-7-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CountryCityThreadView.h"

#import "NSDateUtil.h"

@implementation CountryCityThreadView

@synthesize delegate = _delegate;

@synthesize linkURL = _linkURL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.userInteractionEnabled = YES;
        
        self.linkURL = [NSString string];
        
        _backButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
        [_backButton setFrame:CGRectMake(0, 0, 320, 88)];
        [_backButton setBackgroundColor:[UIColor clearColor]];
        [_backButton setExclusiveTouch:YES];
        [_backButton addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton addTarget:self action:@selector(pressOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_backButton addTarget:self action:@selector(pressDown:) forControlEvents:UIControlEventTouchDown];
        [_backButton addTarget:self action:@selector(pressCancel:) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:_backButton];
        
        
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 88)];
        [_backView setBackgroundColor:RGB(188, 198, 188)];
        [_backView setAlpha:0.4];
        [_backView setHidden:YES];
        [_backButton addSubview:_backView];
        
        
        UIImage * imageee = [UIImage imageNamed:@"Board_Line"];
        imageee = [imageee stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        
        _topLineImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 310, 1)];
        [_topLineImgView setBackgroundColor:[UIColor clearColor]];
        [_topLineImgView setImage:imageee];
        [_backButton addSubview:_topLineImgView];
        
        
        _threadImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 100, 68)];
        [_threadImgView setBackgroundColor:[UIColor clearColor]];
        _threadImgView.layer.masksToBounds = YES;
        _threadImgView.clipsToBounds = YES;
        [_threadImgView setContentMode:UIViewContentModeScaleAspectFill];
        [_backButton addSubview:_threadImgView];

    
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 10, 185, 34)];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:RGB(68, 68, 68)];
        [_titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_backButton addSubview:_titleLabel];
        
        
        _authorTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 65, 300, 14)];
        [_authorTimeLabel setTextColor:RGB(158, 163, 171)];
        [_authorTimeLabel setTextAlignment:NSTextAlignmentLeft];
        [_authorTimeLabel setBackgroundColor:[UIColor clearColor]];
        [_authorTimeLabel setFont:[UIFont systemFontOfSize:12]];
        [_backButton addSubview:_authorTimeLabel];
        
    }
    return self;
}

-(void)setThreadInfo:(NSDictionary *)dict
{
    if (![dict isEqual:[NSNull null]]) {
        
        self.linkURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"view_url"]];
        
        NSString * photoURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"photo"]];
        [_threadImgView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"default_ls_back.png"]];
        
        NSString * title = [NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
        CGSize  titleSize = [title sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(185, 40) lineBreakMode:NSLineBreakByWordWrapping];
        
        if (titleSize.height > 17) {
            [_titleLabel setFrame:CGRectMake(120, 10, 185, 34)];
        }
        else{
            [_titleLabel setFrame:CGRectMake(120, 10, 185, 15)];
        }
        [_titleLabel setText:title];
        
        
        NSString * author = [dict objectForKey:@"username"];
        
        double timeInter = [[dict objectForKey:@"lastpost"] doubleValue];
        NSString * authorTime = [NSString stringWithFormat:@"%@ | %@",author,[NSDateUtil getTimeDiffString:timeInter]];
        [_authorTimeLabel setText:authorTime];
        
    }
}


-(void)clicked:(id)sender
{
    [_delegate didClickThread:self];
}

-(void)pressOutside:(id)sender
{
    [_backView setHidden:YES];
}

-(void)pressDown:(id)sender
{
    [_backView setHidden:NO];
}

-(void)pressCancel:(id)sender
{
    [_backView setHidden:YES];
}

-(void)setBackBtnColor
{
    [_backView setHidden:YES];
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_backButton);
    QY_VIEW_RELEASE(_backView);
    QY_VIEW_RELEASE(_topLineImgView);
    QY_VIEW_RELEASE(_threadImgView);
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_authorTimeLabel);
    
    [super dealloc];
}

@end
