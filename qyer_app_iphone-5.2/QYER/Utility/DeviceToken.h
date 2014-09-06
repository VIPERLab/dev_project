//
//  DeviceToken.h
//  QyGuide
//
//  Created by 你猜你猜 on 13-10-12.
//
//

#import <Foundation/Foundation.h>

@interface DeviceToken : NSObject

+(id)sharedDeviceToken;
+(void)postTokenToServer:(NSString *)token_device;

@end
