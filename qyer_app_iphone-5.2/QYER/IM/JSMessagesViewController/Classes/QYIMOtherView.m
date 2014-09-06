//
//  QYIMOtherView.m
//  IMTest
//
//  Created by Frank on 14-4-30.
//  Copyright (c) 2014年 Frank. All rights reserved.
//

#import "QYIMOtherView.h"
#import "QyYhConst.h"
#import "UIImageView+WebCache.h"
#import "QYIMOtherMessage.h"

@implementation QYIMOtherView

/**
 *  使用视图类型初始化
 *
 *  @return
 */
- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];//IMCOLOR

        [self initView];
    }
    return self;
}

/**
 *  初始化边框样式
 *
 *  @param type 视图样式
 */
- (void)initBorderStyle:(QYIMViewType)type{
    UIColor *color = nil;
    switch (type) {
        case QYIMViewTypeInvite:
            color = RGB(70, 173, 229);
            break;
        case QYIMViewTypeActivities:
            color = RGB(11, 185, 175);
            break;
        case QYIMViewTypeBusiness:
            color = RGB(106, 188, 52);
            break;
    }
    
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 2;
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
}

/**
 *  初始化视图
 */
- (void)initView
{
    //标题
    UILabel *label = [[UILabel alloc] init];
    self.labelTitle = label;
    label.backgroundColor = [UIColor clearColor];//IMCOLOR
    label.textColor = RGB(68, 68, 68);
    label.font = [UIFont systemFontOfSize:15];
    [self addSubview:label];
    
    UIImageView *icon = [[UIImageView alloc] init];
    self.imageViewIcon = icon;
    [icon release];
    
    //分割线
    UIView *line = [[UIView alloc] init];
    _line = line;
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    
    //图片
    UIImageView *imageView = [[UIImageView alloc] init];
    self.imageView = imageView;
    [self addSubview:imageView];
    
    //内容
    UILabel *labelContent = [[UILabel alloc] init];
    self.labelContent = labelContent;
    labelContent.backgroundColor = [UIColor clearColor];//IMCOLOR
    labelContent.textColor = RGB(158, 163, 171);
    labelContent.font = [UIFont systemFontOfSize:13];
    labelContent.lineBreakMode = NSLineBreakByWordWrapping;
    labelContent.numberOfLines = 0;
    [self addSubview:labelContent];
    
    [labelContent release];
    [label release];
    [line release];
    [imageView release];
}

/**
 *  设置内容
 *
 *  @param otherMessage
 */
- (void)setOtherMessage:(QYIMOtherMessage *)otherMessage
{
    if (![_otherMessage isEqual:otherMessage]) {
        [_otherMessage release];
        _otherMessage = [otherMessage retain];
        
        //标题
        self.labelTitle.text = _otherMessage.title;
        //icon
        self.imageViewIcon.image = [self iconWithType:_otherMessage.type];
        //内容
        self.labelContent.text = _otherMessage.content;
        //图片
        NSString *imageUrl = _otherMessage.photo;
        if (imageUrl && ![imageUrl isEqualToString:@""]) {
            [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"114icon"]];
        }
        
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.labelTitle.frame = CGRectMake(10, 10, self.bounds.size.width - 50, 20);
    self.imageViewIcon.frame = CGRectMake(self.bounds.size.width - 22, 4, 12, 12);
    _line.frame = CGRectMake(8, 34, 204, 2);
    
    CGFloat x = 80;
    CGFloat width = 132;
    //图片
    NSString *imageUrl = _otherMessage.photo;
    if (!imageUrl || [imageUrl isEqualToString:@""]) {
        //如果没有图片, 那么改变labelContent的X
        self.imageView.frame = CGRectZero;
        x = 10;
        width = 200;
    }else{
        self.imageView.frame = CGRectMake(10, 44, 60, 60);
    }
    //重新计算labelContent的height,
    CGFloat height = self.bounds.size.height - 55;
    self.labelContent.frame = CGRectMake(x, 45, width, height);
    
    [self initBorderStyle:_otherMessage.type];
}

/**
 *  通过当前类型，返回图片
 *
 *  @param type 当前类型
 *
 *  @return icon图片
 */
- (UIImage*)iconWithType:(QYIMViewType)type
{
    UIImage *image = nil;
    switch (type) {
        case QYIMViewTypeInvite:
            image = [UIImage imageNamed:@"playIcon"];
            break;
        case QYIMViewTypeActivities:
            image = [UIImage imageNamed:@"eventIcon"];
            break;
        case QYIMViewTypeBusiness:
            image = [UIImage imageNamed:@"shopIcon"];
            break;
    }
    return image;
}

- (void)dealloc
{
    self.labelContent = nil;
    self.labelTitle = nil;
    self.imageView = nil;
    self.imageViewIcon = nil;
    
    [_line release];
    _line = nil;
    
    [super dealloc];
}


@end
