//
//  PhotoListCell.m
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PhotoListCell.h"

@implementation PhotoListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 80)];
        [self addSubview:backImageView];
        [backImageView release];
        
        iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        iconImageView.clipsToBounds = YES;
        [self addSubview:iconImageView];
        [iconImageView release];
        
        
        photoName = [[UILabel alloc]initWithFrame:CGRectMake(83, 20, 200, 20)];
        photoName.backgroundColor = [UIColor clearColor];
        photoName.textColor = RGB(68, 68, 68);
        photoName.textAlignment = NSTextAlignmentLeft;
        photoName.font = [UIFont fontWithName:Default_Font size:15.0];
        [self addSubview:photoName];
        [photoName release];
        
        photoNum= [[UILabel alloc]initWithFrame:CGRectMake(83, 45, 200, 15)];
        photoNum.backgroundColor = [UIColor clearColor];
        photoNum.textColor = RGB(158, 163, 171);
        photoNum.textAlignment = NSTextAlignmentLeft;
        photoNum.font = [UIFont fontWithName:Default_Font size:12.0];
        [self addSubview:photoNum];
        [photoNum release];
        
        
        lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 79, UIWidth, .5)];
        lineView.backgroundColor = RGB(215, 215, 215);
        [self addSubview:lineView];
        [lineView release];
        
        nextImageView = [[UIImageView alloc]initWithFrame:CGRectMake(UIWidth-30, (80-24)/2, 24, 24)];
        nextImageView.image = [UIImage imageNamed:@"arrow"];
        [self addSubview:nextImageView];
        [nextImageView release];
        
        back_click_view = [[UIView alloc]initWithFrame:CGRectMake(0,0, UIWidth, 80)];
        back_click_view.alpha = 0.1;
        back_click_view.backgroundColor = [UIColor blackColor];
        back_click_view.hidden = YES;
        [self addSubview:back_click_view];
        [back_click_view release];
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
 *  @param dict 数据
 *  @param flag 是否加阴影
 */
-(void)upDateUIWithDict:(NSDictionary *)dict isShowd:(BOOL)flag{
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *tempMuarr2 = [dict objectForKey:@"photosArr"];
    
    if ([tempMuarr2 count] != 0) {
        
        NSString *urlStr2 = [tempMuarr2 lastObject];
        
        NSURL *url = [NSURL URLWithString:urlStr2];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
            
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            iconImageView.image = image;

            
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }];
    }else{
        iconImageView.image = [UIImage imageNamed:@"bg_detail_cover_default"];
    }
    
    photoName.text = [dict objectForKey:@"photosName"];
    photoNum.text = [NSString stringWithFormat:@"%@张照片",[dict objectForKey:@"photosNumber"]];
  
    [assetLibrary release];
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted == NO) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            back_click_view.hidden = YES;
        });
        
    }else{
        
        back_click_view.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
