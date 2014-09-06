//
//  QyerAppNotification.m
//  QYER
//
//  Created by Qyer on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QyerAppNotification.h"

@implementation QyerAppNotification
@synthesize notification_id= _notification_id;
@synthesize message=_message;
@synthesize type=_type;
@synthesize object_id=_object_id;
@synthesize publish_time=_publish_time;
@synthesize object_photo=_object_photo;
-(void)dealloc{
    self.notification_id=nil;
    self.message=nil;
    self.type=nil;
    self.object_id=nil;
    self.publish_time=nil;
    self.object_photo=nil;
    
    
    self.numbers = nil;
    [super dealloc];
}
@end
