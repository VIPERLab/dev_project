//
//  Message.m
//  IMTest
//
//  Created by Frank on 14-4-29.
//  Copyright (c) 2014年 Frank. All rights reserved.
//

#import "Message.h"
#import "UserInfo.h"
#import "IMConst.h"
#import "AnIMMessage.h"
#import "LocalData.h"
#import "QYIMObject.h"

@implementation Message

@synthesize fileData=_fileData;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super initWithDictionary:item];
    if (self) {
    }
    return self;
}

/**
 *  使用箭扣的Message初始化
 *
 *  @param anMessage 箭扣Message
 *
 *  @return
 */
- (id)initWithAnMessage:(AnIMMessage *)anMessage
{
    self = [self init];
    if (self) {
        self.messageId = anMessage.msgId;
        self.message = anMessage.message;
        self.fromUserId = anMessage.from;
        self.timeSend = [anMessage.timestamp longLongValue];
        NSDictionary *customData = anMessage.customData;
        if ([customData isKindOfClass:[NSDictionary class]]) {
            self.type = [customData[@"type"] integerValue];
            self.userName = customData[@"userName"];
            self.fromUserName = customData[@"fromUserName"];
            self.attribute1 = customData[@"imageUrl"];
            if (self.type == JSBubbleMediaTypeImage) {
                self.fileData = anMessage.content;
            }
        }
    }
    return self;
}

- (NSString*)fromUserAvatar
{
    UserInfo *userInfo = [[LocalData getInstance] queryUserWithImUserId:self.fromUserId];
    return userInfo.avatar;
}

- (NSString*)text
{
    return self.message;
}

- (NSString*)sender
{
    return self.fromUserName;
}

- (NSDate*)date
{
    return [NSDate dateWithTimeIntervalSince1970:self.timeSend / 1000];
}

/**
 *  文件名
 *
 *  @return
 */
- (NSString*)fileName
{
    if (self.type == JSBubbleMediaTypeImage){
        if ([QYIMObject getInstance].imVersion >= 5.13 ) {
            return [NSString stringWithFormat:@"%lld", self.timeSend];
        }else{
            return self.messageId;
        }
    }
    return @"";
}

/**
 *  文件路径
 *
 *  @return
 */
- (NSString*)filePath
{
    if (self.type == JSBubbleMediaTypeImage) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:IMRootDirectory];
        path = [self createDirectory:path];
        path = [self createDirectory:[NSString stringWithFormat:@"%@/%@", path, @"Images"]];
        return [NSString stringWithFormat:@"%@/%@.jpg", path, self.fileName];
    }
    return nil;
}

/**
 *  把NSData存放到本地
 *
 *  @param fileData
 */
- (void)setFileData:(NSData *)fileData
{
    if (self.type == JSBubbleMediaTypeImage && [fileData isKindOfClass:[NSData class]])
    {
        if (![_fileData isEqualToData:fileData]) {
            self.fileSize = [NSString stringWithFormat:@"%.2f KB", fileData.length / 1024.00];
            if (self.filePath) {
                BOOL isSuc = [fileData writeToFile:self.filePath atomically:YES];
                if (!isSuc) {
                    NSLog(@"setFileData is Error, %@", fileData);
                }
            }
        }
    }
}

/**
 *  从本地取文件
 *
 *  @return
 */
- (NSData*)fileData
{
    if (self.type == JSBubbleMediaTypeImage)
    {
        if (self.filePath) {
            return [NSData dataWithContentsOfFile:self.filePath];
        }
    }
    return nil;
}

/**
 *  根据路径判断文件夹是否存在，如果不存在，创建文件夹
 *
 *  @param path 路径
 *
 *  @return
 */
- (NSString*)createDirectory:(NSString*)path
{
    BOOL isDirectory;
    NSError *error = nil;
    NSFileManager *fileMagager = [NSFileManager defaultManager] ;
    BOOL isExist = [fileMagager fileExistsAtPath:path isDirectory:&isDirectory];
    
    if (!isExist) {
        [fileMagager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return path;
}
@end
