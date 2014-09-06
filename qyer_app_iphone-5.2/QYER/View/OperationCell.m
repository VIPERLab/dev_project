//
//  OperationCell.m
//  QyGuide
//
//  Created by an qing on 12-12-26.
//
//

#import "OperationCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation OperationCell
@synthesize RecommendGuideVC;
@synthesize backGroundView;
@synthesize imageView1,imageView2,imageView3,imageView4;


-(void)dealloc
{
    RecommendGuideVC = nil;
    
    backGroundView = nil;
    imageView1 = nil;
    imageView2 = nil;
    imageView3 = nil;
    imageView4 = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        backGroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 198+16/2*3)];
        backGroundView.userInteractionEnabled = YES;
        backGroundView.backgroundColor = [UIColor clearColor];
        //backGroundView.image = [UIImage imageNamed:@"bg_introduce.png"];
        [self addSubview:backGroundView];
        
        
        imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 296/2, 198/2.)];
        imageView1.backgroundColor = [UIColor clearColor];
        imageView1.image = [UIImage imageNamed:@"运营页logo默认图.png"];
        [backGroundView addSubview:imageView1];
        //imageView1.layer.masksToBounds = YES;
        //[imageView1.layer setCornerRadius:8];
        UIControl *control1 = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 296/2, 198/2.)];
        imageView1.userInteractionEnabled = YES;
        [imageView1 addSubview:control1];
        control1.tag = 10;
        [control1 addTarget:self.RecommendGuideVC action:@selector(produceOperationPage:) forControlEvents:UIControlEventTouchUpInside];
        [control1 release];
        
        
        imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(imageView1.frame.origin.x+imageView1.frame.size.width+8, 8, 296/2., 198/2.)];
        imageView2.backgroundColor = [UIColor clearColor];
        imageView2.image = [UIImage imageNamed:@"运营页logo默认图.png"];
        [backGroundView addSubview:imageView2];
        //imageView2.layer.masksToBounds = YES;
        //[imageView2.layer setCornerRadius:8];
        UIControl *control2 = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 296/2, 198/2.)];
        imageView2.userInteractionEnabled = YES;
        [imageView2 addSubview:control2];
        control2.tag = 11;
        [control2 addTarget:self.RecommendGuideVC action:@selector(produceOperationPage:) forControlEvents:UIControlEventTouchUpInside];
        [control2 release];
        
        
        imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(8, imageView1.frame.origin.y+imageView1.frame.size.height+8, 296/2., 198/2.)];
        imageView3.backgroundColor = [UIColor clearColor];
        imageView3.image = [UIImage imageNamed:@"运营页logo默认图.png"];
        [backGroundView addSubview:imageView3];
        //imageView3.layer.masksToBounds = YES;
        //[imageView3.layer setCornerRadius:8];
        UIControl *control3 = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 296/2, 198/2.)];
        imageView3.userInteractionEnabled = YES;
        [imageView3 addSubview:control3];
        control3.tag = 12;
        [control3 addTarget:self.RecommendGuideVC action:@selector(produceOperationPage:) forControlEvents:UIControlEventTouchUpInside];
        [control3 release];
        
        
        imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(imageView1.frame.origin.x+imageView1.frame.size.width+8, imageView1.frame.origin.y+imageView1.frame.size.height+8, 296/2, 198/2.)];
        imageView4.backgroundColor = [UIColor clearColor];
        imageView4.image = [UIImage imageNamed:@"运营页logo默认图.png"];
        [backGroundView addSubview:imageView4];
        //imageView4.layer.masksToBounds = YES;
        //[imageView4.layer setCornerRadius:8];
        UIControl *control4 = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 296/2, 198/2.)];
        imageView4.userInteractionEnabled = YES;
        [imageView4 addSubview:control4];
        control4.tag = 13;
        [control4 addTarget:self.RecommendGuideVC action:@selector(produceOperationPage:) forControlEvents:UIControlEventTouchUpInside];
        [control4 release];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
