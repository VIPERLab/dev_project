/*
 * NSString+MD5.m
 *
 * Copyright (c) 2012, WangLin <wanglin4ios@gmail.com>.
 *
 * by 蔡小雨
 *
 * This library is free software,
 * it is distributed in the hope that it will be useful,
 * you can redistribute it and/or modify it free as you like
 *
 */

#import "NSString+MD5.h"

@implementation NSString (MD5)

- (NSString *) MD5Hash {
	
	CC_MD5_CTX md5;
	CC_MD5_Init (&md5);
	CC_MD5_Update (&md5, [self UTF8String], (CC_LONG) (int)[self length]);
		
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
	NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0],  digest[1], 
				   digest[2],  digest[3],
				   digest[4],  digest[5],
				   digest[6],  digest[7],
				   digest[8],  digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
				   
	return s;
	
}

@end

@implementation NSString (URLEncode)

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
    return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding) autorelease];
}

- (NSString *)URLEncodedString
{
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

@end


@implementation NSString (TrimSpace)
- (NSString *)trimHeadAndTailSpace//去除字符串首尾空格
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

}

- (NSString *)trimAllSpace//去除所有空格
{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];

}

@end

