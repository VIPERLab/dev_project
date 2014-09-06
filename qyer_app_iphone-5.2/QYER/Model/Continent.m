//
//  Continent.m
//  QYER
//
//  Created by Frank on 14-3-26.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "Continent.h"
#import "CountryList.h"

@implementation Continent

/**
 *	@brief	使用一个字典初始化洲类
 *  @param  dict     初始化洲类使用的字典
 *	@return	id
 */
- (id)initWithDictionary:(NSDictionary *)dict {
	self = [super initWithDictionary:dict];
	if (self) {
		self.modelId = dict[@"id"];

        NSArray *countrylistHot = [[self prepareCountryData:dict[@"hotcountrylist"]] retain];
		self.hotcountrylist = countrylistHot;
		[countrylistHot release];
        
		NSArray *countrylistOther = [[self prepareCountryData:dict[@"countrylist"]] retain];
		self.countrylist = countrylistOther;
		[countrylistOther release];
	}
	return self;
}


- (void)dealloc {
	
    self.catename = nil;
    self.catename_en = nil;
    self.photo = nil;
    self.hotcountrylist = nil;
    self.countrylist = nil;
	
	[super dealloc];
}

/**
 *  @private
 *	@brief	解析CountryList
 *  @param  array     由字典构成的数组
 *	@return	NSArray
 */
- (NSArray *)prepareCountryData:(NSArray *)array {
	NSMutableArray *list = [[NSMutableArray alloc] init];
	for (NSDictionary *dic in array) {
		if (dic) {
			CountryList *item = [[CountryList alloc] initWithDictionary:dic];
			[list addObject:item];
			[item release];
		}
	}
	return [list autorelease];
}


@end
