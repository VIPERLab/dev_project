//
//  LastMinuteRecommendView.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-15.
//
//

#import "LastMinuteRecommendView.h"
#import <QuartzCore/QuartzCore.h>
#import "LastMinute.h"
#import "UIImageView+WebCache.h"
#import "ControlWithColorWhenTap.h"
#import "MobClick.h"


#define     Label_LastMinuteName_Height     34
#define     cell_Height                     132/2
#define     positionY_icon                  13
#define     positionY_homeView              100



@implementation LastMinuteRecommendView
@synthesize delegate = _delegate;

-(void)dealloc
{
    [_superView release];
    
    [_backGround_control removeFromSuperview];
    [_backGround_control release];
    
    [_homeView removeFromSuperview];
    [_homeView release];
    
    [_imageview_icon removeFromSuperview];
    [_imageview_icon release];
    
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code
    }
    return self;
}



#pragma mark -
#pragma mark --- 构建View
-(void)showWithArray:(NSArray *)array andTitle:(NSString *)title inView:(UIView *)superView
{
    _superView = [superView retain];
    
    [self initHomeView:array.count];
    [self initHeadBarWithTitle:title];
    [self initLastMinuteCellInfo:array];
    [self initLastMinuteAppInfo];
    
    [[UIApplication sharedApplication] keyWindow].userInteractionEnabled = YES;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _backGround_control.alpha = 0.6;
                     }
                     completion:^(BOOL finished){
                     }];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         _homeView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
    
}

-(void)initHomeView:(NSInteger)number
{
    _backGround_control = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backGround_control.backgroundColor = [UIColor blackColor];
    _backGround_control.userInteractionEnabled = YES;
    _backGround_control.alpha = 0;
    [_backGround_control addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [_superView addSubview:_backGround_control];
    
    float positionY = positionY_homeView;
    if(iPhone5)
    {
        positionY = positionY_homeView + 44;
    }
    
    if(number == 4)
    {
        _homeView = [[UIView alloc] initWithFrame:CGRectMake(18, positionY-cell_Height/2, 568/2., 724/2.)];
    }
    else if(number == 3)
    {
        _homeView = [[UIView alloc] initWithFrame:CGRectMake(18, positionY, 568/2., 724/2.-cell_Height)];
    }
    else if(number == 2)
    {
        _homeView = [[UIView alloc] initWithFrame:CGRectMake(18, positionY+cell_Height/2, 568/2., 724/2.-cell_Height-cell_Height)];
    }
    else
    {
        _homeView = [[UIView alloc] initWithFrame:CGRectMake(18, positionY+cell_Height/2+cell_Height/2, 568/2., 724/2.-cell_Height-cell_Height-cell_Height)];
    }
    
    
    _homeView.backgroundColor = [UIColor whiteColor];
    [_homeView.layer setCornerRadius:2];
    _homeView.userInteractionEnabled = YES;
    _homeView.alpha = 0;
    [_superView addSubview:_homeView];
}
-(void)initHeadBarWithTitle:(NSString *)title
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 568/2.-40, 40)];
    headView.backgroundColor = [UIColor clearColor];
    [_homeView addSubview:headView];
    
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 18)];
    label_title.backgroundColor = [UIColor clearColor];
    label_title.font = [UIFont systemFontOfSize:15];
    label_title.text = @"折扣推荐";
    [headView addSubview:label_title];
    [label_title release];
    
    
    UILabel *label_subTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 21, 100, 16)];
    label_subTitle.backgroundColor = [UIColor clearColor];
    label_subTitle.font = [UIFont systemFontOfSize:11];
    label_subTitle.text = title;
    label_subTitle.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1];
    [headView addSubview:label_subTitle];
    [label_subTitle release];
    
    
    
    UIButton *button_close = [UIButton buttonWithType:UIButtonTypeCustom];
    button_close.frame = CGRectMake(headView.frame.origin.x+headView.frame.size.width, 0, 40, 40);
    [button_close setBackgroundImage:[UIImage imageNamed:@"btn_关闭.png"] forState:UIControlStateNormal];
    [button_close addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [_homeView addSubview:button_close];
    
    
    UILabel *label_line = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, 568/2., 1)];
    label_line.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1];
    [headView addSubview:label_line];
    [label_line release];
    
    originY = 40;
    [headView release];
    
}
-(void)initLastMinuteCellInfo:(NSArray *)array
{
    for(int i = 0; i < array.count; i++)
    {
        LastMinute *last_minute = [array objectAtIndex:i];
        
        [self initLastMinuteCellControlWithPosition:i];
        [self initLastMinuteIcon:last_minute];
        [self initLastMinuteNameLabel:last_minute];
        
        NSRange range = [last_minute.str_price rangeOfString:@"<em>"];
        if(range.location >= last_minute.str_price.length)
        {
            //NSLog(@" last_minute.str_price 字段数据错误 ");
        }
        else
        {
            if(range.location != 0)
            {
                [self initOtherLabel:last_minute];
            }
            [self initLastMinutePriceLabel:last_minute];
            [self initLastMinuteUnitLabel:last_minute];
        }
        
        originY = originY+positionY_icon+_imageview_icon.frame.size.height+positionY_icon;
        [self initLastMinuteLine];
        
        if(_imageview_icon)
        {
            [_imageview_icon release];
            _imageview_icon = nil;
        }
        if(_label_lastMinuteName)
        {
            [_label_lastMinuteName release];
            _label_lastMinuteName = nil;
        }
        if(_label_other)
        {
            [_label_other release];
            _label_other = nil;
        }
        if(_label_price)
        {
            [_label_price release];
            _label_price = nil;
        }
    }
}
-(void)initLastMinuteCellControlWithPosition:(NSInteger)position
{
    ControlWithColorWhenTap *control_cell = [[ControlWithColorWhenTap alloc] initWithFrame:CGRectMake(0, originY, 568/2., cell_Height) andColorWhenTap:[UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3]];
    control_cell.backgroundColor = [UIColor clearColor];
    control_cell.tag = position;
    [control_cell addTarget:self action:@selector(tapInfo:) forControlEvents:UIControlEventTouchUpInside];
    [_homeView addSubview:control_cell];
    [control_cell release];
}
-(void)initLastMinuteIcon:(LastMinute *)last_minute
{
    _imageview_icon = [[UIImageView alloc] initWithFrame:CGRectMake(3, originY+positionY_icon, 40, 40)];
    _imageview_icon.backgroundColor = [UIColor clearColor];
    //[_imageview_icon setImageWithURL:[NSURL URLWithString:last_minute.str_pic] placeholderImage:[UIImage imageNamed:@"lm_default"]];
    if([last_minute.str_productType isEqualToString:@"1016"]) //机票
    {
        _imageview_icon.image = [UIImage imageNamed:@"机票lm.png"];
    }
    else if([last_minute.str_productType isEqualToString:@"1017"]) //酒店
    {
        _imageview_icon.image = [UIImage imageNamed:@"酒店lm.png"];
    }
    else if([last_minute.str_productType isEqualToString:@"1018"]) //机票+酒店
    {
        _imageview_icon.image = [UIImage imageNamed:@"机加酒lm.png"];
    }
    else if([last_minute.str_productType isEqualToString:@"1021"]) //租车
    {
        _imageview_icon.image = [UIImage imageNamed:@"租车lm.png"];
    }
    else if([last_minute.str_productType isEqualToString:@"1049"]) //保险
    {
        _imageview_icon.image = [UIImage imageNamed:@"保险lm.png"];
    }
    else if([last_minute.str_productType isEqualToString:@"1020"]) //油轮
    {
        _imageview_icon.image = [UIImage imageNamed:@"邮轮lm.png"];
    }
    else //其它
    {
        _imageview_icon.image = [UIImage imageNamed:@"默认折扣lm.png"];
    }
    
    
    [_homeView addSubview:_imageview_icon];
}
-(void)initLastMinuteNameLabel:(LastMinute *)last_minute
{
    _label_lastMinuteName = [[UILabel alloc] initWithFrame:CGRectMake(_imageview_icon.frame.origin.x+_imageview_icon.frame.size.width+9, originY+11, 225, Label_LastMinuteName_Height)];
    if(ios7)
    {
        _label_lastMinuteName.frame = CGRectMake(_imageview_icon.frame.origin.x+_imageview_icon.frame.size.width+9, originY+8, 225, Label_LastMinuteName_Height);
    }
    _label_lastMinuteName.backgroundColor = [UIColor clearColor];
    _label_lastMinuteName.text = [NSString stringWithFormat:@"%@",last_minute.str_title];
    _label_lastMinuteName.numberOfLines = 2;
    _label_lastMinuteName.font = [UIFont systemFontOfSize:13];
    float width = [self countContentLabelWidthByString:_label_lastMinuteName.text andHeight:20 andTypeSize:13];
    if(width-225<=0) //表示只有一行文字
    {
        CGRect frame = _label_lastMinuteName.frame;
        frame.origin.y = frame.origin.y + 5;
        frame.size.height = 18;
        _label_lastMinuteName.frame = frame;
    }
    [_homeView addSubview:_label_lastMinuteName];
}
-(void)initOtherLabel:(LastMinute *)last_minute
{
    NSRange range1 = [last_minute.str_price rangeOfString:@"<em>"];
    NSString *other_str = [last_minute.str_price substringToIndex:range1.length-1];
    
    _label_other = [[UILabel alloc] initWithFrame:CGRectMake(_imageview_icon.frame.origin.x+_imageview_icon.frame.size.width+9, _label_lastMinuteName.frame.origin.y+_label_lastMinuteName.frame.size.height+2, 0, 20)];
    if(ios7)
    {
        _label_other.frame = CGRectMake(_imageview_icon.frame.origin.x+_imageview_icon.frame.size.width+9, _label_lastMinuteName.frame.origin.y+_label_lastMinuteName.frame.size.height-1, 0, 20);
    }
    _label_other.backgroundColor = [UIColor clearColor];
    _label_other.text = other_str;
    _label_other.font = [UIFont systemFontOfSize:11.];
    float width = [self countContentLabelWidthByString:other_str andHeight:20 andTypeSize:11];
    CGRect frame = _label_other.frame;
    frame.size.width = width;
    _label_other.frame = frame;
    [_homeView addSubview:_label_other];
}
-(void)initLastMinutePriceLabel:(LastMinute *)last_minute
{
    NSRange range1 = [last_minute.str_price rangeOfString:@"<em>"];
    NSRange range2 = [last_minute.str_price rangeOfString:@"</em>"];
    NSRange range;
    range.location = range1.location + range1.length;
    range.length = range2.location-(range1.location + range1.length);
    NSString *price_num = [last_minute.str_price substringWithRange:range];
    if(_label_other)
    {
        _label_price = [[UILabel alloc] initWithFrame:CGRectMake(_label_other.frame.origin.x+_label_other.frame.size.width, _label_lastMinuteName.frame.origin.y+_label_lastMinuteName.frame.size.height, 0, 20)];
        if(ios7)
        {
            _label_price.frame = CGRectMake(_label_other.frame.origin.x+_label_other.frame.size.width, _label_lastMinuteName.frame.origin.y+_label_lastMinuteName.frame.size.height-3, 0, 20);
        }
    }
    else
    {
        _label_price = [[UILabel alloc] initWithFrame:CGRectMake(_imageview_icon.frame.origin.x+_imageview_icon.frame.size.width+9, _label_lastMinuteName.frame.origin.y+_label_lastMinuteName.frame.size.height, 0, 20)];
        if(ios7)
        {
            _label_price.frame = CGRectMake(_imageview_icon.frame.origin.x+_imageview_icon.frame.size.width+9, _label_lastMinuteName.frame.origin.y+_label_lastMinuteName.frame.size.height-3, 0, 20);
        }
    }
    _label_price.backgroundColor = [UIColor clearColor];
    _label_price.text = [NSString stringWithFormat:@"%@",price_num];
    _label_price.textColor = [UIColor colorWithRed:245/255. green:120/255. blue:0 alpha:1];
    _label_price.font = [UIFont systemFontOfSize:16.];
    float width = [self countContentLabelWidthByString:_label_price.text andHeight:20 andTypeSize:16];
    CGRect frame = _label_price.frame;
    frame.size.width = width;
    _label_price.frame = frame;
    [_homeView addSubview:_label_price];
}
-(void)initLastMinuteUnitLabel:(LastMinute *)last_minute
{
    NSRange range2 = [last_minute.str_price rangeOfString:@"</em>"];
    CGRect frame = _label_price.frame;
    UILabel *label_unit = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+frame.size.width+2, _label_price.frame.origin.y+3, 180-_label_price.frame.size.width, 16)];
    label_unit.backgroundColor = [UIColor clearColor];
    label_unit.text = [last_minute.str_price substringFromIndex:range2.location+range2.length];
    label_unit.font = [UIFont systemFontOfSize:11.];
    [_homeView addSubview:label_unit];
    [label_unit release];
}
-(void)initLastMinuteLine
{
    UILabel *label_line = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, 568/2., 1)];
    label_line.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1];
    [_homeView addSubview:label_line];
    [label_line release];
}

-(void)initLastMinuteAppInfo
{
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, originY-3, 300/2, 128/2)];
    icon.backgroundColor = [UIColor clearColor];
    icon.image = [UIImage imageNamed:@"阅读页面_折扣详情lm.png"];
    icon.layer.masksToBounds = YES;
    [icon.layer setCornerRadius:6];
    [_homeView addSubview:icon];
    
    
    UIButton *button_download = [UIButton buttonWithType:UIButtonTypeCustom];
    button_download.frame = CGRectMake(icon.frame.origin.x+icon.frame.size.width+25, originY+14, 192/2, 60/2);
    [button_download setBackgroundImage:[UIImage imageNamed:@"免费下载lm.png"] forState:UIControlStateNormal];
    [button_download addTarget:self action:@selector(turnToAppStore) forControlEvents:UIControlEventTouchUpInside];
    [_homeView addSubview:button_download];
    [icon release];
}


#pragma mark -
#pragma mark ---
-(float)countContentLabelWidthByString:(NSString *)content andHeight:(float)height andTypeSize:(float)size
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)];
    
    return sizeToFit.width;
}
-(void)turnToAppStore
{
    [MobClick event:@"discountClickDownload"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/qiong-you-zhe-kou-mei-ri-bi/id658779759?mt=8"]];
}



#pragma mark -
#pragma mark --- LastMinuteRecommendView - Delegate
-(void)tapInfo:(id)sender
{
    ControlWithColorWhenTap *control = (ControlWithColorWhenTap *)sender;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(LastMinuteCellSelectedPosition:)])
    {
        [MobClick event:@"discountClickDetail"];
        [self.delegate LastMinuteCellSelectedPosition:control.tag];
    }
}
-(void)close:(id)sender
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _backGround_control.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         
                         if(self.delegate && [self.delegate respondsToSelector:@selector(LastMinuteCellSelectedPosition:)])
                         {
                             [self.delegate LastMinuteViewDidHide];
                         }
                         
                     }];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _homeView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                     }];
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
