//
//  CCActiotSheet.m
//  QYER
//
//  Created by 张伊辉 on 14-5-7.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CCActiotSheet.h"
#import "SlurImageView.h"

#define btnWidth 294
#define btnHeight 48
#define btnSpace 15
#define btnTag 909192

@interface CCActiotSheet()
{
    SlurImageView *imageView ;
    UIImageView *menuView;
    UILabel *label_title;
    UIButton *cancel_btn;
    CGRect frame;
    NSArray *_array;
}
@end
@implementation CCActiotSheet


- (id)initWithTitle:(NSString *)title andDelegate:(id)delegate andArrayData:(NSArray *)array
{
    
    self = [super init];
    if (self) {
        
        _delegate = delegate;
        _array = [array retain];
        
        self.backgroundColor = [UIColor clearColor];
        
        frame = CGRectMake(0, 0, UIWidth, UIHeight);
        self.frame = frame;
        
        
        if(ios7)
        {
            imageView = [[SlurImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            imageView.alpha = 0;
            imageView.userInteractionEnabled = YES;
            [self addSubview:imageView];
        }
        else
        {
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.alpha = 0;
            imageView.userInteractionEnabled = YES;
            [self addSubview:imageView];
        }
        
        
        
        
        /**
         *
         *添加菜单选项
         
         */
        
        menuView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2-btnWidth/2, frame.size.height- btnSpace - btnHeight - btnSpace - array.count*btnHeight, btnWidth, btnHeight*array.count)];
        menuView.userInteractionEnabled = YES;
        menuView.image = [[UIImage imageNamed:@"cancel_btn_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:20];
        [self addSubview:menuView];
        [menuView release];
        
        
        for (int i = 0; i<array.count; i++) {
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i*btnHeight, btnWidth, btnHeight)];
            [btn setTitleColor:RGB(44, 170, 122) forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = btnTag + i + 1;
            [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:Default_Font size:18.0];
            [menuView addSubview:btn];
            [btn release];
            
            if (i < array.count - 1) {
                
                UIImageView *lineView = [[UIImageView alloc]initWithFrame:CGRectMake(10, (i+1)*btnHeight, btnWidth - 20, 0.5)];
                lineView.backgroundColor = RGB(230, 232, 234);
                [menuView addSubview:lineView];
                [lineView release];
            }
            
        }
        
        
        
        
        
        /**
         *
         *添加title
         
         */
        if(title)
        {
            label_title = [[UILabel alloc] initWithFrame:CGRectMake(0, menuView.frame.origin.y-18-15 +[[UIScreen mainScreen] bounds].size.height, 320, 18)];
            label_title.backgroundColor = [UIColor clearColor];
            label_title.textAlignment = NSTextAlignmentCenter;
            label_title.font = [UIFont systemFontOfSize:15];
            label_title.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
            label_title.text = title;
            [self addSubview:label_title];
        }
        
        
        
        
        
        
        
        
        /**
         *  添加取消按钮
         
         */
        cancel_btn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2-btnWidth/2, frame.size.height-btnSpace-btnHeight, btnWidth, btnHeight)];
        [cancel_btn setBackgroundImage:[UIImage imageNamed:@"cancel_btn_bg"] forState:UIControlStateNormal];
        cancel_btn.tag = btnTag;
        [cancel_btn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [cancel_btn setTitleColor:RGB(68, 68, 68) forState:UIControlStateNormal];
        [cancel_btn setTitle:@"取消" forState:UIControlStateNormal];
        cancel_btn.titleLabel.font = [UIFont fontWithName:Default_Font size:18.0];
        [self addSubview:cancel_btn];
        [cancel_btn release];
        

        
    }
    return self;
}

/**
 *  按钮点击事件
 *
 *  @param btn
 */
-(void)btnClickAction:(UIButton *)btn{
    
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ccActionSheet:clickedButtonAtIndex:)]) {
        
        //[self.delegate actionSheetClickedButtonAtIndex:btn.tag-btnTag];
        [self.delegate ccActionSheet:self clickedButtonAtIndex:btn.tag-btnTag];
    }
    
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        imageView.alpha = 0.0;
        cancel_btn.frame = CGRectMake(frame.size.width/2-btnWidth/2,UIHeight+frame.size.height-btnSpace-btnHeight, btnWidth, btnHeight);
        menuView.frame = CGRectMake(frame.size.width/2-btnWidth/2,UIHeight+frame.size.height- btnSpace - btnHeight - btnSpace - _array.count*btnHeight, btnWidth, btnHeight*_array.count);
        label_title.frame = CGRectMake(0, menuView.frame.origin.y-18-15 +[[UIScreen mainScreen] bounds].size.height, 320, 18);
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];

    }];
    
 
    
}


/**
 *  显示视图
 */

- (void)show{
    
 
    cancel_btn.frame = CGRectMake(frame.size.width/2-btnWidth/2, UIHeight + frame.size.height-btnSpace-btnHeight, btnWidth, btnHeight);
    menuView.frame = CGRectMake(frame.size.width/2-btnWidth/2, UIHeight + frame.size.height- btnSpace - btnHeight - btnSpace - _array.count*btnHeight, btnWidth, btnHeight*_array.count);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    label_title.frame = CGRectMake(0, menuView.frame.origin.y-18-15 +[[UIScreen mainScreen] bounds].size.height, 320, 18);
    
   
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            
            imageView.alpha = 1.0;
            cancel_btn.frame = CGRectMake(frame.size.width/2-btnWidth/2,frame.size.height-btnSpace-btnHeight, btnWidth, btnHeight);
            menuView.frame = CGRectMake(frame.size.width/2-btnWidth/2,frame.size.height- btnSpace - btnHeight - btnSpace - _array.count*btnHeight, btnWidth, btnHeight*_array.count);
            label_title.frame = CGRectMake(0, menuView.frame.origin.y-18-15, 320, 18);
            
        } completion:^(BOOL finished) {
            
        }];
        
       
        
    });
    
}

-(void)dealloc{
    
    [_array release];

    [super dealloc];
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
