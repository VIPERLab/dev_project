//
//  KSAudioFormatConvertInterface.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ConvertStatus{
    CONVERT_SUCESS,
    CONVERT_ERR
};

@interface KSAudioFormatConvertInterface : NSObject{
    BOOL m_bIsConvertFinish;
    enum ConvertStatus m_ConvertStatus;
}

- (void) audioFileFormatConvert:(id)in_para;

- (void) convertThreadFun:(id)in_para;

- (BOOL) isConvertFinish;

- (enum ConvertStatus) getConvertStatus;

@end
