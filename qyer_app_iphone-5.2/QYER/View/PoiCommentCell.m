//
//  PoiCommentCell.m
//  QyGuide
//
//  Created by an qing on 13-2-28.
//
//


#import "PoiCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"


#define     positionY_userName         (ios7 ? 6 : 9)
#define     positionY_userCommentTime  (ios7 ? 5 : 8)

#define     positionX_userIcon         9
#define     positionY_userIcon         9
#define     height_userIcon            43
#define     height_userName            22
#define     positionY_star             3
#define     height_star                10
#define     width_star                 10
#define     width_userComment          240
#define     positionY_userComment      6

#define     fontName                   @"HiraKakuProN-W3"
#define     fontSize                   13



@implementation PoiCommentCell
@synthesize bgView = _bgView;
@synthesize userImageView = _userImageView;
@synthesize userNameLabel = _userNameLabel;
@synthesize userCommentTimeLabel = _userCommentTimeLabel;
@synthesize userCommentRateView1 = _userCommentRateView1;
@synthesize userCommentRateView2 = _userCommentRateView2;
@synthesize userCommentRateView3 = _userCommentRateView3;
@synthesize userCommentRateView4 = _userCommentRateView4;
@synthesize userCommentRateView5 = _userCommentRateView5;
@synthesize userCommentLabel = _userCommentLabel;



-(void)dealloc
{
    [_bgView release];
    [_userImageView release];
    [_userNameLabel release];
    [_userCommentRateView1 release];
    [_userCommentRateView2 release];
    [_userCommentRateView3 release];
    [_userCommentRateView4 release];
    [_userCommentRateView5 release];
    [_userCommentTimeLabel release];
    [_userCommentLabel release];
    [_topLabel release];
    [_leftLabel release];
    [_rightLabel release];
    [_bottomLabel release];
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(9, 0, 302, 0)];
        _bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bgView];
        
        
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_userIcon, positionY_userIcon, height_userIcon, height_userIcon)];
        _userImageView.backgroundColor = [UIColor clearColor];
        _userImageView.image = [UIImage imageNamed:@"comment_icon_background"];
        _userImageView.layer.masksToBounds = YES;
        [_userImageView.layer setCornerRadius:21];
        [_bgView addSubview:_userImageView];
        
        
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9+_userImageView.frame.size.width+9, positionY_userName, 155, height_userName)];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textColor = [UIColor blackColor];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        _userNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        [_bgView addSubview:_userNameLabel];
        
        
        _userCommentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(9+_userImageView.frame.size.width+9+_userNameLabel.frame.size.width, positionY_userCommentTime, 80, 22)];
        _userCommentTimeLabel.backgroundColor = [UIColor clearColor];
        _userCommentTimeLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:10];
        _userCommentTimeLabel.textAlignment = NSTextAlignmentRight;
        _userCommentTimeLabel.textColor = [UIColor grayColor];
        [_bgView addSubview:_userCommentTimeLabel];
        
        
        
        UIImage *hollowImage = [UIImage imageNamed:@"hollowstar"];
        _userCommentRateView1 = [[UIImageView alloc] initWithFrame:CGRectMake(9+_userImageView.frame.size.width+9, _userNameLabel.frame.origin.y+_userNameLabel.frame.size.height+positionY_star, width_star, height_star)];
        _userCommentRateView1.backgroundColor = [UIColor clearColor];
        _userCommentRateView1.image = hollowImage;
        [_bgView addSubview:_userCommentRateView1];
        
        _userCommentRateView2 = [[UIImageView alloc] initWithFrame:CGRectMake(_userCommentRateView1.frame.origin.x+_userCommentRateView1.frame.size.width+5, _userNameLabel.frame.origin.y+_userNameLabel.frame.size.height+positionY_star, width_star, height_star)];
        _userCommentRateView2.backgroundColor = [UIColor clearColor];
        _userCommentRateView2.image = hollowImage;
        [_bgView addSubview:_userCommentRateView2];
        
        _userCommentRateView3 = [[UIImageView alloc] initWithFrame:CGRectMake(_userCommentRateView2.frame.origin.x+_userCommentRateView2.frame.size.width+5, _userNameLabel.frame.origin.y+_userNameLabel.frame.size.height+positionY_star, width_star, height_star)];
        _userCommentRateView3.backgroundColor = [UIColor clearColor];
        _userCommentRateView3.image = hollowImage;
        [_bgView addSubview:_userCommentRateView3];
        
        _userCommentRateView4 = [[UIImageView alloc] initWithFrame:CGRectMake(_userCommentRateView3.frame.origin.x+_userCommentRateView3.frame.size.width+5, _userNameLabel.frame.origin.y+_userNameLabel.frame.size.height+positionY_star, width_star, height_star)];
        _userCommentRateView4.backgroundColor = [UIColor clearColor];
        _userCommentRateView4.image = hollowImage;
        [_bgView addSubview:_userCommentRateView4];
        
        _userCommentRateView5 = [[UIImageView alloc] initWithFrame:CGRectMake(_userCommentRateView4.frame.origin.x+_userCommentRateView4.frame.size.width+5, _userNameLabel.frame.origin.y+_userNameLabel.frame.size.height+positionY_star, width_star, height_star)];
        _userCommentRateView5.backgroundColor = [UIColor clearColor];
        _userCommentRateView5.image = hollowImage;
        [_bgView addSubview:_userCommentRateView5];
        
        
        
        _userCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(9+_userImageView.frame.size.width+9, positionY_userName+height_userName+positionY_star+height_star+positionY_userComment, width_userComment, 0)];
        _userCommentLabel.numberOfLines = 0;
        _userCommentLabel.font = [UIFont systemFontOfSize:fontSize];
        _userCommentLabel.backgroundColor = [UIColor clearColor];
        _userCommentLabel.textColor = [UIColor colorWithRed:86/255. green:86/255. blue:86/255. alpha:1];
        [_bgView addSubview:_userCommentLabel];
        
    }
    return self;
}



#pragma mark -
#pragma mark --- 初始化cell
-(void)initWithPoiComment:(PoiComment *)poiComment
{
    if(!poiComment.comment_user || [poiComment.comment_user isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    
    //设置cell评论的高度
    CGRect frame = _userCommentLabel.frame;
    float height_comment = [PoiCommentCell countContentLabelHeightByString:poiComment.comment_user andLength:width_userComment andFontSize:fontSize];
    frame.size.height = height_comment;
    _userCommentLabel.frame = frame;
    
    
    //设置cell背景的高度
    frame = _bgView.frame;
    //frame.size.height = positionY_userIcon+height_userIcon + height_comment;
    if(positionY_userIcon+height_userIcon+positionY_userIcon > positionY_userName+height_userName+positionY_star+height_star+positionY_userComment+height_comment+positionY_userName)
    {
        frame.size.height = positionY_userIcon+height_userIcon+positionY_userIcon;
    }
    else
    {
        frame.size.height = positionY_userName+height_userName+positionY_star+height_star+positionY_userComment+height_comment+positionY_userName;
    }
    _bgView.frame = frame;
    
    
    //用户信息
    [_userImageView setImageWithURL:[NSURL URLWithString:poiComment.str_userImageUrl] placeholderImage:[UIImage imageNamed:@"comment_icon_background"] success:^(UIImage*image){} failure:^(NSError*error){}];
    if(poiComment.name_user && ![poiComment.name_user isKindOfClass:[NSNull class]])
    {
        _userNameLabel.text = poiComment.name_user;
    }
    if(poiComment.comment_user && ![poiComment.comment_user isKindOfClass:[NSNull class]])
    {
        _userCommentLabel.text = poiComment.comment_user;
    }
    
    
    //评论时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *myDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[poiComment.commentTime_user doubleValue]]];
    [dateFormatter release];
    _userCommentTimeLabel.text = myDateStr;

}

-(void)initCommentRateViewByRate:(NSString *)rate
{
    rate = [NSString stringWithFormat:@"%d",[rate intValue]/2];
    
    
    if([rate isEqualToString:@"0"])  //全设为灰色
    {
        return;
    }
    
    
    UIImage *image = [UIImage imageNamed:@"star"];
    UIImage *hollowImage = [UIImage imageNamed:@"hollowstar"];
    
    if([rate isEqualToString:@"1"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = hollowImage;
        self.userCommentRateView3.image = hollowImage;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"2"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = hollowImage;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"3"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = image;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"4"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = image;
        self.userCommentRateView4.image = image;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"5"])  //全设为彩色
    {
        [self setAllRateViewColorful];
    }
}
-(void)initAllRateView
{
    UIImage *hollowImage = [UIImage imageNamed:@"hollowstar"];
    
    self.userCommentRateView1.image = hollowImage;
    self.userCommentRateView2.image = hollowImage;
    self.userCommentRateView3.image = hollowImage;
    self.userCommentRateView4.image = hollowImage;
    self.userCommentRateView5.image = hollowImage;
}
-(void)setAllRateViewColorful
{
    UIImage *image = [UIImage imageNamed:@"star"];
    
    self.userCommentRateView1.image = image;
    self.userCommentRateView2.image = image;
    self.userCommentRateView3.image = image;
    self.userCommentRateView4.image = image;
    self.userCommentRateView5.image = image;
}

-(void)initBorderViewWithHeight:(NSInteger)height
{
    if(_leftLabel)
    {
        [_leftLabel removeFromSuperview];
        [_leftLabel release];
    }
    _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 1, height+1)];
    _leftLabel.backgroundColor = [UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8];
    [self addSubview:_leftLabel];
    
    if(_rightLabel)
    {
        [_rightLabel removeFromSuperview];
        [_rightLabel release];
    }
    _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(311, 0, 1, height+1)];
    _rightLabel.backgroundColor = [UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8];
    [self addSubview:_rightLabel];
    
    if(_bottomLabel)
    {
        [_bottomLabel removeFromSuperview];
        [_bottomLabel release];
    }
    _bottomLabel = [[UIImageView alloc] initWithFrame:CGRectMake(10, height, 300, 1)];
    _bottomLabel.backgroundColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:0.1];
    [self addSubview:_bottomLabel];
    
}
-(void)setBottomLabelColor:(BOOL)showBrokenLine
{
    if(showBrokenLine == 1)
    {
        _bottomLabel.backgroundColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:0.1];
        CGRect frame = _bottomLabel.frame;
        frame.size.width = 300;
        _bottomLabel.frame = frame;
    }
    else
    {
        _bottomLabel.image = nil;
        _bottomLabel.backgroundColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:0.2];
        CGRect frame = _bottomLabel.frame;
        frame.size.height = 2;
        frame.size.width = 301;
        _bottomLabel.frame = frame;
    }
}
-(void)initTopBorderView
{
    if(!_topLabel)
    {
        _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 302, 1)];
    }
    _topLabel.backgroundColor = [UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8];
    [self addSubview:_topLabel];
}
-(void)removeTopBorderView
{
    if(_topLabel)
    {
        [_topLabel removeFromSuperview];
    }
}


#pragma mark -
#pragma mark --- 计算String所占的高度
+(float)countContentLabelHeightByString:(NSString*)content andLength:(float)length andFontSize:(float)font
{
    //CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName_ size:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    
    return sizeToFit.height;
}
+(float)cellHeightWithContent:(NSString *)string
{
    float height = [PoiCommentCell countContentLabelHeightByString:string andLength:width_userComment andFontSize:fontSize];
    
    float height_icon = positionY_userIcon + height_userIcon + positionY_userIcon;
    float height_all = (positionY_userName+height_userName) + (positionY_star+height_star) + (positionY_userComment+height+positionY_userName);
    
    return MAX(height_icon, height_all);
}



#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end

