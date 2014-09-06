//
//  BoadDetailTopCell.m
//  QYER
//
//  Created by Leno on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BoadDetailTopCell.h"

#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@implementation BoadDetailTopCell

//@synthesize backGroundView = _backGroundView;
//@synthesize userAvatarButton = _userAvatarButton;
//@synthesize userNameLabel = _userNameLabel;
//@synthesize postTimeLabel = _postTimeLabel;
//@synthesize gapImgeView = _gapImgeView;
//@synthesize titleLabel = _titleLabel;
//@synthesize contentImgView = _contentImgView;
//@synthesize contentLabel = _contentLabel;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _userAvatarButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
        [_userAvatarButton setFrame:CGRectMake(10, 10, 49, 49)];
        [_userAvatarButton setBackgroundColor:[UIColor clearColor]];
        [_userAvatarButton setContentMode:UIViewContentModeScaleAspectFill];
        [_userAvatarButton.layer setCornerRadius:25];
        [_userAvatarButton.layer setMasksToBounds:YES];
        [_userAvatarButton addTarget:self action:@selector(didClickTopUserAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_userAvatarButton];
        
        _userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(69, 16, 150, 18)];
        [_userNameLabel setUserInteractionEnabled:YES];
        [_userNameLabel setBackgroundColor:[UIColor clearColor]];
        [_userNameLabel setTextAlignment:NSTextAlignmentLeft];
        [_userNameLabel setTextColor:RGB(38, 38, 38)];
        [_userNameLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [self addSubview:_userNameLabel];
        
        _postTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(69, 36, 180, 16)];
        [_postTimeLabel setBackgroundColor:[UIColor clearColor]];
        [_postTimeLabel setTextAlignment:NSTextAlignmentLeft];
        [_postTimeLabel setTextColor:RGB(158, 163, 171)];
        [_postTimeLabel setFont:[UIFont systemFontOfSize:13]];
        [self addSubview:_postTimeLabel];
        
        _gapImgeView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 69, 310, 1)];
        [_gapImgeView setBackgroundColor:[UIColor clearColor]];
        UIImage * imageee = [UIImage imageNamed:@"Board_Line"];
        imageee = [imageee stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        [_gapImgeView setImage:imageee];
        [self addSubview:_gapImgeView];
        
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 90, 300, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setTextColor:RGB(38, 38, 38)];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setUserInteractionEnabled:YES];
        [self addSubview:_titleLabel];
        
        _contentLabel  = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 300, 40)];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setNumberOfLines:0];
        [_contentLabel setTextColor:RGB(158, 163, 171)];
        [_contentLabel setFont:[UIFont systemFontOfSize:14]];
        [_contentLabel setUserInteractionEnabled:YES];
        [self addSubview:_contentLabel];
        
        _contentImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 170, 300, 160)];
        [_contentImgView setBackgroundColor:[UIColor clearColor]];
        [_contentImgView setContentMode:UIViewContentModeScaleAspectFill];
        [_contentImgView.layer setMasksToBounds:YES];
        [_contentImgView setHidden:YES];
        [self addSubview:_contentImgView];
    }
    return self;
}

-(void)didClickTopUserAvatar:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didClickTopUserAvatar)]) {
        [self.delegate didClickTopUserAvatar];
    }
}

-(void)setContentInfo:(NSDictionary *)dict
{    
    NSString * avatar = [dict objectForKey:@"avatar"];
    NSString * userNmae = [dict objectForKey:@"username"];
    NSString * title = [dict objectForKey:@"title"];
    NSString * photoURL = [dict objectForKey:@"photo"];
    NSString * content = [dict objectForKey:@"content"];

    NSInteger   postTimeInterval = [[dict objectForKey:@"publish_time"] integerValue];
    NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:postTimeInterval + timeZoneOffset];
    
    NSString * str1 = [[[NSString stringWithFormat:@"%@",date] componentsSeparatedByString:@" "]objectAtIndex:0];
    NSString * str2 = [[[NSString stringWithFormat:@"%@",date] componentsSeparatedByString:@" "]objectAtIndex:1];
    str2 = [str2 substringToIndex:str2.length -3];
    NSString *postTime = [NSString stringWithFormat:@"%@ %@",str1,str2];
    
    [_userAvatarButton setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:nil];
    [_userNameLabel setText:userNmae];
    [_postTimeLabel setText:[NSString stringWithFormat:@"%@",postTime]];
    
    CGSize  titleSize = [title sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(300, 45) lineBreakMode:NSLineBreakByWordWrapping];
    float titleHeight = titleSize.height;
    [_titleLabel setText:title];
    [_titleLabel setFrame:CGRectMake(10, 85, 300, titleHeight)];
    
    
    //计算内容的高度
    CGSize  contentSize = [content sizeWithFont:_contentLabel.font constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    float contentHeight = contentSize.height;
    [_contentLabel setText:content];
    [_contentLabel setFrame:CGRectMake(10, 85 +titleHeight + 10, 300, contentHeight)];
    
    
    
    float photoOriginY = 85 + titleHeight + 10 + contentHeight +10;
    
    float photoWidth = 0;
    float photoHeight = 0;
    
    
    
    if ([[dict objectForKey:@"photo"] isKindOfClass:[NSString class]] && photoURL.length >0)
    {
        [_contentImgView setHidden:NO];
        
        [_contentImgView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"Board_Normal"]];
        
        UIImage * photoImage = _contentImgView.image;
        
        if (photoImage.size.width >0 && photoImage.size.height >0) {
            
            photoWidth = photoImage.size.width;
            photoHeight = photoImage.size.height;
        }
        
        float _acturalHeight =  (float)(photoHeight/photoWidth) * 300;
        
        //设置显示照片的Frame
        [_contentImgView setFrame:CGRectMake(10, photoOriginY, 300, _acturalHeight)];
    }
    
    else{
        [_contentImgView setHidden:YES];
        [_contentImgView setFrame:CGRectZero];
        
//        //计算内容的高度
//        CGSize  contentSize = [content sizeWithFont:self.contentLabel.font constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByWordWrapping];
//        float contentHeight = contentSize.height;
//        
//        [self.contentLabel setText:content];
//        [self.contentLabel setFrame:CGRectMake(10, 120, 300, contentHeight)];
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_backGroundView);
    QY_VIEW_RELEASE(_userAvatarButton);
    QY_VIEW_RELEASE(_userNameLabel);
    QY_VIEW_RELEASE(_postTimeLabel);
    QY_VIEW_RELEASE(_gapImgeView);
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_contentImgView);
    QY_VIEW_RELEASE(_contentLabel);
    
    [super dealloc];
}

@end
