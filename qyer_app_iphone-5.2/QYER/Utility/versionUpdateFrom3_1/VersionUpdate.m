//
//  VersionUpdate.m
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-14.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "VersionUpdate.h"
#import "QYGuideData.h"
#import "QYGuide.h"
#import "ZipArchive.h"
#import "BookMark.h"
#import "BookMarkData.h"
#import "QYBookmark.h"
#import "QYGuideCategory.h"
#import "FileDecompression.h"






@implementation VersionUpdate

static VersionUpdate *sharedVersionUpdate = nil;
+(id)sharedVersionUpdate
{
    if(sharedVersionUpdate == nil)
    {
        sharedVersionUpdate = [[self alloc] init];
    }
    return sharedVersionUpdate;
}

+(NSString *)getSrcPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    return [pathURL path];
}

+(BOOL)isUpdateFilePath
{
    NSString *path_book = [self getBookPath];
    if(path_book) //首先判断是否是老版本
    {
        //        if(![[NSUserDefaults standardUserDefaults] objectForKey:@"hasUpdateCode"])
        //        {
        //            return 1;
        //        }
        return 1;
    }
    return 0;
}

+(void)updateFileSystem
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hasUpdateCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSInteger times = 0;
    
    [self prepareAllGuide];
    [self prepareRecommendGuide];
    [self prepareAllCategoryOfGuide];
    [self updateFileName_book_to_file];
    [self updateFileName_temp_to_tmpfile];
    [self updateFileName_guideId_to_guideName];
    [self getDownloadFromFile];
    [self setBookMarkData];
    
    
    
    //容错处理:
    if([self isUpdateFilePath])
    {
        times++;
        if(times >= 3)
        {
            return;
        }
        NSLog(@"重新更新下文件系统");
        [self updateFileSystem];
    }
}



#pragma mark -
#pragma mark --- 将原先的锦囊转换为本代码的锦囊:
+(void)prepareAllGuide
{
    BOOL flag_before_3_0 = NO;
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath_2    = [myPathList objectAtIndex:0];
    myPath_2 = [myPath_2 stringByAppendingPathComponent:@"GuideList"];
    if([[NSFileManager defaultManager] fileExistsAtPath:myPath_2])  //Version3.0之前
    {
        flag_before_3_0 = YES;
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"flag_before_3_0"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSString *path = @"GuideList";
    [[FilePath sharedFilePath] createFilePath:@"guideListAndCatalog"];
    NSString *myPath = [[FilePath sharedFilePath] getFilePath:@"guideListAndCatalog"];
    
    NSData *data = nil;
    if(flag_before_3_0)  //Version3.0之前
    {
        NSLog(@"   prepareGuide --- Version3.0之前");
        
        if([[NSFileManager defaultManager] fileExistsAtPath:myPath_2])
        {
            data = [NSData dataWithContentsOfFile:myPath_2];
        }
    }
    else  //Version3.0以后
    {
        NSLog(@"   prepareGuide --- Version3.0以后");
        
        myPath = [myPath stringByAppendingPathComponent:path];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
        {
            data = [NSData dataWithContentsOfFile:myPath];
        }
    }
    
    if(data)
    {
        NSArray *array_oldGuide = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableArray *array_newGuide = [[NSMutableArray alloc] init];
        NSMutableArray *array_sortGuide = [[NSMutableArray alloc] init];
        [self initGuideFromSrc:array_oldGuide toArray:array_newGuide];
        [self sortGuide:array_newGuide toArray:array_sortGuide];
        [[CacheData sharedCacheData] cacheData:array_sortGuide];
        
        [array_newGuide removeAllObjects];
        [array_newGuide release];
        [array_sortGuide removeAllObjects];
        [array_sortGuide release];
    }
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPath error:nil];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:myPath_2])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPath_2 error:nil];
    }
    
}
+(void)initGuideFromSrc:(NSArray *)array toArray:(NSMutableArray *)Array_allguide
{
    for(int i = 0 ; i < array.count ; i++)
    {
        QYGuide *guide_old = [array objectAtIndex:i];
        
        if(guide_old)
        {
            QYGuide *guide = [[QYGuide alloc] init];
            
            guide.guideId = [NSString stringWithFormat:@"%@",guide_old.guideId];
            guide.guideName = guide_old.guideName;
            guide.guideName_en = guide_old.guideNameEn;
            guide.guideName_pinyin = guide_old.guideNamePy;
            guide.guideCategory_id = [NSString stringWithFormat:@"%@",guide_old.guideCategoryId];
            guide.guideCategory_name = guide_old.guideCategoryTitle;
            guide.guideCountry_id = [NSString stringWithFormat:@"%@",guide_old.guideCountryId];
            guide.guideCountry_name_cn = guide_old.guideCountryName;
            guide.guideCountry_name_en = guide_old.guideCountryNameEn;
            guide.guideCountry_name_py = guide_old.guideCountryNamePy;
            guide.guideCoverImage = guide_old.guideCoverImage;
            guide.guideCoverImage_big = guide_old.guideBigCoverImage;
            guide.guideCover_updatetime = [NSString stringWithFormat:@"%@",guide_old.guideCoverUpdateTime];
            guide.guideBriefinfo = guide_old.guideBriefInfo;
            
            
            
            //*** guide的属性(iPhone):
            guide.guideFilePath = guide_old.mobileFilePath;
            guide.guideUpdate_time = [NSString stringWithFormat:@"%@",guide_old.mobileUpdateTime];
            guide.guideSize = [NSString stringWithFormat:@"%@",guide_old.mobileFileSize];
            guide.guidePages = [NSString stringWithFormat:@"%@",guide_old.guidePageCount];
            
            
            
            
            guide.guideCatalog = guide_old.guideCatalog;
            guide.guideCreate_time = [NSString stringWithFormat:@"%@",guide_old.guideCreateTime];
            guide.guideDownloadTimes = [NSString stringWithFormat:@"%@",guide_old.guideDownloadCount];
            guide.guideType = guide_old.guideType;
            guide.guideAuthor_id = [NSString stringWithFormat:@"%@",guide_old.authorId];
            guide.guideAuthor_name = guide_old.authorName;
            guide.guideAuthor_icon = guide_old.authorIcon;
            guide.guideAuthor_intro = guide_old.authorIntroduction;
            //guide.guideData_iPhone = [dic objectForKey:@"mobile_guide"];
            //guide.guideData_iPad = [dic objectForKey:@"pad_guide"];
            
            
            NSString *str_ids = @"";
            for(NSString *str in guide_old.otherGuideArray)
            {
                if(str_ids.length == 0)
                {
                    str_ids = str;
                }
                else if(str)
                {
                    str_ids = [NSString stringWithFormat:@"%@,%@",str_ids,str];
                }
            }
            guide.guide_relatedGuide_ids = str_ids;
            guide.guideUpdate_log = guide_old.updateLog;
            
            
            [Array_allguide addObject:guide];
            [guide release];
        }
    }
}
+(void)sortGuide:(NSArray *)array_allGuide toArray:(NSMutableArray *)sortArray //*** 按照锦囊的更新时间排序
{
    if(!array_allGuide)
    {
        return;
    }
    
    
    NSArray *array_sort = [array_allGuide sortedArrayUsingComparator:^(QYGuide *obj1, QYGuide *obj2){
        
        BOOL result = [obj1.guideUpdate_time compare:obj2.guideUpdate_time];
        if(result < 0)
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        else if(result > 0)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    [sortArray addObjectsFromArray:array_sort];
}



#pragma mark -
#pragma mark --- 将原先的锦囊转换为本代码的锦囊:
+(void)prepareRecommendGuide
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_recommended.plist",[pathURL path]];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
    
    
    NSMutableArray *array_recommendGuide = [[NSMutableArray alloc] init];
    for(NSString *str_guideId in array)
    {
        QYGuide *guide = [QYGuideData getGuideById:str_guideId];
        if(guide)
        {
            [array_recommendGuide addObject:guide];
        }
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array_recommendGuide];
    if(data)
    {
        [data writeToFile:plistPath atomically:NO];
    }
    
    [array_recommendGuide removeAllObjects];
    [array_recommendGuide release];
}



#pragma mark -
#pragma mark --- 处理所有锦囊所属国家的列表
+(void)prepareAllCategoryOfGuide
{
    NSString *myPath = [[FilePath sharedFilePath] getFilePath:@"guideListAndCatalog"];
    NSString *filePath = [NSString stringWithFormat:@"%@/CategoryList",myPath];
    
    
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath_2    = [myPathList objectAtIndex:0];
    myPath_2 = [myPath_2 stringByAppendingPathComponent:@"CategoryList"];
    
    
    NSString *filePath_category = @"";
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"flag_before_3_0"]) //Version3.0以后
    {
        filePath_category = filePath;
    }
    else  //Version3.0之前
    {
        filePath_category = myPath_2;
    }
    NSArray *array = [CacheData getCacheDataFromFilePath:filePath_category];
    
    
    
    NSMutableArray *array_new = [[NSMutableArray alloc] init];
    for(QYGuideCategory *category in array)
    {
        QYGuideCategory *guideCategory = [[QYGuideCategory alloc] init];
        
        guideCategory.str_categoryId = [NSString stringWithFormat:@"%@",category.categoryId];
        guideCategory.str_categoryName = [NSString stringWithFormat:@"%@",category.categoryName];
        guideCategory.str_categoryNameEn = [NSString stringWithFormat:@"%@",category.categoryNameEn];
        guideCategory.str_categoryNamePy = [NSString stringWithFormat:@"%@",category.categoryNamePy];
        guideCategory.str_guideCount = [NSString stringWithFormat:@"%@",category.guideCount];
        guideCategory.str_mobileGuideCount = [NSString stringWithFormat:@"%@",category.mobileGuideCount];
        guideCategory.str_categoryImageUrl = [NSString stringWithFormat:@"%@",category.categoryImage];
        guideCategory.categoryId = nil;
        guideCategory.categoryName = nil;
        guideCategory.categoryNameEn = nil;
        guideCategory.categoryNamePy = nil;
        guideCategory.guideCount = nil;
        guideCategory.mobileGuideCount = nil;
        guideCategory.categoryImage = nil;
        
        [array_new addObject:guideCategory];
        [guideCategory release];
    }
    NSString *plistPath = [[FilePath getQYGuideCategoryPath] retain];
    [CacheData cacheData:array_new toFilePath:plistPath];
    [array_new removeAllObjects];
    [array_new release];
    [plistPath release];
    
    
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath_category])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath_category error:nil];
    }
    
}



#pragma mark -
#pragma mark --- 修改'Application Support'目录下的文件名:
+(NSString *)getBookPath
{
    NSString *bookPath = [NSString stringWithFormat:@"%@/%@",[self getSrcPath],@"book"];
    
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:bookPath isDirectory:&ui])
    {
        return bookPath;
    }
    else
    {
        return nil;
    }
}
+(NSString *)getTempPath
{
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@",[self getSrcPath],@"temp"];
    
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&ui])
    {
        return tempPath;
    }
    else
    {
        return Nil;
    }
}
+(NSString *)createFilePath
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self getSrcPath],@"file"];
    NSLog(@" createFilePath filePath : %@",filePath);
    
    BOOL ui;
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        return filePath;
    }
    else
    {
        return filePath;
    }
}
+(NSString *)createTmpFilePath
{
    NSString *tmpfilePath = [NSString stringWithFormat:@"%@/%@",[self getSrcPath],@"file_tmp"];
    NSLog(@" createTmpFilePath tmpfilePath : %@",tmpfilePath);
    
    BOOL ui;
    if(![[NSFileManager defaultManager] fileExistsAtPath:tmpfilePath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpfilePath withIntermediateDirectories:YES attributes:nil error:nil];
        return tmpfilePath;
    }
    else
    {
        return nil;
    }
}

+(void)updateFileName_book_to_file
{
    NSString *path_book = [self getBookPath];
    NSString *path_file = [self createFilePath];
    
    
    BOOL ui;
    if([[NSFileManager defaultManager] fileExistsAtPath:path_book isDirectory:&ui])
    {
        NSArray *array_file = [[NSFileManager defaultManager] subpathsAtPath:path_book];
        for(NSString *str_zip in array_file)
        {
            if([str_zip rangeOfString:@".zip"].location == NSNotFound)  //已解压缩
            {
                if([array_file indexOfObject:[NSString stringWithFormat:@"%@.zip",str_zip]] < array_file.count) //已解压缩,还有zip包
                {
                    continue;
                }
                else if([str_zip rangeOfString:@"/html"].location == NSNotFound)
                {
                    NSLog(@"  str_html  : %@",str_zip);
                    
                    NSString *path_bookfile = [NSString stringWithFormat:@"%@/%@/html",path_book,str_zip];
                    NSString *path_file_ = [NSString stringWithFormat:@"%@/%@",path_file,str_zip];
                    NSError *error;
                    if([[NSFileManager defaultManager] moveItemAtPath:path_bookfile toPath:path_file_ error:&error])
                    {
                        NSLog(@" path_bookfile [0] ---> path_file 成功 ");
                    }
                    else
                    {
                        NSLog(@" path_bookfile [0] ---> path_file 失败 -2");
                        NSLog(@" Unable to move file: %@", [error localizedDescription]);
                    }
                }
            }
            
            if([str_zip rangeOfString:@".zip"].location != NSNotFound)
            {
                NSLog(@"  str_zip  str_zip : %@",str_zip);
                
                NSString *path_bookfile = [NSString stringWithFormat:@"%@/%@",path_book,str_zip];
                NSString *path_file_ = [NSString stringWithFormat:@"%@/%@",path_file,str_zip];
                NSError *error;
                if([[NSFileManager defaultManager] moveItemAtPath:path_bookfile toPath:path_file_ error:&error])
                {
                    NSLog(@" path_bookfile ---> path_file 成功 ");
                }
                else
                {
                    NSLog(@" path_bookfile ---> path_file 失败 -2");
                    NSLog(@" Unable to move file: %@", [error localizedDescription]);
                }
            }
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path_book])
        {
            if([[NSFileManager defaultManager] removeItemAtPath:path_book error:nil])
            {
                NSLog(@" 删除 path_book 成功 ");
            }
            else
            {
                NSLog(@" 删除 path_book 失败 -1");
            }
        }
        
    }
    else
    {
        NSLog(@" path_book 路径不存在 ");
    }
}

+(void)updateFileName_temp_to_tmpfile
{
    [self createTmpFilePath];
    NSString *path_temp = [self getTempPath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path_temp])
    {
        if([[NSFileManager defaultManager] removeItemAtPath:path_temp error:nil])
        {
            NSLog(@" 删除 path_temp 成功 ");
        }
        else
        {
            NSLog(@" 删除 path_temp 失败 -1");
        }
    }
}

+(void)updateFileName_guideId_to_guideName
{
    NSString *path_file = [self createFilePath];
    
    BOOL ui;
    if([[NSFileManager defaultManager] fileExistsAtPath:path_file isDirectory:&ui])
    {
        NSArray *array_file = [[NSFileManager defaultManager] subpathsAtPath:path_file];
        
        for(NSString *str_zip in array_file)
        {
            if([str_zip rangeOfString:@"zip"].location == NSNotFound)
            {
                if([str_zip rangeOfString:@"."].location == NSNotFound && [str_zip rangeOfString:@"images"].location == NSNotFound)
                {
                    
                    NSString *str_guideId = str_zip;
                    QYGuide *guide = [QYGuideData getGuideById:str_guideId];
                    if(guide)
                    {
                        NSString *guideName = guide.guideName;
                        
                        NSString *path_zip = [NSString stringWithFormat:@"%@/%@",path_file,str_zip]; //是一个名为锦囊id的文件夹
                        NSString *path_htmlfile = [NSString stringWithFormat:@"%@/%@_html",path_file,guideName];
                        NSError *error;
                        if([[NSFileManager defaultManager] moveItemAtPath:path_zip toPath:path_htmlfile error:&error])
                        {
                            NSLog(@" path_zip ---> path_htmlfile 成功 ");
                        }
                        else
                        {
                            NSLog(@" path_zip ---> path_htmlfile 失败 -2");
                            NSLog(@" Unable to move file: %@", [error localizedDescription]);
                        }
                    }
                }
                
                continue;
            }
            
            
            NSString *str_guideId = [str_zip substringToIndex:str_zip.length-@".zip".length];
            QYGuide *guide = [QYGuideData getGuideById:str_guideId];
            if(guide)
            {
                NSString *guideName = guide.guideName;
                
                NSString *path_zip = [NSString stringWithFormat:@"%@/%@",path_file,str_zip];
                NSData *data = [NSData dataWithContentsOfFile:path_zip];
                if(data)
                {
                    [data writeToFile:[NSString stringWithFormat:@"%@/%@.zip",path_file,guideName] atomically:NO];
                    
                    if([[NSFileManager defaultManager] removeItemAtPath:path_zip error:nil])
                    {
                        NSLog(@" 删除 path_zip 成功 ");
                    }
                }
            }
        }
    }
}


+(void)getDownloadFromFile
{
    NSString *path = @"DownloadGuideFile";
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    myPath = [myPath stringByAppendingPathComponent:path];
    
    
    NSString *myPath_2 = [[FilePath sharedFilePath] getFilePath:@"guideListAndCatalog/DownloadGuideFile"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myPath])  //Version3.0之前
    {
        NSLog(@"   getDownloadFromFile --- Version3.0之前");
        
        NSData *data = [NSData dataWithContentsOfFile:myPath];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(!array)
        {
            return;
        }
        
        
        
        
        
        //处理guide的部分属性:
        NSMutableArray *array_new = [[NSMutableArray alloc] init];
        for(id obj in array)
        {
            QYGuide *guide_old = (QYGuide *)obj;
            if(guide_old && [guide_old isKindOfClass:[QYGuide class]])
            {
                QYGuide *guide = [[QYGuide alloc] init];
                
                guide.guideId = [NSString stringWithFormat:@"%@",guide_old.guideId];
                guide.guideName = guide_old.guideName;
                guide.guideName_en = guide_old.guideNameEn;
                guide.guideName_pinyin = guide_old.guideNamePy;
                guide.guideCategory_id = [NSString stringWithFormat:@"%@",guide_old.guideCategoryId];
                guide.guideCategory_name = guide_old.guideCategoryTitle;
                guide.guideCountry_id = [NSString stringWithFormat:@"%@",guide_old.guideCountryId];
                guide.guideCountry_name_cn = guide_old.guideCountryName;
                guide.guideCountry_name_en = guide_old.guideCountryNameEn;
                guide.guideCountry_name_py = guide_old.guideCountryNamePy;
                guide.guideCoverImage = guide_old.guideCoverImage;
                guide.guideCoverImage_big = guide_old.guideBigCoverImage;
                guide.guideCover_updatetime = [NSString stringWithFormat:@"%@",guide_old.guideCoverUpdateTime];
                guide.guideBriefinfo = guide_old.guideBriefInfo;
                guide.guideFilePath = guide_old.mobileFilePath;
                guide.guideUpdate_time = [NSString stringWithFormat:@"%@",guide_old.mobileUpdateTime];
                guide.guideSize = [NSString stringWithFormat:@"%@",guide_old.mobileFileSize];
                guide.guidePages = [NSString stringWithFormat:@"%@",guide_old.guidePageCount];
                guide.guideCatalog = guide_old.guideCatalog;
                guide.guideCreate_time = [NSString stringWithFormat:@"%@",guide_old.guideCreateTime];
                guide.guideDownloadTimes = [NSString stringWithFormat:@"%@",guide_old.guideDownloadCount];
                guide.guideType = guide_old.guideType;
                guide.guideAuthor_id = [NSString stringWithFormat:@"%@",guide_old.authorId];
                guide.guideAuthor_name = guide_old.authorName;
                guide.guideAuthor_icon = guide_old.authorIcon;
                guide.guideAuthor_intro = guide_old.authorIntroduction;
                NSString *str_ids = @"";
                for(NSString *str in guide_old.otherGuideArray)
                {
                    if(str_ids.length == 0)
                    {
                        str_ids = str;
                    }
                    else if(str)
                    {
                        str_ids = [NSString stringWithFormat:@"%@,%@",str_ids,str];
                    }
                }
                guide.guide_relatedGuide_ids = str_ids;
                guide.guideUpdate_log = guide_old.updateLog;
                
                [array_new addObject:guide];
                [guide release];
            }
        }
        
        
        
        
        
        
        
        //将数据保存到plist文件中:
        [CacheData cacheDownloadedGuideData:array_new];
        
        
        NSDate *date = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString *str_date = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[date timeIntervalSince1970]]];
        
        NSInteger number = 0;
        for(QYGuide *guide in array_new)
        {
            number = number + 100000;
            
            
            //记录锦囊的下载时间［在已下载页面显示时使用］:
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
            NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloadtime.plist",[pathURL path]];
            if([fileManager fileExistsAtPath:plistPath])
            {
                NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
                
                [dic removeObjectForKey:guide.guideName];
                //[dic setObject:[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]-number] forKey:guide.guideName];
                
                
                NSLog(@"  str_date  ---  1 : %@",str_date);
                str_date = [NSString stringWithFormat:@"%lld",([str_date longLongValue]-number)];
                NSLog(@"  str_date  ---  1-1 : %@",str_date);
                [dic setObject:str_date forKey:guide.guideName];
                
                
                [dic setObject:guide.guideUpdate_time forKey:[NSString stringWithFormat:@"%@_updatetime",guide.guideName]];
                
                
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
                if(data)
                {
                    [data writeToFile:plistPath atomically:NO];
                }
            }
            else
            {
                NSMutableDictionary *dic_ = [[NSMutableDictionary alloc] init];
                //[dic_ setObject:[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]-number] forKey:guide.guideName];
                //[dic_ setObject:guide.guideName forKey:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]-number]];
                
                NSLog(@"  str_date  ---  2 : %@",str_date);
                str_date = [[NSString stringWithFormat:@"%lld",([str_date longLongValue]-number)] retain];
                NSLog(@"  str_date  ---  2-2 : %@",str_date);
                [dic_ setObject:str_date forKey:guide.guideName];
                [str_date release];
                
                
                [dic_ setObject:guide.guideUpdate_time forKey:[NSString stringWithFormat:@"%@_updatetime",guide.guideName]];
                
                
                
                
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic_];
                if(data)
                {
                    [data writeToFile:plistPath atomically:NO];
                }
                [dic_ removeAllObjects];
                [dic_ release];
            }
        }
        [date release];
        [dateFormatter release];
        [array_new removeAllObjects];
        [array_new release];
        
        
        
        
        if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
        {
            if([[NSFileManager defaultManager] removeItemAtPath:myPath error:nil])
            {
                NSLog(@" 删除 path_temp 成功 ");
            }
            else
            {
                NSLog(@" 删除 path_temp 失败 -1");
            }
        }
        
        
    }
    else if([[NSFileManager defaultManager] fileExistsAtPath:myPath_2])  //Version3.0以后
    {
        NSLog(@"   getDownloadFromFile --- Version3.0以后");
        
        NSData *data = [NSData dataWithContentsOfFile:myPath_2];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(!array)
        {
            return;
        }
        
        
        
        
        //处理guide的部分属性:
        NSMutableArray *array_new = [[NSMutableArray alloc] init];
        for(id obj in array)
        {
            QYGuide *guide_old = (QYGuide *)obj;
            if(guide_old && [guide_old isKindOfClass:[QYGuide class]])
            {
                QYGuide *guide = [[QYGuide alloc] init];
                
                guide.guideId = [NSString stringWithFormat:@"%@",guide_old.guideId];
                guide.guideName = guide_old.guideName;
                guide.guideName_en = guide_old.guideNameEn;
                guide.guideName_pinyin = guide_old.guideNamePy;
                guide.guideCategory_id = [NSString stringWithFormat:@"%@",guide_old.guideCategoryId];
                guide.guideCategory_name = guide_old.guideCategoryTitle;
                guide.guideCountry_id = [NSString stringWithFormat:@"%@",guide_old.guideCountryId];
                guide.guideCountry_name_cn = guide_old.guideCountryName;
                guide.guideCountry_name_en = guide_old.guideCountryNameEn;
                guide.guideCountry_name_py = guide_old.guideCountryNamePy;
                guide.guideCoverImage = guide_old.guideCoverImage;
                guide.guideCoverImage_big = guide_old.guideBigCoverImage;
                guide.guideCover_updatetime = [NSString stringWithFormat:@"%@",guide_old.guideCoverUpdateTime];
                guide.guideBriefinfo = guide_old.guideBriefInfo;
                guide.guideFilePath = guide_old.mobileFilePath;
                guide.guideUpdate_time = [NSString stringWithFormat:@"%@",guide_old.mobileUpdateTime];
                guide.guideSize = [NSString stringWithFormat:@"%@",guide_old.mobileFileSize];
                guide.guidePages = [NSString stringWithFormat:@"%@",guide_old.guidePageCount];
                guide.guideCatalog = guide_old.guideCatalog;
                guide.guideCreate_time = [NSString stringWithFormat:@"%@",guide_old.guideCreateTime];
                guide.guideDownloadTimes = [NSString stringWithFormat:@"%@",guide_old.guideDownloadCount];
                guide.guideType = guide_old.guideType;
                guide.guideAuthor_id = [NSString stringWithFormat:@"%@",guide_old.authorId];
                guide.guideAuthor_name = guide_old.authorName;
                guide.guideAuthor_icon = guide_old.authorIcon;
                guide.guideAuthor_intro = guide_old.authorIntroduction;
                NSString *str_ids = @"";
                for(NSString *str in guide_old.otherGuideArray)
                {
                    if(str_ids.length == 0)
                    {
                        str_ids = str;
                    }
                    else if(str)
                    {
                        str_ids = [NSString stringWithFormat:@"%@,%@",str_ids,str];
                    }
                }
                guide.guide_relatedGuide_ids = str_ids;
                guide.guideUpdate_log = guide_old.updateLog;
                
                
//                NSLog(@"  _updatetime _updatetime : %@",guide.guideUpdate_time);
//                NSLog(@"   guideName    guideName : %@",guide.guideName);
//                
//                NSDate *lastUpdate = [NSDate dateWithTimeIntervalSince1970:[guide.mobileUpdateTime floatValue]];
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//                NSLog(@" ---- : %@",[dateFormatter stringFromDate:lastUpdate]);
//                [dateFormatter release];
                
                
                
                
                
                
                
                [array_new addObject:guide];
                [guide release];
            }
        }
        
        
        
        //将数据保存到plist文件中:
        [CacheData cacheDownloadedGuideData:array_new];
        
        
        
        
        NSDate *date = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString *str_date = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[date timeIntervalSince1970]]];
        
        NSInteger number = 0;
        for(QYGuide *guide in array_new)
        {
            number = number + 100000;
            
            
            //记录锦囊的下载时间［在已下载页面显示时使用］:
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
            NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloadtime.plist",[pathURL path]];
            if([fileManager fileExistsAtPath:plistPath])
            {
                NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
                
                [dic removeObjectForKey:guide.guideName];
                //[dic setObject:[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]-number] forKey:guide.guideName];
                
                
                
                NSLog(@" --- ");
                NSLog(@"  str_date  ---  3 : %@",str_date);
                NSLog(@"   number : %d",number);
                str_date = [[NSString stringWithFormat:@"%lld",([str_date longLongValue]-number)] retain];
                NSLog(@"  str_date  ---  3-3 : %@",str_date);
                NSLog(@" --- ");
                [dic setObject:str_date forKey:guide.guideName];
                [str_date release];
                
                
                [dic setObject:guide.guideUpdate_time forKey:[NSString stringWithFormat:@"%@_updatetime",guide.guideName]];
                
                
                
                
                
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
                if(data)
                {
                    [data writeToFile:plistPath atomically:NO];
                }
            }
            else
            {
                NSMutableDictionary *dic_ = [[NSMutableDictionary alloc] init];
                //[dic_ setObject:[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]-number] forKey:guide.guideName];
                
                
                NSLog(@" --- ");
                NSLog(@"  str_date  ---  4 : %@",str_date);
                NSLog(@"   number : %d",number);
                str_date = [[NSString stringWithFormat:@"%lld",([str_date longLongValue]-number)] retain];
                NSLog(@"  str_date  ---  4-4 : %@",str_date);
                NSLog(@" --- ");
                [dic_ setObject:str_date forKey:guide.guideName];
                [str_date release];
                
                
                [dic_ setObject:guide.guideUpdate_time forKey:[NSString stringWithFormat:@"%@_updatetime",guide.guideName]];
                
                
                
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic_];
                if(data)
                {
                    [data writeToFile:plistPath atomically:NO];
                }
                [dic_ removeAllObjects];
                [dic_ release];
            }
        }
        [date release];
        [dateFormatter release];
        [array_new removeAllObjects];
        [array_new release];
        
        
        
        if([[NSFileManager defaultManager] fileExistsAtPath:myPath_2])
        {
            if([[NSFileManager defaultManager] removeItemAtPath:myPath_2 error:nil])
            {
                NSLog(@" 删除 path_temp 成功 ");
            }
            else
            {
                NSLog(@" 删除 path_temp 失败 -1");
            }
        }
    }
}



#pragma mark -
#pragma mark --- 初始化书签数据
+(void)setBookMarkData
{
    NSString *path_after = [[FilePath sharedFilePath] getFilePath:@"guideListAndCatalog"];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"flag_before_3_0"])  //Version3.0以后
    {
        NSLog(@"   setBookMarkData --- Version3.0以后");
        
        NSArray *array_file = [[NSFileManager defaultManager] subpathsAtPath:path_after];
        
        for(NSString *str_zip in array_file)
        {
            if([str_zip rangeOfString:@"catalog_"].location == NSNotFound)
            {
                NSLog(@" 已解压缩 已解压缩 已解压缩 ");
                continue;
            }
            
            NSArray *array = [self unarchiveDataFromCache_after:str_zip];
            for(QYBookmark *bookMark_src in array)
            {
                BOOL flag = [bookMark_src.whetherAddBookmark boolValue];
                if(flag)
                {
                    
                    BookMark *bookMark = [[BookMark alloc] init];
                    bookMark.str_guideName = bookMark_src.guideName;
                    bookMark.str_bookMarkTitle = bookMark_src.bookmarkTitle;
                    bookMark.str_bookMarkPageNumber = [NSString stringWithFormat:@"%d",[bookMark_src.bookmarkFile intValue]-1];
                    bookMark.str_guideHtmlInfoPath = @"";
                    [[BookMarkData sharedBookMarkData] addBookmark:bookMark];
                    
                    
                    
                    
                    
                    
                    
                    
                    //如果file目录下没有不处理书签:
                    NSArray *array_guideInFile = [QYGuideData getAllDownloadGuide];
                    BOOL flag = NO; //file目录下是否存在'bookMark_src.guideName'该锦囊
                    for(QYGuide *guide in array_guideInFile)
                    {
                        if(guide && guide.guideName && [guide.guideName isEqualToString:bookMark_src.guideName])
                        {
                            flag = YES;
                            break;
                        }
                    }
                    if(flag)
                    {
                        //如果该本锦囊还没有解压缩，则进行解压:
                        NSLog(@" 解压缩 解压缩 解压缩 ");
                        //[FileDecompression decompressionFileWithFileName:bookMark.str_guideName];
                        [FileDecompression decompressionFileWithFileName:bookMark.str_guideName isDeleteZip:NO];
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    [bookMark release];
                    
                    
                }
            }
        }
        
    }
    else  //Version3.0之前
    {
        NSLog(@"   setBookMarkData --- Version3.0之前");
        
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *myPath    = [myPathList  objectAtIndex:0];
        NSArray *array_file = [[NSFileManager defaultManager] subpathsAtPath:myPath];
        
        for(NSString *str_zip in array_file)
        {
            if([str_zip rangeOfString:@"catalog_"].location == NSNotFound)
            {
                continue;
            }
            
            NSArray *array = [self unarchiveDataFromCache:str_zip];
            for(QYBookmark *bookMark_src in array)
            {
                BOOL flag = [bookMark_src.whetherAddBookmark boolValue];
                if(flag)
                {
                    BookMark *bookMark = [[BookMark alloc] init];
                    bookMark.str_guideName = bookMark_src.guideName;
                    bookMark.str_bookMarkTitle = bookMark_src.bookmarkTitle;
                    bookMark.str_bookMarkPageNumber = [NSString stringWithFormat:@"%d",[bookMark_src.bookmarkFile intValue]-1];
                    bookMark.str_guideHtmlInfoPath = @"";
                    [[BookMarkData sharedBookMarkData] addBookmark:bookMark];
                    
                    
                    
                    
                    
                    
                    
                    //如果file目录下没有则不处理书签:
                    NSArray *array_guideInFile = [QYGuideData getAllDownloadGuide];
                    BOOL flag = NO; //file目录下是否存在'bookMark_src.guideName'该锦囊
                    for(QYGuide *guide in array_guideInFile)
                    {
                        if(guide && guide.guideName && [guide.guideName isEqualToString:bookMark_src.guideName])
                        {
                            flag = YES;
                            break;
                        }
                    }
                    if(flag)
                    {
                        //如果该本锦囊还没有解压缩，则进行解压:
                        NSLog(@" 解压缩 解压缩 解压缩 ");
                        //[FileDecompression decompressionFileWithFileName:bookMark.str_guideName];
                        [FileDecompression decompressionFileWithFileName:bookMark.str_guideName isDeleteZip:NO];
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    [bookMark release];
                    
                }
            }
            
            
            
            if([[NSFileManager defaultManager] fileExistsAtPath:str_zip])
            {
                if([[NSFileManager defaultManager] removeItemAtPath:str_zip error:nil])
                {
                    NSLog(@" 删除 path_temp 成功 ");
                }
                else
                {
                    NSLog(@" 删除 path_temp 失败 -1");
                }
            }
            
        }
    }
}
+(NSArray *)unarchiveDataFromCache:(NSString *)guide_name
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = [myPathList objectAtIndex:0];
    
    NSString *catolog_path = [NSString stringWithFormat:@"%@/%@",myPath,guide_name];
    NSLog(@" catolog_path --- %@",catolog_path);
    if([[NSFileManager defaultManager] fileExistsAtPath:catolog_path])
    {
        NSData *data_bookmark = [NSData dataWithContentsOfFile:catolog_path];
        return [NSKeyedUnarchiver unarchiveObjectWithData:data_bookmark];
    }
    else
    {
        return nil;
    }
}
+(NSArray *)unarchiveDataFromCache_after:(NSString *)guide_name
{
    NSString *path_after = [[FilePath sharedFilePath] getFilePath:@"guideListAndCatalog"];
    
    NSString *catolog_path = [NSString stringWithFormat:@"%@/%@",path_after,guide_name];
    NSLog(@" catolog_path --- %@",catolog_path);
    if([[NSFileManager defaultManager] fileExistsAtPath:catolog_path])
    {
        NSData *data_bookmark = [NSData dataWithContentsOfFile:catolog_path];
        return [NSKeyedUnarchiver unarchiveObjectWithData:data_bookmark];
    }
    else
    {
        return nil;
    }
}


+(void)fixBugAppearWhenVersion5WithGuideName:(NSString *)guidename
{
    NSArray *array = [QYGuideData getAllDownloadGuide];
    BOOL flag = NO;
    for(QYGuide *guide in array)
    {
        if([guide.guideName isEqualToString:guidename])
        {
            flag = YES;
        }
    }
    if(!flag)
    {
        
        //删除相关书签:
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[BookMarkData sharedBookMarkData] getBookmarkList]];
        NSString *name_wrong = guidename;
        NSArray *array = [dic allKeys];
        for(NSString *guideName in array)
        {
            NSLog(@"  guideName : %@",guideName);
            if([name_wrong isEqualToString:guideName])
            {
                [dic removeObjectForKey:guideName];
            }
        }
        NSString *plistPath = [[FilePath getBookMarkPath] retain];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [data writeToFile:plistPath atomically:NO];
        [plistPath release];
        
        [dic removeAllObjects];
        [dic release];
    }
}

+(void)fixBugAppearWhenVersion5
{
    
    //取得目录下的所有文件名:
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[FilePath sharedFilePath] getFilePath:@"file"];
    NSArray *downloadGuide_savedInDirectory = [fm contentsOfDirectoryAtPath:filePath error:nil];
    
    BOOL flag = NO;  //初始状态,没有空目录
    for(NSString *str in downloadGuide_savedInDirectory)
    {
        NSLog(@"  str   str  (1) : %@",str);
        if([str rangeOfString:@"_html"].location != NSNotFound)
        {
            NSLog(@"  str   str  (2) : %@",str);
            
            NSString *path_htmlfile = [NSString stringWithFormat:@"%@/%@",filePath,str];
            BOOL ui;
            if([[NSFileManager defaultManager] fileExistsAtPath:path_htmlfile isDirectory:&ui])
            {
                NSArray *array_file = [[NSFileManager defaultManager] subpathsAtPath:path_htmlfile];
                if(array_file.count < 2)
                {
                    NSLog(@"  空目录  空目录 %@",str);
//                    flag = YES;  //有空目录
                    
                    if([[NSFileManager defaultManager] removeItemAtPath:path_htmlfile error:nil])
                    {
                        NSLog(@" 删除 空目录 成功 ");
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"deletewrongguide"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        
                        
                        
                        
                        //删除相关书签:
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[BookMarkData sharedBookMarkData] getBookmarkList]];
                        NSArray *array = [dic allKeys];
                        NSRange range = [str rangeOfString:@"_html"];
                        NSString *name_wrong = [str substringToIndex:range.location];
                        for(NSString *guideName in array)
                        {
                            NSLog(@"  guideName : %@",guideName);
                            if([name_wrong isEqualToString:guideName])
                            {
                                [dic removeObjectForKey:guideName];
                            }
                        }
                        NSString *plistPath = [[FilePath getBookMarkPath] retain];
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
                        [data writeToFile:plistPath atomically:NO];
                        [plistPath release];
                        
                        [dic removeAllObjects];
                        [dic release];
                        
                    }
                    else
                    {
                        NSLog(@" 删除 空目录 失败");
                    }
                    
                }
            }
        }
    }
}


@end

