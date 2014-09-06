#import "LineSpaceLabel.h"
#import <CoreText/CoreText.h>
#import<Foundation/Foundation.h>
@implementation LineSpaceLabel
@synthesize lineSpace = lineSpace_;
@synthesize charSpace = charSpace_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        lineSpace_ = 5.0;
        charSpace_ = 0.0;
        
    }
    return self;
}



-(void)setCharSpace:(CGFloat)charSpace{
    charSpace_ = charSpace;
    [self setNeedsDisplay];
}
-(void)setLineSpace:(CGFloat)lineSpace{
    lineSpace_ = lineSpace;
    [self setNeedsDisplay];
}

-(void) drawTextInRect:(CGRect)requestedRect

{
    
    //创建AttributeString
    
    NSMutableAttributedString *string =[[NSMutableAttributedString alloc]initWithString:self.text];
    
    //设置字体及大小
    
    CTFontRef helveticaBold = CTFontCreateWithName((CFStringRef)self.font.fontName,self.font.pointSize,NULL);
    
    [string addAttribute:(id)kCTFontAttributeName value:(id)helveticaBold range:NSMakeRange(0,[string length])];
    
    //设置字间距
    
    if(self.charSpace)
        
    {
        long number = self.charSpace;
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
        [string addAttribute:(id)kCTKernAttributeName value:(id)num range:NSMakeRange(0,[string length])];
        CFRelease(num);
    }
    
    //设置字体颜色
    
    [string addAttribute:(id)kCTForegroundColorAttributeName value:(id)(self.textColor.CGColor) range:NSMakeRange(0,[string length])];
    
    //创建文本对齐方式
    
    CTTextAlignment alignment = kCTLeftTextAlignment;
    
    if(self.textAlignment == NSTextAlignmentCenter)
        
    {
        alignment = kCTCenterTextAlignment;
        
    }
    
    if(self.textAlignment == NSTextAlignmentLeft)
        
    {
        
        alignment = kCTLeftTextAlignment;
        
    }
    
    CTParagraphStyleSetting alignmentStyle;
    
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
    
    alignmentStyle.valueSize = sizeof(alignment);
    
    alignmentStyle.value = &alignment;
    
    //设置文本行间距
    
    CGFloat lineSpace = self.lineSpace;
    
    CTParagraphStyleSetting lineSpaceStyle;
    
    lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    
    lineSpaceStyle.valueSize = sizeof(lineSpace);
    
    lineSpaceStyle.value =&lineSpace;
    
    //设置文本段间距
    
    CGFloat paragraphSpacing = 0.0;
    
    CTParagraphStyleSetting paragraphSpaceStyle;
    
    paragraphSpaceStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    
    paragraphSpaceStyle.valueSize = sizeof(CGFloat);
    
    paragraphSpaceStyle.value = &paragraphSpacing;
    
    
    
    //设置首行缩进
    /*
    CGFloat firstLineHeadIndentSpacing = 0;
    
    CTParagraphStyleSetting firstLineHeadIndentSpaceStyle;
    
    firstLineHeadIndentSpaceStyle.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
    
    firstLineHeadIndentSpaceStyle.valueSize = sizeof(CGFloat);
    
    firstLineHeadIndentSpaceStyle.value = &firstLineHeadIndentSpacing;
    */
    
    
    //创建设置数组
    
    CTParagraphStyleSetting settings[ ] ={alignmentStyle,lineSpaceStyle,paragraphSpaceStyle};
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings ,3);
    
    //给文本添加设置
    
    [string addAttribute:(id)kCTParagraphStyleAttributeName value:(id)style range:NSMakeRange(0 , [string length])];
    
    //排版
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    
    CGPathAddRect(leftColumnPath, NULL ,CGRectMake(0 , 0 ,self.bounds.size.width , self.bounds.size.height));
    
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), leftColumnPath , NULL);
    
    //翻转坐标系统（文本原来是倒的要翻转下）
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
    
    CGContextTranslateCTM(context , 0 ,self.bounds.size.height);
    
    CGContextScaleCTM(context, 1.0 ,-1.0);
    
    //画出文本
    
    CTFrameDraw(leftFrame,context);
    
    //释放
    
    CGPathRelease(leftColumnPath);
    
    CFRelease(framesetter);
    
    CFRelease(helveticaBold);
    
    [string release];
    
    UIGraphicsPushContext(context);
    
    CFRelease(style);
    CFRelease(leftFrame);
}

@end