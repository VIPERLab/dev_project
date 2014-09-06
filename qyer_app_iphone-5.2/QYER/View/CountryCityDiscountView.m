//
//  CountryCityDiscountBtn.m
//  QYER
//
//  Created by Leno on 14-7-15.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CountryCityDiscountView.h"

@implementation CountryCityDiscountView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        
        _backButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
        [_backButton setFrame:CGRectMake(0, 0, 160, 176)];
        [_backButton setBackgroundColor:[UIColor clearColor]];
        [_backButton setExclusiveTouch:YES];
        [_backButton addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton addTarget:self action:@selector(pressOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_backButton addTarget:self action:@selector(pressDown:) forControlEvents:UIControlEventTouchDown];
        [_backButton addTarget:self action:@selector(pressCancel:) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:_backButton];
        
        
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 160, 176)];
        [_backView setBackgroundColor:RGB(188, 198, 188)];
        [_backView setAlpha:0.4];
        [_backView setHidden:YES];
        [_backButton addSubview:_backView];
        
        
        _discountImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 140, 94)];
        [_discountImgView setBackgroundColor:[UIColor clearColor]];
        [_discountImgView setContentMode:UIViewContentModeScaleToFill];
        [_backButton addSubview:_discountImgView];
        
        _pinkLabel = [[UIImageView alloc]initWithFrame:CGRectMake(70, 75, 85, 25)];
        [_pinkLabel setBackgroundColor:[UIColor clearColor]];
        [_backButton addSubview:_pinkLabel];
        
        _prefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 30, 13)];
        _prefixLabel.backgroundColor = [UIColor clearColor];
        _prefixLabel.textColor = [UIColor whiteColor];
        _prefixLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        [_backButton addSubview:_prefixLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 4, 100, 17)];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.font = [UIFont boldSystemFontOfSize:15];
        [_backButton addSubview:_priceLabel];
        
        _suffixLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 30, 13)];
        _suffixLabel.backgroundColor = [UIColor clearColor];
        _suffixLabel.textColor = [UIColor whiteColor];
        _suffixLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        [_backButton addSubview:_suffixLabel];

        _detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 113, 140, 34)];
        [_detailLabel setNumberOfLines:0];
        [_detailLabel setBackgroundColor:[UIColor clearColor]];
        [_detailLabel setTextColor:RGB(68, 68, 68)];
        [_detailLabel setFont:[UIFont systemFontOfSize:14]];
        [_backButton addSubview:_detailLabel];
        
        
        _clockIconImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 151, 14, 14)];
        [_clockIconImgView setBackgroundColor:[UIColor clearColor]];
        [_clockIconImgView setImage:[UIImage imageNamed:@"lastMinute_time"]];
        [_backButton addSubview:_clockIconImgView];
        
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(28, 151, 120, 14)];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentLeft];
        [_timeLabel setTextColor:RGB(158, 163, 171)];
        [_timeLabel setFont:[UIFont systemFontOfSize:12]];
        [_backButton addSubview:_timeLabel];
        
   
    }
    return self;
}




-(void)setDiscountInfo:(NSDictionary *)dict
{
    if (![dict isEqual:[NSNull null]]) {
        
        int discountID = [[dict objectForKey:@"id"]integerValue];
        [self setTag:discountID + 10000];
        
        
        NSString * photoURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"photo"]];
        [_discountImgView setImageWithURL:[NSURL URLWithString:photoURL]];
        
        NSString * price = [NSString stringWithFormat:@"%@",[dict objectForKey:@"price"]];
        
        if (![price isEqualToString:@""] && price.length >0) {
            
            NSArray *array = [price componentsSeparatedByString:@"<em>"];
            
            if([array count] > 1)
            {
                //价格前的宽度
                float beforeSizeWidth = 0;
                
                if ([[array objectAtIndex:0]isKindOfClass:[NSString class]] && ![[array objectAtIndex:0]isEqualToString:@""]) {
                    beforeSizeWidth = [(NSString *)[array objectAtIndex:0] sizeWithFont:[UIFont boldSystemFontOfSize:11.0f] constrainedToSize:CGSizeMake(100, 15) lineBreakMode:NSLineBreakByWordWrapping].width + 3;
                }
                
                //价格的宽度
                NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];
                UIFont *font = [UIFont boldSystemFontOfSize:15];
                float priceSizeWidth = [(NSString *)[anotherArray objectAtIndex:0] sizeWithFont:font constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping].width;
                
                //后面的宽度
                float afterSizeWidth = 0;
                if([anotherArray count] > 1)
                {
                    afterSizeWidth = [(NSString *)[anotherArray objectAtIndex:1] sizeWithFont:[UIFont boldSystemFontOfSize:11.0f] constrainedToSize:CGSizeMake(100, 15) lineBreakMode:NSLineBreakByWordWrapping].width +3;
                }
                
                _suffixLabel.frame = CGRectMake(150 - afterSizeWidth, 75 +6, afterSizeWidth, 13);
                
                if([anotherArray count] > 1){
                    _suffixLabel.text = [anotherArray objectAtIndex:1];
                    
                }
                [_suffixLabel setTextAlignment:NSTextAlignmentRight];
                
                _priceLabel.frame = CGRectMake(150 - afterSizeWidth - priceSizeWidth, 75 +4, priceSizeWidth, 17);
                _priceLabel.text = [anotherArray objectAtIndex:0];
                
                _prefixLabel.frame = CGRectMake(150 - afterSizeWidth - priceSizeWidth - beforeSizeWidth,75 +6, beforeSizeWidth, 13);
                _prefixLabel.text = [array objectAtIndex:0];
                [_prefixLabel setTextAlignment:NSTextAlignmentLeft];
                
                float totalWidth = _prefixLabel.frame.size.width + _priceLabel.frame.size.width + _suffixLabel.frame.size.width;
                
                [_pinkLabel setFrame:CGRectMake(155 - totalWidth -12, 75, totalWidth + 12, 25)];
                UIImage * imageee = [UIImage imageNamed:@"pinkLabel@2x"];
                imageee = [imageee stretchableImageWithLeftCapWidth:10 topCapHeight:5];
                [_pinkLabel setImage:imageee];
                
            }
        }
        
        NSString * title = [NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
        CGSize  titleSize = [title sizeWithFont:_detailLabel.font constrainedToSize:CGSizeMake(140, 40) lineBreakMode:NSLineBreakByWordWrapping];
        
        
        if (titleSize.height > 17) {
            [_detailLabel setFrame:CGRectMake(10, 113, 140, 34)];
        }
        else{
            [_detailLabel setFrame:CGRectMake(10, 113, 140, 15)];
        }
        [_detailLabel setText:title];
        
        NSString * time = [NSString stringWithFormat:@"%@",[dict objectForKey:@"expire_date"]];
        [_timeLabel setText:time];
    }
}



-(void)clicked:(id)sender
{
    [_delegate didClickDiscount:self];
}

-(void)pressOutside:(id)sender
{
    [_backView setHidden:YES];
}

-(void)pressDown:(id)sender
{
    [_backView setHidden:NO];
}

-(void)pressCancel:(id)sender
{
    [_backView setHidden:YES];
}

-(void)setBackBtnColor
{
    [_backView setHidden:YES];
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_backButton);
    QY_VIEW_RELEASE(_backView);
    QY_VIEW_RELEASE(_discountImgView);
    QY_VIEW_RELEASE(_pinkLabel);
    QY_VIEW_RELEASE(_prefixLabel);
    QY_VIEW_RELEASE(_priceLabel);
    QY_VIEW_RELEASE(_suffixLabel);
    
    QY_VIEW_RELEASE(_clockIconImgView);
    QY_VIEW_RELEASE(_timeLabel);
    
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
