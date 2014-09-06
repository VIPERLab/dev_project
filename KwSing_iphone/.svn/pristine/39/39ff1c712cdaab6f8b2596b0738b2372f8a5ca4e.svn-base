//
//  globalm.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-10.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "debug.h"
#include "float.h"

#ifdef __cplusplus
extern "C" {
#endif

#define CHECK_POINTER(p)     NSCAssert( lpRect != NULL, @"Invalid pointer value!")
    
#define NSSTR(str) @##str
	
#define DATE_TIME_FORMAT (@"yyyy-MM-dd-HH:mm:ss")
	
#ifndef INOUT
#define INOUT
#define IN
#define OUT
#endif
	
#ifndef NOITEM
#define NOITEM ((UInt32)(-1))
#endif
	

#define ROUND_UP(x, align) ({ __typeof__(x) __x = (x); __typeof__(align) __align = (align); (__x + (__align - 1)) & ~(__align-1); })
	
#define IsExp2(x) ({ __typeof__(x) __x = (x); !(__x & (__x - 1)); })
	
UInt32 ToExp2(UInt32 x);

BOOL IsRetina();
bool IsIphone5();
CGFloat ScaleOfDevice();
	
#define isRetinaScreen IsRetina()
#define scaleOfDevice ScaleOfDevice()
	
	
// common function helper
BOOL IsEmptyString(NSString* string);

CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a);    
CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);

// alpha: 0~255

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

UIColor* UIColorFromRGBA(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha);

UIColor* UIColorFromRGB(unsigned char red, unsigned char green, unsigned char blue);

UIColor* UIColorFromRGBValue(NSUInteger rgbValue);
UIColor* UIColorFromRGBAValue(NSUInteger rgbValue, int alpha);

//
CGFloat GetRValue(CGColorRef color);
CGFloat GetGValue(CGColorRef color);
CGFloat GetBValue(CGColorRef color);
CGFloat GetAValue(CGColorRef color);
    
UIColor* GetGradentColor(UIColor* color1, UIColor* color2, unsigned int step, unsigned int total);
	
UIImage* UIImageTransparentOfSize(CGFloat width, CGFloat height);


// CGRect helper
void OffsetRectToXY(CGRect* lpRect, float x, float y);
void OffsetRectToPoint(CGRect* lpRect, CGPoint point);
void OffsetRectX(CGRect* lpRect, float x);
void OffsetRectY(CGRect* lpRect, float y);
void OffsetRect(CGRect* lpRect, float x, float y);
void InflateRect(CGRect* lpRect, float left, float top, float right, float bottom);
void DeflateRect(CGRect* lpRect, float left, float top, float right, float bottom);
void InflateRectXY(CGRect* lpRect, float x, float y);
void DeflateRectXY(CGRect* lpRect, float x, float y);

CGPoint CenterPoint(CGRect rect);
CGPoint LeftTopPoint(CGRect rect);
CGPoint LeftButtomPoint(CGRect rect);
CGPoint RightTopPoint(CGRect rect);
CGPoint RightBottomPoint(CGRect rect);

CGRect CenterRect(CGRect rect, float width, float height);
CGRect CenterRectForBounds(CGRect rect, CGRect bounds);
CGRect LeftRect(CGRect rect, float width, float offset);
CGRect RightRect(CGRect rect, float width, float offset);
CGRect TopRect(CGRect rect, float height, float offset);
CGRect BottomRect(CGRect rect, float height, float offset);
    
CGRect LeftTopRect(CGRect rect, float width, float height);
CGRect LeftBottomRect(CGRect rect, float width, float height);
CGRect RightTopRect(CGRect rect, float width, float height);
CGRect RightBottomRect(CGRect rect, float width, float height);

CGRect LeftCenterRect(CGRect rect, float width, float height, float offset);
CGRect RightCenterRect(CGRect rect, float width, float height, float offset);
CGRect TopCenterRect(CGRect rect, float width, float height, float offset);
CGRect BottomCenterRect(CGRect rect, float width, float height, float offset);
    
// time: time in millisecond, upRound: round up or down if less than 1 second
// mm:ss
NSString* TimeToString(NSInteger time, BOOL upRound);
// hh:mm:ss
NSString* TimeToString2(NSInteger time, BOOL upRound);

// mm:ss.fff
NSString* TimeToStringEx(NSInteger time);
// hh:mm:ss.fff
NSString* TimeToStringEx2(NSInteger time);
	
//yy-mm-dd hh:mm:ss
NSDate* TimeCStringToDate(const char* szTime);
NSDate* TimeStringToDate(NSString* tmString);
	
//time1-time2, by seconds
NSTimeInterval TimeDiff(NSDate* time1, NSDate* time2);
	
//cur time string
NSString* GetCurTimeToString();

//return 0, sus
int SafePerformSelectorOnMainThread(id target, SEL action, id arg, BOOL bWait);
	
//getTickCount
UInt64 tickCount();

	
BOOL CreateDirectory(NSString *dir);
	
BOOL IsFileExists(NSString* path, BOOL isDir);
BOOL MoveFile(NSString *srcPath, NSString *dstPath);
BOOL DeleteFile(NSString* path);


UInt32 GetFileSize(NSString* file);
	
//calc the width to draw index
NSString* TestIndexForDigit(int digit);//test index to draw, "88"
int DigitsOfTotal(int total);//digits, 3 -> "999"
CGFloat WidthToDrawIndexTotal(int total, UIFont* font);
	
// KB or MB
NSString* GetSizeString(UInt32 size);

#ifdef __cplusplus
}
#endif

