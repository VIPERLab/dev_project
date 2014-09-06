//
//  BoardDetailCommentCell.m
//  QYER
//
//  Created by Leno on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BoardDetailCommentCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@implementation BoardDetailCommentCell

//@synthesize topLine = _topLine;
//@synthesize userAvatarBtn = _userAvatarBtn;
//@synthesize userNameLabel = _userNameLabel;
//@synthesize postTimeLabel = _postTimeLabel;
//@synthesize contentLabel = _contentLabel;

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _backViewww = [[UIView alloc]initWithFrame:self.frame];
        [_backViewww setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_backViewww];
        
        _topLine = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 310, 1)];
        [_topLine setBackgroundColor:[UIColor clearColor]];
        UIImage * imageee = [UIImage imageNamed:@"Board_Line"];
        imageee = [imageee stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        [_topLine setImage:imageee];
        [self addSubview:_topLine];
        

        _userAvatarBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
        [_userAvatarBtn setFrame:CGRectMake(10, 10, 38, 38)];
        [_userAvatarBtn setBackgroundColor:[UIColor clearColor]];
        [_userAvatarBtn setContentMode:UIViewContentModeScaleAspectFill];
        [_userAvatarBtn.layer setMasksToBounds:YES];
        [_userAvatarBtn.layer setCornerRadius:19];
        [_userAvatarBtn addTarget:self action:@selector(didTapAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [_backViewww addSubview:_userAvatarBtn];
        
     
        _userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(58, 12, 120, 16)];
        [_userNameLabel setBackgroundColor:[UIColor clearColor]];
        [_userNameLabel setTextAlignment:NSTextAlignmentLeft];
        [_userNameLabel setTextColor:RGB(158, 163, 171)];
        [_userNameLabel setFont:[UIFont systemFontOfSize:13]];
        [_backViewww addSubview:_userNameLabel];
        
        
        _postTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(190, 11, 120, 16)];
        [_postTimeLabel setBackgroundColor:[UIColor clearColor]];
        [_postTimeLabel setTextAlignment:NSTextAlignmentRight];
        [_postTimeLabel setTextColor:RGB(158, 163, 171)];
        [_postTimeLabel setFont:[UIFont systemFontOfSize:14]];
        [_backViewww addSubview:_postTimeLabel];

        
        _contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(58, 33, 320 -68, 60)];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setNumberOfLines:0];
        [_contentLabel setTextColor:RGB(38, 38, 38)];
        [_contentLabel setFont:[UIFont systemFontOfSize:13]];
        [_backViewww addSubview:_contentLabel];
    }
    
    return self;
}

-(void)didTapAvatar:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didClickCommentsUserAvatarByTag:)]) {
        [self.delegate didClickCommentsUserAvatarByTag:self.tag];
    }
}

-(void)setContenInfo:(NSDictionary *)dict
{
    NSString * avatar = [dict objectForKey:@"avatar"];
    NSString * userName = [dict objectForKey:@"username"];
    
//    NSInteger   postTimeInterval = [[dict objectForKey:@"publish_time"] integerValue];
//    NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
//    NSDate * date = [NSDate dateWithTimeIntervalSince1970:postTimeInterval + timeZoneOffset];
//    NSString *postTime = [[[NSString stringWithFormat:@"%@",date] componentsSeparatedByString:@" "]objectAtIndex:0];
    
    NSInteger   postTimeInterval = [[dict objectForKey:@"publish_time"] integerValue];
    NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:postTimeInterval + timeZoneOffset];
    NSString * str1 = [[[NSString stringWithFormat:@"%@",date] componentsSeparatedByString:@" "]objectAtIndex:0];
    NSString * str2 = [[[NSString stringWithFormat:@"%@",date] componentsSeparatedByString:@" "]objectAtIndex:1];
    str2 = [str2 substringToIndex:str2.length -3];
    NSString *postTime = [NSString stringWithFormat:@"%@ %@",str1,str2];
    
    
    NSString * content = [dict objectForKey:@"content"];
    
    [_userAvatarBtn setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:nil];
    [_userNameLabel setText:userName];
    
    [_postTimeLabel setText:postTime];
    [_contentLabel setText:content];
    
    CGSize  contentSize = [content sizeWithFont:_contentLabel.font constrainedToSize:CGSizeMake(252, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    float contentHeight = contentSize.height;
    
    [_contentLabel setFrame:CGRectMake(58, 32, 320 -68, contentHeight)];
}

-(void)insertNewComment:(NSDictionary *)dict
{
    [_backViewww setFrame:CGRectMake(320, 0, 320, self.frame.size.height)];
    
    NSString * avatar = [dict objectForKey:@"avatar"];
    NSString * userName = [dict objectForKey:@"username"];
    
    NSInteger   postTimeInterval = [[dict objectForKey:@"publish_time"] integerValue];
    NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:postTimeInterval + timeZoneOffset];
    NSString *postTime = [[[NSString stringWithFormat:@"%@",date] componentsSeparatedByString:@" "]objectAtIndex:0];
    
    NSString * content = [dict objectForKey:@"content"];
    
    [_userAvatarBtn setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:nil];
    [_userNameLabel setText:userName];
    
    [_postTimeLabel setText:postTime];
    [_contentLabel setText:content];
    
    CGSize  contentSize = [content sizeWithFont:_contentLabel.font constrainedToSize:CGSizeMake(252, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    float contentHeight = contentSize.height;
    
    [_contentLabel setFrame:CGRectMake(58, 32, 320 -68, contentHeight)];
    
    [self performSelector:@selector(showNewCommentAnimation) withObject:nil afterDelay:0.2];
}


-(void)showNewCommentAnimation
{    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.6f];
    [_backViewww setFrame:CGRectMake(0, 0, 320, self.frame.size.height)];
    [UIView commitAnimations];
}



-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_backViewww);
    
    QY_VIEW_RELEASE(_topLine);
    QY_VIEW_RELEASE(_userAvatarBtn);
    QY_VIEW_RELEASE(_userNameLabel);
    QY_VIEW_RELEASE(_postTimeLabel);
    QY_VIEW_RELEASE(_contentLabel);
    
    [super dealloc];
}


@end


