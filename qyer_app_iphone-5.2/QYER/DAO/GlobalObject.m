//
//  GlobalObject.m
//  QYER
//
//  Created by 张伊辉 on 14-6-19.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GlobalObject.h"

@implementation GlobalObject
+(GlobalObject *)share{
    
    static GlobalObject *object = nil;
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[GlobalObject alloc]init];
    });
    
    return object;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _isAuto = YES;
        _priChatArray = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
