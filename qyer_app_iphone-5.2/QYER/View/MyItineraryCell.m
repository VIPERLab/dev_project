//
//  MyItineraryCell.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-10.
//
//

#import "MyItineraryCell.h"
#import "UserItinerary.h"
#import "UIImageView+WebCache.h"
#import "Plan.h"
#import "QyYhConst.h"

#define     positionX_imageviewBackground       10
#define     positionY_imageviewBackground       10
#define     height_imageviewBackground          394/2.
#define     height_imageView_itinerary          300/2.
#define     positionX_imageView_itinerary       0
#define     positionY_imageView_itinerary       0
#define     positionY_days                      10
#define     days_interval_right                 10
#define     Days_width                          100/2
#define     Days_height                         100/2
#define     positionX_imageView_user            10
#define     positionY_imageView_user            100




@implementation MyItineraryCell
@synthesize label_userName = _label_userName;
@synthesize label_days = _label_days;
@synthesize label_itineraryName = _label_itineraryName;
@synthesize label_updateTime = _label_updateTime;
@synthesize imageView_itinerary = _imageView_itinerary;
@synthesize label_verticalLine = _label_verticalLine;
@synthesize imageView_lastCell = _imageView_lastCell;
@synthesize imageView_background = _imageView_background;
@synthesize label_itineraryPath = _label_itineraryPath;
@synthesize imageView_user = _imageView_user;
@synthesize back_click_view = _back_click_view;


-(void)dealloc
{
    self.label_userName = nil;
    self.label_days = nil;
    self.label_itineraryName = nil;
    self.label_updateTime = nil;
    self.label_verticalLine = nil;
    self.imageView_lastCell = nil;
    self.imageView_background = nil;
    self.label_itineraryPath = nil;
    self.imageView_user = nil;
    self.back_click_view = nil;
    [_view_background removeFromSuperview];
    [_view_background release];
    
    QY_VIEW_RELEASE(_view_bg);
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _view_bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_imageviewBackground)];
        _view_bg.backgroundColor = [UIColor whiteColor];
        [self addSubview:_view_bg];
        
        UIImageView *bottomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(7.5, positionY_imageView_itinerary+height_imageView_itinerary+10,305, 41)];
        bottomImageView.backgroundColor = [UIColor clearColor];
        bottomImageView.image = [UIImage imageNamed:@"cell_ls_bottom"];
        [self addSubview:bottomImageView];
        [bottomImageView release];
        
        _imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_imageviewBackground, positionY_imageviewBackground, 320-positionX_imageviewBackground*2, height_imageviewBackground-positionY_imageviewBackground)];
        _imageView_background.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_background];

        _view_background = [[UIView alloc] initWithFrame:CGRectMake(1, 0, _imageView_background.frame.size.width-2, _imageView_background.frame.size.height)];
        _view_background.backgroundColor = [UIColor clearColor];
        [_imageView_background addSubview:_view_background];
        
        
        _imageView_itinerary = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_imageView_itinerary, positionY_imageView_itinerary, 320-positionY_imageviewBackground*2, height_imageView_itinerary)];
        _imageView_itinerary.backgroundColor = [UIColor clearColor];
        [_imageView_background addSubview:_imageView_itinerary];
        _imageView_itinerary.contentMode = UIViewContentModeScaleAspectFill;
        _imageView_itinerary.clipsToBounds = YES;
        
        _shadeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _imageView_itinerary.frame.size.height-100, 300, 100)];
        _shadeImageView.image = [UIImage imageNamed:@"shade_list"];
        [_imageView_itinerary addSubview:_shadeImageView];
        [_shadeImageView release];
        
        /*
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(positionX_imageView_itinerary, positionY_imageView_itinerary+height_imageView_itinerary, _imageView_itinerary.frame.size.width, height_imageviewBackground-(positionY_imageView_itinerary+height_imageView_itinerary))];
        label.backgroundColor = [UIColor redColor];
        label.tag = 88;
        [_imageView_background addSubview:label];
        [label release];
        */
//
        
        
        
        
        UIImageView *imageView_days = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView_itinerary.frame.size.width-Days_width-days_interval_right, positionY_days, Days_width, Days_height)];
        imageView_days.backgroundColor = [UIColor clearColor];
        imageView_days.image = [UIImage imageNamed:@"bg_days"];
        _label_days = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imageView_days.frame.size.width, imageView_days.frame.size.height)];
        _label_days.font = [UIFont systemFontOfSize:18];
        _label_days.textColor = [UIColor whiteColor];
        _label_days.adjustsFontSizeToFitWidth = YES;
        _label_days.textAlignment = NSTextAlignmentCenter;
        _label_days.backgroundColor = [UIColor clearColor];
        [imageView_days addSubview:_label_days];
        [_imageView_itinerary addSubview:imageView_days];
        [imageView_days release];
        
        
        
        _imageView_user = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_imageView_user, positionY_imageView_user, 80/2, 80/2)];
        _imageView_user.backgroundColor = [UIColor clearColor];
        _imageView_user.layer.masksToBounds = YES;
        [_imageView_user.layer setCornerRadius:20];
        [_imageView_user.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_imageView_user.layer setBorderWidth:1];
        [_imageView_itinerary addSubview:_imageView_user];
        
        
        
        _label_itineraryName = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_user.frame.origin.x+_imageView_user.frame.size.width+10, positionY_imageView_user, 260, 18)];
        _label_itineraryName.backgroundColor = [UIColor clearColor];
        _label_itineraryName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _label_itineraryName.textColor = [UIColor whiteColor];
        [_imageView_itinerary addSubview:_label_itineraryName];
        
        
        
        
        _label_userName = [[UILabel alloc] initWithFrame:CGRectMake(_label_itineraryName.frame.origin.x, _label_itineraryName.frame.origin.y +_label_itineraryName.frame.size.height+6, 200, 16)];
        _label_userName.backgroundColor = [UIColor clearColor];
        _label_userName.font = [UIFont systemFontOfSize:12];
        _label_userName.textColor = [UIColor whiteColor];
        [_imageView_itinerary addSubview:_label_userName];
        
        
        /**
         *  文字加投影
         */
        [_label_itineraryName setShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.50f]];
        [_label_itineraryName setShadowOffset:CGSizeMake(0, 1)];
        
        [_label_userName setShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.50f]];
        [_label_userName setShadowOffset:CGSizeMake(0, 1)];
        
        
        _label_city = [[UILabel alloc] initWithFrame:CGRectMake(positionX_imageView_itinerary, _imageView_itinerary.frame.origin.x+_imageView_itinerary.frame.size.height+12, 30, 16)];
        _label_city.backgroundColor = [UIColor clearColor];
        _label_city.text = @"路线";//chang by yihui
        _label_city.textColor = [UIColor blackColor];
        _label_city.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:15];
        [_imageView_background addSubview:_label_city];
        
        
        
        _label_itineraryPath = [[UILabel alloc] initWithFrame:CGRectMake(_label_city.frame.origin.x+_label_city.frame.size.width+10, _label_city.frame.origin.y, 260, 16)];
        _label_itineraryPath.backgroundColor = [UIColor clearColor];
        _label_itineraryPath.font = [UIFont systemFontOfSize:15];
        _label_itineraryPath.textColor = [UIColor colorWithRed:44/255. green:44/255. blue:44/255. alpha:1];
        [_imageView_background addSubview:_label_itineraryPath];
        
        
        
        
        
        _label_verticalLine = [[UILabel alloc] initWithFrame:CGRectMake(-10, height_imageviewBackground-positionY_imageviewBackground-1, 320, .5)];
        _label_verticalLine.backgroundColor = [UIColor colorWithRed:205/255. green:205/255. blue:205/255. alpha:1];
        [_imageView_background addSubview:_label_verticalLine];
        
        _back_click_view = [[UIView alloc]initWithFrame:CGRectMake(_imageView_background.frame.origin.x, _imageView_background.frame.origin.y, _imageView_background.frame.size.width, _imageView_background.frame.size.height+2)];
        _back_click_view.backgroundColor = [UIColor blackColor];
        _back_click_view.layer.cornerRadius = 5.0;
        _back_click_view.layer.masksToBounds = YES;
        _back_click_view.alpha = 0.1;
        _back_click_view.hidden = YES;
        [self addSubview:_back_click_view];
        
    }
    return self;
}
-(void)initMyPlanContentAtPosition:(NSInteger)position WithArray:(NSArray *)array //我的行程
{
    [self resetMyPlanCell];
    
    UserItinerary *itinerary = (UserItinerary *)[array objectAtIndex:position];
    [self.imageView_itinerary setImageWithURL:[NSURL URLWithString:itinerary.itineraryImageLink] placeholderImage:[UIImage imageNamed:@"default_plan_back"]];
    self.label_itineraryName.text = itinerary.itineraryPlannerName;
    self.label_days.text = [NSString stringWithFormat:@"%@天",itinerary.itineraryDays];
    self.label_itineraryPath.text = itinerary.itineraryPath_desc;
}
-(void)resetMyPlanCell //我的行程
{
    _imageView_background.layer.masksToBounds = YES;
    [_imageView_background.layer setCornerRadius:2];
    _imageView_user.hidden = YES;
    _label_verticalLine.hidden = YES;
    _view_bg.hidden = YES;
    
    
    
    _label_itineraryName.frame = CGRectMake(_imageView_itinerary.frame.origin.x+10, _imageView_itinerary.frame.size.height-16-10, 260, 18);
    
    if (!IS_IOS7) {
        
        _label_itineraryName.frame = CGRectMake(_imageView_itinerary.frame.origin.x+10, _imageView_itinerary.frame.size.height-16-10, 260, 23);
        
    }
    
    _label_city.frame = CGRectMake(positionX_imageView_itinerary, _imageView_itinerary.frame.origin.x+_imageView_itinerary.frame.size.height+12, 30, 16);
    _label_city.hidden = YES;
    
    _label_itineraryPath.frame = CGRectMake(_label_city.frame.origin.x+_label_city.frame.size.width+10-30, _label_city.frame.origin.y, 280, 16);
}

-(void)initContentAtPosition:(NSInteger)position WithArray:(NSArray *)array //推荐行程
{
    [self resetCell];
    
    UserItinerary *itinerary = (UserItinerary *)[array objectAtIndex:position];
    [self.imageView_itinerary setImageWithURL:[NSURL URLWithString:itinerary.itineraryImageLink] placeholderImage:[UIImage imageNamed:@"default_plan_back"]];
    
    self.label_itineraryName.text = itinerary.itineraryPlannerName;
    self.label_days.text = [NSString stringWithFormat:@"%@天",itinerary.itineraryDays];
    self.label_itineraryPath.text = itinerary.itineraryPath_desc;
    self.label_userName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *icon_user = [[NSUserDefaults standardUserDefaults] objectForKey:@"usericon"];
    [self.imageView_user setImageWithURL:[NSURL URLWithString:icon_user] placeholderImage:nil];
}

-(void)resetCell //推荐行程
{
    _imageView_background.layer.masksToBounds = YES;
    [_imageView_background.layer setCornerRadius:5];
    _imageView_user.hidden = NO;
    _label_verticalLine.hidden = YES;
    _view_bg.hidden = YES;
    
    _label_itineraryName.frame = CGRectMake(_imageView_user.frame.origin.x+_imageView_user.frame.size.width+10, positionY_imageView_user, 240, 18);
    if (!IS_IOS7) {
        _label_itineraryName.frame = CGRectMake(_imageView_user.frame.origin.x+_imageView_user.frame.size.width+10, positionY_imageView_user, 240, 23);
    }
    
    _label_city.frame = CGRectMake(positionX_imageView_itinerary, _imageView_itinerary.frame.origin.y+_imageView_itinerary.frame.size.height+10, 30, 16);
    _label_city.hidden = YES;
    
    
    _label_itineraryPath.frame = CGRectMake(_label_city.frame.origin.x+_label_city.frame.size.width+10-30, _label_city.frame.origin.y, 280, 16);
    
}


-(void)updateCell:(NSDictionary *)planData{
    
    [self resetCell];
    
    if ([planData objectForKey:@"photo"] != nil && [[planData objectForKey:@"photo"] isKindOfClass:[NSString class]]) {
        NSString * imgURL           = [planData objectForKey:@"photo"];
        [self.imageView_itinerary setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed:@"default_plan_back"]];
    }
    
    if ([planData objectForKey:@"subject"] != nil && [[planData objectForKey:@"subject"] isKindOfClass:[NSString class]]) {
        NSString * itineraryName    = [planData objectForKey:@"subject"];
        self.label_itineraryName.text = itineraryName;
    }
    
    if ([planData objectForKey:@"day_count"] != nil && [[planData objectForKey:@"day_count"] isKindOfClass:[NSString class]]) {
        NSString * days             = [planData objectForKey:@"day_count"];
        self.label_days.text = [NSString stringWithFormat:@"%@天",days];
    }
    
    if ([planData objectForKey:@"username"] != nil && [[planData objectForKey:@"username"] isKindOfClass:[NSString class]]) {
        NSString * userName         = [planData objectForKey:@"username"];
        self.label_userName.text = userName;
    }
    
    if ([planData objectForKey:@"route"] != nil && [[planData objectForKey:@"route"] isKindOfClass:[NSString class]]) {
        NSString * itineraryPath    = [planData objectForKey:@"route"];
        self.label_itineraryPath.text = itineraryPath;
    }
    
    if ([planData objectForKey:@"avatar"] != nil && [[planData objectForKey:@"avatar"] isKindOfClass:[NSString class]]) {
        NSString * avatar = [planData objectForKey:@"avatar"];
        [self.imageView_user setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:nil];
    }
    
}


#pragma mark -
#pragma mark --- 计算String所占的高度/宽度
-(float)countWidthByString:(NSString*)content andFount:font andHeight:(float)height
{
    CGSize sizeToFit = [content sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)];
    return sizeToFit.width;
}
-(float)countHeightByString:(NSString*)content andFount:font andWidth:(float)width
{
    CGSize sizeToFit = [content sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
    return sizeToFit.height;
}



/*
#pragma mark -
#pragma mark --- setHighlighted
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted)
    {
        _view_background.backgroundColor = [UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3];
    }
    else
    {
        [self performSelector:@selector(resetColor) withObject:nil afterDelay:0.15];
    }
}
-(void)resetColor
{
    _view_background.backgroundColor = [UIColor clearColor];
}
*/

#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted == NO) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _back_click_view.hidden = YES;
            
        });
        
    }else{
        _back_click_view.hidden = NO;
    }
}

@end
