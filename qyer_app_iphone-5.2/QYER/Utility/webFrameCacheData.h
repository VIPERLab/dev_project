//
//  webFrameCacheData.h
//  QYER
//
//  Created by Qyer on 14-4-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface webFrameCacheData : NSObject{
    NSString* _version;
}

+(id)sharedCacheWebData;
-(void)getRecommendWebHtml:(NSString *)app_version
                 andWebVer:(NSString *)web_version;
-(void)downWebHtmlFrameWork:(NSString*)value;
-(NSString*)getTmpCachePath;
-(NSString*)getCachePath;
@end
