//
//  PlaceSearchModel.h
//  QYER
//
//  Created by Frank on 14-4-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseModel.h"

@interface PlaceSearchModel : BaseModel

/**
 *  POI名称、国家名称、城市名称
 */
@property (nonatomic, retain) NSString *poiname;

/**
 *  当前model的类型，1：POI，2：城市，3：国家
 */
@property (nonatomic, retain) NSString *type;

/**
 *  当前所属类型的文本, eg：国家，城市，洲
 */
@property (nonatomic, retain) NSString *label;

/**
 *  国家ID
 */
@property (nonatomic, retain) NSString *parentid;

/**
 *  国家名称
 */
@property (nonatomic, retain) NSString *parentname;

/**
 *  所属洲的名称
 */
@property (nonatomic, retain) NSString *parent_parentname;

/**
 *  去过的人数
 */
@property (nonatomic, retain) NSString *beennumber;

/**
 *  多少人去过
 */
@property (nonatomic, retain) NSString *beenstr;

/**
 *  缩略图
 */
@property (nonatomic, retain) NSString *photo;

@end
