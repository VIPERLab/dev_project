//
//  FileDecompression.h
//  DownLoadZipFile_withPods
//
//  Created by an qing on 13-4-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^FileDecompressionSuccess)(void);
typedef void (^FileDecompressionFailed)(void);
#endif



@interface FileDecompression : NSObject

+(void)decompressionFile:(NSDictionary *)dic;
+(void)decompressionFileWithFileName:(NSString *)fileName
                             success:(FileDecompressionSuccess)success
                              failed:(FileDecompressionFailed)failed;

+(void)decompressionFileWithFileName:(NSString *)fileName isDeleteZip:(BOOL)flag;

@end
