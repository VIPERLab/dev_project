//
//  QyerAppNotification.h
//  QYER
//
//  Created by Qyer on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface QyerAppNotification : BaseModel{
    NSString* _notification_id;    //私信 id
    NSString* _message;            //消息内容
    NSString* _type;               //通知类型
    NSString* _object_id;          //通知对象id
    NSString* _publish_time;       //发送时间
    NSString* _object_photo;       //image   url

}
@property(nonatomic, retain) NSString* notification_id;
@property(nonatomic, retain) NSString* message;
@property(nonatomic, retain) NSString* type;
@property(nonatomic, retain) NSString* object_id;
@property(nonatomic, retain) NSString* publish_time;
@property(nonatomic, retain) NSString* object_photo;;
/**
 *  个数
 */
@property (nonatomic, retain) NSString *numbers;
@end
