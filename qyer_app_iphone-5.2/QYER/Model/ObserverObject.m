//
//  ObserverObject.m
//  QYER
//
//  Created by 我去 on 14-4-21.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "ObserverObject.h"

@implementation ObserverObject
@synthesize name = _name;
@synthesize idString = _idString;
@synthesize dic_progress = _dic_progress;
@synthesize progress = _progress;
@synthesize status = _status;
@synthesize dic_addObserver = _dic_addObserver;
@synthesize dic_addObserver_guidecell = _dic_addObserver_guidecell;
@synthesize dic_addObserver_guidecover = _dic_addObserver_guidecover;
@synthesize dic_addObserver_guideviewcell = _dic_addObserver_guideviewcell;

-(void)dealloc
{
    QY_MUTABLERECEPTACLE_RELEASE(_dic_progress);
    QY_MUTABLERECEPTACLE_RELEASE(_dic_addObserver);
    QY_MUTABLERECEPTACLE_RELEASE(_dic_addObserver_guidecell);
    QY_MUTABLERECEPTACLE_RELEASE(_dic_addObserver_guidecover);
    QY_MUTABLERECEPTACLE_RELEASE(_dic_addObserver_guideviewcell);
    QY_SAFE_RELEASE(_name);
    QY_SAFE_RELEASE(_idString);
    
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if(self)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        self.dic_progress = dic;
        [dic release];
        
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc] init];
        self.dic_addObserver = _dic;
        [_dic release];
        
        NSMutableDictionary *dic_ = [[NSMutableDictionary alloc] init];
        self.dic_addObserver_guidecell = dic_;
        [dic_ release];
        
        NSMutableDictionary *dic__ = [[NSMutableDictionary alloc] init];
        self.dic_addObserver_guidecover = dic__;
        [dic__ release];
        
        NSMutableDictionary *dic___ = [[NSMutableDictionary alloc] init];
        self.dic_addObserver_guideviewcell = dic___;
        [dic___ release];
    }
    return self;
}

@end
