//
//  PlayMusicLyricView.m
//  KwSing
//
//  Created by Qian Hu on 12-8-10.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "PlayMusicLyricView.h"
#include "LyricInfo.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

#define REFRESTH_LYRIC_INTERVAL     0.03

@implementation PlayMusicLyricView

-(void)StopRefresh
{
    [timer invalidate];
    timer=NULL;
}

-(void) SetLyricInfo:(CLyricInfo*)plyricinfo
{
    if(plyricinfo == NULL)
    {
        m_bFail = true;
        [self setNeedsDisplay];
    }
    else
        m_pLyricInfo = plyricinfo;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        timer = [NSTimer scheduledTimerWithTimeInterval:REFRESTH_LYRIC_INTERVAL target:self selector:@selector(onRefreshLyric) userInfo:nil repeats:YES];
        self.backgroundColor = [UIColor clearColor];
        m_pLyricInfo = NULL;
        m_pMediaInterface = NULL;
        nCurSentenceID = -1;
        m_bFail = false;
    }
    return self;
}


-(void) SetMedia:(CMediaInterface*) mediaInterface
{
    m_pMediaInterface = mediaInterface;
}

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if(idelegate)
//        [idelegate onTouchEnd:self];
//}

-(void)onRefreshLyric
{
    if(!m_pMediaInterface || !m_pLyricInfo)
        return;
    DRAW_WORD_INFO wordinfo;
    int ntimenum = m_pMediaInterface->CurrentTime();
    m_pLyricInfo->GetDrawWordInfo(ntimenum,wordinfo);

    if (nCurSentenceID == -1 && wordinfo.pCurrentSentence) {
        nCurSentenceID = wordinfo.pCurrentSentence->uiId;
        [self setNeedsDisplay];
    }
    else if(wordinfo.pCurrentSentence){
        nCurSentenceID = wordinfo.pCurrentSentence->uiId;
        [self setNeedsDisplay];
    }

}

- (void)drawRect:(CGRect)rect
{
    NSMutableAttributedString* sentence(NULL);
    if(!m_pMediaInterface || !m_pLyricInfo || m_pLyricInfo->GetLyricType() == LYRIC_NONE)
    {
        if(!m_bFail)
            sentence = [[NSMutableAttributedString alloc]initWithString:@"正在搜索歌词..."];
    }
    else {
        int ntimenum = m_pMediaInterface->CurrentTime();
        DRAW_SENTENCE_INFO info;
        if(!m_pLyricInfo->GetDrawSentenceInfo(ntimenum, info))
            return;
        
        NSString* str_sentence = [info.pCurrentSentenceInfo->str string];
        int n_sentence_len = [str_sentence length];
        
        if (17 <= n_sentence_len) {
            NSArray* sub_str = [str_sentence componentsSeparatedByString:@" "];
            switch ([sub_str count]) {
                case 1:
                {
                    if (ntimenum < ((info.pCurrentSentenceInfo->uiStartTime + info.pCurrentSentenceInfo->uiEndTime) / 2.0)) {
                        sentence = [[NSMutableAttributedString alloc] initWithString : [str_sentence substringToIndex:(n_sentence_len / 2)]];
                    }else {
                        sentence = [[NSMutableAttributedString alloc] initWithString : [str_sentence substringFromIndex : (n_sentence_len / 2)]];
                    }
                    break;
                }
                case 2:
                {
                    if (ntimenum < ((info.pCurrentSentenceInfo->uiStartTime + info.pCurrentSentenceInfo->uiEndTime) / 2.0)){
                        sentence = [[NSMutableAttributedString alloc] initWithString:(NSString *)sub_str[0]];
                    }else {
                        sentence = [[NSMutableAttributedString alloc] initWithString:(NSString *)sub_str[1]];
                    }
                    break;
                }
                    
                default:
                {
                    NSAttributedString* str_blank = [[NSAttributedString alloc] initWithString:@" "];
                    sentence = [[NSMutableAttributedString alloc] initWithString:@" "];
                    if (ntimenum < ((info.pCurrentSentenceInfo->uiStartTime + info.pCurrentSentenceInfo->uiEndTime) / 2.0)){
                        for (int n_index = 0; n_index < ([sub_str count] / 2); ++n_index) {
                            NSAttributedString* str_temp = [[NSAttributedString alloc] initWithString : (NSString*)sub_str[n_index]];
                            [sentence appendAttributedString:str_temp];
                            [sentence appendAttributedString:str_blank];
                            [str_temp release];
                            str_temp = nil;
                        }
                    }else {
                        for (int n_index = ([sub_str count] / 2); n_index < [sub_str count]; ++n_index) {
                            NSAttributedString* str_temp = [[NSAttributedString alloc] initWithString : (NSString*)sub_str[n_index]];
                            [sentence appendAttributedString:str_temp];
                            [sentence appendAttributedString:str_blank];
                            [str_temp release];
                            str_temp = nil;
                        }
                    }
                    
                    [str_blank release];
                    str_blank = nil;
                    
                    break;
                }
            }
        }else {
            sentence = [[NSMutableAttributedString alloc] initWithAttributedString:info.pCurrentSentenceInfo->str];
        }
    }
    
    if (!sentence) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat startx = 0;
    CGFloat starty = 10;
    
    CGFloat radio = 1;
    starty /= radio;
    
    double width;

    int len = [sentence length];
    {
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, radio, -radio);
        
        [sentence addAttribute:(NSString *)(kCTForegroundColorAttributeName) value:(id)[UIColor blackColor].CGColor range:NSMakeRange(0, len)];
        CTFontRef helveticaBold = CTFontCreateWithName((CFStringRef)@"宋体",17,NULL);
        [sentence addAttribute:(id)kCTFontAttributeName value:(id)helveticaBold range:NSMakeRange(0,len)];
//        CTLineRef lineshadow = CTLineCreateWithAttributedString((CFAttributedStringRef)sentence);
//        CGFloat fas,fde,fled;
//        width = CTLineGetTypographicBounds( lineshadow, &fas, &fde, &fled);
        
///        startx = ([self bounds].size.width/radio - width)/2;
//        CGContextSetTextPosition(context, startx, starty);
//        
//        CTLineDraw(lineshadow, context);
//        [sentence removeAttribute:(NSString *)(kCTForegroundColorAttributeName) range:NSMakeRange(0, len)];
        
        [sentence addAttribute:(NSString *)(kCTForegroundColorAttributeName) value:(id)[UIColor whiteColor].CGColor range:NSMakeRange(0, len)];
        
        CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)sentence);
        CGFloat fas,fde,fled;
        width = CTLineGetTypographicBounds( line, &fas, &fde, &fled);
        
        startx = ([self bounds].size.width/radio - width)/2;
        
        CGContextSetTextPosition(context, startx, starty+1/radio);
        CGContextSetShadowWithColor(context, CGSizeMake(0, 1),0.5,[UIColor blackColor].CGColor);
        CTLineDraw(line, context);
        
        CGContextRestoreGState(context);
        
        [sentence removeAttribute:(id)kCTFontAttributeName range:NSMakeRange(0, len)];
        [sentence removeAttribute:(NSString *)(kCTForegroundColorAttributeName) range:NSMakeRange(0, len)];
        
        CFRelease(line);
//        CFRelease(lineshadow);
        CFRelease(helveticaBold);
    }
    if (NULL != sentence) {
        [sentence release];
        sentence = nil;
    }
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
