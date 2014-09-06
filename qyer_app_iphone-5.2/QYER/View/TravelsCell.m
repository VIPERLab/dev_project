//
//  TravelsCell.m
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import "TravelsCell.h"
#import "UIImageView+WebCache.h"
#import "QYToolObject.h"

#define smallIconY 110
#define imageLabelSpace 3
#define labelImageSpace 10
#define smallIconWH 14

@implementation TravelsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.backImage = [[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, UIWidth-20, 130)] autorelease];
        self.backImage.backgroundColor = [UIColor clearColor];
        self.backImage.layer.cornerRadius = 5.0;
        self.backImage.layer.masksToBounds = YES;
        self.backImage.contentMode = UIViewContentModeScaleAspectFill;
        self.backImage.clipsToBounds = YES;
        [self addSubview:self.backImage];
        
        UIImageView *shadeImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 30, 300, 100)];
        shadeImage.image = [UIImage imageNamed:@"shade_list"];
        [self.backImage addSubview:shadeImage];
        [shadeImage release];
        
        self.iconImage = [[[UIImageView alloc]initWithFrame:CGRectMake(10, 90, 30, 30)] autorelease];
        
        self.iconImage.layer.masksToBounds = YES;
        [self.iconImage.layer setCornerRadius:15];
        [self.backImage addSubview:self.iconImage];
        
        self.titleLbl = [[[UILabel alloc]initWithFrame:CGRectMake(50, 90, 250, 18)] autorelease];
        self.titleLbl.numberOfLines = 1;
        
        if (ios7) {
            self.titleLbl.font = [UIFont fontWithName:Default_Font size:15.0];
        }
        else{
            self.titleLbl.font = [UIFont systemFontOfSize:15];
        }
        
        self.titleLbl.backgroundColor = [UIColor clearColor];
        self.titleLbl.textColor = [UIColor whiteColor];
        self.titleLbl.textAlignment = NSTextAlignmentLeft;
//        self.titleLbl.shadowOffset = CGSizeMake(0, 1);
//        self.titleLbl.shadowColor = [UIColor blackColor];
        [self.titleLbl setShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.50f]];
        [self.titleLbl setShadowOffset:CGSizeMake(0, 1)];
        
        [self.backImage addSubview:self.titleLbl];
        
        
        
        
        
        self.nameTimeLbl = [[[UILabel alloc]initWithFrame:CGRectMake(50, 108, 170, 18)] autorelease];
        self.nameTimeLbl.font = [UIFont systemFontOfSize:9.0];
        self.nameTimeLbl.backgroundColor = [UIColor clearColor];
        self.nameTimeLbl.textColor = [UIColor whiteColor];
        self.nameTimeLbl.textAlignment = NSTextAlignmentLeft;
//        self.nameTimeLbl.shadowOffset = CGSizeMake(0, 1);
//        self.nameTimeLbl.shadowColor = [UIColor blackColor];
        [self.nameTimeLbl setShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.50f]];
        [self.nameTimeLbl setShadowOffset:CGSizeMake(0, 1)];
        [self.backImage addSubview:self.nameTimeLbl];
        
       
        
      
        
        self.suppIamgeView = [[[UIImageView alloc]initWithFrame:CGRectZero] autorelease];
        self.suppIamgeView.image = [UIImage imageNamed:@"travel_like.png"];
        self.suppIamgeView.backgroundColor = [UIColor clearColor];
        [self.backImage addSubview:self.suppIamgeView];
        
        
        self.suppNumLabel = [[[UILabel alloc]initWithFrame:CGRectZero] autorelease];
        self.suppNumLabel.font = [UIFont boldSystemFontOfSize:9.0];
        self.suppNumLabel.textColor = [UIColor whiteColor];
        self.suppNumLabel.backgroundColor = [UIColor clearColor];
        self.suppNumLabel.textAlignment = NSTextAlignmentLeft;
        self.suppNumLabel.shadowOffset = CGSizeMake(0, 1);
        self.suppNumLabel.shadowColor = [UIColor blackColor];
        [self.backImage addSubview:self.suppNumLabel];
        
        
        self.comImageView = [[[UIImageView alloc]initWithFrame:CGRectZero] autorelease];
        self.comImageView.image = [UIImage imageNamed:@"travel_review.png"];
        self.comImageView.backgroundColor = [UIColor clearColor];
        [self.backImage addSubview:self.comImageView];
        
        
        self.comNumLabel = [[[UILabel alloc]initWithFrame:CGRectZero] autorelease];
        self.comNumLabel.font = [UIFont boldSystemFontOfSize:9.0];
        self.comNumLabel.textColor = [UIColor whiteColor];
        self.comNumLabel.textAlignment = NSTextAlignmentLeft;
        self.comNumLabel.backgroundColor = [UIColor clearColor];
        self.comNumLabel.shadowOffset = CGSizeMake(0, 1);
        self.comNumLabel.shadowColor = [UIColor blackColor];
        [self.backImage addSubview:self.comNumLabel];
       
        
        self.back_click_view = [[[UIView alloc]initWithFrame:self.backImage.bounds] autorelease];
        self.back_click_view.backgroundColor = [UIColor blackColor];
        self.back_click_view.alpha = 0.1;
        self.back_click_view.hidden = YES;
        [self.backImage addSubview:self.back_click_view];
    }
    return self;
}
-(void)updateCell:(MicroTravel *)object
{
 
    NSLog(@"strPhoto is %@",object.str_travelAlbumCover);
    
    
    [self.backImage setImageWithURL:[NSURL URLWithString:object.str_travelAlbumCover]placeholderImage:[UIImage imageNamed:@"default_travel_back"]];
    [self.iconImage setImageWithURL:[NSURL URLWithString:object.str_avatarUrl]];
    self.titleLbl.text = object.str_travelName;
    self.nameTimeLbl.text = object.str_travelBelongTo;
    
    
    NSString *suppNum = object.str_likeCount;
    NSString *commNum = object.str_commentCount;
    
    CGSize suppSize = [QYToolObject getContentSize:suppNum font:self.suppNumLabel.font width:100];
    CGSize commSize = [QYToolObject getContentSize:commNum font:self.comNumLabel.font width:100];
    
    self.comNumLabel.text = commNum;
    self.comNumLabel.frame = CGRectMake(self.backImage.bounds.size.width - labelImageSpace - commSize.width, smallIconY+1, commSize.width, commSize.height);
    
    self.comImageView.frame = CGRectMake(self.comNumLabel.frame.origin.x - imageLabelSpace - smallIconWH, smallIconY, smallIconWH, smallIconWH);
    
    self.suppNumLabel.text = suppNum;
    self.suppNumLabel.frame = CGRectMake(self.comImageView.frame.origin.x - labelImageSpace - suppSize.width, smallIconY+1, suppSize.width, suppSize.height);
    
    self.suppIamgeView.frame = CGRectMake(self.suppNumLabel.frame.origin.x - imageLabelSpace - smallIconWH, smallIconY, smallIconWH, smallIconWH);
    
}
-(void)updateUIWithDict:(NSDictionary *)dict{
        
    [self.backImage setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"photo"]]placeholderImage:[UIImage imageNamed:@"default_travel_back"]];
    [self.iconImage setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"avatar"]]];
    self.titleLbl.text = [dict objectForKey:@"title"];
    self.nameTimeLbl.text = [dict objectForKey:@"username"];
    
    
    NSString *suppNum = [dict objectForKey:@"likes"];
    NSString *commNum = [dict objectForKey:@"replys"];
    
    CGSize suppSize = [QYToolObject getContentSize:suppNum font:self.suppNumLabel.font width:100];
    CGSize commSize = [QYToolObject getContentSize:commNum font:self.comNumLabel.font width:100];
    
    self.comNumLabel.text = commNum;
    self.comNumLabel.frame = CGRectMake(self.backImage.bounds.size.width - labelImageSpace - commSize.width, smallIconY+1, commSize.width, commSize.height);
    
    self.comImageView.frame = CGRectMake(self.comNumLabel.frame.origin.x - imageLabelSpace - smallIconWH, smallIconY, smallIconWH, smallIconWH);
    
    self.suppNumLabel.text = suppNum;
    self.suppNumLabel.frame = CGRectMake(self.comImageView.frame.origin.x - labelImageSpace - suppSize.width, smallIconY+1, suppSize.width, suppSize.height);
    
    self.suppIamgeView.frame = CGRectMake(self.suppNumLabel.frame.origin.x - imageLabelSpace - smallIconWH, smallIconY, smallIconWH, smallIconWH);
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
