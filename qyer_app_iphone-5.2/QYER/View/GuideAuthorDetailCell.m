//
//  GuideAuthorDetailCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideAuthorDetailCell.h"
#import "QYGuide.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>



#define     positionX_titleBackground               8
#define     positionY_titleBackground               0
#define     height_bottomOfCell                     8   //cell底部预留的高度
#define     height_titleBackground                  35
#define     positionX_title                         8
#define     positionY_guideAuthorDetail             8

#define     fontSize_guideAuthorInfo                13
#define     fontName_guideAuthorInfo                @"HiraKakuProN-W3"
#define     width_guideAuthorLabel                  ((320-positionX_titleBackground*2) - (positionX_briefLabel*2))

#define     positionX_iconBackground                8
#define     positionY_iconBackground                8
#define     width_userIcon                          62
#define     height_userIcon                         62

#define     positionX_betweeniconandintroduction    8
#define     width_introductionlabel                 215

//#define     offsetY                                 positionY_guideAuthorDetail  //ios7之前为做字体适配做的便移




@implementation GuideAuthorDetailCell
@synthesize label_authorName = _label_authorName;
@synthesize imageView_authorIcon = _imageView_authorIcon;
@synthesize label_authorDetailInfo = _label_authorDetailInfo;

-(void)delloc
{
    QY_VIEW_RELEASE(_label_authorName);
    QY_VIEW_RELEASE(_imageView_authorIcon);
    QY_VIEW_RELEASE(_label_authorDetailInfo);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        //*** (1)锦囊作者:
        UIImageView *_imageView_titleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_titleBackground, positionY_titleBackground, 320-positionX_titleBackground*2, height_titleBackground)];
        _imageView_titleBackground.backgroundColor = [UIColor clearColor];
        _imageView_titleBackground.image = [UIImage imageNamed:@"详情页_列表title.png"];
        [self addSubview:_imageView_titleBackground];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionX_title, 8, 70, 26)];
        if(ios7)
        {
            titleLabel.frame = CGRectMake(positionX_title, 8-2, 70, 26);
        }
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:16];
        titleLabel.text = @"锦囊作者";
        titleLabel.adjustsFontSizeToFitWidth = NO;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor blackColor];
        [_imageView_titleBackground addSubview:titleLabel];
        [titleLabel release];
        
        
        float positionY = (ios7 ?  (titleLabel.frame.origin.y+6) : (titleLabel.frame.origin.y+6-3));
        UILabel *label_separate = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.size.width+titleLabel.frame.origin.x+2, positionY, 1, titleLabel.frame.size.height-12)];
        label_separate.backgroundColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:0.8];
        [_imageView_titleBackground addSubview:label_separate];
        
        _label_authorName = [[UILabel alloc] initWithFrame:CGRectMake(label_separate.frame.origin.x+label_separate.frame.size.width+9, titleLabel.frame.origin.y, 200, 26)];
        if(ios7)
        {
            _label_authorName.frame = CGRectMake(label_separate.frame.origin.x+label_separate.frame.size.width+10, titleLabel.frame.origin.y-2, 200, 26);
        }
        _label_authorName.backgroundColor = [UIColor clearColor];
        _label_authorName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _label_authorName.adjustsFontSizeToFitWidth = YES;
        _label_authorName.textAlignment = NSTextAlignmentLeft;
        _label_authorName.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1];
        [_imageView_titleBackground addSubview:_label_authorName];
        [label_separate release];
        
        
        
        
        
        //*** (2)锦囊作者简介:
        _imageView_guideAuthorBackground = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView_titleBackground.frame.origin.x, _imageView_titleBackground.frame.origin.y+_imageView_titleBackground.frame.size.height, 320-positionX_titleBackground*2, 10)];
        _imageView_guideAuthorBackground.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_guideAuthorBackground];
        
        
        UIImageView *iconBackView = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_iconBackground, positionY_iconBackground, width_userIcon, height_userIcon)];
        iconBackView.backgroundColor = [UIColor clearColor];
        [iconBackView setImage:[UIImage imageNamed:@"comment_icon_background.png"]];
        [_imageView_guideAuthorBackground addSubview:iconBackView];
        _imageView_authorIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_userIcon, height_userIcon)];
        _imageView_authorIcon.layer.masksToBounds = YES;
        _imageView_authorIcon.layer.cornerRadius = 58/2.;
        [iconBackView addSubview:_imageView_authorIcon];
        
        
        _label_authorDetailInfo = [[UILabel alloc] initWithFrame:CGRectMake(iconBackView.frame.origin.x+iconBackView.frame.size.width+positionX_betweeniconandintroduction, positionY_guideAuthorDetail, width_introductionlabel, 10)];
        _label_authorDetailInfo.backgroundColor = [UIColor clearColor];
        //[_label_authorDetailInfo setFont:[UIFont fontWithName:fontName_guideAuthorInfo size:fontSize_guideAuthorInfo]];
        [_label_authorDetailInfo setFont:[UIFont systemFontOfSize:fontSize_guideAuthorInfo]];
        _label_authorDetailInfo.numberOfLines = 0;
        _label_authorDetailInfo.textColor = [UIColor blackColor];
        [_imageView_guideAuthorBackground addSubview:_label_authorDetailInfo];
        
        
        
        //cell最下面的阴影:
        _imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _imageView_guideAuthorBackground.frame.size.width, 2)];
        _imageView_lastCell.backgroundColor = [UIColor clearColor];
        _imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影.png"];
        [_imageView_guideAuthorBackground addSubview:_imageView_lastCell];
        
        
        
        [iconBackView release];
        [_imageView_titleBackground release];
    }
    return self;
}


#pragma mark -
#pragma mark --- initCellWithGuide
-(void)initCellWithGuideAuthorInfo:(QYGuide *)guide
{
    if(guide)
    {
        float height_guideAuthorDetail = [GuideAuthorDetailCell countContentLabelHeightByString:guide.guideAuthor_intro andFontNmae:fontName_guideAuthorInfo andLength:width_introductionlabel andFontSize:fontSize_guideAuthorInfo];
        
        //设置内容:
        [self.imageView_authorIcon setImageWithURL:[NSURL URLWithString:guide.guideAuthor_icon] placeholderImage:nil];
        if(guide.guideAuthor_name)
        {
            self.label_authorName.text = [NSString stringWithFormat:@"%@",guide.guideAuthor_name];
        }
        else
        {
            self.label_authorName.text = @"";
        }
        self.label_authorDetailInfo.text = guide.guideAuthor_intro;
        
        
        //设置作者详情的frame:
        CGRect frame = self.label_authorDetailInfo.frame;
        frame.size.height = height_guideAuthorDetail;
        self.label_authorDetailInfo.frame = frame;
        
        
        //设置作者详情背景的frame:
        frame = _imageView_guideAuthorBackground.frame;
        float height_icon = height_userIcon + positionY_iconBackground*2;
        float height_guideAuthorDetailBackGround = 0;
        height_guideAuthorDetailBackGround = height_guideAuthorDetail + positionY_guideAuthorDetail*2;
        frame.size.height = MAX(height_icon, height_guideAuthorDetailBackGround);
        _imageView_guideAuthorBackground.frame = frame;
        _imageView_guideAuthorBackground.image = [[UIImage imageNamed:@"详情页_列表2"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        
        
        //设置阴影的frame:
        frame = _imageView_lastCell.frame;
        frame.origin.y = _imageView_guideAuthorBackground.frame.size.height;
        _imageView_lastCell.frame = frame;
    }
}



#pragma mark -
#pragma mark --- 计算String所占的高度
+(float)countContentLabelHeightByString:(NSString*)content andFontNmae:(NSString *)fontName andLength:(float)length andFontSize:(float)font
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    //CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName size:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    
    return sizeToFit.height;
}
+(float)cellHeightWithContent:(NSString *)string
{
    float height_guideAuthorDetail = [GuideAuthorDetailCell countContentLabelHeightByString:string andFontNmae:fontName_guideAuthorInfo andLength:width_introductionlabel andFontSize:fontSize_guideAuthorInfo];
    
    float height_icon = height_userIcon + positionY_iconBackground*2;
    float height_guideAuthorDetailBackGround = 0;
    height_guideAuthorDetailBackGround = height_guideAuthorDetail + positionY_guideAuthorDetail*2;
    
    
    return MAX(height_titleBackground + height_icon + height_bottomOfCell, height_titleBackground + height_guideAuthorDetailBackGround + height_bottomOfCell);
}


#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
