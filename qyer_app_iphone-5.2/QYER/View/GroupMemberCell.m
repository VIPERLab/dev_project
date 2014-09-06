//
//  GroupMemberCell.m
//  QYER
//
//  Created by 张伊辉 on 14-5-13.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GroupMemberCell.h"
#import "UIImageView+WebCache.h"
#import "NSDateUtil.h"
@implementation GroupMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        
        backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, UIWidth-20, 125)];
        backImageView.backgroundColor = [UIColor whiteColor];
        backImageView.layer.cornerRadius = 5.0;
        backImageView.layer.masksToBounds = YES;
        [self addSubview:backImageView];
        [backImageView release];
        
        logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 48, 48)];
        logoImageView.layer.cornerRadius = 24.0;
        logoImageView.layer.masksToBounds = YES;
        logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        logoImageView.clipsToBounds = YES;
        [backImageView addSubview:logoImageView];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10, 13, 225, 20)];
        lblName.text = @"寒冰射手";
        lblName.textAlignment = NSTextAlignmentLeft;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.textColor = RGB(68, 68, 68);
        lblName.font = [UIFont fontWithName:Default_Font size:15.0];
        [backImageView addSubview:lblName];
        [lblName release];
        
        lblDistance = [[UILabel alloc]initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10, 40, 225, 20)];
        lblDistance.textAlignment = NSTextAlignmentLeft;
        lblDistance.font = [UIFont fontWithName:Default_Font size:12.0];
        lblDistance.text = @"0.06km 1小时前";
        lblDistance.backgroundColor = [UIColor clearColor];
        lblDistance.textColor = RGB(158, 163, 171);
        [backImageView addSubview:lblDistance];
        [lblDistance release];
        
//        sexBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10, lblName.frame.origin.y+lblName.frame.size.height+10, 44, 18)];
//        sexBackImageView.image = [UIImage imageNamed:@"g_bg_female"];
//        [backImageView addSubview:sexBackImageView];
//        [sexBackImageView release];
//        
        
        sexImageView = [[UIImageView alloc]initWithFrame:CGRectMake(45, 45, 13, 13)];
        [backImageView addSubview:sexImageView];
        [sexImageView release];
        
//        lblAge = [[UILabel alloc]initWithFrame:CGRectMake(16, 2, 23, 14)];
//        lblAge.textAlignment = NSTextAlignmentRight;
//        lblAge.font = [UIFont fontWithName:Default_Font size:9.0];
//        lblAge.text = @"88岁";
//        lblAge.textColor = [UIColor whiteColor];
//        lblAge.backgroundColor = [UIColor clearColor];
//        [sexBackImageView addSubview:lblAge];
//        [lblAge release];
        
        lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, logoImageView.frame.size.height + logoImageView.frame.origin.y+10, backImageView.frame.size.width-10, 0.5)];
        lineImageView.backgroundColor = RGB(224, 224, 224);
        [backImageView addSubview:lineImageView];
        [lineImageView release];
        
        lblManyPlace = [[UILabel alloc]initWithFrame:CGRectMake(10, lineImageView.frame.origin.y+lineImageView.frame.size.height + 10, backImageView.frame.size.width-20, 18)];
        lblManyPlace.textAlignment = NSTextAlignmentLeft;
        lblManyPlace.font = [UIFont fontWithName:Default_Font size:14.0];
        lblManyPlace.text = @"你和Ta共同去过14个城市";
        lblManyPlace.textColor = RGB(68, 68, 68);
        lblManyPlace.backgroundColor = [UIColor clearColor];
        [backImageView addSubview:lblManyPlace];
        [lblManyPlace release];
        
        lblPlace = [[UILabel alloc]initWithFrame:CGRectMake(10, lblManyPlace.frame.origin.y+lblManyPlace.frame.size.height + 5, backImageView.frame.size.width-20, 18)];
        lblPlace.textAlignment = NSTextAlignmentLeft;
        lblPlace.font = [UIFont fontWithName:Default_Font size:14.0];
        lblPlace.text = @"";
        lblPlace.textColor = RGB(68, 68, 68);
        lblPlace.backgroundColor = [UIColor clearColor];
        [backImageView addSubview:lblPlace];
        [lblPlace release];
        
        if (!IS_IOS7) {
            lblName.frame = CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10, 13, 225, 24);
            lblManyPlace.frame = CGRectMake(10, lineImageView.frame.origin.y+lineImageView.frame.size.height + 10, backImageView.frame.size.width-20, 22);
            lblPlace.frame = CGRectMake(10, lblManyPlace.frame.origin.y+lblManyPlace.frame.size.height + 5, backImageView.frame.size.width-20, 22);
            
        }
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

/**
  *  刷新UI
  *
  *  @param fOjbect 好友对象
  */
-(void)updateUIWithFriend:(GroupMember *)gOjbect{
    
    
    [logoImageView setImageWithURL:[NSURL URLWithString:gOjbect.avatar] placeholderImage:[UIImage imageNamed:@"default_ls_back"]];
    lblName.text = gOjbect.username;
    
    NSDate *todate = [NSDate dateWithTimeIntervalSince1970:[gOjbect.updated_time floatValue]];

    if (gOjbect.lat == 0 || gOjbect.lon == 0) {
        
        lblDistance.text = [NSString stringWithFormat:@"位置未知  %@",[NSDateUtil  formatDate:todate]];
        
    }else{
        
        lblDistance.text = [NSString stringWithFormat:@"%.2fkm  %@",gOjbect.distance/1000,[NSDateUtil  formatDate:todate]];

    }
    
    
//    lblTime.text = gOjbect.updated_time;
    if (gOjbect.gender == 1) {
        
//        sexBackImageView.image = [UIImage imageNamed:@"g_bg_male"];
        sexImageView.image = [UIImage imageNamed:@"new_male"];
        
    }else if(gOjbect.gender == 2){
        
//        sexBackImageView.image = [UIImage imageNamed:@"g_bg_female"];
        sexImageView.image = [UIImage imageNamed:@"new_famale"];
    }else{
        
        sexImageView.image = nil;
    }
    lblManyPlace.text =  [NSString stringWithFormat:@"你和Ta共同去过%d个城市",gOjbect.total_together_city];
    lblPlace.text = gOjbect.together_city;
    
//    lblAge.text = [NSString stringWithFormat:@"%d岁",gOjbect.age];
    
    
    NSString *imUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid_im"];
    if ([imUserId isEqualToString:gOjbect.im_user_id]) {
        NSString *title = [[NSUserDefaults standardUserDefaults] objectForKey:@"title"];
        lblDistance.text = title;
        lblDistance.hidden = NO;
        lblManyPlace.hidden = YES;
        lblPlace.hidden = YES;
        lineImageView.hidden = YES;
        backImageView.frame = CGRectMake(10, 10,UIWidth-20, 70);
        
        
    }else{
        
        BOOL isHidden = (gOjbect.total_together_city == 0);
        
        lblPlace.hidden = isHidden;
        lblManyPlace.hidden = isHidden;
        lineImageView.hidden = isHidden;
        lblDistance.hidden = NO;
        backImageView.frame = CGRectMake(10, 10,UIWidth-20, isHidden ? 70 : 125);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
