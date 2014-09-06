//
//  DestinationCell.m
//  QYER
//
//  Created by 张伊辉 on 14-6-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "DestinationCell.h"
#import "QyYhConst.h"
#import "UIImageView+WebCache.h"
#import "QYToolObject.h"
@implementation DestinationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        backImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, UIWidth-20, 100)];
        backImage.backgroundColor = [UIColor clearColor];
        backImage.layer.cornerRadius = 2.0;
        backImage.layer.masksToBounds = YES;
        backImage.contentMode = UIViewContentModeScaleAspectFill;
        backImage.clipsToBounds = YES;
        [self addSubview:backImage];
        [backImage release];
        
        
        
        UIImageView *shadeImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
        shadeImage.image = [UIImage imageNamed:@"shade_list"];
        [backImage addSubview:shadeImage];
        [shadeImage release];
        
        
        titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 250, 18)];
        titleLbl.numberOfLines = 1;
        titleLbl.font = [UIFont fontWithName:Default_Font size:15.0];
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textColor = [UIColor whiteColor];
        titleLbl.textAlignment = NSTextAlignmentLeft;
        titleLbl.hidden = YES;
        [titleLbl setShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.50f]];
        [titleLbl setShadowOffset:CGSizeMake(0, 1)];
        
        [backImage addSubview:titleLbl];
        [titleLbl release];
        
        if (!IS_IOS7) {
            titleLbl.frame = CGRectMake(10, 60, 250, 22);
        }
        
        
        iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 80, 14, 14)];
        iconImage.image = [UIImage imageNamed:@"poipoi"];
        iconImage.backgroundColor = [UIColor clearColor];
        [backImage addSubview:iconImage];
        [iconImage release];
        

        
        numberLbl= [[UILabel alloc]initWithFrame:CGRectMake(0, 80, 0, 14)];
        numberLbl.font = [UIFont systemFontOfSize:9.0];
        numberLbl.backgroundColor = [UIColor clearColor];
        numberLbl.textColor = [UIColor whiteColor];
        numberLbl.textAlignment = NSTextAlignmentLeft;
        [numberLbl setShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.50f]];
        [numberLbl setShadowOffset:CGSizeMake(0, 1)];
        [backImage addSubview:numberLbl];
        [numberLbl release];
        
        
        
        
        
        
        
        back_click_view = [[[UIView alloc]initWithFrame:backImage.bounds] autorelease];
        back_click_view.backgroundColor = [UIColor blackColor];
        back_click_view.alpha = 0.3;
        back_click_view.hidden = YES;
        [backImage addSubview:back_click_view];

        
    }
    return self;
}
-(void)updateUIWithDict:(NSDictionary *)dict{
    
    [backImage setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"photo"]]];
    titleLbl.text = [dict objectForKey:@"title"];
    numberLbl.text = [dict objectForKey:@"label"];
    
    
    CGSize size = [[dict objectForKey:@"label"] sizeWithFont:[UIFont systemFontOfSize:9.0] constrainedToSize:CGSizeMake(MAXFLOAT, 14) lineBreakMode:NSLineBreakByCharWrapping];

    numberLbl.frame = CGRectMake(290 - size.width, 80, size.width, 14);

//    CGSize size = [QYToolObject getContentSize:[dict objectForKey:@"label"] font:titleLbl.font width:20];
    
    iconImage.frame = CGRectMake(290 - size.width - 14, 80, 14, 14);
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
            back_click_view.hidden = YES;
            
        });
        
    }else{
        back_click_view.hidden = NO;
    }
}
@end
