//
//  FilePath.h
//  DownLoadZipFile_withPods
//
//  Created by an qing on 13-4-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilePath : NSObject

+(id)sharedFilePath;
-(BOOL)createFilePath:(NSString *)path;
-(NSString *)getFilePath:(NSString *)pathname;
-(NSString *)getMenuFilePath:(NSString *)pathname;
-(NSString *)getZipFilePath;
-(NSString *)getTmpZipFilePath:(NSString *)filename;

+(NSString *)getBookMarkPath;
+(NSString *)getQYMoreAppPath;
+(NSString *)getQYGuideCategoryPath;
+(NSString *)getUserItineraryPathWithUserId:(NSString *)userid;
+(NSString *)getGuideHtmlPathByGuideName:(NSString *)guidename;

//********** Insert By ZhangDong 2014.3.31 Start **********
+ (NSString *)fileFullPathWithPath:(NSString*)pathName;
//********** Insert By ZhangDong 2014.3.31 End **********

+(void)moveDownloadedGuideToAnotherPathWithGuideName:(NSString *)guide_name;
+(void)removeGuideToDownloadPathWithGuideName:(NSString *)guide_name;
+(BOOL)isExitGuideWithGuideName:(NSString *)guide_name;
+(void)deleteGuideWithGuideName:(NSString *)guide_name;

@end

