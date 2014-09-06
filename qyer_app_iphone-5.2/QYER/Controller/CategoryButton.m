//
//  CategoryButton.m
//  LastMinute
//
//  Created by lide on 13-6-25.
//
//

#import "CategoryButton.h"

@implementation CategoryButton

//@synthesize iconArrow = _iconArrow;
@synthesize checkTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.exclusiveTouch = YES;
        
        // Initialization code
//        _iconArrow = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 40, (frame.size.height - 20) / 2, 20, 20)];
//        _iconArrow.backgroundColor = [UIColor clearColor];
//        _iconArrow.image = [UIImage imageNamed:@"arrow_down.png"];
//        [self addSubview:_iconArrow];
        
//        _littleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 6, frame.size.height - 6, 6, 6)];
//        _littleImageView.backgroundColor = [UIColor clearColor];
//        _littleImageView.image = [UIImage imageNamed:@"little.png"];
//        [self addSubview:_littleImageView];
    }
    return self;
}

- (void)dealloc
{
//    QY_VIEW_RELEASE(_iconArrow);
    
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

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    self.checkTitle = title;
    
    if(title && title.length > 5)
    {
        title = [[title substringToIndex:4] stringByAppendingString:@"..."];
    }
    
    [super setTitle:title forState:state];
    
//    CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByCharWrapping];
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    _iconArrow.frame = CGRectMake((self.frame.size.width + size.width) / 2 - 7, (self.frame.size.height - 20) / 2, 20, 20);
//    _littleImageView.frame = CGRectMake(self.frame.size.width - 6.5, self.frame.size.height - 6.5, 6, 6);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
//    if(selected)
//    {
//        _iconArrow.image = [UIImage imageNamed:@"arrow_up.png"];
//    }
//    else
//    {
//        _iconArrow.image = [UIImage imageNamed:@"arrow_down.png"];
//    }
}

@end
