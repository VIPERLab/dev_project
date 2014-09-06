//
//  GlobalObject.h
//  QYER
//
//  Created by 张伊辉 on 14-6-19.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalObject : NSObject
{

}
+(GlobalObject *)share;
/**
 *  是否是自动，默认是YES
 */
@property (nonatomic, assign) BOOL isAuto;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, retain) NSMutableArray *priChatArray;
@property (nonatomic, assign) BOOL isInPublicRoom;
@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lon;
@end
