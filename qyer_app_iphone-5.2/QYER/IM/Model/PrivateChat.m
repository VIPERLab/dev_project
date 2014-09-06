//
//  PrivateChat.m
//  QYER
//
//  Created by 张伊辉 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PrivateChat.h"
#import "NSDateUtil.h"
#import "QYIMObject.h"
#import "JSBubbleImageViewFactory.h"

@implementation PrivateChat

-(void)dealloc{
    
    self.privateChatId = nil;
    self.clientId = nil;
    self.messageId = nil;
    self.lastMessage = nil;
    self.chatUserName = nil;
    self.chatUserAvatar = nil;
    self.lastTime = nil;
    
    [super dealloc];
}

/*
 PrivateChat *tempChat = [[PrivateChat alloc] init];
 NSLog(@"data  is %@",item);
 
 JSBubbleMessageType type = [item[@"type"] integerValue];
 if (type == JSBubbleMediaTypeText) {
 tempChat.lastMessage = [item objectForKey:@"message"];
 }else if (type == JSBubbleMediaTypeImage){
 tempChat.lastMessage = kImageMsgText;
 }
 
 tempChat.messageId = [item objectForKey:@"messageId"];
 
 if (isReceive) {
 
 tempChat.clientId = [item objectForKey:@"fromUserId"];
 tempChat.chatUserName = [item objectForKey:@"fromUserName"];
 tempChat.chatUserAvatar = [item objectForKey:@"fromUserAvatar"];
 tempChat.lastTime = [item objectForKey:@"timeSend"];
 tempChat.unReadNumber = 1;
 
 }else{
 
 tempChat.clientId = [item objectForKey:@"toUserId"];
 tempChat.chatUserName = [item objectForKey:@"toUserName"];
 tempChat.chatUserAvatar = [item objectForKey:@"toUserAvatar"];
 tempChat.lastTime = [NSDate date];
 tempChat.unReadNumber = 0;
 
 }

 
 */
+(PrivateChat *)prasePrivateChatWithDict:(NSDictionary *)dict{
    
    PrivateChat *tempChat = [[PrivateChat alloc]init];
    
    tempChat.privateChatId = [dict objectForKey:@"user_id"];
    tempChat.clientId = [dict objectForKey:@"im_user_id"];
    tempChat.chatUserName = [dict objectForKey:@"username"];
    tempChat.chatUserAvatar = [dict objectForKey:@"user_avatar"];
    tempChat.lastTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"date"] doubleValue]/1000];
    tempChat.lastMessage = [dict objectForKey:@"last_message"];
    tempChat.unReadNumber = [[dict objectForKey:@"pending_msg"] integerValue];
    
    NSDictionary *custom_data = [dict objectForKey:@"custom_data"];
   // tempChat.chatUserAvatar = [custom_data objectForKey:@"fromUserAvatar"];
   // tempChat.chatUserName = [custom_data objectForKey:@"fromUserName"];
    
    JSBubbleMessageType type = [custom_data[@"type"] integerValue];
    
    if (type == JSBubbleMediaTypeText) {
        
    }else if (type == JSBubbleMediaTypeImage){
        
        tempChat.lastMessage = @"[图片]";
    }
    
    return [tempChat autorelease];
}


@end
