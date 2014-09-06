
//
//  CatalogCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "CatalogCell.h"
#import "GuideMenu.h"


#define     positionX_imageView_backGround      8


@implementation CatalogCell
@synthesize label_catalogName = _label_catalogName;
@synthesize label_pageNumber = _label_pageNumber;
@synthesize imgView_bookmark = _imgView_bookmark;


-(void)dealloc
{
    QY_VIEW_RELEASE(_imgView_bookmark);
    QY_VIEW_RELEASE(_imageView_lastCell);
    QY_VIEW_RELEASE(_label_pageNumber);
    QY_VIEW_RELEASE(_label_catalogName);
    QY_VIEW_RELEASE(_view_backGround);
    QY_VIEW_RELEASE(_imageView_backGround);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _imageView_backGround = [[UIImageView alloc] initWithFrame:CGRectMake(positionX_imageView_backGround, 0, 320-positionX_imageView_backGround*2, 0)];
        _imageView_backGround.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_backGround];
        
        _view_backGround = [[UIView alloc] initWithFrame:CGRectMake(0,0,_imageView_backGround.frame.size.width,_imageView_backGround.frame.size.height)];
        [_imageView_backGround addSubview:_view_backGround];
        
        
        _label_pageNumber = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_label_pageNumber, 45, height_catalogName_default)];
        _label_pageNumber.backgroundColor = [UIColor clearColor];
        _label_pageNumber.font = [UIFont fontWithName:fontName_CatalogCell size:fontSize_CatalogCell];
        _label_pageNumber.adjustsFontSizeToFitWidth = NO;
        _label_pageNumber.textAlignment = NSTextAlignmentLeft;
        _label_pageNumber.textColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:1];
        [_imageView_backGround addSubview:_label_pageNumber];
        
        
        _label_catalogName = [[UILabel alloc] initWithFrame:CGRectMake(_label_pageNumber.frame.origin.x+_label_pageNumber.frame.size.width, positionY_label_catalogName, fixedWidth_CatalogCell, height_catalogName_default)];
        _label_catalogName.backgroundColor = [UIColor clearColor];
        [_label_catalogName setFont:[UIFont fontWithName:fontName_CatalogCell size:fontSize_CatalogCell]];
        _label_catalogName.numberOfLines = 0;
        _label_catalogName.textColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:1];
        //_label_catalogName.adjustsFontSizeToFitWidth = YES;
        [_imageView_backGround addSubview:_label_catalogName];
        
        
        
        _imgView_bookmark = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView_backGround.bounds.size.width-35, 0, 40, 40)];
        _imgView_bookmark.backgroundColor = [UIColor clearColor];
        _imgView_bookmark.image = [UIImage imageNamed:@"btn_reader_bookmark_click.png"];
        [_imageView_backGround addSubview:_imgView_bookmark];
        _imgView_bookmark.alpha = 0;
        
        
        
        _imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _imageView_backGround.frame.size.width, 2)];
        _imageView_lastCell.alpha = 0;
        _imageView_lastCell.backgroundColor = [UIColor clearColor];
        _imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影"];
        [_imageView_backGround addSubview:_imageView_lastCell];
        
    }
    return self;
}

-(void)initWithCatelogArray:(NSArray *)array_catelog andBookmarkArray:(NSArray *)array_bookmark atPosition:(NSInteger)position
{
    if(array_catelog.count == 0)
    {
        return;
    }
    
    
    
    GuideMenu *menu = [array_catelog objectAtIndex:position];
    if(position >= array_catelog.count)
    {
        position = 0;
    }
    
    if([menu.str_pageNumber intValue] > 9)
    {
        _label_pageNumber.text = [NSString stringWithFormat:@"%@ --",menu.str_pageNumber];
    }
    else
    {
        _label_pageNumber.text = [NSString stringWithFormat:@"0%@ --",menu.str_pageNumber];
    }
    _label_catalogName.text = menu.title_menu;
    CGRect frame = _label_catalogName.frame;
    frame.size.height = [menu.str_titleHeight floatValue];
    _label_catalogName.frame = frame;
    
    
    
    
    float height = [menu.str_titleHeight floatValue];
    _imageView_lastCell.alpha = 0;
    frame = _imageView_backGround.frame;
    if(ios7)
    {
        frame.size.height = height + 2*positionY_label_catalogName;
    }
    else
    {
        frame.size.height = height + 2*positionY_label_catalogName -6;
    }
    _imageView_backGround.frame = frame;
    frame = _imageView_lastCell.frame;
    frame.origin.y = _imageView_backGround.frame.size.height;
    frame.origin.x = 0;
    frame.size.width = _imageView_backGround.frame.size.width;
    _imageView_lastCell.frame = frame;
    _imageView_backGround.image = [[UIImage imageNamed:@"我的行程_list2.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    if(position == 0)
    {
        _imageView_backGround.image = [[UIImage imageNamed:@"我的行程_list1.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    }
    if(position == [array_catelog count]-1)
    {
        _imageView_lastCell.alpha = 1;
    }
    
    
    
    
    for(BookMark *bookmark in array_bookmark)
    {
        if([[bookmark str_bookMarkTitle] isEqualToString:self.label_catalogName.text])
        {
            _imgView_bookmark.alpha = 1;
            break;
        }
        else
        {
            _imgView_bookmark.alpha = 0;
        }
    }
}


#pragma mark -
#pragma mark --- initBookMark
-(void)initBookMarkCatelogWithArray:(NSArray *)array atPosition:(NSInteger)position
{
    BookMark *bookMark = [array objectAtIndex:position];
    if([bookMark.str_bookMarkPageNumber floatValue]+1 - 9 > 0)
    {
        _label_pageNumber.text = [NSString stringWithFormat:@"%d --",[bookMark.str_bookMarkPageNumber intValue]+1];
    }
    else
    {
        _label_pageNumber.text = [NSString stringWithFormat:@"0%d --",[bookMark.str_bookMarkPageNumber intValue]+1];
    }
    
    
    
    float height = [CatalogCell countContentLabelHeightByString:bookMark.str_bookMarkTitle andFontNmae:fontName_CatalogCell andLength:240 andFontSize:fontSize_CatalogCell];
    CGRect frame = _label_catalogName.frame;
    frame.size.width = 240;
    frame.size.height = height;
    _label_catalogName.frame = frame;
    _label_catalogName.text = bookMark.str_bookMarkTitle;
    
    
    
    
    _imageView_lastCell.alpha = 0;
    frame = _imageView_backGround.frame;
    if(ios7)
    {
        frame.size.height = height + 2*positionY_label_catalogName;
    }
    else
    {
        frame.size.height = height + 2*positionY_label_catalogName -6;
    }
    frame.origin.x = 0;
    frame.size.width = 320;
    _imageView_backGround.frame = frame;
    frame = _imageView_lastCell.frame;
    frame.origin.x = 0;
    frame.size.width = _imageView_backGround.frame.size.width;
    frame.origin.y = _imageView_backGround.frame.size.height+0.5;
    _imageView_lastCell.frame = frame;
    _imageView_backGround.image = [[UIImage imageNamed:@"我的行程_list2.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    if(position == 0)
    {
        _imageView_backGround.image = [[UIImage imageNamed:@"我的行程_list1.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    }
    if(position == [array count]-1)
    {
        _imageView_lastCell.alpha = 1;
    }
    _imgView_bookmark.alpha = 0;
}



#pragma mark -
#pragma mark --- 计算String所占的高度
+(float)countContentLabelHeightByString:(NSString *)content andFontNmae:(NSString *)fontName andLength:(float)length andFontSize:(float)font
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    float height = ((sizeToFit.height - minHeight_CatalogCell > 0) ? sizeToFit.height:minHeight_CatalogCell);
    
    return height;
}
+(float)cellHeightWithContent:(NSString *)string andLength:(NSInteger)width
{
    float height = [CatalogCell countContentLabelHeightByString:string andFontNmae:fontName_CatalogCell andLength:width andFontSize:fontSize_CatalogCell];
    
    if(ios7)
    {
        return height + positionY_label_catalogName*2;
    }
    return height + positionY_label_catalogName*2 -6;
}



#pragma mark -
#pragma mark --- setHighlighted
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted)
    {
        _view_backGround.backgroundColor = [UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3];
    }
    else
    {
        _view_backGround.backgroundColor = [UIColor clearColor];
    }
}


#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
