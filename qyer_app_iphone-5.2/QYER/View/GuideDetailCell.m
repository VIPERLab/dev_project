//
//  GuideDetailCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideDetailCell.h"
#import "QYGuide.h"



#define     positionX_titleBackground       8
#define     positionY_titleBackground       8
#define     height_titleBackground          35
#define     positionX_title                 11
#define     positionX_briefLabel            12
#define     positionY_briefLabel            8

#define     fontSize_guideDetaiinfo         13
#define     fontName_guideDetailInfo        @"HiraKakuProN-W3"
#define     width_guidedetailLabel          ((320-positionX_titleBackground*2) - (positionX_briefLabel*2))

//#define     offsetY                         positionY_briefLabel  //ios7之前为做字体适配做的便移



@implementation GuideDetailCell
@synthesize label_guideDetail = _label_guideDetail;


-(void)dealloc
{
    QY_VIEW_RELEASE(_label_guideDetail);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        //*** title:
        UIImageView *_imageView_titleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_titleBackground, positionY_titleBackground, 320-positionX_titleBackground*2, height_titleBackground)];
        _imageView_titleBackground.backgroundColor = [UIColor clearColor];
        _imageView_titleBackground.image = [UIImage imageNamed:@"详情页_列表title.png"];
        [self addSubview:_imageView_titleBackground];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionX_title, 8, 160, 26)];
        if(ios7)
        {
            titleLabel.frame = CGRectMake(positionX_title, 6, 160, 26);
        }
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:16];
        titleLabel.adjustsFontSizeToFitWidth = NO;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = @"锦囊简介";
        titleLabel.textColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:1];
        [_imageView_titleBackground addSubview:titleLabel];
        [titleLabel release];
        
        
        
        //*** detail:
        _imageView_guideDetailBackground = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView_titleBackground.frame.origin.x, _imageView_titleBackground.frame.origin.y+_imageView_titleBackground.frame.size.height, 320-positionX_titleBackground*2, 10)];
        _imageView_guideDetailBackground.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_guideDetailBackground];
        
        _label_guideDetail = [[UILabel alloc] initWithFrame:CGRectMake(positionX_briefLabel, positionY_briefLabel, width_guidedetailLabel, 10)];
        _label_guideDetail.backgroundColor = [UIColor clearColor];
        //[_label_guideDetail setFont:[UIFont fontWithName:fontName_guideDetailInfo size:fontSize_guideDetaiinfo]];
        [_label_guideDetail setFont:[UIFont systemFontOfSize:fontSize_guideDetaiinfo]];
        _label_guideDetail.numberOfLines = 0;
        _label_guideDetail.textColor = [UIColor blackColor];
        [_imageView_guideDetailBackground addSubview:_label_guideDetail];
        
        
        
        //*** shadow:
        _imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _imageView_guideDetailBackground.frame.size.width, 2)];
        _imageView_lastCell.backgroundColor = [UIColor clearColor];
        _imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影.png"];
        [_imageView_guideDetailBackground addSubview:_imageView_lastCell];
        
        
        [_imageView_titleBackground release];
    }
    return self;
}



#pragma mark -
#pragma mark --- 初始化cell
-(void)initCellWithGuideDetailInfo:(QYGuide *)guide
{
    if(guide)
    {
        float height = [GuideDetailCell countContentLabelHeightByString:guide.guideBriefinfo andFontNmae:fontName_guideDetailInfo andLength:_label_guideDetail.frame.size.width andFontSize:fontSize_guideDetaiinfo];
        
        
        //*** 锦囊详情的frame:
        CGRect frame = self.label_guideDetail.frame;
        frame.size.height = height;
        self.label_guideDetail.frame = frame;
        self.label_guideDetail.text = guide.guideBriefinfo;
        
        
        //*** 锦囊详情背景的frame:
        frame = _imageView_guideDetailBackground.frame;
//        if(ios7)
//        {
            frame.size.height = height + positionY_briefLabel*2;
//        }
//        else
//        {
//            frame.size.height = height + positionY_briefLabel*2 -offsetY  +6;
//        }
        _imageView_guideDetailBackground.frame = frame;
        _imageView_guideDetailBackground.image = [[UIImage imageNamed:@"详情页_列表2.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        
        
        //*** 阴影的frame:
        frame = _imageView_lastCell.frame;
        frame.origin.y = _imageView_guideDetailBackground.frame.size.height;
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
    float height = [GuideDetailCell countContentLabelHeightByString:string andFontNmae:fontName_guideDetailInfo andLength:width_guidedetailLabel andFontSize:fontSize_guideDetaiinfo];
//    if(ios7)
//    {
        height = height + positionY_briefLabel*2;
//    }
//    else
//    {
//        height = height + positionY_briefLabel*2 -offsetY  +6;
//    }
    
    return height + positionY_titleBackground*2 + height_titleBackground;
}



#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
