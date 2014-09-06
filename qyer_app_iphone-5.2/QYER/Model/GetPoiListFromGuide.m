//
//  GetPoiListFromGuide.m
//  QyGuide
//
//  Created by an qing on 13-3-20.
//
//

#import "GetPoiListFromGuide.h"
#import <sys/xattr.h>
#import "NSString+SBJSON.h"



@implementation GetPoiListFromGuide
@synthesize poiId           = _poiId;
@synthesize cateId          = _cateId;
@synthesize chineseName     = _chineseName;
@synthesize englishName     = _englishName;
@synthesize categoryName    = _categoryName;
@synthesize lat             = _lat;
@synthesize lng             = _lng;
@synthesize poilistArray    = _poilistArray;


-(void)dealloc
{
    self.chineseName = nil;
    self.englishName = nil;
    self.poilistArray = nil;
    self.categoryName = nil;
    
    [super dealloc];
}


static GetPoiListFromGuide *sharedGetPoiListFromGuide = nil;
+(id)sharedGetPoiListFromGuide
{
    if (!sharedGetPoiListFromGuide)
    {
        sharedGetPoiListFromGuide = [[self alloc] init];
    }
	return sharedGetPoiListFromGuide;
}

-(int)getPoiListFromGuideByGuideName:(NSString *)guide_name
                            finished:(_getPoilistFinishedBlock)finished
                              failed:(_getPoilistFailedBlock)failed
{
    [self getJsonFileWithGuideName:guide_name finished:^{
        finished();
        return 0;
    } failed:^{
        failed();
        return -1;
    }];
    return 0;
}
-(void)getJsonFileWithGuideName:(NSString *)guide_name finished:(_getPoilistFinishedBlock)finished failed:(_getPoilistFailedBlock)failed
{
    NSString *docPath = [self getDocPath];
	NSString *bookPath = [NSString stringWithFormat:@"%@/file",docPath];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:bookPath isDirectory:&ui])
    {
        //[[NSFileManager defaultManager] createDirectoryAtPath:bookPath withIntermediateDirectories:YES attributes:nil error:nil];
        failed();
    }
    else
    {
        NSString *guidePath = [NSString stringWithFormat:@"%@/%@_html",bookPath,guide_name];
        BOOL ui;
        if (![[NSFileManager defaultManager] fileExistsAtPath:guidePath isDirectory:&ui])
        {
            //[[NSFileManager defaultManager] createDirectoryAtPath:guidePath withIntermediateDirectories:YES attributes:nil error:nil];
            //MYLog(@" +++++++ 没有 某本锦囊");
            failed();
        }
        else
        {
            //MYLog(@"htmlPath ==== %@",htmlPath);
            //NSString *poi_listFilePath_json = [htmlPath stringByAppendingPathComponent:@"/poi_list.json"];
            NSString *poi_listFilePath_json = [NSString stringWithFormat:@"%@/%@",guidePath,@"poi_list.json"];
            //MYLog(@"poi_listFilePath_json ---- %@",poi_listFilePath_json);
            BOOL ui;
            if(![[NSFileManager defaultManager] fileExistsAtPath:poi_listFilePath_json isDirectory:&ui])
            {
                //MYLog(@"没有'poi_list.json'文件 --- 1");
                failed();
            }
            else
            {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:poi_listFilePath_json];
                NSData *cacheData = [fileHandle readDataToEndOfFile];
                NSString *cacheString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
                NSArray *poilist_srcDataArray = [cacheString JSONValue];
                if(poilist_srcDataArray && [poilist_srcDataArray isKindOfClass:[NSArray class]])
                {
                    [self setPoiListData:poilist_srcDataArray];
                    finished();
                }
                else
                {
                    failed();
                }
                [cacheString release];
            }
        }
    }
}
-(void)setPoiListData:(NSArray*)poilist_srcDataArray
{
    if(!_poilistArray)
    {
        _poilistArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [_poilistArray removeAllObjects];
    
    for(NSUInteger i = 0; i < [poilist_srcDataArray count]; i++)
    {
        NSDictionary *infoDic = [poilist_srcDataArray objectAtIndex:i];
        
        if(infoDic && [infoDic isKindOfClass:[NSDictionary class]])
        {
            GetPoiListFromGuide *poilistInfo = [[GetPoiListFromGuide alloc] init];
            poilistInfo.poiId  = [[infoDic objectForKey:@"id"] intValue];
            poilistInfo.cateId = [[infoDic objectForKey:@"category_id"] intValue];
            poilistInfo.chineseName  = [infoDic objectForKey:@"cn_name"];
            poilistInfo.englishName  = [infoDic objectForKey:@"en_name"];
            poilistInfo.lat          = [[infoDic objectForKey:@"lat"] floatValue];
            poilistInfo.lng          = [[infoDic objectForKey:@"lng"] floatValue];
            poilistInfo.categoryName = [infoDic objectForKey:@"category_name"];
            [_poilistArray addObject:poilistInfo];
            [poilistInfo release];
        }
    }
}
-(NSString*)getDocPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    return [pathURL path];
}



#pragma mark -
#pragma mark --- 给目录添加不进行'iTunes/iCloud备份'属性
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.1)
    {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success)
        {
            //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    else
    {
        const char* filePath = [[URL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}

@end


