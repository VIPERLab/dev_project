//
//  QYGuideCategoryData.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-18.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QYGuideCategoryData.h"
#import "QYGuideCategory.h"
#import "QYAPIClient.h"
#import "FilePath.h"
#import "CacheData.h"


@implementation QYGuideCategoryData


#pragma mark -
#pragma mark --- getGuideCategoryList
+(void)getGuideCategoryListMobile:(BOOL)bMobile
                     successBlock:(getCategorySuccessBlock)finishedBlock
                      failedBlock:(getCategoryFailedBlock)failedBlock
{
    //*** 本地缓存:
    NSString *plistPath = [[FilePath getQYGuideCategoryPath] retain];
    NSArray *array_cache = [CacheData getCacheDataFromFilePath:plistPath];
    finishedBlock(array_cache);
    
    
    //*** 网络数据:
    [[QYAPIClient sharedAPIClient] getGuideCategoryListMobile:bMobile
                                                 successBlock:^(NSDictionary *dic) {
                                                     if(finishedBlock)
                                                     {
                                                         NSString *str_flag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]];
                                                         if([str_flag isEqualToString:@"1"])
                                                         {
                                                             NSArray *array = [dic objectForKey:@"data"];
                                                             NSArray *array_ = [[self processData:array] retain];
                                                             
                                                             
                                                             //将数据缓存到本地:
                                                             [CacheData cacheData:array_ toFilePath:plistPath];
                                                             
                                                             
                                                             finishedBlock(array_);
                                                             [array_ release];
                                                         }
                                                     }
                                                 }
                                                  failedBlock:^ {
                                                      if(!array_cache || ![array_cache isKindOfClass:[NSArray class]])
                                                      {
                                                          NSLog(@"getGuideCategoryListMobile 失败");
                                                          failedBlock();
                                                      }
                                                  }];
    
    
    [plistPath release];
}
+(NSArray *)processData:(NSArray*)array
{
    NSMutableArray *array_guideCategory = [[NSMutableArray alloc] init];
    for(int i = 0; i < array.count; i++)
    {
        NSDictionary *dic = [array objectAtIndex:i];
        QYGuideCategory *guideCategory = [[QYGuideCategory alloc] init];
        guideCategory.str_categoryId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        guideCategory.str_categoryName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename"]];
        guideCategory.str_categoryNameEn = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename_en"]];
        guideCategory.str_categoryNamePy = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename_py"]];\
        guideCategory.str_guideCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"infocount"]];
        guideCategory.str_mobileGuideCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"mobile_guide_count"]];
        guideCategory.str_categoryImageUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"image"]];
        [array_guideCategory addObject:guideCategory];
        [guideCategory release];
    }
    return [array_guideCategory autorelease];
}

@end
