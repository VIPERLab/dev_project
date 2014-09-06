//
//  FileDamaged.h
//  QYER
//
//  Created by 我去 on 14-4-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>




/*
 文件损坏:
 当点击阅读锦囊的按钮出现‘文件已损坏’的提示时，做相应的处理。
 */



@interface FileDamaged : NSObject

+(void)processDamagedFileWithFileName:(NSString *)file_name;

@end
