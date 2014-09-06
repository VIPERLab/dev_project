//
//  OtherMessage.h
//  QYER
//
//  Created by Frank on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseModel.h"
/**
 *  视图类型
 */
typedef NS_ENUM(NSUInteger, QYIMViewType) {
    /**
     *  约伴.
     */
    QYIMViewTypeInvite = 1,
    /**
     *  附近活动.
     */
    QYIMViewTypeActivities,
    /**
     *  商家信息.
     */
    QYIMViewTypeBusiness
};

/**
 *  小黑板信息Model
 */
@interface OtherMessage : BaseModel
/**
 *  小黑板ID
 */
@property (nonatomic, copy) NSString *wid;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  照片路径
 */
@property (nonatomic, retain) NSString *photo;
/**
 *  详细内容
 */
@property (nonatomic, copy) NSString *content;
/**
 *  类型
 */
@property (nonatomic, assign) QYIMViewType type;

/**
 *  备用字段1
 */
@property (nonatomic, copy) NSString *attribute1;

/**
 *  备用字段2
 */
@property (nonatomic, copy) NSString *attribute2;

/**
 *  备用字段3
 */
@property (nonatomic, copy) NSString *attribute3;

/**
 *  备用字段4
 */
@property (nonatomic, assign) NSInteger attribute4;

/**
 *  备用字段5
 */
@property (nonatomic, assign) NSInteger attribute5;

@end
