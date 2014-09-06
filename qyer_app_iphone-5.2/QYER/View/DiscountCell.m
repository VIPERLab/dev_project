//
//  DiscountCell.m
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "DiscountCell.h"
#import "UIImageView+WebCache.h"
#import "QYOperation.h"
@implementation DiscountCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        for (int i = 0 ; i<2; i++) {
            
            UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(10+i*(145+10), 10, 145, 90)];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.layer.cornerRadius = 2.0;
            view.layer.masksToBounds = YES;
            view.clipsToBounds = YES;
            view.tag = i+100;
            [self addSubview:view];
            [view release];
            
            
//            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageAction:)];
//            [view addGestureRecognizer:tapGesture];
//            [tapGesture release];
        }
     
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    UITouch *touch = [touches anyObject];
    if (touch.view.tag == 100 || touch.view.tag == 101) {
    
        if (limitMultiple == YES) {
            return;
        }
        limitMultiple = YES;

        
        blackView = [[UIView alloc]initWithFrame:touch.view.bounds];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = 0.3;
        blackView.tag = 1000;
        [touch.view addSubview:blackView];
        [blackView release];
        
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (blackView) {
            [blackView  removeFromSuperview];
            blackView = nil;
        }
        
    });
    
    
    
    
    UITouch *touch = [touches anyObject];
    if (touch.view.tag == 100 || touch.view.tag == 101) {
    
        
        int index =  _indexRow*2 + [touch view].tag - 100 ;
        [self.delegate clickDiscount:index];
        limitMultiple = NO;

        

    }
    
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    limitMultiple = NO;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (blackView) {
            [blackView  removeFromSuperview];
            blackView = nil;
        }
    });
}


-(void)tapImageAction:(UITapGestureRecognizer *)tap{
    
    
    
    int index =  _indexRow*2 + [tap view].tag - 100 ;
    [self.delegate clickDiscount:index];
    
    
    
    NSLog(@"row is %d",index);
}


-(void)updateCellWithLastMinuteDeal:(NSMutableArray *)array index:(int)row{
    
    
    _indexRow = row;
    
    for (int i = 0; i<2; i++) {
        
        UIImageView *imageView = (UIImageView *)[self viewWithTag:100+i];
        
        if (row*2+i < array.count) {
            
            QYOperation *operation = [array objectAtIndex:row*2+i];
            
            [imageView setImageWithURL:[NSURL URLWithString:operation.operationPic]  placeholderImage:[UIImage imageNamed:@"default_ls_back"]];
                imageView.hidden = NO;
                imageView.userInteractionEnabled = YES;
            
        }else{
            
            imageView.hidden = YES;
            imageView.userInteractionEnabled = NO;
        }
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)dealloc{
    
    blackView  = nil;
    [super dealloc];
}
@end










