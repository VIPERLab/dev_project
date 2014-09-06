//
//  MoreSettingCell.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-8-28.
//
//

#import "MoreSettingCell.h"
#import "UIImageView+WebCache.h"
#import "MyMoreControl.h"
#import "QYMoreApp.h"
#import "MobClick.h"
#import "Reachability.h"
#import "Toast+UIView.h"



#define     positionX_imageView_label_nameBackGround        8
#define     height_imageView_label_nameBackGround           45
#define     positionX_titlelabel                            8
#define     positionY_titlelabel                            13
#define     positionX_usernamelabel                         85
#define     positionY_usernamelabel                         14
#define     width_usernamelabel                             190
#define     positionX_imageView_arrow                       280



@implementation MoreSettingCell
@synthesize imageView_label_nameBackGround = _imageView_label_nameBackGround;
@synthesize label_titleName = _label_titleName;
@synthesize label_userName = _label_userName;
@synthesize imageView_arrow = _imageView_arrow;
@synthesize imageView_lastCell = _imageView_lastCell;
@synthesize switch_download = _switch_download;
@synthesize view_backGroundColor = _view_backGroundColor;
@synthesize flag_noBackGroundColor = _flag_noBackGroundColor;

-(void)dealloc
{
    self.imageView_label_nameBackGround = nil;
    self.label_titleName = nil;
    self.label_userName = nil;
    self.imageView_lastCell = nil;
    self.imageView_arrow = nil;
    self.switch_download = nil;
    self.view_backGroundColor = nil;
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _imageView_label_nameBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_imageView_label_nameBackGround, 0, 320-positionX_imageView_label_nameBackGround*2, height_imageView_label_nameBackGround)];
        _imageView_label_nameBackGround.userInteractionEnabled = YES;
        _imageView_label_nameBackGround.backgroundColor = [UIColor clearColor];
        _imageView_label_nameBackGround.image = [UIImage imageNamed:@"更多设置_列表背景_高90"];
        [self addSubview:_imageView_label_nameBackGround];
        
        
        _view_backGroundColor = [[UIView alloc] initWithFrame:CGRectMake(1.5, 0, _imageView_label_nameBackGround.frame.size.width-3, _imageView_label_nameBackGround.frame.size.height)];
        _view_backGroundColor.backgroundColor = [UIColor clearColor];
        [_imageView_label_nameBackGround addSubview:_view_backGroundColor];
        
        
        _label_titleName = [[UILabel alloc] initWithFrame:CGRectMake(positionX_titlelabel, positionY_titlelabel, 320-positionX_titlelabel*2 - positionX_imageView_label_nameBackGround*2, 30)];
        if([[[UIDevice currentDevice] systemVersion] floatValue] - 7. >= 0)
        {
            _label_titleName.frame = CGRectMake(positionX_titlelabel, positionY_titlelabel-5, 320-positionX_titlelabel*2 - positionX_imageView_label_nameBackGround*2, 30);
        }
        _label_titleName.backgroundColor = [UIColor clearColor];
        _label_titleName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _label_titleName.textColor = [UIColor blackColor];
        [_imageView_label_nameBackGround addSubview:_label_titleName];
        
        
        _label_userName = [[UILabel alloc] initWithFrame:CGRectMake(positionX_usernamelabel, positionY_usernamelabel, width_usernamelabel, 20)];
        if([[[UIDevice currentDevice] systemVersion] floatValue] - 7. >= 0)
        {
            _label_userName.frame = CGRectMake(positionX_usernamelabel, positionY_usernamelabel-2, width_usernamelabel, 20);
        }
        _label_userName.backgroundColor = [UIColor clearColor];
        _label_userName.adjustsFontSizeToFitWidth = YES;
        _label_userName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
        _label_userName.textColor = [UIColor colorWithRed:150/255. green:150/255. blue:150/255. alpha:1];
        _label_userName.textAlignment = NSTextAlignmentRight;
        [_imageView_label_nameBackGround addSubview:_label_userName];
        
        
        _imageView_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_imageView_arrow, 13, 20, 20)];
        _imageView_arrow.backgroundColor = [UIColor clearColor];
        _imageView_arrow.image = [UIImage imageNamed:@"箭头"];
        [_imageView_label_nameBackGround addSubview:_imageView_arrow];
        
        
        _imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, height_imageView_label_nameBackGround, 320 - positionX_imageView_label_nameBackGround*2, 2)];
        _imageView_lastCell.alpha = 0;
        _imageView_lastCell.backgroundColor = [UIColor clearColor];
        _imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影"];
        [_imageView_label_nameBackGround addSubview:_imageView_lastCell];
        
        
        
        _switch_download = [[UISwitch alloc] init]; //WithFrame:CGRectMake(225, 8, 79, 27)];
        _switch_download.frame = CGRectMake(320 - _switch_download.frame.size.width - 22, 9, _switch_download.frame.size.width, _switch_download.frame.size.height);
        if([[[UIDevice currentDevice] systemVersion] floatValue] - 7. >= 0)
        {
            _switch_download.frame = CGRectMake(320 - _switch_download.frame.size.width - 22, 7, _switch_download.frame.size.width, _switch_download.frame.size.height);
        }
        _switch_download.alpha = 0;
        _switch_download.on = YES;
        [_switch_download addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
        if(![[NSUserDefaults standardUserDefaults] objectForKey:@"WIFISwitch"])
        {
            _switch_download.on = NO;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WIFISwitch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:@"WIFISwitch"];
            _switch_download.on = value;
        }
        [_imageView_label_nameBackGround addSubview:_switch_download];
        
    }
    
    return self;
}

-(void)setAppWithArray:(NSArray *)_applicationArray
{
    NSUInteger line = 0;
    if([_applicationArray count]%4 == 0)
    {
        line = [_applicationArray count]/4;
    }
    else
    {
        line = [_applicationArray count]/4 + 1;
    }
    float height = 88*line + 10;
    CGRect frame = self.imageView_label_nameBackGround.frame;
    frame.size.height = height;
    self.imageView_label_nameBackGround.frame = frame;
    self.imageView_label_nameBackGround.image = nil;
    self.imageView_label_nameBackGround.image = [[UIImage imageNamed:@"更多设置_列表背景_高90"]  stretchableImageWithLeftCapWidth:5 topCapHeight:2];
    
    for(int i = 0; i < [_applicationArray count];i++)
    {
        NSInteger xa = 10+(60+15)*(i%4);
        NSInteger ya = 10+(28+60)*(i/4);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xa, ya, 60, 60)];
        [imageView setUserInteractionEnabled:YES];
        [imageView setImageWithURL:[NSURL URLWithString:[[_applicationArray objectAtIndex:i] appPicUrl]]];
        [self.imageView_label_nameBackGround addSubview:imageView];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y + imageView.frame.size.height + 4, imageView.frame.size.width, 20)];
        label.text = [[_applicationArray objectAtIndex:i] appName];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        label.textAlignment = NSTextAlignmentCenter;
        [self.imageView_label_nameBackGround addSubview:label];
        [label release];
        
        MyMoreControl *control = [[MyMoreControl alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        control.url = [[_applicationArray objectAtIndex:i] appAppStoreURL];
        control.appName = [[_applicationArray objectAtIndex:i] appName];
        [imageView addSubview:control];
        [control addTarget:self action:@selector(doTurnToAppStore:) forControlEvents:UIControlEventTouchUpInside];
        [control setBackgroundColor:[UIColor clearColor]];
        [control release];
        [imageView release];
        
    }
}


-(void)doTurnToAppStore:(id)sender
{
    MyMoreControl *control = (MyMoreControl *)sender;
    NSString *str = control.url;
    
    
    //跳转到应用在itunes里的上线地址
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.superview hideToast];
        [self.superview makeToast:@"貌似网络有点不好，检查一下吧..." duration:1 position:@"center" isShadow:NO];
        
        return;
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}


- (void)switchValueChange:(id)sender
{
    if([_switch_download isOn])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WIFISwitch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WIFISwitch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}



- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
{
    [super setHighlighted:highlighted animated:animated];
    
    // Configure the view for the selected state
    
    if(self.flag_noBackGroundColor == 1) //cell没有点击背景
    {
        self.view_backGroundColor.backgroundColor = [UIColor clearColor];
        return;
    }
    
    if(highlighted == YES)
    {
        self.view_backGroundColor.backgroundColor = [UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3];
    }
    else
    {
        self.view_backGroundColor.backgroundColor = [UIColor clearColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
