//
//  AllPlaceData.m
//  QYER
//
//  Created by Frank on 14-3-26.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "AllPlaceData.h"
#import "QYAPIClient.h"
#import "Continent.h"
#import "CacheData.h"
#import "FilePath.h"


static NSString *kCachePathAllPlace = @"PlaceList";

static AllPlaceDataSuccessBlock kSuccessBlock;
static AllPlaceDataFailedBlock kFailedBlock;

@implementation AllPlaceData

/**
 *	@brief	查询所有目的地数据
 *  @param  finishedBlock       查询成功的Block方法
 *  @param  reuseIdentifier     查询失败的Block方法
 */
+ (void)getAllPlaceListSuccess:(AllPlaceDataSuccessBlock)finishedBlock
                        failed:(AllPlaceDataFailedBlock)failedBlock {
    
    //缓存路径:
	NSString *plistPath = [FilePath fileFullPathWithPath:kCachePathAllPlace];
    
    kSuccessBlock = Block_copy(finishedBlock);
    kFailedBlock = Block_copy(failedBlock);
    
    if (isNotReachable) {
        [self getDataFromCache:plistPath failedType:QYRequestFailedTypeNotReachable];
        return;
    }
    
    [self getDataFromCache:plistPath failedType:QYRequestFailedTypeLoading];
    
	[[QYAPIClient sharedAPIClient] getAllPlaceListSuccess: ^(NSDictionary *dic) {
	    if (dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@", [dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
        {
	        NSLog(@" getAllPlaceList 成功 ");

	        NSArray *arrayData = [dic objectForKey:@"data"];
	        NSArray *continentData = [[self prepareData:arrayData] retain];
	        //缓存数据
	        [CacheData cacheData:continentData toFilePath:plistPath];
	        finishedBlock(continentData);
	        [continentData release];
		}
	} failed: ^{
	    MYLog(@" getAllPlaceList 失败! ");
        NSArray *arrayCache = [[CacheData getCacheDataFromFilePath:plistPath] retain];
        if (arrayCache && [arrayCache isKindOfClass:[NSArray class]] && arrayCache.count > 0) {
            failedBlock(QYRequestFailedTypeTimeout);    //有缓存提示超时
        }else{
            failedBlock(QYRequestFailedTypeNotReachable);   //没缓存显示无网络视图
        }
        [arrayCache release];
	}];
}

/**
 *  通过plist路径，从plist中读取数据
 *
 *  @param cachePath plist路径
 *  @param type      错误类型
 */
+ (void)getDataFromCache:(NSString*)cachePath failedType:(enum QYRequestFailedType)type
{
    //从缓存中读取数据
    NSArray *arrayCache = [[CacheData getCacheDataFromFilePath:cachePath] retain];
    if (arrayCache && [arrayCache isKindOfClass:[NSArray class]] && arrayCache.count > 0) {
        kSuccessBlock(arrayCache);
    }
    else {
        kFailedBlock(type);
    }
    [arrayCache release];
}

/**
 *	@brief	把普通的数组转换成由Model组成的数组
 *  @param  array      普通的数组
 *  @return NSArray
 */
+ (NSArray *)prepareData:(NSArray *)array {
	NSMutableArray *arrayData = [[NSMutableArray alloc] init];
	for (NSDictionary *dic in array) {
		if (dic) {
			Continent *continent = [[Continent alloc] initWithDictionary:dic];
			[arrayData addObject:continent];
			[continent release];
		}
	}
	return [arrayData autorelease];
}

- (void)dealloc
{
    Block_release(kSuccessBlock);
    Block_release(kFailedBlock);
    [super dealloc];
}

@end
