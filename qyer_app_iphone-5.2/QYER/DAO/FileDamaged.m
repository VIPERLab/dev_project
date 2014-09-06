//
//  FileDamaged.m
//  QYER
//
//  Created by 我去 on 14-4-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "FileDamaged.h"
#import "FilePath.h"
#import "QYGuide.h"
#import "QYGuideData.h"
#import "BookMarkData.h"



@implementation FileDamaged

+(void)processDamagedFileWithFileName:(NSString *)file_name
{
    //***(1) 修改锦囊的状态:
    QYGuide *guide = [QYGuideData getGuideByName:file_name];
    guide.guide_state = GuideNoamal_State;
    
    
    //***(2) 删除已下载目录下的文件
    NSString *filePath = [[FilePath sharedFilePath] getZipFilePath];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@_html",filePath,file_name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:htmlPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:htmlPath error:nil];
    }
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@.zip",filePath,file_name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
    }
    
    
    
    //***(3) 删除该锦囊的下载时间
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloadtime.plist",[pathURL path]];
    if([fileManager fileExistsAtPath:plistPath])
    {
        NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
        if(dic)
        {
            [dic removeObjectForKey:file_name];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
            if(data)
            {
                [data writeToFile:plistPath atomically:NO];
            }
        }
    }
    
    
    
    //***(4) 删除已保存的该锦囊的书签
    [[BookMarkData sharedBookMarkData] removeBookmarkByGuideName:file_name];
    
    
    
    //***(5) 从保存本地已下载的锦囊的plist文件中删除:
    NSMutableArray *array_download_new = [[NSMutableArray alloc] init];
    if([CacheData getDownloadedGuideCache] && [CacheData getDownloadedGuideCache].count > 0)
    {
        [array_download_new addObjectsFromArray:[CacheData getDownloadedGuideCache]];
    }
    for(QYGuide *guide_download in array_download_new)
    {
        if([guide_download.guideName isEqualToString:guide.guideName])
        {
            [array_download_new removeObject:guide_download];
            break;
        }
    }
    [CacheData cacheDownloadedGuideData:array_download_new];
    [array_download_new release];
    
    
    
    //***(6) 删除已记录的本本锦囊的阅读页数:
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,file_name]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    //***(7) 发消息(更新tableview的cell)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FileDamaged" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:file_name,@"guidename", nil]];
    
}

@end
