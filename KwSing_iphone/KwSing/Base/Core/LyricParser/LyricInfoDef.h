//
//  LyricInfoDef.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-8.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_LyricInfoDef_h
#define KwSing_LyricInfoDef_h

#ifndef IN
#define IN
#endif
#ifndef OUT
#define OUT
#endif

#define DEVICE_TOTAL_WIDTH              320
#define LYRIC_DRAW_RUN_SPEED            100    //pixel/second
#define LYRIC_DRAW_NOWPOS_PIXEL         41
#define LYRIC_DRAW_LEFT_USE_TIME        (LYRIC_DRAW_NOWPOS_PIXEL*1000/LYRIC_DRAW_RUN_SPEED) //ms
#define LYRIC_DRAW_NOWPOS_RIGHT_PIXEL   (DEVICE_TOTAL_WIDTH-LYRIC_DRAW_NOWPOS_PIXEL)
#define LYRIC_DRAW_NOWPOS_RIGHT_USE_TIME (LYRIC_DRAW_NOWPOS_RIGHT_PIXEL*1000/LYRIC_DRAW_RUN_SPEED)

typedef enum
{
    LYRIC_NONE = -1
    ,LYRIC_CLASSIC =0
    ,LYRIC_LRCX = 1
    ,LYRIC_KDTX = 2
}LYRIC_TYPE;

typedef struct
{
    unsigned uiStartTime;
    unsigned uiEndTime;
    unsigned uiRange;
    unsigned uiPosInSentenceAsByte;
    unsigned uiLenAsByte;
}WORD_TIME_INFO;

typedef struct
{
    NSMutableAttributedString* str;
    WORD_TIME_INFO* pStartWord;
    WORD_TIME_INFO* pEndWord;
    unsigned uiStartTime;
    unsigned uiEndTime;
    unsigned uiLenAsByte;
    double* pFrequencyInfo;
    unsigned uiFrequencyInfoNum;
    double* pEnvelopeInfo;
    unsigned uiEnvelopInfoNum;
    unsigned uiId;
}SENTENCE_INFO;

typedef struct
{
    WORD_TIME_INFO* pWordCurrent;   //当前时间命中的字，两字之间空白的话返回左边一个
    WORD_TIME_INFO* pWordLeft;  //屏幕左侧第一个露出的字
    WORD_TIME_INFO* pWordRight; //右侧屏幕外的字
    SENTENCE_INFO* pCurrentSentence;
}DRAW_WORD_INFO;

typedef enum __eumCountDownState
{
    COUNTDOWN_PRE_PLAY = -1
    ,COUNTDOWN_NORMAL = 0
    ,COUNTDOWN_STAGE1 = 1
    ,COUNTDOWN_STAGE2 = 2
    ,COUNTDOWN_STAGE3 = 3
    ,COUNTDOWN_STAGE4 = 4
    ,COUNTDOWN_STAGE_PREPARE = 5
}DRAW_COUNTDOWN_STAGE;
typedef struct
{
    SENTENCE_INFO* pPreSentenceInfo;
    SENTENCE_INFO* pPostSentenceInfo;
    SENTENCE_INFO* pCurrentSentenceInfo;
    DRAW_COUNTDOWN_STAGE eumCountDownStage;
    float fCurrentPercent;
}DRAW_SENTENCE_INFO;

typedef struct
{
    double* pFrequencyInfo;
    unsigned uiFrequencyInfoNum;
    double* pEnvelopInfo;
    unsigned uiEnvelopInfoNum;
    double dMaxEnvelop;
}LYRIC_RATING_INFO;

typedef struct
{
    WORD_TIME_INFO* pWordTimeInfoIdx;
    SENTENCE_INFO* pSentenceTimeInfoIdx;
}TIME_INFO_INDEX_ITEM;


#endif
