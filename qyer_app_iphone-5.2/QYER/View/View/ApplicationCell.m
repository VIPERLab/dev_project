//
//  ApplicationCell.m
//  NewPackingList
//
//  Created by lide on 12-10-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ApplicationCell.h"
#import "UIImageView+WebCache.h"


@implementation ApplicationCell

@synthesize applicationImageView = _applicationImageView;
@synthesize applicationTitle = _applicationTitle;
@synthesize applicationContent = _applicationContent;
@synthesize imageView_background = _imageView_background;
@synthesize imageView_lastCell = _imageView_lastCell;




- (void)dealloc
{
    [_applicationImageView removeFromSuperview];
    [_applicationImageView release];
    
    [_applicationTitle removeFromSuperview];
    [_applicationTitle release];
    
    [_applicationContent removeFromSuperview];
    [_applicationContent release];
    
    self.imageView_background = nil;
    self.imageView_lastCell = nil;
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        _imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 320-8*2, 0)];
        _imageView_background.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_background];
        
        
        _applicationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 54, 54)];
        _applicationImageView.backgroundColor = [UIColor clearColor];
        [_imageView_background addSubview:_applicationImageView];
        
        
        
        _applicationTitle = [[UILabel alloc] initWithFrame:CGRectMake(8+54+8, 8, 220, 16)];
        _applicationTitle.font = [UIFont systemFontOfSize:15.0f];
        _applicationTitle.backgroundColor = [UIColor clearColor];
        [_imageView_background addSubview:_applicationTitle];
        
        
        
        _applicationContent = [[UILabel alloc] initWithFrame:CGRectMake(8+54+8, _applicationTitle.frame.size.height+_applicationTitle.frame.origin.y, 230, 0)];
        _applicationContent.numberOfLines = 0;
        _applicationContent.font = [UIFont systemFontOfSize:13.];
        _applicationContent.textColor = [UIColor darkGrayColor];
        _applicationContent.backgroundColor = [UIColor clearColor];
        [_imageView_background addSubview:_applicationContent];
        
        
        
        _imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320-8*2, 2)];
        _imageView_lastCell.alpha = 0;
        _imageView_lastCell.backgroundColor = [UIColor clearColor];
        _imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影.png"];
        [_imageView_background addSubview:_imageView_lastCell];
        
    }
    return self;
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
{
    [super setHighlighted:highlighted animated:animated];

    // Configure the view for the selected state
    
//    if(highlighted == YES)
//    {
//        self.imageView_background.image = nil;
//        self.imageView_background.backgroundColor = [UIColor colorWithRed:47/255. green:159/255. blue:232/255. alpha:0.3];
//    }
//    else 
//    {
//        self.imageView_background.image = [UIImage imageNamed:@"更多设置_列表背景_高90.png"];
//        self.imageView_background.backgroundColor = [UIColor clearColor];
//    }
}


-(void)reset
{
    [self.applicationImageView setImageWithURL:[NSURL URLWithString:nil]];
    self.applicationTitle.text = @"";
    self.applicationContent.text = @"";
    self.imageView_lastCell.alpha = 0;
}

-(void)initDataWithArray:(NSArray *)array atPosition:(NSInteger)position andHeightDic:(NSDictionary *)heightDic
{
    NSDictionary *dictionary = [array objectAtIndex:position];
    float height = [[heightDic objectForKey:[dictionary objectForKey:@"description"]] floatValue];
    
    [self.applicationImageView setImageWithURL:[NSURL URLWithString:[dictionary objectForKey:@"thumb"]]];
    self.applicationTitle.text = [dictionary objectForKey:@"title"];
    self.applicationContent.text = [dictionary objectForKey:@"description"];
    
    CGRect frame = self.applicationContent.frame;
    frame.size.height = height;
    self.applicationContent.frame = frame;
    
    
    height = MAX(height+_applicationTitle.frame.size.height+_applicationTitle.frame.origin.y+8, 54+8*2);
    frame = self.imageView_background.frame;
    frame.size.height = height;
    self.imageView_background.frame = frame;
    self.imageView_background.backgroundColor = [UIColor clearColor];
    
    
    self.imageView_lastCell.alpha = 0;
    if(position == 0)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"全实线@2x" ofType:@"png"]];
        _imageView_background.image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:2];
    }
    else if(position > 0 && position < array.count - 1)
    {
        _imageView_background.image = [[UIImage imageNamed:@"更多设置_列表背景_高90.png"]  stretchableImageWithLeftCapWidth:5 topCapHeight:2];
    }
    else if(position == array.count - 1)
    {
        _imageView_background.image = [[UIImage imageNamed:@"更多设置_列表背景_高90.png"]  stretchableImageWithLeftCapWidth:5 topCapHeight:2];
        self.imageView_lastCell.alpha = 1;
    }
    
    
    
    frame = self.imageView_lastCell.frame;
    frame.origin.y = height;
    self.imageView_lastCell.frame = frame;
}


@end
