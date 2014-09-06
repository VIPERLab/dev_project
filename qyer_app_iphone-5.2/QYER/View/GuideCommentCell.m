//
//  GuideCommentCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-8.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "QYGuideComment.h"
#import "UIImageView+WebCache.h"


#define     positionX                   8
#define     positionX_icon              8
#define     positionY_icon              8
#define     width_icon                  43
#define     height_icon                 43
#define     positionX_userName          8
#define     positionY_userName          (ios7 ? 5 : 8)
#define     height_userName             (ios7 ? 16 : 20)
#define     width_commentLabel          240
#define     positionY_commentTime       (ios7 ? 4 : 9)

#define     fontSize_guideComment       13
#define     fontName_guideComment       @"HiraKakuProN-W3"
#define     fontName_commentTime        @"HiraKakuProN-W3"

#define     offsetY                     5  //ios7之前为做字体适配做的便移





@implementation GuideCommentCell
@synthesize imageView_userIcon = _imageView_userIcon;
@synthesize label_userComment = _label_userComment;
@synthesize label_userName = _label_userName;
@synthesize label_commentTime = _label_commentTime;


-(void)dealloc
{
    self.label_userName = nil;
    self.label_commentTime = nil;
    self.label_userComment = nil;
    self.imageView_userIcon = nil;
    
    [_imageView_background removeFromSuperview];
    [_imageView_background release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(positionX, 0, 320-positionX*2, 10)];
        _imageView_background.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_background];
        
        
        //*** 用户头像:
        UIImageView *iconBackView = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_icon, positionY_icon, width_icon, height_icon)];
        [iconBackView setImage:[UIImage imageNamed:@"comment_icon_background.png"]];
        _imageView_userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_icon, height_icon)];
        _imageView_userIcon.layer.masksToBounds = YES;
        _imageView_userIcon.layer.cornerRadius = 43/2.;
        [iconBackView addSubview:_imageView_userIcon];
        [_imageView_background addSubview:iconBackView];
        [iconBackView release];
        
        
        //*** 用户名称:
        _label_userName = [[UILabel alloc] initWithFrame:CGRectMake(positionX_icon+width_icon+positionX_userName, positionY_userName, 160, height_userName)];
        _label_userName.backgroundColor = [UIColor clearColor];
        _label_userName.font = [UIFont fontWithName:fontName_guideComment size:12];
        _label_userName.adjustsFontSizeToFitWidth = NO;
        _label_userName.textAlignment = NSTextAlignmentLeft;
        _label_userName.textColor = [UIColor colorWithRed:150/255. green:150/255. blue:150/255. alpha:1];
        [_imageView_background addSubview:_label_userName];
        
        
        //*** 用户的评论:
        _label_userComment = [[UILabel alloc] initWithFrame:CGRectMake(_label_userName.frame.origin.x, _label_userName.frame.origin.y+height_userName, width_commentLabel, 20)];
        _label_userComment.backgroundColor = [UIColor clearColor];
        //[_label_userComment setFont:[UIFont fontWithName:fontName_guideComment size:fontSize_guideComment]];
        [_label_userComment setFont:[UIFont systemFontOfSize:fontSize_guideComment]];
        _label_userComment.numberOfLines = 0;
        _label_userComment.textColor = [UIColor blackColor];
        [_imageView_background addSubview:_label_userComment];
        
        
        //*** 用户评论时间:
        _label_commentTime = [[UILabel alloc] initWithFrame:CGRectMake(235, positionY_commentTime, 60, 18)];
        _label_commentTime.backgroundColor = [UIColor clearColor];
        _label_commentTime.font = [UIFont fontWithName:fontName_commentTime size:10];
        _label_commentTime.textAlignment = NSTextAlignmentRight;
        _label_commentTime.textColor = [UIColor colorWithRed:150/255. green:150/255. blue:150/255. alpha:1];
        [_imageView_background addSubview:_label_commentTime];
        
        
        //*** 阴影:
        _imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _imageView_background.frame.size.width, 2)];
        _imageView_lastCell.alpha = 0;
        _imageView_lastCell.backgroundColor = [UIColor clearColor];
        _imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影.png"];
        [_imageView_background addSubview:_imageView_lastCell];
    }
    return self;
}


#pragma mark -
#pragma mark --- 初始化GuideComment
-(void)initCellWithArray:(NSArray *)array atPosition:(NSInteger)position
{
    QYGuideComment *guideComment = [array objectAtIndex:position];
    if(guideComment)
    {
        //*** 初始化cell要显示的内容:
        self.label_userComment.text = guideComment.str_content;
        self.label_commentTime.text = guideComment.str_commentTime;
        self.label_userName.text = guideComment.str_userName;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *myDateStr = [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[guideComment.str_commentTime doubleValue]]] retain];
        self.label_commentTime.text = myDateStr;
        [self.imageView_userIcon setImageWithURL:[NSURL URLWithString:guideComment.str_userAvatar] placeholderImage:nil];
        
        
        //*** 调整评论的高度:
        float height = [GuideCommentCell countContentLabelHeightByString:guideComment.str_content andFontNmae:fontName_guideComment andLength:width_commentLabel andFontSize:fontSize_guideComment];
        CGRect frame = self.label_userComment.frame;
        frame.size.height = height;
        self.label_userComment.frame = frame;
        
        
        //*** 调整评论背景的高度:
        frame = _imageView_background.frame;
        if(ios7)
        {
            height = MAX((positionY_userName*2 + height_userName) + height, positionY_icon*2 + height_icon);
        }
        else
        {
            height = MAX((positionY_userName*2 -offsetY + height_userName) + height, positionY_icon*2 + height_icon);
        }
        frame.size.height = height;
        _imageView_background.frame = frame;
        _imageView_lastCell.alpha = 0;
        
        
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"下实线@2x" ofType:@"png"]];
        _imageView_background.image = [image stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        if(position < [array count]-1)
        {
//            UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"下虚线@2x" ofType:@"png"]];
//            _imageView_background.image = [image stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        }
        else if(position == [array count]-1)
        {
//            UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"下实线@2x" ofType:@"png"]];
//            _imageView_background.image = [image stretchableImageWithLeftCapWidth:2 topCapHeight:2];
            
            frame = _imageView_lastCell.frame;
            frame.origin.y = _imageView_background.frame.size.height;
            _imageView_lastCell.frame = frame;
            _imageView_lastCell.alpha = 1;
        }
        
        [dateFormatter release];
        [myDateStr release];
    }
}



#pragma mark -
#pragma mark --- 计算String所占的高度
+(float)countContentLabelHeightByString:(NSString*)content andFontNmae:(NSString *)fontName andLength:(float)length andFontSize:(float)font
{
    //CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName size:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    
    return sizeToFit.height;
}
+(float)cellHeightWithContent:(NSString *)string
{
    float height = [GuideCommentCell countContentLabelHeightByString:string andFontNmae:fontName_guideComment andLength:width_commentLabel andFontSize:fontSize_guideComment];
    
    if(ios7)
    {
        return MAX(positionY_icon*2 + height_icon, (positionY_userName*2 + height_userName) + height);
    }
    return MAX(positionY_icon*2 + height_icon, (positionY_userName*2 -offsetY + height_userName) + height);
}



#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end

