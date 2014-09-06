//
//  BaseModel.h
//  QYER
//
//  Created by Frank on 14-4-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  Model的基类
 */
@interface BaseModel : NSObject<NSCoding>

/**
 *  model的ID
 */
@property (nonatomic, retain) NSString *modelId;

/**
 *  通过字典初始化本类, item的key要和本类的属性保持一致
 *
 *  @param item
 *
 *  @return
 */
- (id)initWithDictionary:(NSDictionary*)item;

/**
 *  转换成字典类型
 *
 *  @return 字典
 */
- (NSMutableDictionary*)toDictionary;

@end
