//
//  KSongLyricView.m
//  KwSing
//
//  Created by Qian Hu on 12-7-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSongLyricView.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#include "globalm.h"
#include "LyricInfo.h"
#include <map>
#include <algorithm>

#define REFRESTH_LYRIC_INTERVAL     0.03
#define CAP_WIDTH                   10
#define CAP_HEIGHT                  5
#define COLOR_LYRIC_HIGHLIGHT       0xffe400
 
typedef struct
{
    NSMutableAttributedString* sentence;
    CTLineRef lineNormal;
    CTLineRef lineHighlight;
    double width;
}Draw_Sentence_Line_INFO;
typedef std::map<NSMutableAttributedString*,Draw_Sentence_Line_INFO*> MAP_LINE_INFOS;

@interface KSongLyricView()
{
    MAP_LINE_INFOS mapLineInfos;
}
    
@end

@implementation KSongLyricView

-(void)StopRefresh
{
    [timer invalidate];
    timer=NULL;
    m_pMediaInterface=NULL;
    [self clearLineMap];
}

-(void)dealloc
{
    [self clearLineMap];
    [super dealloc];
}

-(void)clearLineMap
{
    for (MAP_LINE_INFOS::iterator ite=mapLineInfos.begin(); ite!=mapLineInfos.end();++ite) {
        CFRelease(ite->second->lineNormal);
        CFRelease(ite->second->lineHighlight);
        delete ite->second;
    }
    mapLineInfos.clear();
}

-(void) SetLyricInfo:(CLyricInfo*)plyricinfo
{
    m_pLyricInfo = plyricinfo;
    [self clearLineMap];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        timer = [NSTimer scheduledTimerWithTimeInterval:REFRESTH_LYRIC_INTERVAL target:self selector:@selector(onRefreshLyric) userInfo:nil repeats:YES];
        uiCurSentenceID = -1;
        bHighlightTopLine = 1;
        m_pLyricInfo = NULL;
        m_pMediaInterface = NULL;
    }
   
    return self;
}

-(void)onRefreshLyric
{
    if(!m_pMediaInterface || !m_pLyricInfo || (m_pLyricInfo && m_pLyricInfo->GetLyricType() == LYRIC_NONE))
        return;
    
    [self setNeedsDisplay];
}

-(void) SetMedia:(CMediaInterface*) mediaInterface
{
    m_pMediaInterface = mediaInterface;
}

#define HEIGHT_LYRIC_SENTENCE 55
- (void)drawRect:(CGRect)rect
{
    if(!m_pMediaInterface || !m_pLyricInfo || (m_pLyricInfo && m_pLyricInfo->GetLyricType() == LYRIC_NONE))
        return;

    int ntimenum = m_pMediaInterface->CurrentTime();
    
    DRAW_SENTENCE_INFO info;
    if(!m_pLyricInfo->GetDrawSentenceInfo(ntimenum, info))
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw bk
    CGRect bkrc = BottomRect(self.bounds,HEIGHT_LYRIC_SENTENCE, 0);
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.15);
    CGContextAddRect(context, bkrc);
    CGContextFillPath(context);  

    if (uiCurSentenceID == -1) {
        uiCurSentenceID = info.pCurrentSentenceInfo->uiId;
        bHighlightTopLine = 1;
    }
    else if(uiCurSentenceID != info.pCurrentSentenceInfo->uiId){
        uiCurSentenceID = info.pCurrentSentenceInfo->uiId;
        bHighlightTopLine = !bHighlightTopLine;
    }
    
    if(info.eumCountDownStage != COUNTDOWN_NORMAL)
        bHighlightTopLine = true;
    
    // 倒计时
    if(info.eumCountDownStage >=1 && info.eumCountDownStage <= 4)
    {
        [self DrawCountDown:context Count:info.eumCountDownStage];
    }
    
    [self prepareDrawSentenceLine:&info];

    if (bHighlightTopLine) {
        if(info.pCurrentSentenceInfo != nil)
            [self DrawSentence:context :info.pCurrentSentenceInfo->str :true  :info.fCurrentPercent];
        if(info.pPostSentenceInfo != nil)
            [self DrawSentence:context :info.pPostSentenceInfo->str :false  :info.fCurrentPercent];
    }
    else {
        if(info.pPostSentenceInfo != nil)
            [self DrawSentence:context :info.pPostSentenceInfo->str :true :info.fCurrentPercent];
        if(info.pCurrentSentenceInfo != nil)
            [self DrawSentence:context :info.pCurrentSentenceInfo->str :false :info.fCurrentPercent];
    }
}

-(void)DrawCountDown:(CGContextRef) context Count:(int)nCount
{
    #define OUT_RADIUS 5
    #define IN_RADIUS  4 
    
    for(int i = 0;i < nCount;i++)
    {
        int x = OUT_RADIUS + 10 + (OUT_RADIUS*2+10)*i;
        CGContextBeginPath(context);
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
        CGContextAddArc(context,x,OUT_RADIUS+10,OUT_RADIUS,-M_PI,M_PI,1);
        CGContextFillPath(context);  
        
        CGContextBeginPath(context);
        CGContextSetRGBFillColor(context,0.38,0.48,0.84,1);//(context, 0, 0, 1, 1);
        CGContextAddArc(context,x,OUT_RADIUS+10,IN_RADIUS,-M_PI,M_PI,1);
        CGContextFillPath(context);  
    }
}

//[NSMutableAttributedString addAttribute]和CTLineCreateWithAttributedString是非常慢的
//每次重绘都反复执行很耗CPU，这个函数实现有新句子的时候才创建新的释放旧的
- (void)prepareDrawSentenceLine:(DRAW_SENTENCE_INFO*)pInfo
{
    NSMutableAttributedString* pSentenceStrs[3]={0,0,0};

    if(pInfo->pPreSentenceInfo)pSentenceStrs[0]=pInfo->pPreSentenceInfo->str;
    if(pInfo->pCurrentSentenceInfo)pSentenceStrs[1]=pInfo->pCurrentSentenceInfo->str;
    if(pInfo->pPostSentenceInfo)pSentenceStrs[2]=pInfo->pPostSentenceInfo->str;
    
    for (MAP_LINE_INFOS::iterator ite=mapLineInfos.begin(); ite!=mapLineInfos.end();) {
        NSMutableAttributedString** end=&pSentenceStrs[3]+1;
        if( end == std::find(pSentenceStrs, end, ite->first) ) {
            CFRelease(ite->second->lineNormal);
            CFRelease(ite->second->lineHighlight);
            delete ite->second;
            
            mapLineInfos.erase(ite++);
        } else {
            ++ite;
        }
    }
    if (mapLineInfos.size()<3) {
        for (int i=0; i<3; ++i) {
            if (pSentenceStrs[i]) {
                MAP_LINE_INFOS::iterator ite=mapLineInfos.find(pSentenceStrs[i]);
                if (ite==mapLineInfos.end()) {
                    Draw_Sentence_Line_INFO* p=new Draw_Sentence_Line_INFO;
                    
                    p->sentence=pSentenceStrs[i];
                    int len=[p->sentence length];
                    
                    //CTFontRef font = CTFontCreateWithName((CFStringRef)@"宋体",9.2,NULL);
                    //[p->sentence addAttribute:(id)kCTFontAttributeName value:(id)font range:NSMakeRange(0,len)];
                    [p->sentence addAttribute:(NSString *)(kCTForegroundColorAttributeName) value:(id)[UIColor whiteColor].CGColor range:NSMakeRange(0, len)];
                    p->lineNormal = CTLineCreateWithAttributedString((CFAttributedStringRef)p->sentence);
                    [p->sentence removeAttribute:(NSString *)(kCTForegroundColorAttributeName)range:NSMakeRange(0, len)];
                    
                    
                    UIColor *colhigh = UIColorFromRGBValue(COLOR_LYRIC_HIGHLIGHT);
                    [p->sentence addAttribute:(NSString *)(kCTForegroundColorAttributeName) value:(id)colhigh.CGColor range:NSMakeRange(0, len)];
                    p->lineHighlight = CTLineCreateWithAttributedString((CFAttributedStringRef)p->sentence);
                    [p->sentence removeAttribute:(NSString *)(kCTForegroundColorAttributeName)range:NSMakeRange(0, len)];
                    
                    [p->sentence removeAttribute:(id)kCTFontAttributeName  range:NSMakeRange(0,len)];
                    //CFRelease(font);
                    
                    CGFloat fas,fde,fled;
                    p->width = CTLineGetTypographicBounds( p->lineNormal, &fas, &fde, &fled);
                    mapLineInfos[pSentenceStrs[i]]=p;
                }
            }
        }
    }
}

-(void) DrawSentence:(CGContextRef) context :(NSMutableAttributedString*) sentence :(bool)btopLine:(float)fpercent
{
    CGRect rect = BottomRect(self.bounds,HEIGHT_LYRIC_SENTENCE, 0);
    
    CGFloat startx = CAP_WIDTH;
    CGFloat starty = rect.size.height/2 + CAP_HEIGHT;
    
    MAP_LINE_INFOS::iterator ite=mapLineInfos.find(sentence);
    if (ite==mapLineInfos.end()) {
        return;
    }
    Draw_Sentence_Line_INFO* pInfo=ite->second;
    
    CGFloat radio = 1.5;
    if((rect.size.width - CAP_WIDTH)/radio < pInfo->width)
    {
        radio = 1.0;
//        radio = (rect.size.width - CAP_WIDTH)/pInfo->width;
//        if(radio < 1)
//            radio = 1.0;
        
    }
    startx /= radio;
    starty /= radio;
    
    {
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, radio, -radio);

        if(!btopLine)
        {
            startx = (rect.size.width - CAP_WIDTH)/radio - pInfo->width;
            starty = CAP_HEIGHT/radio;
        }
        
        if((btopLine && bHighlightTopLine) || (!btopLine && !bHighlightTopLine))
            CGContextClipToRect(context, CGRectMake(startx + pInfo->width*fpercent,starty-2, pInfo->width- pInfo->width*fpercent, rect.size.height));
        
        CGContextSetTextPosition(context, startx, starty);
        CGContextSetShadowWithColor(context, CGSizeMake(0, 1),0.5,[UIColor blackColor].CGColor);
        CTLineDraw(pInfo->lineNormal, context);

        CGContextRestoreGState(context);
    }
    
    //****高亮部分歌词
    if((btopLine&&bHighlightTopLine) || (!btopLine && !bHighlightTopLine))
    {
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, radio, -radio);
        
        CGContextClipToRect(context, CGRectMake(startx,starty-2,  pInfo->width*fpercent, rect.size.height));
        
        CGContextSetTextPosition(context, startx, starty);
        CTLineDraw(pInfo->lineHighlight, context);
        
        CGContextRestoreGState(context);
    }
}

@end
