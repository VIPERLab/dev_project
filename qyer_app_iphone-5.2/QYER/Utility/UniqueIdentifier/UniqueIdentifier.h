//
//  UniqueIdentifier.h
//  NewPackingList
//
//  Created by 安庆 安庆 on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UniqueIdentifier : NSObject

+(NSString *)getUniqueIdentifier;
+(NSString *)getUniqueIdentifierMd5String;
+(NSString *)getIdfa;

@end
