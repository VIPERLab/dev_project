//
//  PoiImageCell.m
//  QyGuide
//
//  Created by an qing on 13-2-19.
//
//

#import "PoiImageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"



@implementation PoiImageCell
@synthesize bgView     = _bgView;
@synthesize imageView1 = _imageView1;
@synthesize imageView2 = _imageView2;
@synthesize imageView3 = _imageView3;
@synthesize imageView4 = _imageView4;
@synthesize control1   = _control1;
@synthesize control2   = _control2;
@synthesize control3   = _control3;
@synthesize control4   = _control4;
@synthesize delegate   = _delegate;

//@synthesize ll;

-(void)dealloc
{
    [_control1 release];
    [_control2 release];
    [_control3 release];
    [_control4 release];
    [_imageView1 release];
    [_imageView2 release];
    [_imageView3 release];
    [_imageView4 release];
    [_bgView release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        float x = (320-poiImageViewHeight*poiImageNumberOfOneLine)/(poiImageNumberOfOneLine+1.0);
        float y = x;
        
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, poiImageViewHeight+y*2)];
        _bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bgView];
        
        
        _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, poiImageViewHeight, poiImageViewHeight)];
        _imageView1.userInteractionEnabled = YES;
        _imageView1.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView1];
        _control1 = [[MyPoiImageViewControl alloc] initWithFrame:CGRectMake(0, 0, poiImageViewHeight, poiImageViewHeight)];
        _control1.backgroundColor = [UIColor clearColor];
        [_imageView1 addSubview:_control1];
        [_control1 addTarget:self action:@selector(browserPoiImage:) forControlEvents:UIControlEventTouchUpInside];
//        _active1 = [[UIActivityIndicatorView alloc]
//                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _active1.center = _imageView1.center;
//        [self addSubview:_active1];
//        [_active1 startAnimating];
        
        
//        ll = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 75, 20)];
//        ll.backgroundColor = [UIColor redColor];
//        ll.textColor = [UIColor yellowColor];
//        ll.textAlignment = UITextAlignmentCenter;
//        ll.font = [UIFont systemFontOfSize:11.];
//        [_imageView1 addSubview:ll];
        
        
        
        
        
        
        _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(x+poiImageViewHeight+x, y, poiImageViewHeight, poiImageViewHeight)];
        _imageView2.userInteractionEnabled = YES;
        _imageView2.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView2];
        _control2 = [[MyPoiImageViewControl alloc] initWithFrame:CGRectMake(0, 0, poiImageViewHeight, poiImageViewHeight)];
        _control2.backgroundColor = [UIColor clearColor];
        [_imageView2 addSubview:_control2];
        [_control2 addTarget:self action:@selector(browserPoiImage:) forControlEvents:UIControlEventTouchUpInside];
//        _active2 = [[UIActivityIndicatorView alloc]
//                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _active2.center = _imageView2.center;
//        [self addSubview:_active2];
//        [_active2 startAnimating];
        
        
        
        _imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(x+poiImageViewHeight+x+poiImageViewHeight+x, y, poiImageViewHeight, poiImageViewHeight)];
        _imageView3.userInteractionEnabled = YES;
        _imageView3.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView3];
        _control3 = [[MyPoiImageViewControl alloc] initWithFrame:CGRectMake(0, 0, poiImageViewHeight, poiImageViewHeight)];
        _control3.backgroundColor = [UIColor clearColor];
        [_imageView3 addSubview:_control3];
        [_control3 addTarget:self action:@selector(browserPoiImage:) forControlEvents:UIControlEventTouchUpInside];
//        _active3 = [[UIActivityIndicatorView alloc]
//                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _active3.center = _imageView3.center;
//        [self addSubview:_active3];
//        [_active3 startAnimating];
        
        
        _imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(x+poiImageViewHeight+x+poiImageViewHeight+x+poiImageViewHeight+x, y, poiImageViewHeight, poiImageViewHeight)];
        _imageView4.userInteractionEnabled = YES;
        _imageView4.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView4];
        _control4 = [[MyPoiImageViewControl alloc] initWithFrame:CGRectMake(0, 0, poiImageViewHeight, poiImageViewHeight)];
        _control4.backgroundColor = [UIColor clearColor];
        [_imageView4 addSubview:_control4];
        [_control4 addTarget:self action:@selector(browserPoiImage:) forControlEvents:UIControlEventTouchUpInside];
//        _active4 = [[UIActivityIndicatorView alloc]
//                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _active4.center = _imageView4.center;
//        [self addSubview:_active4];
//        [_active4 startAnimating];
        
    }
    return self;
}

-(void)browserPoiImage:(MyPoiImageViewControl*)control
{
    if(_delegate && [_delegate respondsToSelector:@selector(PoiImageCellDidSelected:)])
    {
        [_delegate PoiImageCellDidSelected:control];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
