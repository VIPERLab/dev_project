//
//  UserMapCell.m
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserMapCell.h"
#import "UserInfo.h"
#import "MyControl.h"
#import "UserMap.h"
#import "UIImageView+WebCache.h"
#import "RegexKitLite.h"


#define positionY               height_imageView_map
#define positionX_labelGone     10
#define positionY_labelGone     (ios7 ? 10 : 13)


@implementation UserMapCell
@synthesize view_background = _view_background;
@synthesize label_gone = _label_gone;
@synthesize label_country = _label_country;
@synthesize label_city = _label_city;
@synthesize label_poi = _label_poi;
@synthesize imageView_map = _imageView_map;
@synthesize label_city_type = _label_city_type;
@synthesize label_country_type = _label_country_type;
@synthesize label_poi_type = _label_poi_type;
@synthesize control = _control;
@synthesize delegate;

-(void)dealloc
{
    QY_VIEW_RELEASE(_control);
    QY_VIEW_RELEASE(_label_poi_type);
    QY_VIEW_RELEASE(_label_city_type);
    QY_VIEW_RELEASE(_label_country_type);
    QY_VIEW_RELEASE(_label_poi);
    QY_VIEW_RELEASE(_label_city);
    QY_VIEW_RELEASE(_label_country);
    QY_VIEW_RELEASE(_label_gone);
    QY_VIEW_RELEASE(_imageView_map);
    QY_VIEW_RELEASE(_view_background);
    
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        _view_background = [[UIView alloc] initWithFrame:CGRectMake(0, positionY, 320, 51)];
        _view_background.backgroundColor = [UIColor whiteColor];
        _view_background.userInteractionEnabled = YES;
        [self addSubview:_view_background];
        
        
        _label_gone = [[UILabel alloc] initWithFrame:CGRectMake(positionX_labelGone, positionY_labelGone, 66, _view_background.frame.size.height-10*2)];
        _label_gone.backgroundColor = [UIColor clearColor];
        _label_gone.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        _label_gone.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        [_view_background addSubview:_label_gone];
        _label_gone.text = @"TA的足迹";
        
        
        _label_country = [[UILabel alloc] initWithFrame:CGRectMake(_label_gone.frame.origin.x+_label_gone.frame.size.width+8, 14, 40, _view_background.frame.size.height-14*2)];
        _label_country.backgroundColor = [UIColor clearColor];
        _label_country.font = [UIFont systemFontOfSize:24];
        _label_country.textColor = [UIColor colorWithRed:249/255. green:115/255. blue:115/255. alpha:1];
        [_view_background addSubview:_label_country];
        _label_country.textAlignment = NSTextAlignmentRight;
        _label_country_type = [[UILabel alloc] initWithFrame:CGRectMake(_label_country.frame.origin.x+_label_country.frame.size.width, _label_country.frame.origin.y+4, 24, 20)];
        _label_country_type.backgroundColor = [UIColor clearColor];
        _label_country_type.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
        _label_country_type.font = [UIFont systemFontOfSize:12];
        _label_country_type.text = @"国家";
        [_view_background addSubview:_label_country_type];
        
        
        _label_city = [[UILabel alloc] initWithFrame:CGRectMake(_label_country_type.frame.origin.x+_label_country_type.frame.size.width, 14, 42, _view_background.frame.size.height-14*2)];
        _label_city.backgroundColor = [UIColor clearColor];
        _label_city.font = [UIFont systemFontOfSize:24];
        _label_city.textColor = [UIColor colorWithRed:249/255. green:115/255. blue:115/255. alpha:1];
        [_view_background addSubview:_label_city];
        _label_city.textAlignment = NSTextAlignmentRight;
        _label_city_type = [[UILabel alloc] initWithFrame:CGRectMake(_label_city.frame.origin.x+_label_city.frame.size.width, _label_city.frame.origin.y+4, 24, 20)];
        _label_city_type.backgroundColor = [UIColor clearColor];
        _label_city_type.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
        _label_city_type.font = [UIFont systemFontOfSize:12];
        _label_city_type.text = @"城市";
        [_view_background addSubview:_label_city_type];
        
        
        _label_poi = [[UILabel alloc] initWithFrame:CGRectMake(_label_city_type.frame.origin.x+_label_city_type.frame.size.width, 14, 42, _view_background.frame.size.height-14*2)];
        _label_poi.backgroundColor = [UIColor clearColor];
        _label_poi.font = [UIFont systemFontOfSize:24];
        _label_poi.textColor = [UIColor colorWithRed:249/255. green:115/255. blue:115/255. alpha:1];
        [_view_background addSubview:_label_poi];
        _label_poi.textAlignment = NSTextAlignmentRight;
        _label_poi_type = [[UILabel alloc] initWithFrame:CGRectMake(_label_poi.frame.origin.x+_label_poi.frame.size.width, _label_poi.frame.origin.y+4, 24, 20)];
        _label_poi_type.backgroundColor = [UIColor clearColor];
        _label_poi_type.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
        _label_poi_type.font = [UIFont systemFontOfSize:12];
        _label_poi_type.text = @"景点";
        [_view_background addSubview:_label_poi_type];
        
        
        
        UIImageView *imageView_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(320-48/2-8, (_view_background.frame.size.height-48/2)/2, 48/2, 48/2)];
        imageView_arrow.backgroundColor = [UIColor clearColor];
        imageView_arrow.image = [UIImage imageNamed:@"arrow"];
        [_view_background addSubview:imageView_arrow];
        [imageView_arrow release];
        
        
        
        
        _imageView_map = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_imageView_map)];
        _imageView_map.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_map];
        
        
        
        _control = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, 320, height_imageView_map+51) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        _control.backgroundColor = [UIColor clearColor];
        [_control addTarget:self action:@selector(selectedUserMap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_control];
        
        
        
        
        UIImageView *imageView_bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, _view_background.bounds.size.height-0.5, 310, 1)];
        imageView_bottomLine.backgroundColor = [UIColor clearColor];
        imageView_bottomLine.image = [UIImage imageNamed:@"分割线_"];
        [_view_background addSubview:imageView_bottomLine];
        [imageView_bottomLine release];
        
    }
    return self;
}

-(void)initWithNotLogin
{
    _label_gone.text = @"我的足迹";
    [_imageView_map setImage:[UIImage imageNamed:@"map"]];
    _label_country.text = nil;
    _label_city.text = nil;
    _label_poi.text = nil;
    _control.backgroundColor = [UIColor clearColor];
    _label_country_type.hidden = YES;
    _label_city_type.hidden = YES;
    _label_poi_type.hidden = YES;
}

-(void)initInfoWithUserData:(UserInfo *)userinfo mine:(BOOL)flag
{
    _label_country_type.hidden = NO;
    _label_city_type.hidden = NO;
    _label_poi_type.hidden = NO;
    _control.backgroundColor = [UIColor clearColor];
    
    
    if(flag)
    {
        _label_gone.text = @"我的足迹";
    }
    else
    {
        _label_gone.text = @"TA的足迹";
    }
    
    if(userinfo.countries < 10)
    {
        _label_country.text = [NSString stringWithFormat:@"0%d",userinfo.countries];
    }
    else
    {
        _label_country.text = [NSString stringWithFormat:@"%d",userinfo.countries];
    }
    if(userinfo.cities < 10)
    {
        _label_city.text = [NSString stringWithFormat:@"0%d",userinfo.cities];
    }
    else
    {
        _label_city.text = [NSString stringWithFormat:@"%d",userinfo.cities];
    }
    if(userinfo.pois < 10)
    {
        _label_poi.text = [NSString stringWithFormat:@"0%d",userinfo.pois];
    }
    else
    {
        _label_poi.text = [NSString stringWithFormat:@"%d",userinfo.pois];
    }
    
    [self processUserMapWithUserInfo:userinfo];
}

-(void)processUserMapWithUserInfo:(UserInfo *)userinfo
{
    NSString *url = [NSString stringWithFormat:@"%@&width=1080&height=587&client_id=%@&client_secret=%@&%d",userinfo.footprint,ClientId_QY,ClientSecret_QY,userinfo.countries];
    NSLog(@"userinfo.footprint url : %@",url);
    [_imageView_map setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"map"]];
}



#pragma mark -
#pragma mark --- UserMapCell - Delegate
-(void)selectedUserMap
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedUserFootprint)])
    {
        [self.delegate selectedUserFootprint];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
