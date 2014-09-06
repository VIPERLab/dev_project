//
//  MyCallOutAnnotationView.m
//  OnLineMap
//
//  Created by an qing on 13-1-30.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "MyCallOutAnnotationView.h"
#import "MyPopViewControl.h"
#import <QuartzCore/QuartzCore.h>
#import "MapPopViewControl.h"
#import "CalloutButton.h"
#import "MobClick.h"
#import "UIImageView+WebCache.h"


#define  arrow_height   0    //popView最下面的箭头的高度
#define  popViewHeight  63   //popView的宽度
#define  popViewWidth   320  //popView的高度


#define partofpopviewheight     63      //每小部分popview的高度
#define partofpopviewwidth      36      //每小部分popview的宽度
#define popviewalphavalue       0.75    //popview的alpha
#define titlePositionX          10      //popview的title距离左边框的长度
#define chineseTitleFont        17      //中文字号
#define englishTitleFont        13      //英文字号
#define rightArrowImageVWidth   16      //右箭头的宽度

#define partofpopviewMaxNum     7       //popview最多允许有7小部分



@implementation MyCallOutAnnotationView
@synthesize delegate;
@synthesize contentView;
@synthesize backgroundImage;
@synthesize bgView = _bgView;
@synthesize rightArrowImageV = _rightArrowImageV;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize cateIdStr = _cateIdStr;
@synthesize poiId = _poiId;
@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize hasRightArrow = _hasRightArrow;
@synthesize isRightButtonEnabled = _isRightButtonEnabled;
@synthesize imageView_poi = _imageView_poi;

@synthesize readPoiDetailInfoButton = _readPoiDetailInfoButton;
@synthesize turnToSystemMapButton = _turnToSystemMapButton;



-(void)dealloc
{
    self.bgView = nil;
    self.contentView = nil;
    self.backgroundImage = nil;
    self.delegate = nil;
    self.title = nil;
    self.subtitle = nil;
    self.cateIdStr = nil;
    self.rightArrowImageV = nil;
    self.imageView_poi = nil;
    
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.canShowCallout = NO;
        //self.centerOffset = CGPointMake(0, -55);
        self.frame = CGRectMake(0, 0, popViewWidth, popViewHeight);  //popView的大小
        
        
        _turnToSystemMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _turnToSystemMapButton.frame = CGRectMake(20,0,100,58);
        _turnToSystemMapButton.tag = 1;
        [_turnToSystemMapButton setBackgroundColor:[UIColor clearColor]];
        [_turnToSystemMapButton addTarget:self action:@selector(popViewDidSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_turnToSystemMapButton];
        UIImage *image_turnToSystemMapButton = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"路线@2x" ofType:@"png"]];
        [_turnToSystemMapButton setBackgroundImage:image_turnToSystemMapButton forState:UIControlStateNormal];
        UIImage *image_turnToSystemMapButton_select = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"路线pressed@2x" ofType:@"png"]];
        [_turnToSystemMapButton setBackgroundImage:image_turnToSystemMapButton_select forState:UIControlStateHighlighted];
        
        
        
        
        _readPoiDetailInfoButton = [CalloutButton buttonWithType:UIButtonTypeCustom];
        _readPoiDetailInfoButton.frame = CGRectMake(100,0,100,58);
        _readPoiDetailInfoButton.tag = 2;
        [_readPoiDetailInfoButton setBackgroundColor:[UIColor clearColor]];
        [_readPoiDetailInfoButton addTarget:self action:@selector(popViewDidSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_readPoiDetailInfoButton];
        _readPoiDetailInfoButton.colorFlag = 0;
        
        if(_hasRightArrow == 0)
        {
            _readPoiDetailInfoButton.colorFlag = 2;
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    //self.layer.shadowColor = [[UIColor blackColor] CGColor];
    //self.layer.shadowOpacity = 1.0;
    //self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}
-(void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);  //背景色
    
    [self getDrawPath:context];
    
    [self setMyPopView];
    
    CGContextFillPath(context);
}
- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
	CGFloat radius = 0.0;
    
	CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect),
    // midy = CGRectGetMidY(rrect),
    maxy = CGRectGetMaxY(rrect)-arrow_height;
    CGContextMoveToPoint(context, midx+arrow_height, maxy);
    CGContextAddLineToPoint(context,midx, maxy+arrow_height);
    CGContextAddLineToPoint(context,midx-arrow_height, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

-(void)setBackgroundImage:(UIImage*)image
{
    self.contentView.image = image;
}
-(void)setMyPopView
{
    self.userInteractionEnabled = YES;
    
    
    
    if(!_bgView)
    {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 156/2)];
    }
    _bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgView];
    
    _imageView_pop = [[UIImageView alloc] initWithFrame:CGRectMake((320-584/2.)/2., 0, 584/2, 156/2)];
    _imageView_pop.userInteractionEnabled = YES;
    _imageView_pop.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"poi气泡@2x" ofType:@"png"]];
    [_bgView addSubview:_imageView_pop];
    
    
    _readPoiDetailInfoButton.frame = CGRectMake(5, 5, 215, 156/2-17);
    _readPoiDetailInfoButton.backgroundColor = [UIColor clearColor];
    [_imageView_pop addSubview:_readPoiDetailInfoButton];
    
    
    _turnToSystemMapButton.frame = CGRectMake(222, 5, 65, 156/2-17);
    _turnToSystemMapButton.backgroundColor = [UIColor clearColor];
    [_imageView_pop addSubview:_turnToSystemMapButton];
    
    
    _imageView_poi = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 54, 54)];
    _imageView_poi.backgroundColor = [UIColor clearColor];
    _imageView_poi.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"108*108@2x" ofType:@"png"]];
    [_imageView_pop addSubview:_imageView_poi];
    
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_poi.frame.origin.x+_imageView_poi.frame.size.width+13, _imageView_poi.frame.origin.y+2, 143, 24)];
    label_title.backgroundColor = [UIColor clearColor];
    label_title.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15.];
    label_title.textColor = [UIColor blackColor];
    label_title.textAlignment = NSTextAlignmentLeft;
    label_title.text = self.title;
    [_imageView_pop addSubview:label_title];
    [label_title release];
    
    
    
    UILabel *label_subTitle = [[UILabel alloc] initWithFrame:CGRectMake(label_title.frame.origin.x, label_title.frame.origin.y+label_title.frame.size.height-3, 143, 18)];
    label_subTitle.backgroundColor = [UIColor clearColor];
    label_subTitle.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12.];
    label_subTitle.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:100/255.];
    label_subTitle.textAlignment = NSTextAlignmentLeft;
    label_subTitle.text = self.subtitle;
    [_imageView_pop addSubview:label_subTitle];
    [label_subTitle release];
    
    
    
    
    
    
    
    
    
    
    
    
//    ######################################################################################################
//    if(!_bgView)
//    {
//        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 63)];
//    }
//    _bgView.backgroundColor = [UIColor brownColor];
//    [self addSubview:_bgView];
//    
//    
//    UIImageView *arrowImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, partofpopviewwidth, partofpopviewheight)];
//    arrowImageV.center = _bgView.center;
//    arrowImageV.userInteractionEnabled = YES;
//    arrowImageV.backgroundColor = [UIColor clearColor];
//    UIImage *image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"地图黑色浮窗bg（有箭头）@2x" ofType:@"png"]];
//    arrowImageV.image = image;
//    [_bgView addSubview:arrowImageV];
//    [arrowImageV release];
//    
//    _readPoiDetailInfoButton.frame = CGRectMake(arrowImageV.frame.origin.x, 0, partofpopviewwidth*2, partofpopviewheight);
//    [self addSubview:_readPoiDetailInfoButton];
//    _readPoiDetailInfoButton.backgroundColor = [UIColor clearColor];
//
//    
//    
//    
//    float chineseTitleWidth = 0;
//    float englishTitleWidth = 0;
//    if(self.title && self.title.length > 0)
//    {
//        chineseTitleWidth = [self countContentLabelHeightByString:self.title andWidth:30 andTypeSize:chineseTitleFont];
//        chineseTitleWidth = chineseTitleWidth+titlePositionX+rightArrowImageVWidth;
//    }
//    if(self.subtitle && self.subtitle.length > 0)
//    {
//        englishTitleWidth = [self countContentLabelHeightByString:self.subtitle andWidth:20 andTypeSize:englishTitleFont];
//        englishTitleWidth = englishTitleWidth+titlePositionX+rightArrowImageVWidth;
//    }
//    if(!self.title || self.title.length == 0)
//    {
//        englishTitleWidth = [self countContentLabelHeightByString:self.subtitle andWidth:30 andTypeSize:chineseTitleFont];
//        englishTitleWidth = englishTitleWidth+titlePositionX+rightArrowImageVWidth;
//    }
//    
//    
//    
//    
//    
//    NSInteger num = 0;
//    if(chineseTitleWidth - englishTitleWidth >= 0)
//    {
//        num = chineseTitleWidth/arrowImageV.frame.size.width;
//        if(num*arrowImageV.frame.size.width - chineseTitleWidth <= 0)
//        {
//            num = num+1;
//        }
//    }
//    else if(englishTitleWidth - chineseTitleWidth >= 0)
//    {
//        num = englishTitleWidth/arrowImageV.frame.size.width;
//        if(num*arrowImageV.frame.size.width - englishTitleWidth <= 0)
//        {
//            num = num+1;
//        }
//    }
//    
//    
//    num = num+1;
//    if(num%2 == 0)
//    {
//        num = num+1;
//    }
//    
//    if(num <= 1)
//    {
//        num = 3;
//    }
//    else if(num >= 7)
//    {
//        num = 7;
//    }
//    
//    
//    
//    float x = (320-num*arrowImageV.frame.size.width)/2.;
//    
//    
//    
//    for(int i = 0; i < num; i++)
//    {
//        if(i == (num-1)/2)
//        {
//            if(i == 1)
//            {
//                positionX = x+36*i +titlePositionX;
//            }
//            
//            continue;
//        }
//        else
//        {
//            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(x+36*i, 0, 36, 63)];
//            imageV.userInteractionEnabled = YES;
//            imageV.backgroundColor = [UIColor clearColor];
//            //imageV.alpha = popviewalphavalue;
//            UIImage *image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"地图黑色浮窗bg（无箭头）@2x" ofType:@"png"]];
//            imageV.image = image;
//            
//            if(i == 0)
//            {
//                CGRect frame = imageV.frame;
//                frame.origin.x = frame.origin.x-1;
//                imageV.frame = frame;
//                
//                UIImageView *lineImageV = [[UIImageView alloc] initWithFrame:CGRectMake((36-24)/2., (63-24)/2.0 - 10, 24, 24)];
//                imageV.backgroundColor = [UIColor clearColor];
//                UIImage *image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"路线icon_@2x" ofType:@"png"]];
//                lineImageV.image = image;
//                [imageV addSubview:lineImageV];
//                [lineImageV release];
//                
//                
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, lineImageV.frame.size.height+lineImageV.frame.origin.y+3, 36, 12)];
//                CGRect frame1 = label.frame;
//                frame1.origin.y = (int)frame1.origin.y;
//                label.frame = frame1;
//                label.backgroundColor = [UIColor clearColor];
//                label.text = @"路线";
//                label.textAlignment = UITextAlignmentCenter;
//                label.font = [UIFont systemFontOfSize:10.];
//                label.textColor = [UIColor whiteColor];
//                [imageV addSubview:label];
//                [label release];
//                
//                
//                CGRect frame2 = imageV.frame;
//                frame2.size.height = 58;
//                _turnToSystemMapButton.frame = frame2;
//                [self addSubview:_turnToSystemMapButton];
//                _turnToSystemMapButton.backgroundColor = [UIColor clearColor];
//                
//            }
//            else if(i == 1)
//            {
//                positionX = x+36*i +titlePositionX;
//                
//                
//                _readPoiDetailInfoButton.frame = CGRectMake(x+36*i, 0, partofpopviewwidth*(num-1), 58);
//                [self addSubview:_readPoiDetailInfoButton];
//                _readPoiDetailInfoButton.backgroundColor = [UIColor clearColor];
//                
//            }
//            else if(i == num-1)
//            {
//                positionLastX = x+36*i +titlePositionX;
//            }
//            
//            [_bgView addSubview:imageV];
//            [imageV release];
//        }
//    }
//    
//    //初始化TitleView和SubTitleView
//    [self initTileViewWithTitle:self.title andTitleViewWidth:chineseTitleWidth andSubTileViewWithSubTitle:self.subtitle andSubTitleViewWidth:englishTitleWidth];
//    
//    if(self.hasRightArrow == 1)
//    {
//        self.readPoiDetailInfoButton.colorFlag = 0;
//        [self initRightArrowImageV];
//    }
//    else
//    {
//        self.readPoiDetailInfoButton.colorFlag = 2;
//    }
}
-(void)initTileViewWithTitle:(NSString*)title andTitleViewWidth:(float)titlewidth andSubTileViewWithSubTitle:(NSString*)subtitle andSubTitleViewWidth:(float)subtitlewidth
{
    if((titlewidth+rightArrowImageVWidth) - (partofpopviewMaxNum-1)*partofpopviewwidth >= 0)
    {
        if(_hasRightArrow == 0)
        {
            titlewidth = (partofpopviewMaxNum-1)*partofpopviewwidth - titlePositionX;
        }
        else
        {
            titlewidth = (partofpopviewMaxNum-1)*partofpopviewwidth -rightArrowImageVWidth;
        }
    }
    if((subtitlewidth+rightArrowImageVWidth) - (partofpopviewMaxNum-1)*partofpopviewwidth >= 0)
    {
        if(_hasRightArrow == 0)
        {
            subtitlewidth = (partofpopviewMaxNum-1)*partofpopviewwidth - titlePositionX;
        }
        else
        {
            subtitlewidth = (partofpopviewMaxNum-1)*partofpopviewwidth -rightArrowImageVWidth;
        }
    }
    
    
    
    if(self.title && self.title.length > 0 && self.subtitle && self.subtitle.length > 0)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionX, 12, titlewidth, 25)];
        titleLabel.backgroundColor = [UIColor clearColor];
        //titleLabel.font = [UIFont systemFontOfSize:chineseTitleFont];
        titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleFont];
        titleLabel.text = self.title;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:titleLabel];
        [titleLabel release];
        
        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionX, 35, subtitlewidth, 20)];
        subTitleLabel.backgroundColor = [UIColor clearColor];
        //subTitleLabel.font = [UIFont systemFontOfSize:englishTitleFont];
        subTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:englishTitleFont];
        subTitleLabel.text = self.subtitle;
        subTitleLabel.textColor = [UIColor colorWithRed:165/255. green:165/255. blue:165/255. alpha:1];
        subTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:subTitleLabel];
        [subTitleLabel release];
    }
    else if(!self.subtitle || self.subtitle.length == 0)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionX, 22, titlewidth, 25)];
        titleLabel.backgroundColor = [UIColor clearColor];
        //titleLabel.font = [UIFont systemFontOfSize:chineseTitleFont];
        titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleFont];
        titleLabel.text = self.title;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:titleLabel];
        [titleLabel release];
    }
    else if(!self.title || self.title.length == 0)
    {
        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionX, 21, subtitlewidth, 25)];
        subTitleLabel.backgroundColor = [UIColor clearColor];
        //subTitleLabel.font = [UIFont systemFontOfSize:chineseTitleFont];
        subTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleFont];
        subTitleLabel.text = self.subtitle;
        subTitleLabel.textColor = [UIColor whiteColor];
        subTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:subTitleLabel];
        [subTitleLabel release];
    }
    else
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionX, 12, 50, 25)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleFont];
        titleLabel.text = self.title;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:titleLabel];
        [titleLabel release];
        
        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(positionX, 35, 50, 20)];
        subTitleLabel.backgroundColor = [UIColor clearColor];
        subTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:englishTitleFont];
        subTitleLabel.text = self.subtitle;
        subTitleLabel.textColor = [UIColor colorWithRed:165/255. green:165/255. blue:165/255. alpha:1];
        subTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:subTitleLabel];
        [subTitleLabel release];
    }
}
-(void)initRightArrowImageV
{
    _rightArrowImageV = [[UIImageView alloc] initWithFrame:CGRectMake(positionLastX+6, ((partofpopviewheight-3)-rightArrowImageVWidth)/2.-1, rightArrowImageVWidth, rightArrowImageVWidth)];
    _rightArrowImageV.backgroundColor = [UIColor clearColor];
    UIImage *image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"右箭头icon@2x" ofType:@"png"]];
    _rightArrowImageV.image = image;
    [_bgView addSubview:_rightArrowImageV];
}



#pragma mark -
#pragma mark --- 计算String所占的高度
-(float)countContentLabelHeightByString:(NSString*)content andWidth:(float)width andTypeSize:(float)size
{
    //CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    //return sizeToFit.height;
    
    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W3" size:size] constrainedToSize:CGSizeMake(CGFLOAT_MAX, width)];
    return sizeToFit.width;
}

#pragma mark -
#pragma mark --- popViewDidSelected
-(void)popViewDidSelected:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if(button.tag == 1) //地图
    {
        if(delegate && [delegate respondsToSelector:@selector(popViewDidSelectedWithType:andTitle:andSubtitle:andLat:andLng:andPoiId:)])
        {
            
            
            [delegate popViewDidSelectedWithType:@"systemmap" andTitle:self.title andSubtitle:self.subtitle andLat:self.lat andLng:self.lng andPoiId:self.poiId];
        }
    }
    else if(button.tag == 2)
    {
        if(delegate && [delegate respondsToSelector:@selector(popViewDidSelectedWithType:andTitle:andSubtitle:andLat:andLng:andPoiId:)] && self.isRightButtonEnabled == 0)
        {
            
            [delegate popViewDidSelectedWithType:@"poidetailinfo" andTitle:self.title andSubtitle:self.subtitle andLat:self.lat andLng:self.lng andPoiId:self.poiId];
        }
    }
}


#pragma mark -
#pragma mark --- 根据评星初始化star
-(void)initStartViewWithGrade:(NSInteger)grade
{
    NSInteger positionX_star = _imageView_poi.frame.origin.x+_imageView_poi.frame.size.width+13;
    NSInteger number_star = 0;
    
    [[_imageView_pop viewWithTag:10] removeFromSuperview];
    [[_imageView_pop viewWithTag:11] removeFromSuperview];
    [[_imageView_pop viewWithTag:12] removeFromSuperview];
    [[_imageView_pop viewWithTag:13] removeFromSuperview];
    [[_imageView_pop viewWithTag:14] removeFromSuperview];
    
    
    for(;;)
    {
        grade = grade-2;
        
        if(grade <= 0)
        {
            number_star++;
            
            //半颗star:
            UIImageView *imageView_star = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_star, 50, 12, 12)];
            imageView_star.backgroundColor = [UIColor clearColor];
            imageView_star.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star3@2x" ofType:@"png"]];
            [_imageView_pop addSubview:imageView_star];
            imageView_star.tag = number_star+10;
            [imageView_star release];
            
            
            //空心star:
            NSInteger left_star = 5-number_star;
            for(int num = left_star; num > 0; num--)
            {
                positionX_star = positionX_star + 12 + 5;
                number_star++;
                
                UIImageView *imageView_star = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_star, 50, 12, 12)];
                imageView_star.backgroundColor = [UIColor clearColor];
                imageView_star.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star2@2x" ofType:@"png"]];
                [_imageView_pop addSubview:imageView_star];
                imageView_star.tag = number_star+10;
                [imageView_star release];
            }
            
            break;
        }
        else
        {
            number_star++;
            
            //整颗star:
            UIImageView *imageView_star = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_star, 50, 12, 12)];
            imageView_star.backgroundColor = [UIColor clearColor];
            imageView_star.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star1@2x" ofType:@"png"]];
            [_imageView_pop addSubview:imageView_star];
            imageView_star.tag = number_star+10;
            [imageView_star release];
        }
        
        positionX_star = positionX_star + 12 + 5;
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
