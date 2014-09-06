//
//  WantGo_hasGoneCitiesCell.m
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "WantGo_hasGoneCitiesCell.h"
#import "UIImageView+WebCache.h"
#import "MyControl.h"


#define  positionX_background   10
#define  positionY_background   10
#define  height_background      (224+134)/2
#define  height_background_     274/2
#define  width_imageview        290/2
#define  height_imageview       224/2
#define  positionX_star         5
#define  positionY_star         5



@implementation WantGo_hasGoneCitiesCell
@synthesize label_rate_left = _label_rate_left;
@synthesize label_rate_right = _label_rate_right;
@synthesize imageView_poiPhoto_left = _imageView_poiPhoto_left;
@synthesize label_reviewinfo_left = _label_reviewinfo_left;
@synthesize imageView_poiPhoto_right = _imageView_poiPhoto_right;
@synthesize label_reviewinfo_right = _label_reviewinfo_right;
@synthesize label_noRate_left = _label_noRate_left;
@synthesize label_noRate_right = _label_noRate_right;
@synthesize poiId_left;
@synthesize poiId_right;
@synthesize flag_type;

-(void)dealloc
{
    QY_VIEW_RELEASE(_label_poiName_cn_left);
    QY_VIEW_RELEASE(_label_poiName_en_left);
    QY_VIEW_RELEASE(_label_poiName_cn_right);
    QY_VIEW_RELEASE(_label_poiName_en_right);
    QY_VIEW_RELEASE(_label_rate_left);
    QY_VIEW_RELEASE(_label_rate_right);
    
    QY_VIEW_RELEASE(_label_noRate_left);
    QY_VIEW_RELEASE(_label_noRate_right);
    QY_VIEW_RELEASE(_imageView_poiPhoto_left);
    QY_VIEW_RELEASE(_label_reviewinfo_left);
    QY_VIEW_RELEASE(_imageView_poiPhoto_right);
    QY_VIEW_RELEASE(_label_reviewinfo_right);
    QY_VIEW_RELEASE(_backgroundView_left);
    QY_VIEW_RELEASE(_backgroundView_right);
    
    self.delegate = nil;
    
    [super dealloc];
}


-(id)initHasGoneWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andType:(BOOL)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        /*
            type: yes   自己的想去
            type: no    Ta的想去
         */
        
        
        
        self.flag_type = type;
        self.backgroundColor = [UIColor clearColor];
        
        
        _backgroundView_left = [[UIView alloc] initWithFrame:CGRectMake(positionX_background, positionY_background, width_imageview, height_background)];
        _backgroundView_left.backgroundColor = [UIColor whiteColor];
        _backgroundView_left.userInteractionEnabled = YES;
        [self addSubview:_backgroundView_left];
        _backgroundView_left.layer.masksToBounds = YES;
        [_backgroundView_left.layer setCornerRadius:2];
        
        
        _imageView_poiPhoto_left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_imageview)];
        _imageView_poiPhoto_left.backgroundColor = [UIColor clearColor];
        [_backgroundView_left addSubview:_imageView_poiPhoto_left];
        
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
        _label_reviewinfo_left = [[UILabel alloc] initWithFrame:CGRectMake(positionX_star, height_background-84/2, width_imageview-positionX_star*2, 84/2)];
        _label_reviewinfo_left.numberOfLines = 2;
        _label_reviewinfo_left.backgroundColor = [UIColor clearColor];
        _label_reviewinfo_left.font = [UIFont systemFontOfSize:13];
        _label_reviewinfo_left.textAlignment = NSTextAlignmentLeft;
        _label_reviewinfo_left.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [_backgroundView_left addSubview:_label_reviewinfo_left];
        
        
        if(type)
        {
            MyControl *control_left = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_imageview) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
            [control_left addTarget:self action:@selector(selectLeft) forControlEvents:UIControlEventTouchUpInside];
            [_backgroundView_left addSubview:control_left];
            [control_left release];
            control_poicomment_left = [[MyControl alloc] initWithFrame:CGRectMake(0, height_background-84/2, width_imageview, 84/2) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
            [control_poicomment_left addTarget:self action:@selector(updateCommentLeft:) forControlEvents:UIControlEventTouchUpInside];
            control_poicomment_left.backgroundColor = [UIColor clearColor];
            [_backgroundView_left addSubview:control_poicomment_left];
        }
        else
        {
            MyControl *control_left = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_background) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
            [control_left addTarget:self action:@selector(selectLeft) forControlEvents:UIControlEventTouchUpInside];
            [_backgroundView_left addSubview:control_left];
            [control_left release];
        }
        
        
        _label_poiName_cn_left = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width_imageview-10, 20)];
        _label_poiName_cn_left.backgroundColor = [UIColor clearColor];
        _label_poiName_cn_left.textColor = [UIColor whiteColor];
        _label_poiName_cn_left.font = [UIFont systemFontOfSize:18];
        [_backgroundView_left addSubview:_label_poiName_cn_left];
        _label_poiName_cn_left.shadowColor = [UIColor blackColor];
        _label_poiName_cn_left.shadowOffset = CGSizeMake(0, 1);
        _label_poiName_en_left = [[UILabel alloc] initWithFrame:CGRectMake(5, 5+_label_poiName_cn_left.frame.size.height, width_imageview-10, 18)];
        _label_poiName_en_left.backgroundColor = [UIColor clearColor];
        _label_poiName_en_left.textColor = [UIColor whiteColor];
        _label_poiName_en_left.font = [UIFont systemFontOfSize:14];
        [_backgroundView_left addSubview:_label_poiName_en_left];
        _label_poiName_en_left.shadowColor = [UIColor blackColor];
        _label_poiName_en_left.shadowOffset = CGSizeMake(0, 1);
        
        _button_comment_left = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_comment_left.frame = CGRectMake(56/2, height_imageview+40/2, 180/2, 54/2);
        _button_comment_left.backgroundColor = [UIColor clearColor];
        [_button_comment_left setBackgroundImage:[UIImage imageNamed:@"add comment"] forState:UIControlStateNormal];
        [_button_comment_left addTarget:self action:@selector(addCommentLeft) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView_left addSubview:_button_comment_left];
        _button_comment_left.hidden = YES;
        
        _label_rate_left = [[UILabel alloc] initWithFrame:CGRectMake(_backgroundView_left.frame.size.width-50-5, height_background-84/2, height_background_-20, 20)];
        _label_rate_left.backgroundColor = [UIColor clearColor];
        _label_rate_left.font = [UIFont systemFontOfSize:13];
        _label_rate_left.textAlignment = NSTextAlignmentRight;
        _label_rate_left.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [_backgroundView_left addSubview:_label_rate_left];
        
        _label_noRate_left = [[UILabel alloc] initWithFrame:CGRectMake(56/2-20, height_imageview+40/2, 180/2+40, 54/2)];
        _label_noRate_left.backgroundColor = [UIColor clearColor];
        _label_noRate_left.text = @"Ta去过但没添加点评";
        _label_noRate_left.textAlignment = NSTextAlignmentCenter;
        _label_noRate_left.font = [UIFont systemFontOfSize:14];
        _label_noRate_left.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [_backgroundView_left addSubview:_label_noRate_left];
        
        
        
        
        
        
        _backgroundView_right = [[UIView alloc] initWithFrame:CGRectMake(_backgroundView_left.frame.origin.x+_backgroundView_left.frame.size.width+positionX_background, positionY_background, width_imageview, height_background)];
        _backgroundView_right.backgroundColor = [UIColor whiteColor];
        _backgroundView_right.userInteractionEnabled = YES;
        [self addSubview:_backgroundView_right];
        _backgroundView_right.layer.masksToBounds = YES;
        [_backgroundView_right.layer setCornerRadius:2];
        
        _imageView_poiPhoto_right = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_imageview)];
        _imageView_poiPhoto_right.backgroundColor = [UIColor clearColor];
        [_backgroundView_right addSubview:_imageView_poiPhoto_right];
        
        UIImageView *imageView_cityPhoto_right_bac = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, 128/2)];
        imageView_cityPhoto_right_bac.backgroundColor = [UIColor clearColor];
        imageView_cityPhoto_right_bac.image = [UIImage imageNamed:@"mask_"];
        [_backgroundView_right addSubview:imageView_cityPhoto_right_bac];
        [imageView_cityPhoto_right_bac release];
        UIImageView *imegeview_2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, height_background-76/2, width_imageview, 76/2)];
        imegeview_2.backgroundColor = [UIColor clearColor];
        image = [UIImage imageNamed:@"bg_"];
        image = [image stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        imegeview_2.image = image;
        [_backgroundView_right addSubview:imegeview_2];
        [imegeview_2 release];
        _label_reviewinfo_right = [[UILabel alloc] initWithFrame:CGRectMake(positionX_star, height_background-84/2, width_imageview-positionX_star*2, 84/2)];
        _label_reviewinfo_right.numberOfLines = 2;
        _label_reviewinfo_right.backgroundColor = [UIColor clearColor];
        _label_reviewinfo_right.font = [UIFont systemFontOfSize:13];
        _label_reviewinfo_right.textAlignment = NSTextAlignmentLeft;
        _label_reviewinfo_right.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [_backgroundView_right addSubview:_label_reviewinfo_right];
        
        
        if(type)
        {
            MyControl *control_right = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_imageview) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
            [control_right addTarget:self action:@selector(selectRight) forControlEvents:UIControlEventTouchUpInside];
            [_backgroundView_right addSubview:control_right];
            [control_right release];
            control_poicomment_right = [[MyControl alloc] initWithFrame:CGRectMake(0, height_background-84/2, width_imageview, 84/2) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
            [control_poicomment_right addTarget:self action:@selector(updateCommentRight:) forControlEvents:UIControlEventTouchUpInside];
            control_poicomment_right.backgroundColor = [UIColor clearColor];
            [_backgroundView_right addSubview:control_poicomment_right];
        }
        else
        {
            MyControl *control_right = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_background) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
            [control_right addTarget:self action:@selector(selectRight) forControlEvents:UIControlEventTouchUpInside];
            [_backgroundView_right addSubview:control_right];
            [control_right release];
        }
        
        
        _label_poiName_cn_right = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width_imageview-10, 20)];
        _label_poiName_cn_right.backgroundColor = [UIColor clearColor];
        _label_poiName_cn_right.font = [UIFont systemFontOfSize:18];
        _label_poiName_cn_right.textColor = [UIColor whiteColor];
        [_backgroundView_right addSubview:_label_poiName_cn_right];
        _label_poiName_cn_right.shadowColor = [UIColor blackColor];
        _label_poiName_cn_right.shadowOffset = CGSizeMake(0, 1);
        
        _label_poiName_en_right = [[UILabel alloc] initWithFrame:CGRectMake(5, 5+_label_poiName_cn_right.frame.size.height, width_imageview-10, 18)];
        _label_poiName_en_right.backgroundColor = [UIColor clearColor];
        _label_poiName_en_right.font = [UIFont systemFontOfSize:14];
        _label_poiName_en_right.textColor = [UIColor whiteColor];
        [_backgroundView_right addSubview:_label_poiName_en_right];
        _label_poiName_en_right.shadowColor = [UIColor blackColor];
        _label_poiName_en_right.shadowOffset = CGSizeMake(0, 1);
        
        _button_comment_right = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_comment_right.frame = CGRectMake(56/2, height_imageview+40/2, 180/2, 54/2);
        _button_comment_right.backgroundColor = [UIColor clearColor];
        [_button_comment_right setBackgroundImage:[UIImage imageNamed:@"add comment"] forState:UIControlStateNormal];
        [_button_comment_right addTarget:self action:@selector(addCommentRight) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView_right addSubview:_button_comment_right];
        _button_comment_right.hidden = YES;
        
        _label_rate_right = [[UILabel alloc] initWithFrame:CGRectMake(_backgroundView_right.frame.size.width-50-5, height_background-84/2, 50, 20)];
        _label_rate_right.backgroundColor = [UIColor clearColor];
        _label_rate_right.font = [UIFont systemFontOfSize:13];
        _label_rate_right.textAlignment = NSTextAlignmentRight;
        _label_rate_right.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [_backgroundView_right addSubview:_label_rate_right];
        
        _label_noRate_right = [[UILabel alloc] initWithFrame:CGRectMake(56/2-20, height_imageview+40/2, 180/2+40, 54/2)];
        _label_noRate_right.backgroundColor = [UIColor clearColor];
        _label_noRate_right.text =  @"Ta去过但没添加点评";
        _label_noRate_right.textAlignment = NSTextAlignmentCenter;
        _label_noRate_right.font = [UIFont systemFontOfSize:14];
        _label_noRate_right.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [_backgroundView_right addSubview:_label_noRate_right];
        
    }
    return self;
}
-(id)initWantGoWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _backgroundView_left = [[UIView alloc] initWithFrame:CGRectMake(positionX_background, positionY_background, width_imageview, height_background_)];
        _backgroundView_left.backgroundColor = [UIColor whiteColor];
        _backgroundView_left.userInteractionEnabled = YES;
        [self addSubview:_backgroundView_left];
        _backgroundView_left.layer.masksToBounds = YES;
        [_backgroundView_left.layer setCornerRadius:2];
        MyControl *control_left = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_background_) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [control_left addTarget:self action:@selector(selectLeft) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView_left addSubview:control_left];
        [control_left release];
        
        
        _imageView_poiPhoto_left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_imageview)];
        _imageView_poiPhoto_left.backgroundColor = [UIColor clearColor];
        [_backgroundView_left addSubview:_imageView_poiPhoto_left];
        UIImageView *imageView_cityPhoto_left_bac = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, 128/2)];
        imageView_cityPhoto_left_bac.backgroundColor = [UIColor clearColor];
        imageView_cityPhoto_left_bac.image = [UIImage imageNamed:@"mask_"];
        [_backgroundView_left addSubview:imageView_cityPhoto_left_bac];
        [imageView_cityPhoto_left_bac release];
        
        
        _label_poiName_cn_left = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width_imageview, 20)];
        if(!ios7)
        {
            _label_poiName_cn_left.frame = CGRectMake(5, 5, width_imageview, 26);
        }
        _label_poiName_cn_left.backgroundColor = [UIColor clearColor];
        _label_poiName_cn_left.textColor = [UIColor whiteColor];
        _label_poiName_cn_left.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
        _label_poiName_cn_left.shadowColor = [UIColor blackColor];
        _label_poiName_cn_left.shadowOffset = CGSizeMake(0, 1);
        [_backgroundView_left addSubview:_label_poiName_cn_left];
        _label_poiName_en_left = [[UILabel alloc] initWithFrame:CGRectMake(5, 5+_label_poiName_cn_left.frame.size.height, width_imageview, 18)];
        if(!ios7)
        {
            _label_poiName_en_left.frame = CGRectMake(5, _label_poiName_cn_left.frame.size.height, width_imageview, 18);
        }
        _label_poiName_en_left.backgroundColor = [UIColor clearColor];
        _label_poiName_en_left.textColor = [UIColor whiteColor];
        _label_poiName_en_left.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
        _label_poiName_en_left.shadowColor = [UIColor blackColor];
        _label_poiName_en_left.shadowOffset = CGSizeMake(0, 1);
        [_backgroundView_left addSubview:_label_poiName_en_left];
        
        
        _label_rate_left = [[UILabel alloc] initWithFrame:CGRectMake(_backgroundView_left.frame.size.width-60-5, _backgroundView_left.frame.size.height-20-2, 60, 20)];
        _label_rate_left.backgroundColor = [UIColor clearColor];
        _label_rate_left.font = [UIFont systemFontOfSize:13];
        _label_rate_left.textAlignment = NSTextAlignmentRight;
        _label_rate_left.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
        [_backgroundView_left addSubview:_label_rate_left];
        
        
        
        
        _backgroundView_right = [[UIView alloc] initWithFrame:CGRectMake(_backgroundView_left.frame.origin.x+_backgroundView_left.frame.size.width+positionX_background, positionY_background, width_imageview, height_background_)];
        _backgroundView_right.backgroundColor = [UIColor whiteColor];
        _backgroundView_right.userInteractionEnabled = YES;
        [self addSubview:_backgroundView_right];
        _backgroundView_right.layer.masksToBounds = YES;
        [_backgroundView_right.layer setCornerRadius:2];
        MyControl *control_right = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_background_) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [control_right addTarget:self action:@selector(selectRight) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView_right addSubview:control_right];
        [control_right release];
        
        _imageView_poiPhoto_right = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, height_imageview)];
        _imageView_poiPhoto_right.backgroundColor = [UIColor clearColor];
        [_backgroundView_right addSubview:_imageView_poiPhoto_right];
        UIImageView *imageView_cityPhoto_right_bac = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_imageview, 128/2)];
        imageView_cityPhoto_right_bac.backgroundColor = [UIColor clearColor];
        imageView_cityPhoto_right_bac.image = [UIImage imageNamed:@"mask_"];
        [_backgroundView_right addSubview:imageView_cityPhoto_right_bac];
        [imageView_cityPhoto_right_bac release];
        
        
        _label_poiName_cn_right = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width_imageview, 20)];
        if(!ios7)
        {
            _label_poiName_cn_right.frame = CGRectMake(5, 5, width_imageview, 26);
        }
        _label_poiName_cn_right.backgroundColor = [UIColor clearColor];
        //_label_poiName_cn_right.font = [UIFont systemFontOfSize:18];
        _label_poiName_cn_right.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
        _label_poiName_cn_right.textColor = [UIColor whiteColor];
        _label_poiName_cn_right.shadowColor = [UIColor blackColor];
        _label_poiName_cn_right.shadowOffset = CGSizeMake(0, 1);
        [_backgroundView_right addSubview:_label_poiName_cn_right];
        _label_poiName_en_right = [[UILabel alloc] initWithFrame:CGRectMake(5, 5+_label_poiName_cn_right.frame.size.height, width_imageview, 18)];
        if(!ios7)
        {
            _label_poiName_en_right.frame = CGRectMake(5, _label_poiName_cn_left.frame.size.height, width_imageview, 18);
        }
        _label_poiName_en_right.backgroundColor = [UIColor clearColor];
        //_label_poiName_en_right.font = [UIFont systemFontOfSize:14];
        _label_poiName_en_right.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
        _label_poiName_en_right.textColor = [UIColor whiteColor];
        _label_poiName_en_right.shadowColor = [UIColor blackColor];
        _label_poiName_en_right.shadowOffset = CGSizeMake(0, 1);
        [_backgroundView_right addSubview:_label_poiName_en_right];
        
        
        _label_rate_right = [[UILabel alloc] initWithFrame:CGRectMake(_backgroundView_right.frame.size.width-60-5, _backgroundView_right.frame.size.height-20-2, 60, 20)];
        _label_rate_right.backgroundColor = [UIColor clearColor];
        _label_rate_right.font = [UIFont systemFontOfSize:13];
        _label_rate_right.textAlignment = NSTextAlignmentRight;
        _label_rate_right.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
        [_backgroundView_right addSubview:_label_rate_right];
        
    }
    return self;
}

-(void)initLeftStarWithRate:(NSString *)rate_str
{
    NSInteger rate = [rate_str intValue];
    float rate_f = rate/2.;
    
    if(!self.flag_type)
    {
        rate = rate/2;
    }
    
    for(int i = 0; i < rate; i++)
    {
        NSInteger width = 30/2; //高和宽相等
        NSInteger x = positionX_star + i*width;
        NSInteger y = _imageView_poiPhoto_left.frame.origin.y  + _imageView_poiPhoto_left.frame.size.height + positionY_star;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"poi_collorstar"];
        [_backgroundView_left addSubview:imageView];
        imageView.tag = 100 + i;
        [imageView release];
        
    }
    if(rate < 5)
    {
        BOOL flag = NO;
        if(rate_f - rate - 0.5 == 0)
        {
            flag = YES;
        }
        
        for(int i = rate; i < 5; i++)
        {
            if(flag)
            {
                flag = NO;
                NSInteger width = 30/2; //高和宽相等
                NSInteger x = positionX_star + i*width;
                NSInteger y = _imageView_poiPhoto_left.frame.origin.y + _imageView_poiPhoto_left.frame.size.height + positionY_star;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                imageView.backgroundColor = [UIColor clearColor];
                imageView.image = [UIImage imageNamed:@"poi_halfstar"];
                [_backgroundView_left addSubview:imageView];
                imageView.tag = 100 + i;
                [imageView release];
            }
            else
            {
                NSInteger width = 30/2; //高和宽相等
                NSInteger x = positionX_star + i*width;
                NSInteger y = _imageView_poiPhoto_left.frame.origin.y + _imageView_poiPhoto_left.frame.size.height + positionY_star;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                imageView.backgroundColor = [UIColor clearColor];
                imageView.image = [UIImage imageNamed:@"poi_hollowstar"];
                [_backgroundView_left addSubview:imageView];
                imageView.tag = 100 + i;
                [imageView release];
            }
        }
    }
}
-(void)initRightStarWithRate:(NSString *)rate_str
{
    NSInteger rate = [rate_str intValue];
    float rate_f = rate/2.;
    
    if(!self.flag_type)
    {
        rate = rate/2;
    }
    
    for(int i = 0; i < rate; i++)
    {
        NSInteger width = 30/2; //高和宽相等
        NSInteger x = positionX_star + i*width;
        NSInteger y = _imageView_poiPhoto_right.frame.origin.y + _imageView_poiPhoto_right.frame.size.height + positionY_star;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"poi_collorstar"];
        [_backgroundView_right addSubview:imageView];
        imageView.tag = 200 + i;
        [imageView release];
    }
    if(rate < 5)
    {
        BOOL flag = NO;
        if(rate_f - rate - 0.5 == 0)
        {
            flag = YES;
        }
        
        
        for(int i = rate; i < 5; i++)
        {
            if(flag)
            {
                flag = NO;
                NSInteger width = 30/2; //高和宽相等
                NSInteger x = positionX_star + i*width;
                NSInteger y = _imageView_poiPhoto_right.frame.origin.y + _imageView_poiPhoto_right.frame.size.height + positionY_star;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                imageView.backgroundColor = [UIColor clearColor];
                imageView.image = [UIImage imageNamed:@"poi_halfstar"];
                [_backgroundView_right addSubview:imageView];
                imageView.tag = 200 + i;
                [imageView release];
            }
            else
            {
                NSInteger width = 30/2; //高和宽相等
                NSInteger x = positionX_star + i*width;
                NSInteger y = _imageView_poiPhoto_right.frame.origin.y + _imageView_poiPhoto_right.frame.size.height + positionY_star;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                imageView.backgroundColor = [UIColor clearColor];
                imageView.image = [UIImage imageNamed:@"poi_hollowstar"];
                [_backgroundView_right addSubview:imageView];
                imageView.tag = 200 + i;
                [imageView release];
            }
        }
    }
}
-(void)restartStar
{
    for(int i = 0; i < 5; i++)
    {
        UIView *view_1 = [_backgroundView_left viewWithTag:100+i];
        UIView *view_2 = [_backgroundView_right viewWithTag:200+i];
        
        if(view_1)
        {
            [view_1 removeFromSuperview];
        }
        if(view_2)
        {
            [view_2 removeFromSuperview];
        }
    }
}

-(void)initDataWithArray:(NSArray *)array atIndex:(NSInteger)position withType:(NSString *)type isMinInfo:(BOOL)flag
{
    position = position *2;
    
    
    [self restartStar];
    
    self.poiId_left = 0;
    self.poiId_right = 0;
    _button_comment_left.hidden = YES;
    _button_comment_right.hidden = YES;
    _label_rate_left.hidden = YES;
    _label_rate_right.hidden = YES;
    _label_noRate_left.hidden = YES;
    _label_noRate_right.hidden = YES;
    
    
    //leftinfo:
    if(array.count > position)
    {
        NSDictionary *dic = [array objectAtIndex:position];
        NSString *url = [dic objectForKey:@"photo"];
        [_imageView_poiPhoto_left setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"足迹"]];
        if(type && [type isEqualToString:@"wantgo"])
        {
            _label_reviewinfo_left.text = @"";
            [self initLeftStarWithRate:[dic objectForKey:@"my_review_ranking"]];
            _label_rate_left.hidden = NO;
            if([[dic objectForKey:@"my_review_ranking"] intValue] > 0)
            {
                _label_rate_left.text = [NSString stringWithFormat:@"%@分",[dic objectForKey:@"my_review_ranking"]];
            }
            else
            {
                _label_rate_left.text = @"暂无评分";
            }
        }
        else if(type && [type isEqualToString:@"hasgone"])
        {
            NSString *my_reivew = [dic objectForKey:@"my_reivew"];
            if(my_reivew && my_reivew.length > 0)
            {
                _label_reviewinfo_left.text = my_reivew;
                control_poicomment_left.info = [NSDictionary dictionaryWithObjectsAndKeys:my_reivew, @"review", [dic objectForKey:@"str_poiid"], @"poiid", [dic objectForKey:@"comment_id"], @"comment_id", [dic objectForKey:@"my_review_ranking"],@"rate", nil];
                [self initLeftStarWithRate:[dic objectForKey:@"my_review_ranking"]];
            }
            else
            {
                if(flag) //个人中心
                {
                    _label_reviewinfo_left.text = @"";
                    _button_comment_left.hidden = NO;
                }
                else
                {
                    _label_reviewinfo_left.text = @"";
                    _button_comment_left.hidden = YES;
                    _label_noRate_left.hidden = NO;
                }
            }
        }
        _label_poiName_cn_left.text = [dic objectForKey:@"poi_cn"];
        _label_poiName_en_left.text = [dic objectForKey:@"poi_en"];
        self.poiId_left = [[dic objectForKey:@"str_poiid"] intValue];
    }
    
    
    //rightinfo:
    position = position + 1;
    if(array.count > position)
    {
        _backgroundView_right.hidden = NO;
        
        NSDictionary *dic = [array objectAtIndex:position];
        NSString *url = [dic objectForKey:@"photo"];
        [_imageView_poiPhoto_right setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"足迹"]];
        if(type && [type isEqualToString:@"wantgo"])
        {
            _label_reviewinfo_left.text = @"";
            [self initRightStarWithRate:[dic objectForKey:@"my_review_ranking"]];
            _label_rate_right.hidden = NO;
            if([[dic objectForKey:@"my_review_ranking"] intValue] > 0)
            {
                _label_rate_right.text = [NSString stringWithFormat:@"%@分",[dic objectForKey:@"my_review_ranking"]];
            }
            else
            {
                _label_rate_right.text = @"暂无评分";
            }
        }
        else if(type && [type isEqualToString:@"hasgone"])
        {
            NSString *my_reivew = [dic objectForKey:@"my_reivew"];
            if(my_reivew && my_reivew.length > 0)
            {
                _label_reviewinfo_right.text = [dic objectForKey:@"my_reivew"];
                control_poicomment_right.info = [NSDictionary dictionaryWithObjectsAndKeys:my_reivew, @"review", [dic objectForKey:@"str_poiid"], @"poiid", [dic objectForKey:@"comment_id"], @"comment_id", [dic objectForKey:@"my_review_ranking"], @"rate", nil];
                [self initRightStarWithRate:[dic objectForKey:@"my_review_ranking"]];
            }
            else
            {
                if(flag) //个人中心
                {
                    _label_reviewinfo_right.text = @"";
                    _button_comment_right.hidden = NO;
                }
                else
                {
                    _label_reviewinfo_right.text = @"";
                    _button_comment_right.hidden = YES;
                    _label_noRate_right.hidden = NO;
                }
            }
        }
        _label_poiName_cn_right.text = [dic objectForKey:@"poi_cn"];
        _label_poiName_en_right.text = [dic objectForKey:@"poi_en"];
        self.poiId_right = [[dic objectForKey:@"str_poiid"] intValue];
    }
    else
    {
        _backgroundView_right.hidden = YES;
    }
}

-(void)selectLeft
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedLeftImageViewWithPoiId:)])
    {
        [self.delegate selectedLeftImageViewWithPoiId:self.poiId_left];
    }
}
-(void)selectRight
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedRightImageViewWithPoiId:)])
    {
        [self.delegate selectedRightImageViewWithPoiId:self.poiId_right];
    }
}
-(void)addCommentLeft
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(addCommentLeft:)])
    {
        [self.delegate addCommentLeft:self];
    }
}
-(void)updateCommentLeft:(id)sender
{
    MyControl *control = (MyControl *)sender;
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateCommentLeft:)])
    {
        [self.delegate updateCommentLeft:control];
    }
}
-(void)addCommentRight
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(addCommentRight:)])
    {
        [self.delegate addCommentRight:self];
    }
}
-(void)updateCommentRight:(id)sender
{
    MyControl *control = (MyControl *)sender;
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateCommentRight:)])
    {
        [self.delegate updateCommentRight:control];
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

