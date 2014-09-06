//
//  PlaceSearchData.m
//  QYER
//
//  Created by Frank on 14-4-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PlaceSearchData.h"
#import "QYAPIClient.h"
#import "PlaceSearchModel.h"


@implementation PlaceSearchData

+ (void)searchDataByText:(NSString *)text page:(NSInteger)page success:(PlaceSearchDataSuccessBlock)finishedBlock failed:(PlaceSearchDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] searchDataByText:text page:page success:^(NSDictionary *dic) {
        if (dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@", [dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
        {
	        NSLog(@"Place searchDataByText 成功 ");
            
	        NSArray *arrayData = [dic objectForKey:@"data"];
            
	        NSArray *continentData = [[self prepareData:arrayData] retain];
	        
	        finishedBlock(continentData);
	        [continentData release];
		}
        else
        {
            failedBlock();
        }
    } failed:^{
        failedBlock();
    }];
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
            PlaceSearchModel *model = [[PlaceSearchModel alloc] initWithDictionary:dic];
            [arrayData addObject:model];
            [model release];
		}
	}
	return [arrayData autorelease];
}
@end
