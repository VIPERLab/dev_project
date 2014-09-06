/*
 * NSString+MD5.h
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

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)

- (NSString *) MD5Hash;

@end

@interface NSString (URLEncode)
- (NSString *)URLEncodedString;
@end

@interface NSString (TrimSpace)
- (NSString *)trimHeadAndTailSpace;//去除字符串首尾空格
- (NSString *)trimAllSpace;//去除所有空格
@end

