//
//  WantGo_hasGoneCell.m
//  QYER
//
//  Created by 我去 on 14-5-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "WantGo_hasGoneCell.h"
#import "UIImageView+WebCache.h"
#import "WantGo.h"
#import "MyControl.h"


#define  positionX_background   10
#define  positionY_background   10
#define  height_background      (224+76)/2
#define  width_imageview        290/2
#define  height_imageview       224/2



@implementation WantGo_hasGoneCell
@synthesize imageView_cityPhoto_left = _imageView_cityPhoto_left;
@synthesize label_info_left = _label_info_left;
@synthesize imageView_cityPhoto_right = _imageView_cityPhoto_right;
@synthesize label_info_right = _label_info_right;
@synthesize cityId_left;
@synthesize cityId_right;
@synthesize delegate;

-(void)dealloc
{
    QY_VIEW_RELEASE(_label_cityName_cn_left);
    QY_VIEW_RELEASE(_label_cityName_en_left);
    QY_VIEW_RELEASE(_label_cityName_cn_right);
    QY_VIEW_RELEASE(_label_cityName_en_right);
    
    QY_VIEW_RELEASE(_imageView_cityPhoto_left);
    QY_VIEW_RELEASE(_label_info_left);
    QY_VIEW_RELEASE(_imageView_cityPhoto_right);
    QY_VIEW_RELEASE(_label_info_right);
    QY_VIEW_RELEASE(_backgroundView_left);
    QY_VIEW_RELEASE(_backgroundView_right);
    
    self.delegate = nil;
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _backgroundView_left = [[UIView alloc] initWithFrame:CGRectMake(positionX_background, positionY_background, width_imageview, height_background)];
        _backgroundView_left.backgroundColor = [UIColor clearColor];
        _backgroundView_left.userInteractionEnabled = YES;
        [self addSubview:_backgroundView_left];
        _backgroundView_left.layer.masksToBounds = YES;
        [_backgroundView_left.layer setCornerRadius:2];
        
        _imageView_cityPhoto_left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_imageview)];
        _imageView_cityPhoto_left.backgroundColor = [UIColor clearColor];
        [_backgroundView_left addSubview:_imageView_cityPhoto_left];
        UIImageView *imageView_cityPhoto_left_bac = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, 128/2)];
        imageView_cityPhoto_left_bac.backgroundColor = [UIColor clearColor];
        imageView_cityPhoto_left_bac.image = [UIImage imageNamed:@"mask_"];
        [_backgroundView_left addSubview:imageView_cityPhoto_left_bac];
        [imageView_cityPhoto_left_bac release];
        UIImageView *imegeview = [[UIImageView alloc] initWithFrame:CGRectMake(0, height_background-76/2, width_imageview, 76/2)];
        imegeview.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"bg_"];
        image = [image stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        imegeview.image = image;
        [_backgroundView_left addSubview:imegeview];
        [imegeview release];
        MyControl *control_left = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_background) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [control_left addTarget:self action:@selector(selectLeft) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView_left addSubview:control_left];
        [control_left release];
        
        _label_info_left = [[UILabel alloc] initWithFrame:CGRectMake(0, height_background-76/2, width_imageview, 76/2)];
        _label_info_left.backgroundColor = [UIColor clearColor];
        _label_info_left.font = [UIFont systemFontOfSize:13];
        _label_info_left.textAlignment = NSTextAlignmentCenter;
        _label_info_left.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
        [_backgroundView_left addSubview:_label_info_left];
        _label_cityName_cn_left = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width_imageview-5*2, 20)];
        if(!ios7)
        {
            _label_cityName_cn_left.frame = CGRectMake(5, 5, width_imageview-5*2, 26);
        }
        _label_cityName_cn_left.backgroundColor = [UIColor clearColor];
        _label_cityName_cn_left.textColor = [UIColor whiteColor];
        //_label_cityName_cn_left.font = [UIFont systemFontOfSize:18];
        _label_cityName_cn_left.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
        _label_cityName_cn_left.shadowColor = [UIColor blackColor];
        _label_cityName_cn_left.shadowOffset = CGSizeMake(0, 1);
        [_backgroundView_left addSubview:_label_cityName_cn_left];
        _label_cityName_en_left = [[UILabel alloc] initWithFrame:CGRectMake(5, 5+_label_cityName_cn_left.frame.size.height, width_imageview-5*2, 18)];
        if(!ios7)
        {
            _label_cityName_en_left.frame = CGRectMake(5, _label_cityName_cn_left.frame.size.height, width_imageview-5*2, 18);
        }
        _label_cityName_en_left.backgroundColor = [UIColor clearColor];
        _label_cityName_en_left.textColor = [UIColor whiteColor];
        //_label_cityName_en_left.font = [UIFont systemFontOfSize:14];
        _label_cityName_en_left.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
        [_backgroundView_left addSubview:_label_cityName_en_left];
        _label_cityName_en_left.shadowColor = [UIColor blackColor];
        _label_cityName_en_left.shadowOffset = CGSizeMake(0, 1);
        
        
        
        
        
        _backgroundView_right = [[UIView alloc] initWithFrame:CGRectMake(_backgroundView_left.frame.origin.x+_backgroundView_left.frame.size.width+positionX_background, positionY_background, width_imageview, height_background)];
        _backgroundView_right.backgroundColor = [UIColor whiteColor];
        _backgroundView_right.userInteractionEnabled = YES;
        [self addSubview:_backgroundView_right];
        _backgroundView_right.layer.masksToBounds = YES;
        [_backgroundView_right.layer setCornerRadius:2];
        
        _imageView_cityPhoto_right = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_imageview)];
        _imageView_cityPhoto_right.backgroundColor = [UIColor clearColor];
        [_backgroundView_right addSubview:_imageView_cityPhoto_right];
        UIImageView *imageView_cityPhoto_right_bac = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, 128/2)];
        imageView_cityPhoto_right_bac.backgroundColor = [UIColor clearColor];
        imageView_cityPhoto_right_bac.image = [UIImage imageNamed:@"mask_"];
        [_backgroundView_right addSubview:imageView_cityPhoto_right_bac];
        [imageView_cityPhoto_right_bac release];
        UIImageView *imegeview_2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, height_background-76/2, width_imageview, 76/2)];
        imegeview_2.backgroundColor = [UIColor clearColor];
        imegeview_2.image = image;
        [_backgroundView_right addSubview:imegeview_2];
        [imegeview_2 release];
        MyControl *control_right = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_background) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [control_right addTarget:self action:@selector(selectRight) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView_right addSubview:control_right];
        [control_right release];
        
        _label_info_right = [[UILabel alloc] initWithFrame:CGRectMake(0, height_background-76/2, width_imageview, 76/2)];
        _label_info_right.backgroundColor = [UIColor clearColor];
        _label_info_right.font = [UIFont systemFontOfSize:13];
        _label_info_right.textAlignment = NSTextAlignmentCenter;
        _label_info_right.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
        [_backgroundView_right addSubview:_label_info_right];
        _label_cityName_cn_right = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width_imageview-5*2, 20)];
        if(!ios7)
        {
            _label_cityName_cn_right.frame = CGRectMake(5, 5, width_imageview-5*2, 26);
        }
        _label_cityName_cn_right.backgroundColor = [UIColor clearColor];
        //_label_cityName_cn_right.font = [UIFont systemFontOfSize:18];
        _label_cityName_cn_right.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
        _label_cityName_cn_right.textColor = [UIColor whiteColor];
        [_backgroundView_right addSubview:_label_cityName_cn_right];
        _label_cityName_cn_right.shadowColor = [UIColor blackColor];
        _label_cityName_cn_right.shadowOffset = CGSizeMake(0, 1);
        _label_cityName_en_right = [[UILabel alloc] initWithFrame:CGRectMake(5, 5+_label_cityName_cn_right.frame.size.height, width_imageview-5*2, 18)];
        if(!ios7)
        {
            _label_cityName_en_right.frame = CGRectMake(5, _label_cityName_cn_left.frame.size.height, width_imageview-5*2, 18);
        }
        _label_cityName_en_right.backgroundColor = [UIColor clearColor];
        //_label_cityName_en_right.font = [UIFont systemFontOfSize:14];
        _label_cityName_en_right.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
        _label_cityName_en_right.textColor = [UIColor whiteColor];
        [_backgroundView_right addSubview:_label_cityName_en_right];
        _label_cityName_en_right.shadowColor = [UIColor blackColor];
        _label_cityName_en_right.shadowOffset = CGSizeMake(0, 1);
    }
    return self;
}


-(void)initDataWithWantGoData:(NSArray *)array atIndex:(NSInteger)position type:(NSString *)type
{
    position = position *2;
    
    
    //leftinfo:
    if(array.count > position)
    {
        NSDictionary *dic = [array objectAtIndex:position];
        [_imageView_cityPhoto_left setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"足迹"]];
        if([[dic objectForKey:@"total_gone_poi"] intValue] > 0)
        {
            if(type && [type isEqualToString:@"wantgo"])
            {
                _label_info_left.text = [NSString stringWithFormat:@"%@个想去的景点",[dic objectForKey:@"total_gone_poi"]];
            }
            else if(type && [type isEqualToString:@"hasgone"])
            {
                _label_info_left.text = [NSString stringWithFormat:@"%@个去过的景点",[dic objectForKey:@"total_gone_poi"]];
            }
        }
        else
        {
            if(type && [type isEqualToString:@"wantgo"])
            {
                _label_info_left.text = @"没有想去的景点";
            }
            else if(type && [type isEqualToString:@"hasgone"])
            {
                _label_info_left.text = @"没有去过的景点";
            }
        }
        _label_cityName_cn_left.text = [dic objectForKey:@"city_cn"];
        _label_cityName_en_left.text = [dic objectForKey:@"city_en"];
        self.cityId_left = [[dic objectForKey:@"city_id"] intValue];
    }
    
    
    //rightinfo:
    position = position+1;
    if(array.count > position)
    {
        _backgroundView_right.hidden = NO;
        NSDictionary *dic = [array objectAtIndex:position];
        [_imageView_cityPhoto_right setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"足迹"]];
        if([[dic objectForKey:@"total_gone_poi"] intValue] > 0)
        {
            if(type && [type isEqualToString:@"wantgo"])
            {
                _label_info_right.text = [NSString stringWithFormat:@"%@个想去的景点",[dic objectForKey:@"total_gone_poi"]];
            }
            else if(type && [type isEqualToString:@"hasgone"])
            {
                _label_info_right.text = [NSString stringWithFormat:@"%@个去过的景点",[dic objectForKey:@"total_gone_poi"]];
            }
        }
        else
        {
            if(type && [type isEqualToString:@"wantgo"])
            {
                _label_info_right.text = @"没有想去的景点";
            }
            else if(type && [type isEqualToString:@"hasgone"])
            {
                _label_info_right.text = @"没有去过的景点";
            }
            
        }
        _label_cityName_cn_right.text = [dic objectForKey:@"city_cn"];
        _label_cityName_en_right.text = [dic objectForKey:@"city_en"];
        self.cityId_right = [[dic objectForKey:@"city_id"] intValue];
    }
    else
    {
        _backgroundView_right.hidden = YES;
    }
}


-(void)selectLeft
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedLeftImageViewWithCityId:andCityName:)])
    {
        NSString *cityname = _label_cityName_cn_left.text;
        if(!cityname)
        {
            cityname = _label_cityName_en_left.text;
        }
        [self.delegate selectedLeftImageViewWithCityId:self.cityId_left andCityName:cityname];
    }
}
-(void)selectRight
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedRightImageViewWithCityId:andCityName:)])
    {
        NSString *cityname = _label_cityName_cn_right.text;
        if(!cityname)
        {
            cityname = _label_cityName_en_right.text;
        }
        [self.delegate selectedRightImageViewWithCityId:self.cityId_right andCityName:cityname];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
