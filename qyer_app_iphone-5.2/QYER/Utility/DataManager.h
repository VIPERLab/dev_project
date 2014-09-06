//
//  DataManager.h
//  Travel Gather
//
//  Created by lide on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject
{
    
}

+ (id)sharedManager;

//- (void)archiveDataArray:(NSArray *)array IntoCache:(NSString *)path;
- (void)archiveData:(NSData *)data IntoCache:(NSString *)path;

//- (NSArray *)unarchiveDataArrayFromCache:(NSString *)path;
- (NSData *)unarchiveDataFromCache:(NSString *)path;

//缓存WebView
- (void)archiveWebData:(NSData *)data IntoCache:(NSString *)path;
- (NSData *)unarchiveWebDataFromCache:(NSString *)path;

-(void)archiveDict:(NSDictionary *)dict IntoCache:(NSString *)path;
-(NSDictionary *)unarchiveWebDictFromCache:(NSString *)path;


- (BOOL)webFileExistsFromCache:(NSString*)path;

@end
