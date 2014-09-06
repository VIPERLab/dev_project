//
//  chatroomAdvertiseView.m
//  QYER
//
//  Created by Qyer on 14-5-28.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "chatroomAdvertiseView.h"
#import "QYAPIClient.h"
#define ios5_btn_height 55
#define ios7_btn_height 101
#define label_witdh     290
#define label_height     20
@implementation chatroomAdvertiseView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat _height=iPhone5?ios7_btn_height:ios5_btn_height;
        if (iPhone5 == NO) {
            _height += 10;
        }
        UIImageView* imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        if (iPhone5) {
            imgView.frame=CGRectMake(0, 0, 320, 568);
            [imgView setImage:[UIImage imageNamed:@"bg_ad_iphone5"]];
        }else{
            [imgView setImage:[UIImage imageNamed:@"bg_ad_iphone4"]];
        }
        
        [self addSubview:imgView];
        [imgView release];
        
        UIButton *back_btn=[UIButton buttonWithType:UIButtonTypeCustom];
        back_btn.backgroundColor = [UIColor clearColor];
        back_btn.frame = CGRectMake(566/2, ios5_btn_height, 32, 32);
        
        [back_btn setBackgroundImage:[UIImage imageNamed:@"close_ad"] forState:UIControlStateNormal];
        [back_btn addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:back_btn];
        
        UIButton *chat_btn=[UIButton buttonWithType:UIButtonTypeCustom];
        chat_btn.backgroundColor = [UIColor clearColor];
        chat_btn.frame = CGRectMake(30, _height+349, 260, 42);
        
        [chat_btn setBackgroundImage:[UIImage imageNamed:@"join_ad_btn"] forState:UIControlStateNormal];
        [chat_btn addTarget:self action:@selector(goChatroomButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chat_btn];
        
        if (!iPhone5) {
            back_btn.frame = CGRectMake(562/2, 16, 32, 32);
            chat_btn.frame = CGRectMake(30, _height+339, 260, 42);
        }
        
//        if (!iPhone5) {
//             back_btn.frame = CGRectMake(562/2, 22, 32, 32);
////            chat_btn.frame = CGRectMake(40, _height+349, 240, 42);
//            [back_btn setBackgroundImage:[UIImage imageNamed:@"close_ad"] forState:UIControlStateNormal];
//            [chat_btn setBackgroundImage:[UIImage imageNamed:@"join_ad_btn"] forState:UIControlStateNormal];
//        }
        
        /*
        _introduceLabel = [[LineSpaceLabel alloc] initWithFrame:CGRectMake(25, _height+160, label_witdh-25, label_height+45)];
        _introduceLabel.backgroundColor = [UIColor clearColor];
        _introduceLabel.text = @"让每一段旅行，都不再孤单。\n同城组爬梯，异国有盆友。吃饭聊天看风景，求助问询查信息。旅途中，在这里发现身边的穷游er。";
        _introduceLabel.textAlignment = NSTextAlignmentLeft;
        _introduceLabel.textColor = [UIColor colorWithRed:158.0/255.0 green:163.0/255.0 blue:171.0/255.0 alpha:1.0];
        _introduceLabel.font = [UIFont systemFontOfSize:12];
        _introduceLabel.numberOfLines=0;
        [self addSubview:_introduceLabel];
        [_introduceLabel release];
        
        
        _introduceLabel2 = [[LineSpaceLabel alloc] initWithFrame:CGRectMake(25, _height+220, label_witdh-25, label_height+20)];
        _introduceLabel2.backgroundColor = [UIColor clearColor];
        _introduceLabel2.text = @"目前，这项功能已经覆盖了曼谷，吉隆坡，马尔代夫等100多个城市。";
        _introduceLabel2.textAlignment = NSTextAlignmentLeft;
        _introduceLabel2.textColor = [UIColor colorWithRed:158.0/255.0 green:163.0/255.0 blue:171.0/255.0 alpha:1.0];
        _introduceLabel2.font = [UIFont systemFontOfSize:12];
        _introduceLabel2.numberOfLines=0;
        [self addSubview:_introduceLabel2];
        [_introduceLabel2 release];
        */
        
        btnDetail = [[UIButton alloc]initWithFrame:CGRectMake(label_witdh-65, _height+218, 70, 18)];
        [btnDetail setImage:[UIImage imageNamed:@"city_ad_btn"] forState:UIControlStateNormal];
        btnDetail.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btnDetail addTarget:self action:@selector(btnDetailAction) forControlEvents:UIControlEventTouchUpInside];
        [btnDetail setTitleColor:RGB(73, 152, 204) forState:UIControlStateNormal];
        [self addSubview:btnDetail];
        [btnDetail release];
        
        if (!iPhone5) {
            btnDetail.frame = CGRectMake(label_witdh-65, _height + 210, 70, 18);
        }
        
        for (int i = 0; i<3; i++) {
            
            UILabel *lbl1 = [[UILabel alloc]initWithFrame:CGRectMake(0, _height+255+i*22, 200, 20)];
            lbl1.font = [UIFont systemFontOfSize:15.0];
            lbl1.textColor = RGB(106, 188, 52);
            lbl1.tag = 100+i;
            lbl1.backgroundColor = [UIColor clearColor];
            lbl1.textAlignment = NSTextAlignmentRight;
           // lbl1.text = @"身边人在线：";
            [self addSubview:lbl1];
            [lbl1 release];
            
            UILabel *lbl2 = [[UILabel alloc]initWithFrame:CGRectMake(200, _height+255+i*22, 90, 20)];
            lbl2.font = [UIFont systemFontOfSize:15.0];
            lbl2.textColor = RGB(106, 188, 52);
            lbl2.tag = 200+i;
            lbl2.backgroundColor = [UIColor clearColor];
            lbl2.textAlignment = NSTextAlignmentLeft;
            //lbl2.text = @"人";
            [self addSubview:lbl2];
            [lbl2 release];
            
            if (!iPhone5) {
                
                lbl1.frame = CGRectMake(0, _height+245+i*22, 200, 20);
                lbl2.frame = CGRectMake(200, _height+245+i*22, 90, 20);
            }
        }
        
     
        [self getChatroomStats];
    }
    return self;
}

/**
 *  查看详情
 */
-(void)btnDetailAction{
    
    [self.delegate moreDetailAboutChatRoom];
    
}

/**
 *  刷新UI
 *
 *  @param dict
 */
-(void)updateUIWithDict:(NSDictionary *)dic{
    
    
    NSArray *arrHot = [[dic objectForKey:@"data"] objectForKey:@"hot"];
    
    for (int i = 0; i<arrHot.count; i++) {
        
        NSDictionary *dict = [arrHot objectAtIndex:i];

        UILabel *lbl1 = (UILabel *)[self viewWithTag:100+i];
        UILabel *lbl2 = (UILabel *)[self viewWithTag:200+i];
        lbl1.text = [NSString stringWithFormat:@"%@身边人在线：",[dict objectForKey:@"name"]];
        lbl2.text = [NSString stringWithFormat:@"%@人",[dict objectForKey:@"members"]];
        

    }
   // _introduceLabel2.text = [NSString stringWithFormat:@"目前，这项功能已经覆盖了曼谷，吉隆坡，马尔代夫等%@个城市。",[[dic objectForKey:@"data"] objectForKey:@"total"]];

   
}

/**
 *  请求数据
 */
-(void)getChatroomStats{
    
    
    NSDictionary * statisticalChatRoomDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"statisticalChatRoomDict"];
    if (statisticalChatRoomDict) {
        
        [self updateUIWithDict:statisticalChatRoomDict];
    }
    
    [[QYAPIClient sharedAPIClient] getChatroomStatsHotNum:nil newNum:nil success:^(NSDictionary *dic) {
        [self updateUIWithDict:dic];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"statisticalChatRoomDict"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } failed:^{
        
    }];
}

-(void)clickBackButton:(id)sender{
    if (delegate&&[delegate respondsToSelector:@selector(clickBackButton:)]) {
        [delegate clickBackButton:sender];
    }
}
-(void)goChatroomButton:(id)sender{
    
    if (delegate&&[delegate respondsToSelector:@selector(goChatroomButton:)]) {
        [delegate goChatroomButton:sender];
    }
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
