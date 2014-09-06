//
//  FrequencyDrawView.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "FrequencyDrawView.h"
#include "LyricInfo.h"
#include "ImageMgr.h"
#include "MediaInterface.h"
#include "globalm.h"
#include <vector>
#include "Score.h"
#include "MessageManager.h"

#define FREQUENCY_VIEW_RENDER_START_Y (IsIphone5()?28:8)
#define FREQUENCY_VIEW_RENDER_HEIGHT  (IsIphone5()?100:58)

#define FREQUENCY_UPDATE_INTERVAL 30

typedef struct _SentencePoints
{
    unsigned uiSentencePoints;
    float fTotalPoints;
}SENTENCE_POINTS;

SENTENCE_POINTS* s_pSentencePoints;
unsigned s_uiSentencePointsNum;

@interface KSFrequencyDrawView_Draw:UIView
{
    CLyricInfo* pLyricInfo;
    CMediaInterface* pMediaInterface;
    DRAW_WORD_INFO drawWordInfo;
    DRAW_SENTENCE_INFO drawSentenceInfo;
    
    NSTimer* pTimer;
    UIImage* pVernierImgRed;
    UIImage* pVernierImgGreen;
    UIImage* pVernierImgYellow;
    
    UILabel* pText1;
    UILabel* pText2;
    UILabel* pText3;
    UILabel* pText4;
    UILabel* pText5;
    UILabel* pText6;
    
    int nLastSentenceId;
    
    unsigned uiLyricMaxMinRange;
    dispatch_queue_t m_dispatchQueue;
    
    BOOL bRecalculatePoints;
}

- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
- (void)update:(NSTimer*)theTimer;
- (void)drawRect:(CGRect)rect;

- (UILabel*)addLabelView:(CGRect)rc title:(NSString*)text fontsize:(CGFloat)fFontSize;

- (void)renderFrequency:(unsigned)t;
- (void)drawOneWordFrequency:(int)pos wordLen:(unsigned)len wordRange:(unsigned)range;
- (void)renderVernier:(unsigned)t;

- (void)updatePoint:(unsigned)uiSentenceId point:(unsigned)uiPoint;
- (float)calculateTotalPoint:(unsigned)uiSentenceId sentencepoints:(unsigned)points;

@end

@implementation KSFrequencyDrawView_Draw

- (UILabel*)addLabelView:(CGRect)rc title:(NSString*)text fontsize:(CGFloat)fFontSize
{
    UILabel* pLabelView=[[[UILabel alloc] initWithFrame:rc] autorelease];
    [pLabelView setText:text];
    [pLabelView setTextColor:[UIColor blackColor]];
    [pLabelView setBackgroundColor:[UIColor clearColor]];
    [pLabelView setFont: [UIFont systemFontOfSize:fFontSize]];
    [self addSubview:pLabelView];
    return pLabelView;
}

- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    self.backgroundColor=[UIColor clearColor];
    
    m_dispatchQueue=dispatch_queue_create("com.KwSing.SentenceEndQueue", NULL);
    
    pLyricInfo = NULL;
    pVernierImgRed=CImageMgr::GetImageEx("recordWordVernierRed.png");
    pVernierImgGreen=CImageMgr::GetImageEx("recordWordVernierGreen.png");
    pVernierImgYellow=CImageMgr::GetImageEx("recordWordVernierYellow.png");
    
    CGRect rc=CGRectMake(5, FREQUENCY_VIEW_RENDER_START_Y+FREQUENCY_VIEW_RENDER_HEIGHT, 65, 26);
    if (IsIphone5()) {
        rc.origin.y+=30;
    }
    pText1=[self addLabelView:rc title:@"单句得分" fontsize:12];
    
    OffsetRectX(&rc,44);
    rc.size.width=35;
    pText2=[self addLabelView:rc title:@"0" fontsize:16];
    [pText2 setTextAlignment:UITextAlignmentCenter];
    
    OffsetRectX(&rc,32);
    rc.size.width=100;
    pText3=[self addLabelView:rc title:@"分  (加油啊)" fontsize:12];
    
    OffsetRectX(&rc,135);
    rc.size.width=120;
    pText4=[self addLabelView:rc title:@"综合得分         分" fontsize:12];
    
    OffsetRectX(&rc,46);
    rc.size.width=35;
    pText5=[self addLabelView:rc title:@"0" fontsize:16];
    [pText5 setTextAlignment:UITextAlignmentCenter];
    
    OffsetRectX(&rc,-182);
    rc.size.width=160;
    pText6=[self addLabelView:rc title:@"该歌曲暂不支持打分！" fontsize:16];
    [pText6 setTextAlignment:UITextAlignmentCenter];
    pText6.textColor = [UIColor colorWithRed:0.375 green:0.375 blue:0.375 alpha:1.0];
    [pText6 setHidden:YES];
    
    return self;
}

- (void)dealloc
{
    if (pTimer) {
        [pTimer invalidate];;
    }

    dispatch_release(m_dispatchQueue);
    CScore::GetInstance()->UnInit();
    [super dealloc];
}

- (void)start
{
    if (!pLyricInfo || !pMediaInterface) {
        [pText1 setHidden:YES];
        [pText2 setHidden:YES];
        [pText3 setHidden:YES];
        [pText4 setHidden:YES];
        [pText5 setHidden:YES];
        [pText6 setHidden:NO];
        
        return;
    }
    if (pLyricInfo->GetLyricType()!=LYRIC_KDTX) {
        [pText1 setHidden:YES];
        [pText2 setHidden:YES];
        [pText3 setHidden:YES];
        [pText4 setHidden:YES];
        [pText5 setHidden:YES];
        [pText6 setHidden:NO];
        
        return;
    }
    if (pTimer) {
        [pTimer invalidate];
    }
    memset(&drawWordInfo,0,sizeof(DRAW_WORD_INFO));
    memset(&drawSentenceInfo, 0, sizeof(DRAW_SENTENCE_INFO));
    if (bRecalculatePoints) {
        memset(s_pSentencePoints, 0, s_uiSentencePointsNum*sizeof(SENTENCE_POINTS));
    }
    
    nLastSentenceId=-1;
    
    LYRIC_RATING_INFO info;
    pLyricInfo->GetRatingInfo(0, info);
    CScore::GetInstance()->UnInit();
    if (bRecalculatePoints) {
        CScore::GetInstance()->Init(info.dMaxEnvelop);
    }
    
    uiLyricMaxMinRange=pLyricInfo->GetMaxWordRange()-pLyricInfo->GetMinWordRange();
    if (uiLyricMaxMinRange<40) {
        uiLyricMaxMinRange=40;
    }
    
    pTimer=[NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)FREQUENCY_UPDATE_INTERVAL/1000 target:self selector:@selector(update:) userInfo:nil repeats:YES];
}

- (void)stop
{
    [pTimer invalidate];
    pTimer=NULL;
}

- (void)continue
{
    if (!pLyricInfo) {
        return;
    }
    if (pLyricInfo->GetLyricType()!=LYRIC_KDTX) {
        return;
    }
    if(!pTimer){
        pTimer=[NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)FREQUENCY_UPDATE_INTERVAL/1000 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    }
}

- (void)setLyric:(CLyricInfo*)lyric recalculatePoints:(BOOL)recal
{
    pLyricInfo=lyric;
    bRecalculatePoints=recal;
    
    nLastSentenceId=0;
    
    if (recal || !s_pSentencePoints) {
        if (s_pSentencePoints) {
            delete[] s_pSentencePoints;
        }
        s_uiSentencePointsNum=pLyricInfo->GetSentenceNum();
        s_pSentencePoints=new SENTENCE_POINTS[s_uiSentencePointsNum];
        memset(s_pSentencePoints, 0, s_uiSentencePointsNum*sizeof(SENTENCE_POINTS));
        bRecalculatePoints=TRUE;
        
        for (int n_itr = 0; n_itr < s_uiSentencePointsNum; ++n_itr) {
            SENTENCE_POINTS& pointInfo=s_pSentencePoints[n_itr];
            pointInfo.uiSentencePoints = 0;
            pointInfo.fTotalPoints = 0.f;
        }
        
        [pText2 setText:@"0"];
        [pText3 setText:@"分  (加油啊)"];
        [pText5 setText:@"0"];
    }
}

- (void)setMediaInterface:(CMediaInterface*)media
{
    pMediaInterface=media;
}

- (void)update:(NSTimer*)theTimer
{
    [self setNeedsDisplayInRect:CGRectMake(0, 0, DEVICE_TOTAL_WIDTH, FREQUENCY_VIEW_RENDER_START_Y+FREQUENCY_VIEW_RENDER_HEIGHT+pVernierImgRed.size.height/2)];
}

- (void)drawRect:(CGRect)rect
{
    if (!pTimer || !pLyricInfo) {
        return;
    }
    unsigned t=0;
    if (NULL != pMediaInterface) {
        t=pMediaInterface->CurrentTime();
    }
    
    unsigned uiRightTime=t+LYRIC_DRAW_NOWPOS_RIGHT_USE_TIME;
    if (!drawWordInfo.pWordLeft || drawWordInfo.pWordRight->uiEndTime<uiRightTime
        || drawWordInfo.pWordCurrent->uiEndTime<t)
    {
        pLyricInfo->GetDrawWordInfo(t, drawWordInfo);
        if (!drawWordInfo.pWordLeft || !drawWordInfo.pWordRight) {
            return;
        }
    }
    
    [self renderFrequency:t];
    [self renderVernier:t];
    
    if (!drawSentenceInfo.pCurrentSentenceInfo
        || t<drawSentenceInfo.pCurrentSentenceInfo->uiStartTime
        || t>drawSentenceInfo.pCurrentSentenceInfo->uiEndTime)
    {
        pLyricInfo->GetDrawSentenceInfo(t, drawSentenceInfo);
    }
    
    enum {
        LAST_SENTENCE_ID_CALCULATING    = -2
        ,LAST_SENTENCE_ID_WAITING_START = -1
    };

    if (nLastSentenceId!=LAST_SENTENCE_ID_CALCULATING) {
        if (nLastSentenceId==LAST_SENTENCE_ID_WAITING_START) {
            if (t>=drawSentenceInfo.pCurrentSentenceInfo->uiStartTime
                && t<=drawSentenceInfo.pCurrentSentenceInfo->uiEndTime)
            {
                if (bRecalculatePoints) {
                    nLastSentenceId=LAST_SENTENCE_ID_CALCULATING;
                    
                    LYRIC_RATING_INFO info;
                    pLyricInfo->GetRatingInfo(drawSentenceInfo.pCurrentSentenceInfo->uiId, info);
                    
                    dispatch_async(m_dispatchQueue,^{
                        CScore::GetInstance()->SentenceStart(info.pFrequencyInfo, info.uiFrequencyInfoNum, info.pEnvelopInfo, info.uiEnvelopInfoNum);
                        KS_BLOCK_DECLARE
                        {
                            if(drawSentenceInfo.pCurrentSentenceInfo)
                                nLastSentenceId=drawSentenceInfo.pCurrentSentenceInfo->uiId;
                        }
                        KS_BLOCK_SYNRUN()
                    });
                } else {
                    if(drawSentenceInfo.pCurrentSentenceInfo)
                        nLastSentenceId=drawSentenceInfo.pCurrentSentenceInfo->uiId;
                }
            }
        } else if (nLastSentenceId!=drawSentenceInfo.pCurrentSentenceInfo->uiId
                   || t>drawSentenceInfo.pCurrentSentenceInfo->uiEndTime)
        {
            if (bRecalculatePoints) {
                int nUpdatePointId(nLastSentenceId);
                nLastSentenceId=LAST_SENTENCE_ID_CALCULATING;
                dispatch_async(m_dispatchQueue,^{
                    int nPoint=CScore::GetInstance()->SentenceEnd();//这破玩意太慢。。。
                    KS_BLOCK_DECLARE
                    {
                        [self updatePoint:nUpdatePointId point:nPoint];
                        nLastSentenceId=LAST_SENTENCE_ID_WAITING_START;
                    }
                    KS_BLOCK_SYNRUN()
                });
            } else {
                [self updatePoint:nLastSentenceId point:0];
                nLastSentenceId=LAST_SENTENCE_ID_WAITING_START;
            }
        }
    }
}

- (void)renderFrequency:(unsigned)t
{
#define time_to_pos(time) ( (int)((time)+LYRIC_DRAW_LEFT_USE_TIME-t)*LYRIC_DRAW_RUN_SPEED/1000 )
    WORD_TIME_INFO* pWord(drawWordInfo.pWordLeft);
    while (pWord<=drawWordInfo.pWordRight) {
        int nWordRenderPos=time_to_pos(pWord->uiStartTime);
        unsigned uiWordLen=(pWord->uiEndTime-pWord->uiStartTime)*LYRIC_DRAW_RUN_SPEED/1000-1;
        [self drawOneWordFrequency:nWordRenderPos wordLen:uiWordLen wordRange:(pWord->uiRange * pWord->uiRange / 100)];
        ++pWord;
    }
}

- (void)drawOneWordFrequency:(int)pos wordLen:(unsigned)len wordRange:(unsigned)range
{
    int nY=FREQUENCY_VIEW_RENDER_START_Y+FREQUENCY_VIEW_RENDER_HEIGHT*(uiLyricMaxMinRange-range)/uiLyricMaxMinRange;
    CGContextRef pContex=UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(pContex, YES);

    #define HEAD_RADIUS 3
    CGContextBeginPath(pContex);
    CGContextSetRGBFillColor(pContex, 0.48, 0.5, 0.8, 0.5);
    CGRect rc=CGRectMake(pos+HEAD_RADIUS*2, nY-1, len-HEAD_RADIUS*2, 1);
    CGContextAddRect(pContex, rc);
    rc.size.width-=1;
    rc.size.height=3;
    rc.origin.y-=1;
    CGContextAddRect(pContex, rc);
    rc.size.width-=1;
    rc.size.height=5;
    rc.origin.y-=1;
    CGContextAddRect(pContex, rc);
    CGContextFillPath(pContex);
    
    CGContextBeginPath(pContex);
    CGContextSetRGBFillColor(pContex, 1, 0.93, 0.75, 1);
    CGContextAddArc(pContex, pos+HEAD_RADIUS,nY-1,HEAD_RADIUS,-M_PI,M_PI,1);
    CGContextAddArc(pContex, pos+HEAD_RADIUS+1,nY-1,HEAD_RADIUS,-M_PI,M_PI,1);
    rc=CGRectMake(pos+HEAD_RADIUS*2+1, nY-2, len-3-HEAD_RADIUS*2, 1);
    CGContextAddRect(pContex, rc);
    CGContextFillPath(pContex);

    CGContextBeginPath(pContex);
    CGContextSetRGBFillColor(pContex, 1, 0.788, 0, 1);
    CGContextAddArc(pContex, pos+HEAD_RADIUS,nY,HEAD_RADIUS,-M_PI,M_PI,1);
    CGContextAddArc(pContex, pos+HEAD_RADIUS+1,nY,HEAD_RADIUS,-M_PI,M_PI,1);
    rc=CGRectMake(pos+HEAD_RADIUS*2+1, nY-1, len-3-HEAD_RADIUS*2, 2);
    CGContextAddRect(pContex, rc);
    CGContextFillPath(pContex);
    
    CGContextBeginPath(pContex);
    CGContextSetRGBFillColor(pContex, 1, 0.788, 0, 0.5);
    rc.origin.y-=1;
    rc.size.width+=1;
    CGContextAddRect(pContex, rc);
    CGContextFillPath(pContex);
}

- (void)renderVernier:(unsigned)t
{
    int nRange=pMediaInterface->GetCurVolume();

    CGSize size=pVernierImgRed.size;
    int nY=FREQUENCY_VIEW_RENDER_START_Y+FREQUENCY_VIEW_RENDER_HEIGHT*(uiLyricMaxMinRange-nRange)/uiLyricMaxMinRange;
    CGRect rc=CGRectMake(16, nY-size.height/2,size.width,size.height);
    
    UIImage* pImgDraw(pVernierImgRed);
    unsigned uiDeviation=abs(nRange-(int)drawWordInfo.pWordCurrent->uiRange);
    
    if (t<drawWordInfo.pWordCurrent->uiStartTime || t>drawWordInfo.pWordCurrent->uiEndTime) {
        pImgDraw=pVernierImgGreen;
    } else if (uiDeviation<30) {
        pImgDraw=pVernierImgGreen;
    } else if (uiDeviation<60) {
        pImgDraw=pVernierImgYellow;
    }
    
    [pImgDraw drawInRect:rc];
}

- (void)updatePoint:(unsigned)uiSentenceId point:(unsigned)uiPoint
{
    if (uiSentenceId>=pLyricInfo->GetSentenceNum()) {
        return;
    }
    SENTENCE_POINTS& pointInfo=s_pSentencePoints[uiSentenceId];
    if (bRecalculatePoints) {
        pointInfo.fTotalPoints=[self calculateTotalPoint:uiSentenceId sentencepoints:uiPoint];
        pointInfo.uiSentencePoints=uiPoint;
    }
    
    [pText2 setText:[NSString stringWithFormat:@"%d",pointInfo.uiSentencePoints]];
    [pText5 setText:[NSString stringWithFormat:@"%d",(int)pointInfo.fTotalPoints]];
    NSString* str(NULL);
    if (pointInfo.uiSentencePoints>=85) {
        str=@"分  (太棒了)";
    } else if (pointInfo.uiSentencePoints>=70) {
        str=@"分  (看好你哦)";
    } else if (pointInfo.uiSentencePoints>=60) {
        str=@"分  (加油加油)";
    } else if (pointInfo.uiSentencePoints>=15) {
        str=@"分  (要努力啊)";
    } else {
        str=@"分  (雷死了)";
    }

    [pText3 setText:str];
}

- (float)calculateTotalPoint:(unsigned)uiSentenceId sentencepoints:(unsigned)points
{
    if (uiSentenceId==0) {
        return points;
    } else {
        float nTotal=s_pSentencePoints[uiSentenceId-1].fTotalPoints*uiSentenceId+points;
        return nTotal/(uiSentenceId+1);
    }
}

- (unsigned)getTotalPoint
{
    for (int i=s_uiSentencePointsNum-1; i>=0; --i) {
        if (s_pSentencePoints[i].fTotalPoints) {
            return s_pSentencePoints[i].fTotalPoints;
        }
    }
    return 0;
}

@end


//增加一个背景层，背景贴图由drawrect自绘改为单独的背景层，效率提升不少
@interface KSFrequencyDrawView()
{
    KSFrequencyDrawView_Draw* pDrawPlace;
    UIImageView* pBkgView;
}

- (id)initWithFrame:(CGRect)frame;
- (void)setFrame:(CGRect)frame;

@end

@implementation KSFrequencyDrawView

- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (IsIphone5()) 
        pBkgView=[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("recordFrequencyViewBkg_5.png")] autorelease];
    else
        pBkgView=[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("recordFrequencyViewBkg.png")] autorelease];
    [pBkgView setFrame:self.bounds];
    [self addSubview:pBkgView];
    
    pDrawPlace=[[[KSFrequencyDrawView_Draw alloc] initWithFrame:self.bounds] autorelease];
    [self addSubview:pDrawPlace];
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [pBkgView setFrame:self.bounds];
    [pDrawPlace setFrame:self.bounds];
}

- (void)setLyric:(CLyricInfo*)lyric recalculatePoints:(BOOL)recal
{
    [pDrawPlace setLyric:lyric recalculatePoints:recal];
}

- (void)setMediaInterface:(CMediaInterface*)media
{
    [pDrawPlace setMediaInterface:media];
}

- (void)start
{
    [pDrawPlace start];
}

- (void)stop
{
    [pDrawPlace stop];
}

- (void)continue
{
    [pDrawPlace continue];
}

- (unsigned)getTotalPoint
{
    return [pDrawPlace getTotalPoint];
}

@end










