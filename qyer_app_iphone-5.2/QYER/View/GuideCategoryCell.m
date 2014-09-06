//
//  GuideCategoryCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-24.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideCategoryCell.h"
#import "QYGuideCategory.h"

#define     positionX_imageView_backGround  8
#define     height_imageView_backGround     60
#define     height_titleLabel_briefLabel    30

#define     label_Chinese_Font              16
#define     label_English_Font              14
#define     label_guideNumber_Font          12



@implementation GuideCategoryCell
@synthesize label_nameEnglish = _label_nameEnglish;
@synthesize label_guideNumber = _label_guideNumber;
@synthesize label_nameChinese = _label_nameChinese;


-(void)dealloc
{
    self.label_nameChinese = nil;
    self.label_nameEnglish = nil;
    self.label_guideNumber = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _imageView_backGround = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_imageView_backGround, 0, 320-positionX_imageView_backGround*2, height_imageView_backGround)];
        _imageView_backGround.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_backGround];
        
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 320-positionX_imageView_backGround*2-2, height_imageView_backGround)];
        _backView.backgroundColor = [UIColor clearColor];
        [_imageView_backGround addSubview:_backView];
        
        
        _label_nameChinese = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 220, 30)];
        if(ios7)
        {
            _label_nameChinese.frame = CGRectMake(12, 12, 220, 20);
        }
        _label_nameChinese.backgroundColor = [UIColor clearColor];
        _label_nameChinese.textColor = [UIColor blackColor];
        _label_nameChinese.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:label_Chinese_Font];
        [_imageView_backGround addSubview:_label_nameChinese];
        
        
        _label_nameEnglish = [[UILabel alloc] initWithFrame:CGRectMake(12, 34, 220, 20)];
        if(ios7)
        {
            _label_nameEnglish.frame = CGRectMake(12, 34, 220, 16);
        }
        _label_nameEnglish.backgroundColor = [UIColor clearColor];
        _label_nameEnglish.textColor = [UIColor colorWithRed:103/255. green:152/255. blue:157/255. alpha:1];
        _label_nameEnglish.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:label_English_Font];
        _label_nameEnglish.shadowColor = [UIColor whiteColor];
        _label_nameEnglish.shadowOffset = CGSizeMake(1, 1);
        [_imageView_backGround addSubview:_label_nameEnglish];
        
        
        
        UIImageView *countBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(235, 21, 37, 19)];
        [countBGImageView setImage:[UIImage imageNamed:@"category_cell_countbg.png"]];
        [_imageView_backGround addSubview:countBGImageView];
        _label_guideNumber = [[UILabel alloc] initWithFrame:CGRectMake(1, 4, 35, 17)];
        if(ios7)
        {
            _label_guideNumber.frame = CGRectMake(1, 1, 35, 17);
        }
        _label_guideNumber.backgroundColor = [UIColor clearColor];
        _label_guideNumber.textColor = [UIColor colorWithRed:103/255. green:152/255. blue:157/255. alpha:1];
        _label_guideNumber.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:label_guideNumber_Font];
        _label_guideNumber.textAlignment = NSTextAlignmentCenter;
        [countBGImageView addSubview:_label_guideNumber];
        [_imageView_backGround addSubview:countBGImageView];
        [countBGImageView release];
        
        
        
        UIImageView *imageView_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280, 20, 20, 20)];
        imageView_arrow.backgroundColor = [UIColor clearColor];
        imageView_arrow.image = [UIImage imageNamed:@"箭头.png"];
        [_imageView_backGround addSubview:imageView_arrow];
        [imageView_arrow release];
        
        
        
        _imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_imageView_backGround, height_imageView_backGround-1, _imageView_backGround.frame.size.width, 2)];
        _imageView_lastCell.alpha = 0;
        _imageView_lastCell.backgroundColor = [UIColor clearColor];
        _imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影.png"];
        [self addSubview:_imageView_lastCell];
        
    }
    return self;
}


#pragma mark -
#pragma mark --- initWithCategory
-(void)initWithCategoryArray:(NSArray *)array atPosition:(NSInteger)position
{
    QYGuideCategory *guideCategory = [array objectAtIndex:position];
    
    
    self.label_nameChinese.text = guideCategory.str_categoryName;
    self.label_guideNumber.text = guideCategory.str_mobileGuideCount;
    self.label_nameEnglish.text = guideCategory.str_categoryNameEn;
    
    
    _imageView_lastCell.alpha = 0;
    _imageView_backGround.image = [[UIImage imageNamed:@"我的行程_list2.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    if(position == 0)
    {
        _imageView_backGround.image = [[UIImage imageNamed:@"我的行程_list1.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    }
    else if(position == [array count]-1)
    {
        _imageView_lastCell.alpha = 1;
    }
}


#pragma mark -
#pragma mark --- setHighlighted
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted)
    {
        _backView.backgroundColor = [UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3];
    }
    else
    {
        [self performSelector:@selector(setBackgroundColor) withObject:[UIColor clearColor] afterDelay:0.1];
    }
}
-(void)setBackgroundColor
{
    _backView.backgroundColor = [UIColor clearColor];
}


#pragma mark -
#pragma mark --- 计算String所占的高度
-(float)countContentLabelWidthByString:(NSString*)content andFontNmae:(NSString *)fontName  andHeight:(float)height andFontSize:(float)font
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName size:font] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)];
    
    return sizeToFit.width;
}



#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
