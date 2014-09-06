//
//  BlackBoardCell.m
//  QYER
//
//  Created by Leno on 14-5-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BlackBoardCell.h"

#import "UIImageView+WebCache.h"

@implementation BlackBoardCell

//@synthesize backGroundView = _backGroundView;
//@synthesize whiteBoardImgView = _whiteBoardImgView;
//@synthesize typeLabel = _typeLabel;
//@synthesize typeIconImgView = _typeIconImgView;
//@synthesize photoImgView = _photoImgView;
//@synthesize titleLabel = _titleLabel;
//@synthesize gapLine = _gapLine;
//@synthesize contentLabel = _contentLabel;
//@synthesize bottomImgView = _bottomImgView;
//@synthesize timeLabel = _timeLabel;
//@synthesize commentIconImgView = _commentIconImgView;
//@synthesize commentNumberLabel = _commentNumberLabel;
//
//@synthesize shadowView = _shadowView;
//@synthesize shadow1 = _shadow1;
//@synthesize shadow2 = _shadow2;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        _backGroundView = [[UIView alloc]initWithFrame:self.contentView.frame];
        [_backGroundView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_backGroundView];
    
        _whiteBoardImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 300, 145)];
        [_whiteBoardImgView setBackgroundColor:[UIColor whiteColor]];
        [_whiteBoardImgView.layer setCornerRadius:6];
        [_whiteBoardImgView.layer setMasksToBounds:YES];
        [_backGroundView addSubview:_whiteBoardImgView];
        
        _typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 12, 100, 20)];
        [_typeLabel setBackgroundColor:[UIColor clearColor]];
        [_typeLabel setTextAlignment:NSTextAlignmentLeft];
        [_typeLabel setTextColor:RGB(38, 38, 38)];
        [_typeLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [_backGroundView addSubview:_typeLabel];
        
        _typeIconImgView = [[UIImageView alloc]initWithFrame:CGRectMake(275, 10, 24, 24)];
        [_typeIconImgView setBackgroundColor:[UIColor clearColor]];
        [_backGroundView addSubview:_typeIconImgView];
        
        _photoImgView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 45, 40, 40)];
        [_photoImgView setBackgroundColor:[UIColor clearColor]];
        [_photoImgView setContentMode:UIViewContentModeScaleAspectFill];
        [_photoImgView.layer setMasksToBounds:YES];
        [_photoImgView.layer setCornerRadius:4];
        [_backGroundView addSubview:_photoImgView];
        
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 45, 150, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setTextColor:RGB(38, 38, 38)];
        [_titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_backGroundView addSubview:_titleLabel];
        
        
        _gapLine = [[UIImageView alloc]initWithFrame:CGRectMake(75, 67, 205, 1)];
        [_gapLine setBackgroundColor:[UIColor clearColor]];
        UIImage * imageee = [UIImage imageNamed:@"Board_Line"];
        imageee = [imageee stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        [_gapLine setImage:imageee];
        [_backGroundView addSubview:_gapLine];
        
        _contentLabel = [[RTLabel alloc]initWithFrame:CGRectMake(75, 73, 205, 65)];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setParagraphReplacement:@""];
        [_contentLabel setTextColor:[UIColor blackColor]];
        [_contentLabel setFont:[UIFont systemFontOfSize:13]];
        [_backGroundView addSubview:_contentLabel];
        
        
        _bottomImgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 145, 280, 30)];
        [_bottomImgView setBackgroundColor:[UIColor clearColor]];
        [_bottomImgView setImage:[UIImage imageNamed:@"wall_play"]];
        [_backGroundView addSubview:_bottomImgView];
        
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 30)];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentLeft];
        [_timeLabel setFont:[UIFont systemFontOfSize:13]];
        [_timeLabel setTextColor:[UIColor whiteColor]];
        [_bottomImgView addSubview:_timeLabel];
        
        
        _commentIconImgView = [[UIImageView alloc]initWithFrame:CGRectMake(233, 8, 14, 14)];
        [_commentIconImgView setBackgroundColor:[UIColor clearColor]];
        [_commentIconImgView setImage:[UIImage imageNamed:@"Boardcomment"]];
        [_bottomImgView addSubview:_commentIconImgView];
        
        _commentNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(247, 5, 25, 20)];
        [_commentNumberLabel setBackgroundColor:[UIColor clearColor]];
        [_commentNumberLabel setTextAlignment:NSTextAlignmentRight];
        [_commentNumberLabel setFont:[UIFont systemFontOfSize:12]];
        [_commentNumberLabel setTextColor:[UIColor whiteColor]];
        [_bottomImgView addSubview:_commentNumberLabel];
     
        _shadowView = [[UIView alloc]initWithFrame:self.frame];
        [_shadowView setBackgroundColor:[UIColor clearColor]];
        [_shadowView setHidden:YES];
        [_backGroundView addSubview:_shadowView];
        
        _shadow1 = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 145)];
        [_shadow1 setBackgroundColor:[UIColor blackColor]];
        [_shadow1 setAlpha:0.2];
        [_shadow1.layer setCornerRadius:6];
        [_shadow1.layer setMasksToBounds:YES];
        [_shadowView addSubview:_shadow1];
        _shadow2 = [[UIView alloc]initWithFrame:CGRectMake(20, 145, 280, 30)];
        [_shadow2 setBackgroundColor:[UIColor blackColor]];
        [_shadow2 setAlpha:0.2];
        [_shadow2.layer setCornerRadius:3];
        [_shadow2.layer setMasksToBounds:YES];
        [_shadowView addSubview:_shadow2];
        
    }
    
    return self;
}


-(void)setCellContentInfo:(NSDictionary *)dict
{
    [_typeLabel setText:nil];
    [_typeIconImgView setImage:nil];
    [_bottomImgView setImage:nil];
    
    [_photoImgView setImage:nil];
    [_titleLabel setText:nil];
    [_contentLabel setText:nil];
    [_commentNumberLabel setText:nil];
    
    
    
    NSInteger typeee       = [[dict objectForKey:@"type"]integerValue];//黑板类型  1约伴  2附近活动  3商家信息
    
    NSInteger  commentCount= [[dict objectForKey:@"total_comments"]integerValue];//点评数目
    
    NSInteger   postTimeInterval = [[dict objectForKey:@"publish_time"] integerValue];
    NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:postTimeInterval + timeZoneOffset];
    
    
    NSString * str1 = [[[NSString stringWithFormat:@"%@",date] componentsSeparatedByString:@" "]objectAtIndex:0];
    NSString * str2 = [[[NSString stringWithFormat:@"%@",date] componentsSeparatedByString:@" "]objectAtIndex:1];
    str2 = [str2 substringToIndex:str2.length -3];
    
    NSString *postTime = [NSString stringWithFormat:@"%@ %@",str1,str2];
    
    if (typeee == 1)
    {
        [_typeLabel setText:@"约伴拼车:"];
        [_typeIconImgView setImage:[UIImage imageNamed:@"playIcon"]];
        [_bottomImgView setImage:[UIImage imageNamed:@"wall_play"]];
    }
    
    if (typeee ==2)
    {
        [_typeLabel setText:@"附近活动:"];
        [_typeIconImgView setImage:[UIImage imageNamed:@"eventIcon"]];
        [_bottomImgView setImage:[UIImage imageNamed:@"wall_event"]];
    }
    
    if (typeee == 3) {
        [_typeLabel setText:@"商家信息:"];
        [_typeIconImgView setImage:[UIImage imageNamed:@"shopIcon"]];
        [_bottomImgView setImage:[UIImage imageNamed:@"wall_shop"]];
    }
    
    //根据内容是否包含图片显示不同的UI布局
    //有图片
    if ([[dict objectForKey:@"photo"] isKindOfClass:[NSString class]] && ![[dict objectForKey:@"photo"] isEqualToString:@""]) {
       
        NSString * photoURL  = [dict objectForKey:@"photo"];//用户图片地址
        [_photoImgView setHidden:NO];
        [_photoImgView setFrame:CGRectMake(20, 39, 73, 95)];
        [_photoImgView.layer setCornerRadius:4];
        [_photoImgView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"Board_Normal.png"]];
        
        NSString * titleee  = [NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];//标题
        [_titleLabel setText:titleee];
        
        
        CGSize  contentSize = [titleee sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(190, 40) lineBreakMode:NSLineBreakByWordWrapping];
        float contentHeight = contentSize.height;
        
        [_titleLabel setFrame:CGRectMake(103, 39, 190, contentHeight)];
        
        float xxxx = _titleLabel.frame.origin.y + _titleLabel.frame.size.height +12;
        
        [_gapLine setFrame:CGRectMake(103, xxxx - 5, 205, 1)];
        [_contentLabel setFrame:CGRectMake(103, xxxx, 190, 140 - xxxx)];
        
        NSString * userName = @"";
        if ([[dict objectForKey:@"username"] isKindOfClass:[NSString class]] && [dict objectForKey:@"username"] != nil) {
            userName = [NSString stringWithFormat:@"%@:",[dict objectForKey:@"username"]];
        }
        NSString * content = [dict objectForKey:@"content"];
        NSString * showContent = [NSString stringWithFormat:@"<font face='Heiti SC' size=15><font color='#444444'>%@</font> <font size=15 color='#9EA3AB'> %@</font>",userName,content];
        [_contentLabel setText:showContent];
    }
    
    //没有图片
    else{
        [_photoImgView setHidden:YES];
        
        NSString * title    = [NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
        
        CGSize  contentSize = [title sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(270, 40) lineBreakMode:NSLineBreakByWordWrapping];
        float contentHeight = contentSize.height;
        
        [_titleLabel setText:title];
        [_titleLabel setFrame:CGRectMake(20, 39, 270, contentHeight)];
        
        float xxxx = _titleLabel.frame.origin.y + _titleLabel.frame.size.height +12;
        
        [_gapLine setFrame:CGRectMake(20, xxxx -5, 270, 1)];
        
        [_contentLabel setFrame:CGRectMake(20, xxxx, 270, 140 -xxxx)];

        
        NSString * userName = @"";
        
        if ([[dict objectForKey:@"username"] isKindOfClass:[NSString class]] && [dict objectForKey:@"username"] != nil) {
            userName = [NSString stringWithFormat:@"%@:",[dict objectForKey:@"username"]];
        }
        
        NSString * content = [dict objectForKey:@"content"];
        
        NSString * showContent = [NSString stringWithFormat:@"<font face='Heiti SC' size=15><font color='#444444'>%@</font> <font size=15 color='#9EA3AB'> %@</font>",userName,content];
        [_contentLabel setText:showContent];
    }
    
    [_timeLabel setText:[NSString stringWithFormat:@"%@",postTime]];

    if (commentCount > 999) {
        commentCount = 999;
    }
    
    CGSize sizee = [[NSString stringWithFormat:@"%d",commentCount] sizeWithFont:_commentNumberLabel.font constrainedToSize:CGSizeMake(200, 20) lineBreakMode:NSLineBreakByCharWrapping];
    
    [_commentNumberLabel setText:[NSString stringWithFormat:@"%d",commentCount]];
    [_commentNumberLabel setFrame:CGRectMake(269 - sizee.width, 8, sizee.width, 14)];
    [_commentIconImgView setFrame:CGRectMake(270 - sizee.width -14 -3, 8, 14, 14)];
    
}





- (void)awakeFromNib
{

}


-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:YES animated:YES];
    
    if (highlighted == YES) {
        [_shadowView setHidden:NO];
    }
    else{
        [_shadowView setHidden:YES];
    }
}


-(void)dealloc
{
    QY_VIEW_RELEASE(_backGroundView);
    QY_VIEW_RELEASE(_whiteBoardImgView);
    QY_VIEW_RELEASE(_typeLabel);
    QY_VIEW_RELEASE(_typeIconImgView);
    QY_VIEW_RELEASE(_photoImgView);
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_gapLine);
    QY_VIEW_RELEASE(_contentLabel);
    QY_VIEW_RELEASE(_bottomImgView);
    QY_VIEW_RELEASE(_timeLabel);
    QY_VIEW_RELEASE(_commentIconImgView);
    QY_VIEW_RELEASE(_commentNumberLabel);
    
    QY_VIEW_RELEASE(_shadowView);
    QY_VIEW_RELEASE(_shadow1);
    QY_VIEW_RELEASE(_shadow2);
    
    [super dealloc];
}


@end
