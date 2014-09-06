//
//  TripNewViewCell.m
//  QYER
//
//  Created by 张伊辉 on 14-6-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "TripNewViewCell.h"
#import "UIImageView+WebCache.h"
#import "UILabel+VerticalAlign.h"
#import "NSDateUtil.h"
@implementation TripNewViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.
        
        self.backImage = [[[UIImageView alloc]initWithFrame:CGRectMake(7, 10, UIWidth-14, 78)] autorelease];
        self.backImage.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backImage];
        
        self.iconImage = [[[UIImageView alloc]initWithFrame:CGRectMake(3, 0, 100, 67)] autorelease];
        self.iconImage.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImage.clipsToBounds = YES;
        [self.backImage addSubview:self.iconImage];
        
        
        self.titleLbl = [[[LineSpaceLabel alloc]initWithFrame:CGRectMake(110, 0, 180, 46)] autorelease];
        self.titleLbl.font = [UIFont fontWithName:Default_Font size:14.0];//[UIFont systemFontOfSize:15.0];
        self.titleLbl.backgroundColor = [UIColor clearColor];
        self.titleLbl.numberOfLines = 0.0;
        self.titleLbl.lineSpace = 0.0;
        self.titleLbl.textColor = RGB(68, 68, 68);
        self.titleLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.titleLbl];
        
        if (!IS_IOS7) {
            self.titleLbl.frame = CGRectMake(110, 0, 170, 46);
        }
        
        self.autorAndTimeLbl = [[[UILabel alloc]initWithFrame:CGRectMake(110, 50, 180, 18)] autorelease];
        self.autorAndTimeLbl.font = [UIFont fontWithName:Default_Font size:12.0];//[UIFont systemFontOfSize:12.0];
        self.autorAndTimeLbl.backgroundColor = [UIColor clearColor];
        self.autorAndTimeLbl.textColor = RGB(188, 188, 188);
        self.autorAndTimeLbl.textAlignment = NSTextAlignmentLeft;
        [self.backImage addSubview:self.autorAndTimeLbl];
        
        
        
        
        UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 88.5, UIWidth-10, 0.5)];
        lineImageView.backgroundColor = RGB(205, 205, 205);
        [self addSubview:lineImageView];
        [lineImageView release];
        
        
        self.back_click_view = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 89)] autorelease];
        self.back_click_view.alpha = 0.1;
        self.back_click_view.backgroundColor = [UIColor blackColor];
        self.back_click_view.hidden = YES;
        [self addSubview:self.back_click_view];
    }
    return self;
}
-(void)updateUIWithDict:(NSDictionary *)dict{
    
    [self.iconImage setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"default_ls_back.png"]];
    self.titleLbl.text = [dict objectForKey:@"title"];
    
    double timeInter = [[dict objectForKey:@"lastpost"] doubleValue];
    
    self.autorAndTimeLbl.text =  [NSString stringWithFormat:@"%@ | %@",[dict objectForKey:@"username"],[NSDateUtil getTimeDiffString:timeInter]];

    
    
    [self.titleLbl alignTop];

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
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted == NO) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.back_click_view.hidden = YES;
            
        });
        
    }else{
        self.back_click_view.hidden = NO;
    }
    
    
}
@end
