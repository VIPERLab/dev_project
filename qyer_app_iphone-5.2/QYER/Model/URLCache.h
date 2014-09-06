//
//  URLCache.h
//  URLCacheTest
//
//  Created by Jin Luo on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLCache : NSURLCache {
    NSMutableDictionary *cachedResponses;
    NSMutableDictionary *responsesInfo;
    NSMutableSet  *cachePaths;
}

@property (nonatomic, retain) NSMutableDictionary *cachedResponses;
@property (nonatomic, retain) NSMutableDictionary *responsesInfo;
@property (nonatomic, retain) NSMutableSet  *cachePaths;
- (void)saveInfo;
@end
