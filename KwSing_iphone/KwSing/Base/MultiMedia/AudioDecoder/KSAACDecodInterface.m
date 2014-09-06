//
//  KSAACDecodInterface.m
//  KwSing
//
//  Created by 单 永杰 on 12-11-28.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSAACDecodInterface.h"
#import "AACDecoder.h"

@implementation KSAACDecodInterface

+(bool)Decode : (const char*) str_source_file_path resultFilePath : (const char*) str_result_file_path{
    AACDecoder* p_decoder = [[AACDecoder alloc] init];
    FILE* p_out_file = fopen(str_result_file_path, "wb");
    int n_buffer_size = 0;
    if (0 != [p_decoder loadFile:[NSString stringWithUTF8String:str_source_file_path]]) {
        [p_decoder release];
        p_decoder = nil;
        fclose(p_out_file);
        return false;
    }
    while (true) {
        n_buffer_size = [p_decoder decodeAAC];
        if (-1 == n_buffer_size) {
            break;
        }else if(0 == n_buffer_size)
            continue;
        fwrite([p_decoder audioBuffer_], 1, n_buffer_size, p_out_file);
        [p_decoder nextPacket];
    }
    [p_decoder release];
    p_decoder = nil;
    fclose(p_out_file);
    
    return true;
}

@end
