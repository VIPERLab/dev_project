//
//  MyFriendsCell.m
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MyFriendsCell.h"
#import "Friends.h"
#import "UIImageView+WebCache.h"

#define  positionX              10
#define  positionY              10
#define  width_useravatar       98/2
#define  positionX_username     10   //用户名和用户头像之间的间隔
#define  positionY_username     15
#define  width_usergender       26/2
#define  positionX_usertrak     5    //用户足迹和用户性别头像之间的间隔





@implementation MyFriendsCell
@synthesize user_id;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor whiteColor];
        
        _imageView_user = [[UIImageView alloc] initWithFrame:CGRectMake(positionX, positionY, width_useravatar, width_useravatar)];
        _imageView_user.userInteractionEnabled = YES;
        _imageView_user.backgroundColor = [UIColor clearColor];
        _imageView_user.layer.masksToBounds = YES;
        [_imageView_user.layer setCornerRadius:24];
        [self addSubview:_imageView_user];
        
        
        _label_userName = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_user.frame.origin.x+_imageView_user.frame.size.width+positionX_username, positionY_username, 220, 16)];
        _label_userName.backgroundColor = [UIColor clearColor];
        _label_userName.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        _label_userName.font = [UIFont systemFontOfSize:15];
        [self addSubview:_label_userName];
        
        
        _imageView_gender = [[UIImageView alloc] initWithFrame:CGRectMake(_label_userName.frame.origin.x, _label_userName.frame.origin.y+_label_userName.frame.size.height+12, width_usergender, width_usergender)];
        _imageView_gender.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_gender];
        
        
        _label_track = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_gender.frame.origin.x+_imageView_gender.frame.size.width+positionX_usertrak, _imageView_gender.frame.origin.y, 220, 14)];
        _label_track.font = [UIFont systemFontOfSize:13];
        _label_track.backgroundColor = [UIColor clearColor];
        _label_track.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
        [self addSubview:_label_track];
        
        
        _imageView_bothFollow = [[UIImageView alloc] initWithFrame:CGRectMake(320-48/2-12/2, 10, 48/2, 48/2)];
        _imageView_bothFollow.backgroundColor = [UIColor clearColor];
        _imageView_bothFollow.image = [UIImage imageNamed:@"following icon"];
        [self addSubview:_imageView_bothFollow];
        
        
        
        UIImageView *imageView_bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 138/2-0.5, 310, 1)];
        imageView_bottomLine.backgroundColor = [UIColor clearColor];
        imageView_bottomLine.image = [UIImage imageNamed:@"分割线_"];
        [self addSubview:imageView_bottomLine];
        [imageView_bottomLine release];
    }
    return self;
}

-(void)initInfoWithUserData:(NSArray *)array atPosition:(NSInteger)position
{
    if(array.count <= position)
    {
        return;
    }
    
    Friends *friend_ = [array objectAtIndex:position];
    self.user_id = friend_.user_id;
    
    NSLog(@"friend_.avatar:%@",friend_.avatar);
    [_imageView_user setImageWithURL:[NSURL URLWithString:friend_.avatar] placeholderImage:[UIImage imageNamed:@""]];
    _label_userName.text = friend_.username;
    _imageView_gender.hidden = NO;
    _label_track.frame = CGRectMake(_imageView_gender.frame.origin.x+_imageView_gender.frame.size.width+positionX_usertrak, _imageView_gender.frame.origin.y, 220, 14);
    switch (friend_.gender)
    {
        case 1:
        {
            _imageView_gender.image = [UIImage imageNamed:@"male"];
        }
            break;
        case 2:
        {
            _imageView_gender.image = [UIImage imageNamed:@"famale"];
        }
            break;
            
        default:
        {
            _imageView_gender.hidden = YES;
            CGRect frame = _label_track.frame;
            frame.origin.x = _imageView_gender.frame.origin.x;
            _label_track.frame = frame;
        }
            break;
    }
    _label_track.text = [NSString stringWithFormat:@"去过%d个国家，%d个城市",friend_.countries,friend_.cities];
    
    
    if(friend_.both_follow)
    {
        _imageView_bothFollow.hidden = NO;
    }
    else
    {
        _imageView_bothFollow.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
