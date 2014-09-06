//
//  LoadMore.m
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import "LoadMoreView.h"

@implementation LoadMoreView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isHaveData = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(140, 5, 100, 30)];
        label.tag = 1;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"加载更多";
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:label];
        [label release];
        
        
        UIActivityIndicatorView *_activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _activityView.backgroundColor = [UIColor clearColor];
        _activityView.center = CGPointMake(120, 20);
        _activityView.tag = 2;
        [self addSubview:_activityView];
        [_activityView release];

        [self addObserver:self forKeyPath:@"isHaveData" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-40, 8, 80, 24)];
        imageView.tag = 3;
        imageView.hidden = YES;
        imageView.image = [UIImage imageNamed:@"nodata_logo"];
        [self addSubview:imageView];
        [imageView release];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"isHaveData"]) {
        
        UILabel *label = (UILabel *)[self viewWithTag:1];
        UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[self viewWithTag:2];
        UIImageView *imageview  = (UIImageView *)[self viewWithTag:3];
        
        [activityView stopAnimating];
        
        if (self.isHaveData == NO) {
            
            imageview.hidden = NO;
            label.hidden = YES;

            
        }else{
            
            imageview.hidden = YES;
            label.hidden = NO;

        }
    }
}


-(void)changeLoadingStatus:(BOOL)isLoading{
    
    
    UILabel *label = (UILabel *)[self viewWithTag:1];
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[self viewWithTag:2];
    UIImageView *imageview  = (UIImageView *)[self viewWithTag:3];
    imageview.hidden = YES;
    
    if (isLoading == NO) {
        
       
        label.text = @"加载更多";
        [activityView stopAnimating];
        
        
    }else if(isLoading == YES){
        
      
        label.text = @"正在加载...";
        [activityView startAnimating];
        
    }
}
-(void)dealloc{
    
    [self removeObserver:self forKeyPath:@"isHaveData" context:nil];
    
    [super dealloc];
    
}

@end
