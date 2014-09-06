//
//  FileDecompression.m
//  DownLoadZipFile_withPods
//
//  Created by an qing on 13-4-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "FileDecompression.h"
#import "ZipArchive.h"
#import "FilePath.h"
#import "FileSize.h"

@implementation FileDecompression

+(void)decompressionFileWithFileName:(NSString *)fileName
                             success:(FileDecompressionSuccess)success
                              failed:(FileDecompressionFailed)failed
{
    NSString *zipPath = [[FilePath sharedFilePath] getZipFilePath];
    NSString *zipFilePath = [NSString stringWithFormat:@"%@/%@.zip",zipPath,fileName];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@_html",zipPath,fileName];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath])
    {
        ZipArchive *zip = [[ZipArchive alloc] init];
        [[NSFileManager defaultManager] createDirectoryAtPath:htmlPath withIntermediateDirectories:YES attributes:nil error:nil];
        if([zip UnzipOpenFile:zipFilePath])
        {
            BOOL ret = [zip UnzipFileTo:htmlPath overWrite:YES];
            
            BOOL flag = NO;
            NSArray *array_file = [[NSFileManager defaultManager] subpathsAtPath:htmlPath];
            for(NSString *str_html in array_file)
            {
                if([str_html rangeOfString:@".html"].location != NSNotFound)
                {
                    flag = YES;
                    break;
                }
            }
            
            if(NO == ret)
            {
                NSLog(@" zip包解压缩失败-1");
                
                failed();
            }
            else if(!flag) //解压缩后的html文件夹里没有'xxx.html'文件
            {
                NSLog(@" zip包解压缩失败-3");
                
                failed();
            }
            else
            {
                [zip UnzipCloseFile];
                
                //*** zip包解压成功后,将其删除,以节省手机的存储空间。
                [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
                
                success();
            }
        }
        else
        {
            NSLog(@" zip包出了一些问题");
            
            failed();
        }
        [zip release];
    }
    else
    {
        NSLog(@" zip包已经解压-4");
        success();
    }
}

+(void)decompressionFileWithFileName:(NSString *)fileName isDeleteZip:(BOOL)flag
{
    NSString *zipPath = [[FilePath sharedFilePath] getZipFilePath];
    NSString *zipFilePath = [NSString stringWithFormat:@"%@/%@.zip",zipPath,fileName];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@_html",zipPath,fileName];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath])
    {
        ZipArchive *zip = [[ZipArchive alloc] init];
        [[NSFileManager defaultManager] createDirectoryAtPath:htmlPath withIntermediateDirectories:YES attributes:nil error:nil];
        if([zip UnzipOpenFile:zipFilePath])
        {
            BOOL ret = [zip UnzipFileTo:htmlPath overWrite:YES];
            if(NO == ret)
            {
                NSLog(@" zip包解压缩失败");
            }
            else
            {
                [zip UnzipCloseFile];
                
                if(flag)
                {
                    //*** zip包解压成功后,将其删除,以节省手机的存储空间。
                    [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
                }
            }
        }
        else
        {
            NSLog(@" zip包出了一些问题");
        }
        [zip release];
    }
    else
    {
        NSLog(@" zip包已经解压");
    }
}

+(void)decompressionFile:(NSDictionary *)dic
{
    NSString *zipPath = [[FilePath sharedFilePath] getZipFilePath];
    NSString *zipFilePath = [NSString stringWithFormat:@"%@/%@.zip",zipPath,[dic objectForKey:@"guideName"]];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@_html",zipPath,[dic objectForKey:@"guideName"]];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath])
    {
        ZipArchive *zip = [[ZipArchive alloc] init];
        [[NSFileManager defaultManager] createDirectoryAtPath:htmlPath withIntermediateDirectories:YES attributes:nil error:nil];
        if([zip UnzipOpenFile:zipFilePath])
        {
            BOOL ret = [zip UnzipFileTo:htmlPath overWrite:YES];
            if(NO == ret)
            {
                NSLog(@" zip包解压缩失败");
            }
            else
            {
                [zip UnzipCloseFile];
                
                //*** zip包解压成功后,将其删除,以节省手机的存储空间。
                [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
            }
        }
        else
        {
            NSLog(@" zip包出了一些问题");
        }
        [zip release];
    }
}

@end
