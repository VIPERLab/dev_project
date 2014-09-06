//
//  KBSetTimming.h
//  kwbook
//
//  Created by 单 永杰 on 14-1-3.
//  Copyright (c) 2014年 单 永杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBSetTimming : NSObject

+(KBSetTimming*)sharedInstance;

-(void)setTimming : (int)n_min;

-(bool)isTimingSet;
-(int)getLeftTime;

@end
