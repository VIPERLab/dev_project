//
//  KSAACDecodInterface.m
//  KwSing
//
//  Created by 单 永杰 on 12-11-28.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//
/*
#import "KSAACDecodInterface.h"
#import "AACDecoder.h"
#import "MessageManager.h"
#import "IMediaSaveProcessObserver.h"
#import "PcmResample.h"

@implementation KSAACDecodInterface

+(bool)Decode : (const char*) str_source_file_path resultFilePath : (const char*) str_result_file_path fileLength : (unsigned long) n_file_length{
    AACDecoder* p_decoder = [[AACDecoder alloc] init];
    FILE* p_out_file = fopen(str_result_file_path, "wb");
    int n_buffer_size = 0;
    if (0 != [p_decoder loadFile:[NSString stringWithUTF8String:str_source_file_path]]) {
        [p_decoder release];
        p_decoder = nil;
        fclose(p_out_file);
        return false;
    }
    
    int n_decoded_size = 0;
    while (true) {
        n_buffer_size = [p_decoder decodeAAC];
        if (-1 == n_buffer_size) {
            break;
        }else if(0 == n_buffer_size)
            continue;
        fwrite([p_decoder audioBuffer_], 1, n_buffer_size, p_out_file);
        n_decoded_size += n_buffer_size;
        if (n_decoded_size > (n_file_length + 2000)) {
            break;
        }
        [p_decoder nextPacket];
        if (0 != n_file_length) {
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, n_decoded_size * (0.3 / (float)n_file_length));
        }
    }
    
    fclose(p_out_file);
    p_out_file = NULL;
    
//    NSLog(@"%d", ([p_decoder audioCodecContext_]->sample_rate));
    CPcmResample::ResampleProcess(str_result_file_path, [p_decoder audioCodecContext_]->sample_rate);
    
    [p_decoder release];
    p_decoder = nil;
    
    
    return true;
}

@end
*/