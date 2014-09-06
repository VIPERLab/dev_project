//
//  PrivateChatCell.m
//  QYER
//
//  Created by 张伊辉 on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PrivateChatCell.h"
#import "UIImageView+WebCache.h"
#import "NSDateUtil.h"
@implementation PrivateChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 64)];
        backImageView.backgroundColor = [UIColor whiteColor];
        backImageView.layer.cornerRadius = 5.0;
        backImageView.layer.masksToBounds = YES;
        [self addSubview:backImageView];
        [backImageView release];
        
        logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 48, 48)];
        logoImageView.layer.cornerRadius = 24.0;
        logoImageView.layer.masksToBounds = YES;
        logoImageView.image = [UIImage imageNamed:@"80icon"];
        [backImageView addSubview:logoImageView];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10, 15, 125, 15)];
        lblName.text = @"寒冰射手:";
        lblName.backgroundColor = [UIColor clearColor];
        lblName.textColor = RGB(68, 68, 68);
        lblName.font = [UIFont fontWithName:Default_Font size:13.0];
        [backImageView addSubview:lblName];
        [lblName release];
        
        lblTime = [[UILabel alloc]initWithFrame:CGRectMake(180, 16, backImageView.frame.size.width-190, 12)];
        lblTime.textAlignment = NSTextAlignmentRight;
        lblTime.font = [UIFont fontWithName:Default_Font size:12.0];
        lblTime.text = @"3月5日";
        lblTime.textColor = RGB(158, 163, 171);
        lblTime.backgroundColor = [UIColor clearColor];
        [backImageView addSubview:lblTime];
        [lblTime release];
        
        lblContent = [[UILabel alloc]initWithFrame:CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y+lblName.frame.size.height+12, 200, 18)];
        lblContent.textAlignment = NSTextAlignmentLeft;
        lblContent.backgroundColor = [UIColor clearColor];
        lblContent.font = [UIFont fontWithName:Default_Font size:13.0];
        lblContent.text = @"我一会就泰国了，你到哪里等我一会。";
        lblContent.textColor = RGB(158, 163, 171);
        [backImageView addSubview:lblContent];
        [lblContent release];
        
        
        lblNewMsgNum = [[UILabel alloc]initWithFrame:CGRectMake(45, 5, 20, 20)];
        lblNewMsgNum.textAlignment = NSTextAlignmentCenter;
        lblNewMsgNum.font = [UIFont fontWithName:Default_Font size:8.0];
        lblNewMsgNum.text = @"20";
        lblNewMsgNum.layer.cornerRadius = 10.0;
        lblNewMsgNum.layer.masksToBounds = YES;
        lblNewMsgNum.textColor = [UIColor whiteColor];
        lblNewMsgNum.backgroundColor = [UIColor redColor];
        [backImageView addSubview:lblNewMsgNum];
        [lblNewMsgNum release];
        
        lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 63.5, backImageView.frame.size.width-10, 0.5)];
        lineImageView.backgroundColor = RGB(224, 224, 224);
        [backImageView addSubview:lineImageView];
        [lineImageView release];
        
     
        if (!IS_IOS7) {
            lblName.frame = CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10, 15, 125, 20);
            lblTime.frame = CGRectMake(180, 16, backImageView.frame.size.width-190, 18);
            lblContent.frame = CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y+lblName.frame.size.height+8, 200, 20);
            
        }
    }
    return self;
}
-(void)updateUIWith:(PrivateChat *)chatItem{
    

    
    
    [logoImageView setImageWithURL:[NSURL URLWithString:chatItem.chatUserAvatar]];
    lblName.text = chatItem.chatUserName;
    lblTime.text = [NSDateUtil formatDate:chatItem.lastTime];
    lblContent.text = chatItem.lastMessage;
    lblNewMsgNum.text = [NSString stringWithFormat:@"%d",chatItem.unReadNumber];
    
    if (chatItem.unReadNumber == 0) {
        lblNewMsgNum.hidden = YES;
    }else{
        lblNewMsgNum.hidden = NO;
    }
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
