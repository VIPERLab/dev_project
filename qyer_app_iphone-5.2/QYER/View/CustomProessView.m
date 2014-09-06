//
//  CustomProessView.m
//  QyGuide
//
//  Created by Qyer on 13-1-8.
//
//

#import "CustomProessView.h"
#import <QuartzCore/QuartzCore.h>




@implementation CustomProessView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setTintColorWithImage:(UIImage *)image
{
    if(!image)
    {
        return;
    }
    [_tintColor release];
    _tintColor = [[UIColor colorWithPatternImage:image] retain];
}
-(void)setBackGroundTintColor:(UIColor *)color
{
    if(!color)
    {
        return;
    }
    [_backgroundColor release];
    _backgroundColor = [color retain];
}
-(void)setBackGroundTintColorWithImage:(UIImage *)image
{
    if(!image)
    {
        return;
    }
    [_backgroundColor release];
    _backgroundColor = [[UIColor colorWithPatternImage:image] retain];
}



 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
     // Drawing code
     
     
     if([self progressViewStyle] == UIProgressViewStyleDefault)
     {
         self.layer.masksToBounds = YES;
         
         self.layer.cornerRadius = 2;
         CGContextRef ctx = UIGraphicsGetCurrentContext();
         CGContextSetFillColorWithColor(ctx, [_backgroundColor CGColor]);
         CGContextFillRect(ctx, rect);
         CGRect progressRect = rect;
         progressRect.size.width *= [self progress];
         //        addRoundedRectToPath(ctx, progressRect, 4, 4); //圆角处理
         //CGContextClip(ctx);
         //Progress Tint Color
         CGContextSetFillColorWithColor(ctx, [_tintColor CGColor]);
         CGContextFillRect(ctx, progressRect);
         progressRect.size.width -= 1.25;
         progressRect.origin.x += 0.625;
         progressRect.size.height -= 1.25;
         progressRect.origin.y += 0.625;
         //        addRoundedRectToPath(ctx, progressRect, 2, 2); //圆角处理
         //CGContextClip(ctx);
         CGContextSetLineWidth(ctx, 1);
         CGContextSetRGBStrokeColor(ctx, 20/255., 20/255., 20/255.,0);
         CGContextStrokeRect(ctx, progressRect);
     }
     else
     {
         [super drawRect: rect];
     }
 }




void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                          float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@end
