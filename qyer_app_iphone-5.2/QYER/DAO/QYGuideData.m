//
//  QYGuideData.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-6.
//  Copyright (c) 2013年 an qing. All rights reserved.
//





/***************************************************************************

获取锦囊数据的逻辑是:
在获取编辑推荐锦囊之前,如果有缓存的编辑推荐锦囊,先加载缓存再从服务端获取所有的锦囊;如果没有缓存的编辑推荐锦囊首先要获取到所有的锦囊。
当获取到所有的锦囊之后,再获取编辑推荐的锦囊(由获取到的锦囊id从所有锦囊中进行筛选)。
当获取到所有的锦囊之后,再获取需要更新的锦囊。


****************************************************************************/






#import "QYGuideData.h"
#import "Reachability.h"
#import "GetRecommendedGuideByEditer.h"
#import "ASIHTTPRequest.h"
#import "QYGuide.h"
#import "DownloadData.h"
#import "ASIFormDataRequest.h"



@implementation QYGuideData
@synthesize array_allGuide = _array_allGuide;
@synthesize array_guideIsDownloading = _array_guideIsDownloading;
@synthesize array_guideNeedToBeUpdated = _array_guideNeedToBeUpdated;
@synthesize guideName_downloading;
@synthesize flag_getAllNew = _flag_getAllNew;


-(void)dealloc
{
    QY_MUTABLERECEPTACLE_RELEASE(_array_allGuide);
    QY_MUTABLERECEPTACLE_RELEASE(_array_guideIsDownloading);
    QY_MUTABLERECEPTACLE_RELEASE(_array_guideNeedToBeUpdated);
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- sharedQYGuideData 单例
static QYGuideData *sharedQYGuideData = nil;
+(id)sharedQYGuideData
{
    @synchronized (self)
    {
        if(!sharedQYGuideData)
        {
            sharedQYGuideData = [[self alloc] init];
            
            NSMutableArray *array_all = [[NSMutableArray alloc] init];
            sharedQYGuideData.array_allGuide = array_all;
            [array_all release];
            
            
            NSMutableArray *array_isDownloading = [[NSMutableArray alloc] init];
            sharedQYGuideData.array_guideIsDownloading = array_isDownloading;
            [array_isDownloading release];
            
            NSMutableArray *array_needToBeUpdated = [[NSMutableArray alloc] init];
            sharedQYGuideData.array_guideNeedToBeUpdated = array_needToBeUpdated;
            [array_needToBeUpdated release];
            
            
//            [[NSNotificationCenter defaultCenter] addObserver:sharedQYGuideData selector:@selector(changeGuideStatus:) name:@"changeGuideStatus" object:nil];
        }
    }
    
    return sharedQYGuideData;  //外界初始化得到单例类对象的唯一接口,这个类方法返回的就是sharedQYGuideData,即类的一个对象。如果sharedQYGuideData为空,则实例化一个对象;如果不为空,则直接返回。这样保证了实例的唯一。
}
+(id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if(!sharedQYGuideData)
        {
            sharedQYGuideData = [super allocWithZone:zone];
            return sharedQYGuideData;
        }
        
        return sharedQYGuideData;
    }
}
-(id)init
{
    self = [super init];
    @synchronized(self)
    {
        if(sharedQYGuideData)
        {
            return sharedQYGuideData;
        }
        else
        {
            [super init];
            return self;
        }
    }
}
-(id)copy
{
    return self; //copy和copyWithZone这两个方法是为了防止外界拷贝造成多个实例,保证实例的唯一性。
}
-(id)copyWithZone:(NSZone *)zone
{
    return self;
}
-(id)retain
{
    return self; //因为只有一个实例对象,所以retain不能增加引用计数。
}
-(unsigned)retainCount
{
    return UINT_MAX; //因为只有一个实例对象,设置默认引用计数。这里是取的NSUinteger的最大值,当然也可以设置成1或其他值。
}
-(oneway void)release  //'oneway void'用于多线程编程中,表示单向执行,不能“回滚”,即原子操作。
{
    // Do nothing
}




//#pragma mark -
//#pragma mark --- 修改锦囊的状态
//-(void)changeGuideStatus:(NSNotification *)notification
//{
//    NSDictionary *dic = notification.userInfo;
//    
//    if(dic && [dic objectForKey:@"guideName"])
//    {
//        NSLog(@" 修改'%@'的状态",[dic objectForKey:@"guideName"]);
//        NSString *guideName = [dic objectForKey:@"guideName"];
//        QYGuide *guide = [QYGuideData getGuideByName:guideName];
//        guide.guide_state = GuideWating_State;
//    }
//}



#pragma mark -
#pragma mark --- QYGuide锦囊数据存取
//*** [初始化所有锦囊,并获取编辑推荐锦囊]
+(void)getRecommendGuideSuccess:(QYGuideDataSuccessBlock)successBlock
                         failed:(QYGuideDataFailedBlock)failedBlock
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        NSLog(@" initAllGuideFromCache ");
        [self getDataFromCacheSuccess:successBlock
                               failed:failedBlock];
    }
    
    else
    {
        NSLog(@" 开始initAllGuideFromServerSuccess:");
        [self initAllGuideFromServerSuccess:^(NSArray *array){
            NSRange range;
            range.location = 0;
            range.length = recommendGuideNumber;
            if(array.count >= recommendGuideNumber)
            {
                successBlock([array subarrayWithRange:range]);
            }
            else
            {
                successBlock(array);
            }
            
            //从已下载的锦囊列表中获取需要更新的锦囊:
            NSLog(@"开始获取需要更新的锦囊(1):");
            [self getGuideNeedToBeUpdated];
            
        } failed:^{
            NSLog(@"initAllGuideFromServer 失败了！");
            
            
            [self getDataFromCacheSuccess:successBlock
                                   failed:failedBlock];
            
            
            //从已下载的锦囊列表中获取需要更新的锦囊:
            NSLog(@"开始获取需要更新的锦囊(2):");
            [self getGuideNeedToBeUpdated];
            
            failedBlock();
        }];
    }
}
//*** 从缓存获取编辑推荐的锦囊
+(void)getDataFromCacheSuccess:(QYGuideDataSuccessBlock)successBlock
                        failed:(QYGuideDataFailedBlock)failedBlock
{
    if([CacheData isFileExist])
    {
        [self initOnlyRecommendGuideFromCacheSuccess:^(NSArray *array){
            NSRange range;
            range.location = 0;
            range.length = recommendGuideNumber;
            if(array.count >= recommendGuideNumber)
            {
                successBlock([array subarrayWithRange:range]);
            }
            else
            {
                successBlock(array);
            }
        } failed:^{
            NSLog(@"获取编辑推荐锦囊(缓存)失败了！");
        }];
    }
}
+(void)initOnlyRecommendGuideFromCacheSuccess:(QYGuideDataSuccessBlock)successBlock
                                       failed:(QYGuideDataFailedBlock)failedBlock
{
    NSMutableArray *array_allGuide = [[NSMutableArray alloc] init];
    
    //获取编辑推荐锦囊:
    [self initRecommendGuideFromCache:array_allGuide];
    
    
    successBlock(array_allGuide);
    
    [array_allGuide removeAllObjects];
    [array_allGuide release];
}
+(void)initAllGuideFromServerSuccess:(QYGuideDataSuccessBlock)successBlock
                              failed:(QYGuideDataFailedBlock)failedBlock
{
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"get_all_guide_time"])
    {
        [self getAllMobileGuideListWithModifiedTime:0
                                            success:^(NSArray *array){
                                                
                                                //记录获取到数据的时间:
                                                NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
                                                [[NSUserDefaults standardUserDefaults] setObject:time forKey:@"get_all_guide_time"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                
                                                NSLog(@" [首次启动时] 从网络请求到的数据个数:%d",array.count);
                                                
                                                
                                                //获取编辑推荐锦囊:
                                                [self initRecommendGuideSuccess:^(NSArray *array){
                                                    NSMutableArray *array_allGuide = [[NSMutableArray alloc] initWithArray:array];
                                                    
                                                    
                                                    successBlock(array_allGuide);
                                                    
                                                    [array_allGuide removeAllObjects];
                                                    [array_allGuide release];
                                                    
                                                } failed:^{
                                                    NSLog(@" 首次 initRecommendGuide 失败");
                                                    failedBlock();
                                                }];
                                            } failed:^{
                                                NSLog(@" 首次 getAllMobileGuideListWithModifiedTime 失败 -- ModifiedTime = 0");
                                                failedBlock();
                                            }];
    }
    else
    {
        [self getAllMobileGuideListWithModifiedTime:[[[NSUserDefaults standardUserDefaults] objectForKey:@"get_all_guide_time"] intValue]
                                            success:^(NSArray *array){
                                                
                                                
                                                if(array.count == 0)
                                                {
                                                    NSLog(@" 没有获取到新的锦囊");
                                                }
                                                else
                                                {
                                                    //记录获取到数据的时间:
                                                    NSString *time = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
                                                    [[NSUserDefaults standardUserDefaults] setObject:time forKey:@"get_all_guide_time"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                }
                                                
                                                NSLog(@" ==== 从网络请求到的数据个数:%d",array.count);
                                                
                                                
                                                //获取编辑推荐锦囊:
                                                [self initRecommendGuideSuccess:^(NSArray *array){
                                                    
                                                    NSLog(@" initRecommendGuide 成功");
                                                    
                                                    NSMutableArray *array_guideGeted = [[NSMutableArray alloc] initWithArray:array];
                                                    
                                                    
                                                    successBlock(array_guideGeted);
                                                    
                                                    
                                                    [array_guideGeted removeAllObjects];
                                                    [array_guideGeted release];
                                                } failed:^{
                                                    NSLog(@"initRecommendGuide 失败");
                                                    failedBlock();
                                                }];
                                                
                                                
                                                
                                            } failed:^{
                                                NSLog(@"getAllMobileGuideListWithModifiedTime失败 ModifiedTime != 0");
                                                failedBlock();
                                            }];
    }
}
//获取编辑推荐锦囊[缓存]:
+(void)initRecommendGuideFromCache:(NSMutableArray *)_array_editerRecommendDuide
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_recommended.plist",[pathURL path]];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
    
    NSMutableArray *arrar_ = [[NSMutableArray alloc] init];
    NSArray *array_allGuide = [self getAllGuide];
    
    for(QYGuide *guide in array)
    {
        for(QYGuide *guide_ in array_allGuide)
        {
            if([guide.guideId isEqualToString:guide_.guideId])
            {
                [arrar_ addObject:guide_];
                break;
            }
        }
    }
    if(arrar_ && arrar_.count > 0)
    {
        NSLog(@"缓存数据 -- 编辑推荐 ");
        [_array_editerRecommendDuide removeAllObjects];
        [_array_editerRecommendDuide addObjectsFromArray:arrar_];
    }
    [arrar_ removeAllObjects];
    [arrar_ release];
}
//获取编辑推荐锦囊[服务器]:
+(void)initRecommendGuideSuccess:(QYGuideDataSuccessBlock)successBlock
                          failed:(QYGuideDataFailedBlock)failedBlock
{
    NSLog(@" === 获取编辑推荐锦囊[服务器] ===");
    NSMutableArray *_array_editerRecommendDuide = [[NSMutableArray alloc] init];
    
    
    NSDictionary *infoDict =[[NSBundle mainBundle] infoDictionary];
    float appVerson = [[infoDict objectForKey:@"CFBundleShortVersionString"] floatValue];
    Reachability *netCheck = [Reachability reachabilityForInternetConnection];
    if(appVerson - 2.5 > 0 && [netCheck currentReachabilityStatus] > 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hasdownloadguiderecommendedbyediter"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //从服务器请求数据:
        [GetRecommendedGuideByEditer getRecommendedGuidebyPoiByClientid:ClientId_QY
                                                       andClientSecrect:ClientSecret_QY
                                                          andDeviceType:@"iphone"
                                                               finished:^(NSArray *array){
                                                                   
                                                                   NSLog(@"网络数据 -- 编辑推荐 ");
                                                                   
                                                                   NSMutableArray *arr_ = [[NSMutableArray alloc] init];
                                                                   for(int i = 0; i < array.count; i++)
                                                                   {
                                                                       QYGuide *guide = [self getGuideById:[array objectAtIndex:i]];
                                                                       if(guide)
                                                                       {
                                                                           [arr_ addObject:guide];
                                                                       }
                                                                   }
                                                                   
                                                                   
                                                                   //保存数据，供无网络时使用:
                                                                   [self cacheRecommendedData:arr_];
                                                                   
                                                                   [_array_editerRecommendDuide removeAllObjects];
                                                                   [_array_editerRecommendDuide addObjectsFromArray:arr_];
                                                                   
                                                                   successBlock(_array_editerRecommendDuide);
                                                                   [arr_ removeAllObjects];
                                                                   [arr_ release];
                                                                   
                                                                   [_array_editerRecommendDuide removeAllObjects];
                                                                   [_array_editerRecommendDuide release];
                                                                   
                                                               }
                                                                 failed:^{
                                                                     [_array_editerRecommendDuide removeAllObjects];
                                                                     [_array_editerRecommendDuide release];
                                                                     
                                                                     failedBlock();
                                                                 }];
        
    }
    else if(appVerson - 2.5 > 0 && [[NSUserDefaults standardUserDefaults] objectForKey:@"hasdownloadguiderecommendedbyediter"])  //没有网络时读取缓存
    {
        [self initRecommendGuideFromCache:_array_editerRecommendDuide];
        successBlock(_array_editerRecommendDuide);
        [_array_editerRecommendDuide removeAllObjects];
        [_array_editerRecommendDuide release];
    }
    else
    {
        [_array_editerRecommendDuide release];
        
    }
}
+(void)cacheRecommendedData:(NSArray *)arr_
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_recommended.plist",[pathURL path]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr_];
    [data writeToFile:plistPath atomically:NO];
}


//*** [搜索锦囊]:
+(void)searchGuideWithString:(NSString *)searchStr
                    finished:(QYGuideDataSuccessBlock)successBlock
                      failed:(QYGuideDataFailedBlock)failedBlock
{
    NSMutableArray *array_allGuide = [[NSMutableArray alloc] initWithArray:[self getAllGuide]];
    
    NSMutableArray *array_result = [[NSMutableArray alloc] init];
    NSString *search_Str = [searchStr uppercaseString];
    for(QYGuide *guide in array_allGuide)
    {
        NSString *guideName             = [guide.guideName uppercaseString];
        NSString *guideName_en          = [guide.guideName_en uppercaseString];
        NSString *guideName_py          = [guide.guideName_pinyin uppercaseString];
        NSString *guideCountryName      = [guide.guideCountry_name_cn uppercaseString];
        NSString *guideCountryName_en   = [guide.guideCountry_name_en uppercaseString];
        NSString *guideCountryName_py   = [guide.guideCountry_name_py uppercaseString];
        
        if( (guideName && [guideName rangeOfString:search_Str].location != NSNotFound) ||
           (guideName_en && [guideName_en rangeOfString:search_Str].location != NSNotFound) ||
           (guideName_py && [guideName_py rangeOfString:search_Str].location != NSNotFound) ||
           (guideCountryName && [guideCountryName rangeOfString:search_Str].location != NSNotFound) ||
           (guideCountryName_en && [guideCountryName_en rangeOfString:search_Str].location != NSNotFound) ||
           (guideCountryName_py && [guideCountryName_py rangeOfString:search_Str].location != NSNotFound) )
        {
            //[array_result addObject:guide];
            [array_result insertObject:guide atIndex:0];
        }
    }
    
    if(array_result.count > 0)
    {
        successBlock(array_result);
    }
    else
    {
        NSLog(@"无搜索结果");
        failedBlock();
    }
    
    [array_allGuide removeAllObjects];
    [array_allGuide release];
    [array_result removeAllObjects];
    [array_result release];
}


//*** [从服务器获取全部锦囊列表]
+(void)getAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime
                                     success:(QYGuideDataSuccessBlock)successBlock
                                      failed:(QYGuideDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient]
     getAllMobileGuideListWithModifiedTime:modifiedTime
     success:^(NSDictionary *dic){
         if(dic && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"])
         {
             NSLog(@"getAllMobileGuideListWithModifiedTime 成功");
             
             NSArray *array = [dic objectForKey:@"data"];
             if(array && array.count > 0)
             {
                 NSLog(@"新获取锦囊的个数:%d",array.count);
                 
                 
                 [self processData:array];
                 
                 
                 
                 //*** 更新锦囊最新的下载次数:
                 NSArray *arr = [[CacheData sharedCacheData] getCacheData];
                 NSLog(@"  arr.count (1) : %d",arr.count);
                 [self getGuideDownloadTimeSuccessBlock:^(NSArray *array_downloadTimes){
                     
                     for(QYGuide *guide in arr)
                     {
                         for(NSDictionary *dic in array_downloadTimes)
                         {
                             if(dic && [dic objectForKey:@"id"])
                             {
                                 NSString *str_guide_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
                                 NSString *str_downloadTimes = [NSString stringWithFormat:@"%@",[dic objectForKey:@"downcount"]];
                                 
                                 if([guide.guideId isEqualToString:str_guide_id])
                                 {
                                     guide.guideDownloadTimes = str_downloadTimes;
                                     break;
                                 }
                             }
                         }
                     }
                     NSLog(@"  arr.count (2) : %d",arr.count);
                     
                     //*** 缓存到本地:
                     [[CacheData sharedCacheData] cacheData:arr];
                     
                     NSArray *arr = [[CacheData sharedCacheData] getCacheData];
                     NSLog(@"  arr.count (3) : %d",arr.count);
                     successBlock(arr);
                     
                 } failed:^{
                     
                     successBlock(arr);
                 }];
                 
             }
             else
             {
                 NSLog(@"没有新更新或新增加的锦囊 !");
                 
                 
                 //本地已缓存的锦囊:
                 NSMutableArray *array_allLocalGuide = [[NSMutableArray alloc] initWithArray:[[CacheData sharedCacheData] getCacheData]];
                 NSLog(@"  array_allLocalGuide.count  : %d",array_allLocalGuide.count);
                 
                 
                 //*** 删除已下线的锦囊:
                 [self getAllInvalidGuideListSuccess:^(NSArray *array_invalid){
                     if(array_invalid && array_invalid.count > 0)
                     {
                         [self deleteInvalidGuideInArrayFromAllDownloadGuideArray:array_invalid];
                         [self deleteInvalidGuideInArray:array_invalid FromAllGuideArray:array_allLocalGuide];
                         
                         
                         [array_allLocalGuide removeAllObjects];
                         [array_allLocalGuide release];
                         
                     }
                 } failed:^{
                     NSLog(@"没有已下线的锦囊");
                 }];
                 
                 
                 
                 //*** 更新锦囊最新的下载次数:
                 NSArray *arr = [[CacheData sharedCacheData] getCacheData];
                 NSLog(@"  array_allLocalGuide.count  : %d",array_allLocalGuide.count);
                 NSLog(@"  arr.count == 1 ==  : %d",arr.count);
                 [self getGuideDownloadTimeSuccessBlock:^(NSArray *array_downloadTimes){
                     
                     for(QYGuide *guide in arr)
                     {
                         for(NSDictionary *dic in array_downloadTimes)
                         {
                             if(dic && [dic objectForKey:@"id"])
                             {
                                 NSString *str_guide_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
                                 NSString *str_downloadTimes = [NSString stringWithFormat:@"%@",[dic objectForKey:@"downcount"]];
                                 
                                 if([guide.guideId isEqualToString:str_guide_id])
                                 {
                                     guide.guideDownloadTimes = str_downloadTimes;
                                     break;
                                 }
                             }
                         }
                     }
                     
                     
                     //*** 缓存到本地:
                     NSLog(@"  arr.count == 2 ==  : %d",arr.count);
                     [[CacheData sharedCacheData] cacheData:arr];
                     
                     NSArray *arr = [[CacheData sharedCacheData] getCacheData];
                     successBlock(arr);
                     
                 } failed:^{
                     
                     successBlock(arr);
                 }];
                 
             }
         }
         else
         {
             NSLog(@"getAllMobileGuideListWithModifiedTime 失败");
             failedBlock();
         }
     }
     failed:^{
         NSLog(@"getAllMobileGuideListWithModifiedTime 失败");
         failedBlock();
     }];
    
}
+(void)getGuideDownloadTimeSuccessBlock:(QYGuideDataSuccessBlock)successBlock
                                 failed:(QYGuideDataFailedBlock)failedBlock
{
    NSLog(@" 开始获取所有锦囊的最新下载次数:");
    
    [[QYAPIClient sharedAPIClient] getGuideDownloadTimeFinished:^(NSDictionary *dic){
        
        if(dic && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
        {
            NSLog(@" 获取锦囊的最新下载次数 成功");
            
            successBlock([dic objectForKey:@"data"]);
        }
        else
        {
            NSLog(@" 获取锦囊的最新下载次数 失败 ~~");
            failedBlock();
        }
    } failed:^{
        NSLog(@" 获取锦囊的最新下载次数 失败!");
        failedBlock();
    }];
}
+(void)processData:(NSArray *)array
{
    NSMutableArray *array_newGuide = [[NSMutableArray alloc] init];
    [self initGuideFromSrc:array toArray:array_newGuide];
    
    
    //本地已缓存的锦囊:
    NSMutableArray *array_allLocalGuide = [[NSMutableArray alloc] initWithArray:[[CacheData sharedCacheData] getCacheData]];
    
    
    //*** 将数据缓存到本地:
    if(array_newGuide && array_newGuide.count > 0)
    {
        NSArray *array_local_tmp = [array_allLocalGuide retain];
        for(QYGuide *guide_server in array_newGuide)
        {
            for(QYGuide *guide_local in array_local_tmp)
            {
                if([guide_server.guideName isEqualToString:guide_local.guideName])
                {
                    [array_allLocalGuide removeObject:guide_local];
                    break;
                }
            }
        }
        [array_local_tmp release];
        [array_allLocalGuide addObjectsFromArray:array_newGuide];
        
        
        //*** 按照锦囊的更新时间排序:
        NSArray *array_sort = [array_allLocalGuide sortedArrayUsingComparator:^(QYGuide *obj1, QYGuide *obj2){
            
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
        [array_allLocalGuide removeAllObjects];
        [array_allLocalGuide addObjectsFromArray:array_sort];
    }
    
    
    
    //*** 删除已下线的锦囊:
    [self getAllInvalidGuideListSuccess:^(NSArray *array){
        if(array && array.count > 0)
        {
            [self deleteInvalidGuideInArrayFromAllDownloadGuideArray:array];
            [self deleteInvalidGuideInArray:array FromAllGuideArray:array_allLocalGuide];
        }
    } failed:^{
        NSLog(@"没有已下线的锦囊");
    }];
    
    
    
    //*** 缓存到本地:
    [[CacheData sharedCacheData] cacheData:array_allLocalGuide];
    
    
    [array_allLocalGuide removeAllObjects];
    [array_allLocalGuide release];
    [array_newGuide removeAllObjects];
    [array_newGuide release];
}
+(void)deleteInvalidGuideInArray:(NSArray *)array FromAllGuideArray:(NSMutableArray *)array_allLocalGuide
{
    if(!array_allLocalGuide || !array || array_allLocalGuide.count == 0 || array.count == 0)
    {
        return;
    }
    
    for(id dic in array)
    {
        if([dic isKindOfClass:[NSDictionary class]])
        {
            NSString *guide_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            
            for(QYGuide *guide in array_allLocalGuide)
            {
                if([guide.guideId isEqualToString:guide_id])
                {
                    NSLog(@" 删除时的名称: %@",guide.guideName);
                    [array_allLocalGuide removeObject:guide];
                    
                    break;
                }
            }
        }
    }
    
    
    //*** 缓存到本地:
    [[CacheData sharedCacheData] cacheData:array_allLocalGuide];
    [[[QYGuideData sharedQYGuideData] array_allGuide] removeAllObjects];
}
+(void)deleteInvalidGuideInArrayFromAllDownloadGuideArray:(NSArray *)array
{
    if(!array || array.count == 0)
    {
        return;
    }
    
    
    NSMutableArray *array_allDownloadGuide = [[NSMutableArray alloc] initWithArray:[QYGuideData getAllDownloadGuide]];
    for(id dic in array)
    {
        if([dic isKindOfClass:[NSDictionary class]])
        {
            NSString *guide_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            
            for(QYGuide *guide in array_allDownloadGuide)
            {
                if([guide.guideId isEqualToString:guide_id])
                {
                    NSLog(@" 删除已下载时的名称: %@",guide.guideName);
                    [array_allDownloadGuide removeObject:guide];
                    
                    
                    
                    //*** 从沙盒中删除:
                    NSString *filePath = [[FilePath sharedFilePath] getZipFilePath];
                    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@_html",filePath,guide.guideName];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:htmlPath])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:htmlPath error:nil];
                    }
                    NSString *zipPath = [NSString stringWithFormat:@"%@/%@.zip",filePath,guide.guideName];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
                    }
                    
                    
                    break;
                }
            }
        }
    }
    
    
    //*** 缓存到本地:
    [CacheData cacheDownloadedGuideData:array_allDownloadGuide];
    [array_allDownloadGuide removeAllObjects];
    [array_allDownloadGuide release];
}
+(void)initGuideFromSrc:(NSArray *)array toArray:(NSMutableArray *)Array_allguide
{
    for(int i = 0 ; i < array.count ; i++)
    {
        NSDictionary *dic = [array objectAtIndex:i];
        if(dic && [dic isKindOfClass:[NSDictionary class]])
        {
            QYGuide *guide = [[QYGuide alloc] init];
            
            guide.guideId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            guide.guideName = [dic objectForKey:@"name"];
            guide.guideName_en = [dic objectForKey:@"enname"];
            guide.guideName_pinyin = [dic objectForKey:@"pinyin"];
            guide.guideCategory_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"category_id"]];
            guide.guideCategory_name = [dic objectForKey:@"category_title"];
            guide.guideCountry_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"country_id"]];
            guide.guideCountry_name_cn = [dic objectForKey:@"country_name_cn"];
            guide.guideCountry_name_en = [dic objectForKey:@"country_name_en"];
            guide.guideCountry_name_py = [dic objectForKey:@"country_name_py"];
            guide.guideCoverImage = [dic objectForKey:@"cover"];
            guide.guideCoverImage_big = [dic objectForKey:@"big_cover"];
            guide.guideCover_updatetime = [dic objectForKey:@"update_time"];
            guide.guideBriefinfo = [dic objectForKey:@"briefinfo"];
            
            
            
            //*** guide的属性(iPhone):
            NSDictionary *dic_mobile = [dic objectForKey:@"mobile_guide"];
            guide.guideFilePath = [dic_mobile objectForKey:@"file"];
            guide.guideUpdate_time = [NSString stringWithFormat:@"%@",[dic_mobile objectForKey:@"update_time"]];
            guide.guideSize = [NSString stringWithFormat:@"%@",[dic_mobile objectForKey:@"size"]];
            guide.guidePages = [NSString stringWithFormat:@"%@",[dic_mobile objectForKey:@"page"]];
            
            
            
            guide.guideCatalog = [dic objectForKey:@"catalog"];
            guide.guideCreate_time = [NSString stringWithFormat:@"%@",[dic objectForKey:@"create_time"]];
            guide.guideDownloadTimes = [NSString stringWithFormat:@"%@",[dic objectForKey:@"download"]];
            guide.guideType = [dic objectForKey:@"type"];
            guide.guideAuthor_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"author_id"]];
            guide.guideAuthor_name = [dic objectForKey:@"author_name"];
            guide.guideAuthor_icon = [dic objectForKey:@"author_icon"];
            guide.guideAuthor_intro = [dic objectForKey:@"author_intro"];
            guide.guideData_iPhone = [dic objectForKey:@"mobile_guide"];
            guide.guideData_iPad = [dic objectForKey:@"pad_guide"];
            guide.guide_relatedGuide_ids = [dic objectForKey:@"other_guide_ids"];
            guide.guideUpdate_log = [dic objectForKey:@"update_log"];
            
            
            
            [Array_allguide addObject:guide];
            [guide release];
        }
    }
}

//*** 获取已下线的锦囊列表:
+(void)getAllInvalidGuideListSuccess:(QYGuideDataSuccessBlock)successBlock
                              failed:(QYGuideDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getAllInvalidGuideListSuccess:^(NSDictionary *dic){
        NSLog(@"获取已下线的锦囊列表成功!");
        if(dic && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"])
        {
            NSArray *array = [dic objectForKey:@"data"];
            successBlock(array);
        }
        
    } failed:^{
        NSLog(@"获取已下线的锦囊列表失败!");
        failedBlock();
    }];
}

//*** [获取所有锦囊]
+(NSArray *)getAllGuide
{
    if(![[QYGuideData sharedQYGuideData] array_allGuide] || [[[QYGuideData sharedQYGuideData] array_allGuide] isKindOfClass:[NSNull class]] || [[[QYGuideData sharedQYGuideData] array_allGuide] count] == 0)
    {
        NSArray *array = [[CacheData sharedCacheData] getCacheData];
        [[[QYGuideData sharedQYGuideData] array_allGuide] addObjectsFromArray:array];
        [self replaceGuideStateWithDownloadedGuide:array];
        return [[QYGuideData sharedQYGuideData] array_allGuide];
    }
    else
    {
        return [[QYGuideData sharedQYGuideData] array_allGuide];
    }
}
+(NSArray *)getAllGuide_first //私有方法,不允许外部调用!
{
    NSArray *array = [[CacheData sharedCacheData] getCacheData];
    [[[QYGuideData sharedQYGuideData] array_allGuide] removeAllObjects];
    [[[QYGuideData sharedQYGuideData] array_allGuide] addObjectsFromArray:array];
    [self replaceGuideStateWithDownloadedGuide:array];
    
    sharedQYGuideData.flag_getAllNew = YES;
    
    
    
    //处理特殊情况(当已下载的锦囊不在getall的数据中时)
    //获取plist文件中保存的已下载的锦囊:
    NSArray *array_download_cachedInPlist = [[CacheData getDownloadedGuideCache] retain];
    for(QYGuide *guide in array_download_cachedInPlist)
    {
        QYGuide *guide_ = [QYGuideData getGuideByName:guide.guideName];
        if(!guide_)
        {
            guide.guide_state = GuideRead_State;
            [[[QYGuideData sharedQYGuideData] array_allGuide] addObject:guide];
        }
    }
    [array_download_cachedInPlist release];
    
    
    return [[QYGuideData sharedQYGuideData] array_allGuide];
}


//*** [如果数组中包含已下载的锦囊,则将该数组中已下载锦囊的锦囊状态修改为GuideRead_State]
+(void)replaceGuideStateWithDownloadedGuide:(NSArray *)array
{
    if(!array || array.count == 0)
    {
        return;
    }
    
    
    NSArray *download_array = [[self getAllDownloadGuide] retain]; //本地已下载的锦囊
    for(QYGuide *guide_download in download_array)
    {
        if(guide_download && ![guide_download isKindOfClass:[NSNull class]])
        {
            for(int i = 0; i < array.count; i++)
            {
                QYGuide *guide_new = [array objectAtIndex:i];
                if([guide_download.guideName isEqualToString:guide_new.guideName])
                {
                    guide_new.guide_state = GuideRead_State;
                    
                    break;
                }
            }
        }
    }
    [download_array release];
}


//*** [获取所有已下载的锦囊]
+(NSArray *)getAllDownloadGuide
{
    
    
    //*** [ 03.31调整 ]:
    //取得一个目录下的所有文件名:
    NSMutableArray *downloadArray = [[NSMutableArray alloc] init];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[FilePath sharedFilePath] getFilePath:@"file"];
    NSArray *downloadGuide_savedInDirectory = [fm contentsOfDirectoryAtPath:filePath error:nil];
    
    for(NSString *str in downloadGuide_savedInDirectory)
    {
        if([str rangeOfString:@"_html"].location != NSNotFound)
        {
            NSString *guide_name = [str substringToIndex:[str length]-[@"_html" length]];
            NSLog(@" guide_name [_html] : %@",guide_name);
            
            QYGuide *guide = [QYGuideData getGuideByName:guide_name];
            if(guide)
            {
                guide.guide_state = GuideRead_State; //在‘QYGuide’类没有对guide_state进行序列化,因为guide_state不是某个类的对象,而是一枚举类型的实例变量。
                [downloadArray removeObject:guide];
                [downloadArray addObject:guide];
            }
        }
        else if ([str rangeOfString:@".zip"].location != NSNotFound)
        {
            NSString *guide_name = [str substringToIndex:[str length]-[@".zip" length]];
            
            
            QYGuide *guide = [QYGuideData getGuideByName:guide_name];
            if(guide)
            {
                guide.guide_state = GuideRead_State; //在‘QYGuide’类没有对guide_state进行序列化,因为guide_state不是某个类的对象,而是一枚举类型的实例变量。
                [downloadArray removeObject:guide];
                [downloadArray addObject:guide];
            }
        }
    }
    
    NSLog(@" ");
    NSLog(@" ");
    NSLog(@" ");
    NSLog(@" ");
    for(QYGuide *guide in downloadArray)
    {
        NSLog(@"  guideName : %@",guide.guideName);
    }
    
    return [downloadArray autorelease];
    
    
    
    
    
    
    
//    
//    //获取plist文件中保存的已下载的锦囊:
//    NSArray *array_download_cachedInPlist = [[CacheData getDownloadedGuideCache] retain];
//
//    
//    //取得一个目录下的所有文件名:
//    NSMutableArray *downloadArray = [[NSMutableArray alloc] init];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSString *filePath = [[FilePath sharedFilePath] getFilePath:@"file"];
//    NSArray *downloadGuide_savedInDirectory = [fm contentsOfDirectoryAtPath:filePath error:nil];
//    
//    
//    
//    for(NSString *str in downloadGuide_savedInDirectory)
//    {
//        if([str rangeOfString:@"_html"].location != NSNotFound)
//        {
//            NSString *guide_name = [str substringToIndex:[str length]-[@"_html" length]];
//            
//            for(QYGuide *guide in array_download_cachedInPlist)
//            {
//                if(guide && [guide.guideName isEqualToString:guide_name])
//                {
//                    guide.guide_state = GuideRead_State; //在‘QYGuide’类没有对guide_state进行序列化,因为guide_state不是某个类的对象,而是一枚举类型的实例变量。
//                    [downloadArray removeObject:guide];
//                    [downloadArray addObject:guide];
//                    
//                    break;
//                }
//            }
//        }
//        else if ([str rangeOfString:@".zip"].location != NSNotFound)
//        {
//            NSString *guide_name = [str substringToIndex:[str length]-[@".zip" length]];
//            
//            for(QYGuide *guide in array_download_cachedInPlist)
//            {
//                if(guide && [guide.guideName isEqualToString:guide_name])
//                {
//                    guide.guide_state = GuideRead_State; //在‘QYGuide’类没有对guide_state进行序列化,因为guide_state不是某个类的对象,而是一枚举类型的实例变量。
//                    [downloadArray removeObject:guide];
//                    [downloadArray addObject:guide];
//                    
//                    break;
//                }
//            }
//        }
//    }
//    
//    [array_download_cachedInPlist release];
//    return [downloadArray autorelease];
}

//*** [通过guide_id获取guide_name]
+(NSString *)getGuideNameByGuideId:(NSString *)idString
{
    NSArray *array_allGuide = [self getAllGuide];
    for(int i = 0; i < array_allGuide.count; i++)
    {
        QYGuide *guide = (QYGuide *)[array_allGuide objectAtIndex:i];
        if([guide.guideId isEqualToString:idString])
        {
            return guide.guideName;
        }
    }
    return nil;
}


//*** [通过guide_id获取QYGuide]
+(QYGuide *)getGuideById:(NSString *)idString
{
    NSArray *array_allGuide = [self getAllGuide];
    for(int i = 0; i < array_allGuide.count; i++)
    {
        QYGuide *guide = (QYGuide *)[array_allGuide objectAtIndex:i];
        if(guide && ![guide isKindOfClass:[NSNull class]])
        {
            NSString *guide_id = [NSString stringWithFormat:@"%@",guide.guideId];
            if([guide_id isEqualToString:idString])
            {
                return guide;
            }
        }
    }
    return nil;
}

//*** [通过guide_name获取QYGuide]
+(QYGuide *)getGuideByName:(NSString *)guide_name
{
    NSArray *array_allGuide = [self getAllGuide];
    
    for(int i = 0; i < array_allGuide.count; i++)
    {
        QYGuide *guide = (QYGuide *)[array_allGuide objectAtIndex:i];
        if(guide && ![guide isKindOfClass:[NSNull class]])
        {
            if([guide.guideName isEqualToString:guide_name])
            {
                return guide;
            }
        }
    }
    return nil;
}


#pragma mark -
#pragma mark --- 从已下载的锦囊列表中获取需要更新的锦囊 & 删除需要更新的锦囊:
//+(void)getGuideNeedToBeUpdated
//{
//    NSArray *array_download = [[self getAllDownloadGuide] retain];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for(QYGuide *guide_download in array_download)
//        {
//            QYGuide *guide = [QYGuideData getGuideById:guide_download.guideId];
//            
//            BOOL flag = [guide.guideUpdate_time compare:guide_download.guideUpdate_time];
//            if(flag > 0)
//            {
//                for(int i = 0; i < [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count; i++)
//                {
//                    QYGuide *guide_ = [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] objectAtIndex:i];
//                    if([guide_.guideName isEqualToString:guide_download.guideName])
//                    {
//                        [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] removeObjectAtIndex:i];
//                    }
//                }
//                [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] addObject:guide];
//            }
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count : %d",[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count);
//            NSLog(@"获取需要更新的锦囊 完毕!");
//            
//            
//            if([[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] && [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count > 0)
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"someGuideNeedToBeUpdated" object:nil userInfo:nil];
//            }
//            
//        });
//    });
//    
//    [array_download release];
//}
+(void)getGuideNeedToBeUpdated
{
    NSArray *array_download = [[self getAllDownloadGuide] retain];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
        NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloadtime.plist",[pathURL path]];
        if([fileManager fileExistsAtPath:plistPath])
        {
            NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
            NSLog(@"  dic : %@",dic);
            
            for(QYGuide *guide_download in array_download)
            {
                NSString *time_old = [dic objectForKey:[NSString stringWithFormat:@"%@_updatetime",guide_download.guideName]];
                NSLog(@"   time_old : %@",time_old);
                NSLog(@"   time_new : %@",guide_download.guideUpdate_time);
                NSLog(@"   guideName: %@",guide_download.guideName);
                
//                long long time = [time_old longLongValue];
//                NSDate *date = [[[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0] autorelease];
//                NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//                dateFormatter.dateFormat = @"yyyyMMdd HHmmss";

                
                if([guide_download.guideUpdate_time longLongValue] - [time_old longLongValue] > 0)
                {
                    [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] removeObject:guide_download];
                    [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] addObject:guide_download];
                }
                
                //从旧版本更新过来的(已没有这种情况，已做处理。 14/04/19 01:33:31)
                if(!time_old)
                {
                    [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] removeObject:guide_download];
                    QYGuide *guide = [QYGuideData getGuideById:guide_download.guideId];
                    if([guide.guideUpdate_time longLongValue] - [guide_download.guideUpdate_time longLongValue] > 0)
                    {
                        [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] addObject:guide_download];
                    }
                }
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count : %d",[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count);
            NSLog(@"获取需要更新的锦囊 完毕!");
            
            
            if([[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] && [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"someGuideNeedToBeUpdated" object:nil userInfo:nil];
            }
            
        });
    });
    
    [array_download release];
}
+(void)deleteGuideNeedToBeUpdatedWithGuideName:(NSString *)guide_name
{
    for(int i = 0; i < [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] count]; i++)
    {
        QYGuide *guide = [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] objectAtIndex:i];
        if([guide.guideName isEqualToString:guide_name])
        {
            [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] removeObjectAtIndex:i];
            break;
        }
    }
}



#pragma mark -
#pragma mark --- 保存 / 删除 / 获取正在下载的锦囊:
+(void)cacheDownloadingGuide:(QYGuide *)guide
{
    NSLog(@" 新增的   guidename : %@",guide.guideName);
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[QYGuideData sharedQYGuideData] array_guideIsDownloading]];
    for(QYGuide *guide_ in array)
    {
        NSLog(@" 删除   guide : %@",guide_);
        NSLog(@" 删除   guidename : %@",guide_.guideName);
        
        if([guide.guideName isEqualToString:guide_.guideName])
        {
            NSLog(@" 删除  删除  删除 ");
            
            [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObject:guide_];
            break;
        }
    }
    if(guide && guide.guide_state != GuideRead_State)
    {
        [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] addObject:guide];
    }
    [array removeAllObjects];
    [array release];
}
+(void)deleteGuideIsDownloadingWithGuideName:(NSString *)guide_name
{
    for(int i = 0; i < [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] count]; i++)
    {
        QYGuide *guide = [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] objectAtIndex:i];
        if([guide.guideName isEqualToString:guide_name])
        {
            NSLog(@" 删除的锦囊的名称是 : %@",guide_name);
            
            [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObjectAtIndex:i];
            
            [[QYGuideData sharedQYGuideData] deleteGuideInDownloadingPlistWithGuideName:guide.guideName];
            
        }
    }
    
    
    
    
    NSArray *array_downloading_plist = [self getDownloadingGuide];
    for(int i = 0; i < [array_downloading_plist count]; i++)
    {
        QYGuide *guide = [array_downloading_plist objectAtIndex:i];
        if([guide.guideName isEqualToString:guide_name])
        {
            [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObjectAtIndex:i];
            
            [[QYGuideData sharedQYGuideData] deleteGuideInDownloadingPlistWithGuideName:guide.guideName];
            
        }
    }
    
}
+(NSArray *)getDownloadingGuide
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloading.plist",[pathURL path]];
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&ui])
    {
        NSData *data = [NSData dataWithContentsOfFile:plistPath];
        if(data)
        {
            NSArray *array = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
            for(QYGuide *guide in array)
            {
                NSString *guideName = [guide.guideName retain];
                QYGuide *guide_new = [QYGuideData getGuideByName:guideName];
                for(QYGuide *guide_old in [[QYGuideData sharedQYGuideData] array_guideIsDownloading])
                {
                    if(guide_old && [guide_old.guideName isEqualToString:guideName])
                    {
                        [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObject:guide_old];
                        break;
                    }
                }
                if(guide_new && guide_new.guide_state != GuideRead_State)
                {
                    [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] addObject:guide_new];
                }
                [guideName release];
            }
            [array release];
        }
    }
    
    for(QYGuide *guide in [[QYGuideData sharedQYGuideData] array_guideIsDownloading])
    {
        if(guide.guide_state == GuideRead_State)
        {
            [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObject:guide];
            break;
        }
    }
    
    return [[QYGuideData sharedQYGuideData] array_guideIsDownloading];
}



#pragma mark -
#pragma mark --- [锦囊的下载暂停取消等操作]
+(void)startDownloadWithGuide:(QYGuide *)guide
{
    [self createFileStorePath];
    [self getDataFromServer:guide];
    [self saveGuideIsDownloading:guide];
}
+(void)createFileStorePath
{
    BOOL success_flag = [[FilePath sharedFilePath] createFilePath:@"file"];
    BOOL success_flag2 = [[FilePath sharedFilePath] createFilePath:@"file_tmp"];
    
    if(success_flag >= 0)
    {
        //NSLog(@"创建目录成功");
    }
    else
    {
        //NSLog(@"创建目录失败");
    }
    if(success_flag2 >= 0)
    {
        //NSLog(@"创建临时目录成功");
    }
    else
    {
        //NSLog(@"创建临时目录失败");
    }
}
+(void)getDataFromServer:(QYGuide *)guide
{
    NSString *key = guide.guideName;
    NSString *value = [NSString stringWithFormat:@"%@?modified=%@",guide.guideFilePath,guide.guideUpdate_time];
    
    
    
    //*** 测试结果ok:
    //NSString *value = [NSString stringWithFormat:@"%@%@",guide.guideFilePath,@"?1393842028"];
    //NSLog(@"  value  : %@",value);
    
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:value]];
    NSString *plistPathTmp = [[FilePath sharedFilePath] getFilePath:@"file_tmp"];
    NSString *plistPath = [[FilePath sharedFilePath] getFilePath:@"file"];
    plistPathTmp = [NSString stringWithFormat:@"%@/%@.zip.tmp",plistPathTmp,key];
    plistPath = [NSString stringWithFormat:@"%@/%@.zip",plistPath,key];
    request.temporaryFileDownloadPath = plistPathTmp;
    request.downloadDestinationPath = plistPath;
    [request setAllowResumeForFileDownloads:YES];
    request.shouldContinueWhenAppEntersBackground = YES;  //后台允许下载
    request.shouldAttemptPersistentConnection = NO;
    request.timeOutSeconds = 15;
    
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:guide.guideName forKey:@"guideName"];
    [dic setObject:guide.guideId forKey:@"guideId"];
    [dic setObject:guide.guideFilePath forKey:@"guideFilePath"];
    [dic setObject:guide.guideUpdate_time forKey:@"guideUpdate_time"];
    request.userInfo = dic;
    [dic release];
    
    
    [[DownloadData sharedDownloadData] addRequest:request withDelegate:[QYGuideData sharedQYGuideData]];
}
+(void)suspend:(QYGuide *)guide
{
    [self deleteGuideIsDownloadingWithGuideName:guide.guideName];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:guide.guideName forKey:@"guideName"];
    [[DownloadData sharedDownloadData] suspend:dic];
    [dic removeAllObjects];
    [dic release];
}
+(void)saveGuideIsDownloading:(QYGuide *)guide
{
    [QYGuideData cacheDownloadingGuide:guide];
}



#pragma mark -
#pragma mark --- MINE - ASIDownloadQueue - delegate
- (void)downloadQueueDidStarted:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [[request userInfo] retain];
    NSLog(@" QYGuideData  (Started) = %@",userInfo);
    
    
    [[QYGuideData sharedQYGuideData] setGuideName_downloading:[userInfo objectForKey:@"guideName"]];
    
    
    //*** 更新锦囊的状态:
    [self reSetGuideState:GuideDownloading_State withGuideName:[userInfo objectForKey:@"guideName"]];
    
    [userInfo release];
}
-(void)downloadQueueDidFinished:(ASIHTTPRequest *)request
{
    NSDictionary *userinfo = [[request userInfo] retain];
    NSLog(@" QYGuideData -下载成功  = %@",[userinfo objectForKey:@"guideName"]);
    
    
    [self deleteGuideInDownloadingPlistWithGuideName:[userinfo objectForKey:@"guideName"]];
    
    
    //将下载成功的消息反馈给服务器:
    [self guideDownloadedCount:[[userinfo objectForKey:@"guideId"] intValue]];
    
    
    //删除原来已阅读的页数(仅在更新时有意义):
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,[userinfo objectForKey:@"guideName"]]];
    
    
    //*** 更新锦囊的状态:
    [self reSetGuideState:GuideRead_State withGuideName:[userinfo objectForKey:@"guideName"]];
    
    
    //*** 更新正在下载锦囊的个数:
    [QYGuideData deleteGuideIsDownloadingWithGuideName:[userinfo objectForKey:@"guideName"]];
    
    
    //*** 更新需要更新的锦囊的个数:
    [QYGuideData deleteGuideNeedToBeUpdatedWithGuideName:[userinfo objectForKey:@"guideName"]];
    
    
    //*** 更新'需要更新的锦囊按钮'个数:
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNumOfGuideNeedToBeUpdated" object:nil userInfo:nil];
    
    
    //*** 将下载成功的锦囊保存到本地:
    NSMutableArray *array_download = [[NSMutableArray alloc] init];
    if([CacheData getDownloadedGuideCache] && [CacheData getDownloadedGuideCache].count > 0)
    {
        [array_download addObjectsFromArray:[CacheData getDownloadedGuideCache]];
    }
    for(QYGuide *guide_download in array_download)
    {
        if([guide_download.guideName isEqualToString:[userinfo objectForKey:@"guideName"]])
        {
            [array_download removeObject:guide_download];
            break;
        }
    }
    QYGuide *guide_download = [QYGuideData getGuideByName:[userinfo objectForKey:@"guideName"]];
    guide_download.download_type = nil;
    [array_download addObject:guide_download];
    [CacheData cacheDownloadedGuideData:array_download];
    [array_download release];
    
    
    
    //将'已下载的并需要更新的锦囊'删除:
    [FilePath deleteGuideWithGuideName:[userinfo objectForKey:@"guideName"]];
    
    
    [userinfo release];
    
}
- (void)downloadQueueDidFailed:(ASIHTTPRequest *)request
{
    NSDictionary *userinfo = [request userInfo];
    if(!userinfo || ![userinfo objectForKey:@"guideName"])
    {
        return;
    }
    NSLog(@" QYGuideData  下载失败 = %@",[userinfo objectForKey:@"guideName"]);
    
    [self processGuideWhenDownloadFailed:userinfo];
    
}
-(void)processGuideWhenDownloadFailed:(NSDictionary *)userinfo
{
    //修改锦囊的状态:
    if([FilePath isExitGuideWithGuideName:[userinfo objectForKey:@"guideName"]])
    {
        NSLog(@" 更新失败啦～");
        [self reSetGuideState:GuideRead_State withGuideName:[userinfo objectForKey:@"guideName"]];
    }
    else
    {
        NSLog(@" 下载失败啦～");
        [self reSetGuideState:GuideDownloadFailed_State withGuideName:[userinfo objectForKey:@"guideName"]];
    }
    
    
    //将锦囊移动到沙盒中的file目录下(更新锦囊的情况):
    [FilePath removeGuideToDownloadPathWithGuideName:[userinfo objectForKey:@"guideName"]];
    
    
    //更新失败后的逻辑,继续提示'一键更新N本锦囊'。
    //更新‘正在下载的锦囊’数组:
    [QYGuideData deleteGuideIsDownloadingWithGuideName:[userinfo objectForKey:@"guideName"]];
    
    
    //更新‘需要进行更新的锦囊’数组:
    NSArray *array_allDownload = [QYGuideData getAllDownloadGuide];
    for(QYGuide *guide in array_allDownload)
    {
        if([guide.guideName isEqualToString:[userinfo objectForKey:@"guideName"]])
        {
            BOOL flag = 0;
            for(QYGuide *guide_NeedToBeUpdated in [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated])
            {
                if([guide.guideName isEqualToString:guide_NeedToBeUpdated.guideName])
                {
                    flag = 1;
                    break;
                }
            }
            if(flag == 0)
            {
                [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] addObject:guide];
            }
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hideUpdateButton_updateAllGuide"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

-(void)deleteGuideInDownloadingPlistWithGuideName:(NSString *)guideName
{
    if(!guideName)
    {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloading.plist",[pathURL path]];
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&ui])
    {
        NSData *data = [NSData dataWithContentsOfFile:plistPath];
        if(data)
        {
            NSArray *array_tmp = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:array_tmp];
            for(QYGuide *guide in array)
            {
                if([guideName isEqualToString:guide.guideName])
                {
                    NSLog(@" 删除原来已存在的 :%@",guideName);
                    [array removeObject:guide];
                    break;
                }
            }
            NSData *data_ = [NSKeyedArchiver archivedDataWithRootObject:array];
            if(data_)
            {
                [data_ writeToFile:plistPath atomically:NO];
            }
            
            [array removeAllObjects];
            [array release];
            [array_tmp release];
            
        }
        
    }
}


#pragma mark -
#pragma mark --- 更新锦囊的状态
-(void)reSetGuideState:(Guide_state_fuction)state withGuideName:(NSString *)guide_name
{
    QYGuide *guide = [QYGuideData getGuideByName:[[QYGuideData sharedQYGuideData] guideName_downloading]];
    guide.guide_state = state;
}




#pragma mark -
#pragma mark --- ASIProgress - Delegate
-(void)setProgress:(float)newProgress
{
    if([[QYGuideData sharedQYGuideData] guideName_downloading])
    {
        QYGuide *guide = [QYGuideData getGuideByName:[[QYGuideData sharedQYGuideData] guideName_downloading]];
        guide.progressValue = newProgress;
    }
}













// ================================ ***   V4.0   *** ============================= //
// ================================ ***   V4.0   *** ============================= //
// ================================ ***   V4.0   *** ============================= //


//获取上次退出时还正在下载的锦囊:
+(NSArray *)getDownloadingGuideWhenQuit
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloading.plist",[pathURL path]];
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&ui])
    {
        NSData *data = [NSData dataWithContentsOfFile:plistPath];
        if(data)
        {
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if(array)
            {
                NSMutableArray *array_guideName = [[NSMutableArray alloc] init];
                for(QYGuide *guide in array)
                {
                    if(guide && ![guide isKindOfClass:[NSNull class]] && guide.guideName)
                    {
                        [array_guideName addObject:guide.guideName];
                    }
                }
                
                return [array_guideName autorelease];
            }
        }
    }
    return nil;
}


#pragma mark -
#pragma mark --- 获取所有锦囊数据
+(void)fromV4_getAllGuideIncludeCache:(BOOL)flag
                              success:(fromV4_QYGuideListSuccessBlock)successBlock
                               failed:(fromV4_QYGuideListFailedBlock)failedBlock
{
    if(flag)
    {
        //缓存:
        NSLog(@" fromV4_getDataFromCache ");
        [self fromV4_getDataFromCacheSuccess:successBlock
                                      failed:failedBlock];
    }
    
    
    
    //有网络时再从服务器获取:
    if(!([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable))
    {
        NSLog(@" 开始fromV4_initAllGuideFromServer:");
        [self fromV4_initAllGuideFromServerSuccess:^(NSArray *array,BOOL isCache){
            
            
            //获取上次退出时还正在下载的锦囊:
            NSArray *array_tmp = [[self getDownloadingGuideWhenQuit] retain];
            for(NSString *guide_name in array_tmp)
            {
                for(QYGuide *guide in array)
                {
                    if([guide_name isEqualToString:guide.guideName])
                    {
                        guide.guide_state = GuideDownloadFailed_State;
                        break;
                    }
                }
            }
            [array_tmp release];
            
            successBlock(array,isCache);
            
            
            //从已下载的锦囊列表中获取需要更新的锦囊:
            NSLog(@"开始获取需要更新的锦囊(1):");
            [self getGuideNeedToBeUpdated];
            
        } failed:^{
            NSLog(@"initAllGuideFromServer 失败了！");
            
            //从已下载的锦囊列表中获取需要更新的锦囊:
            NSLog(@"开始获取需要更新的锦囊(2):");
            [self getGuideNeedToBeUpdated];
            
            
            failedBlock();
        }];
    }
}
+(void)fromV4_getDataFromCacheSuccess:(fromV4_QYGuideListSuccessBlock)successBlock
                               failed:(fromV4_QYGuideListFailedBlock)failedBlock
{
    NSArray *arr_out = [self getAllGuide];
    
    
    //获取上次退出时还正在下载的锦囊:
    NSArray *array_tmp = [[self getDownloadingGuideWhenQuit] retain];
    for(NSString *guide_name in array_tmp)
    {
        for(QYGuide *guide in arr_out)
        {
            if([guide_name isEqualToString:guide.guideName])
            {
                guide.guide_state = GuideDownloadFailed_State;
                break;
            }
        }
    }
    [array_tmp release];
    
    successBlock(arr_out,1);
}
+(void)fromV4_initAllGuideFromServerSuccess:(fromV4_QYGuideListSuccessBlock)successBlock
                                     failed:(fromV4_QYGuideListFailedBlock)failedBlock
{
    [self fromV4_getAllMobileGuideListWithModifiedTime:0
                                               success:^(NSArray *array,BOOL isCache){
                                                   
                                                   if(array)
                                                   {
                                                       NSLog(@" fromV4_getAllMobileGuideList个数:%d",array.count);
                                                       
                                                       successBlock(array,isCache);
                                                   }
                                                   else
                                                   {
                                                       NSLog(@"  fromV4_getAllMobileGuideList 失败 - 0 ");
                                                       failedBlock();
                                                   }
                                                   

                                               } failed:^{
                                                   NSLog(@"  fromV4_getAllMobileGuideList 失败 - 1");
                                                   failedBlock();
                                               }];
    
}

//*** [从服务器获取全部锦囊列表]
+(void)fromV4_getAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime
                                            success:(fromV4_QYGuideListSuccessBlock)successBlock
                                             failed:(fromV4_QYGuideListFailedBlock)failedBlock
{
    
    NSLog(@" 开始 --- 从服务器获取全部锦囊列表 ");
    
    [[QYAPIClient sharedAPIClient]
     fromV4_getAllMobileGuideListWithModifiedTime:modifiedTime
     success:^(NSDictionary *dic){
         
         if(dic && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"])
         {
             NSLog(@"fromV4_getAllMobileGuideList 成功");
             
             NSArray *array = [dic objectForKey:@"data"];
             if(array && array.count > 0)
             {
                 
                 NSLog(@" 成功 --- 从服务器获取全部锦囊列表 ");
                 
                 NSLog(@"新获取锦囊的个数:%d",array.count);
                 
                 
                 [self fromV4_processData:array];
                 NSArray *arr_out = [self getAllGuide_first];
                 successBlock(arr_out,0);
                 
                 
             }
             else
             {
                 NSLog(@" 成功 --- 从服务器获取全部锦囊列表 ");
                 
                 NSLog(@"没有新更新或新增加的锦囊 !");
                 
                 
                 NSArray *arr_out = [self getAllGuide_first];
                 successBlock(arr_out,0);
                 
                 
             }
         }
         else
         {
             NSLog(@" 失败 --- 从服务器获取全部锦囊列表 ");
             
             NSLog(@"fromV4_getAllMobileGuideList 失败");
             failedBlock();
         }
     }
     failed:^{
         NSLog(@" 失败 --- 从服务器获取全部锦囊列表 ");
         
         NSLog(@"fromV4_getAllMobileGuideList 失败");
         failedBlock();
     }];
}

//取消获取锦囊数据:
+(void)cancleGetGuideData
{
    [[QYAPIClient sharedAPIClient] cancleGetAllMobileGuideListWithModifiedTime:0];
}


//*** [由锦囊的id获取锦囊的详情 --- 本地缓存 ]
+(void)getGuideDetailInfoFromCacheWithGuideId:(NSString *)guide_id
                                      success:(QYGuideSuccessBlock)successBlock
                                       failed:(QYGuideFailedBlock)failedBlock
{
    NSDictionary *dic_cache = [CacheData getCachedGuideDetailInfoData];
    if(dic_cache && [dic_cache isKindOfClass:[NSDictionary class]])
    {
        QYGuide *guide = [dic_cache objectForKey:guide_id];
        if(guide)
        {
            successBlock(guide);
        }
        else
        {
            failedBlock();
        }
    }
    else
    {
        failedBlock();
    }
}


//*** [由锦囊的id获取锦囊的详情 --- 服务器 ]
+(void)getGuideDetailInfoWithGuideId:(NSString *)guide_id
                             success:(QYGuideSuccessBlock)successBlock
                              failed:(QYGuideFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getGuideDeatilInfoWithGuideId:guide_id
                                                         success:^(NSDictionary *dic){
                                                             
                                                             if(dic && [dic isKindOfClass:[NSDictionary class]] && dic.count > 0)
                                                             {
                                                                 NSString *state = [NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]];
                                                                 if(state && [state isEqualToString:@"1"] && [dic objectForKey:@"data"])
                                                                 {
                                                                     QYGuide *guide = [self prepareGuideInfo:[dic objectForKey:@"data"]];
                                                                     if(guide)
                                                                     {
                                                                         NSMutableDictionary *dic_cache = [[NSMutableDictionary alloc] initWithDictionary:[CacheData getCachedGuideDetailInfoData]];
                                                                         [dic_cache setObject:guide forKey:guide.guideId];
                                                                         [CacheData cacheGuideDetailInfoData:dic_cache];
                                                                         [dic_cache release];
                                                                         
                                                                         successBlock(guide);
                                                                     }
                                                                     else
                                                                     {
                                                                         failedBlock();
                                                                     }
                                                                 }
                                                                 else
                                                                 {
                                                                     failedBlock();
                                                                 }
                                                             }
                                                             else
                                                             {
                                                                 failedBlock();
                                                             }
                                                         }
                                                          failed:^{
                                                              NSLog(@" failed failed failed");
                                                              failedBlock();
                                                          }];
    
}
+(QYGuide *)prepareGuideInfo:(NSDictionary *)dic
{
    if(dic && [dic isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic_mobile = [dic objectForKey:@"mobile_guide"];
        if((![dic objectForKey:@"id"] || [[dic objectForKey:@"id"] isKindOfClass:[NSNull class]])
           ||(![dic objectForKey:@"name"] || [[dic objectForKey:@"name"] isKindOfClass:[NSNull class]])
           ||(![dic_mobile objectForKey:@"file"] || [[dic_mobile objectForKey:@"file"] isKindOfClass:[NSNull class]])
           ||(![dic objectForKey:@"category_title"] || [[dic objectForKey:@"category_title"] isKindOfClass:[NSNull class]])
           )
        {
            return nil;
        }
        
        
        
        
        
        
        //***(有问题)
        QYGuide *guide = [QYGuideData getGuideById:[NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]]];
        if(!guide)
        {
            return nil;
        }
        
        
        guide.guideId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        guide.guideName = [dic objectForKey:@"name"];
        guide.guideName_en = [dic objectForKey:@"enname"];
        guide.guideName_pinyin = [dic objectForKey:@"pinyin"];
        guide.guideCategory_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"category_id"]];
        if([dic objectForKey:@"category_title"] && [[dic objectForKey:@"category_title"] isEqualToString:@"专题锦囊"])
        {
            guide.guideCategory_name = @"专题";
        }
        else
        {
            guide.guideCategory_name = [dic objectForKey:@"category_title"];
        }
        guide.guideCountry_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"country_id"]];
        guide.guideCountry_name_cn = [dic objectForKey:@"country_name_cn"];
        guide.guideCountry_name_en = [dic objectForKey:@"country_name_en"];
        guide.guideCountry_name_py = [dic objectForKey:@"country_name_py"];
        //guide.guideCoverImage = [dic objectForKey:@"cover"];
        guide.guideCoverImage_big = [dic objectForKey:@"big_cover"];
        //guide.guideCover_updatetime = [dic objectForKey:@"updatetime"];
        guide.guideBriefinfo = [dic objectForKey:@"briefinfo"];
        
        
        
        
        //*** dic_mobile -- guide的属性(iPhone):
        guide.guideFilePath = [NSString stringWithFormat:@"%@",[dic_mobile objectForKey:@"file"]];
        guide.guideUpdate_time = [NSString stringWithFormat:@"%@",[dic_mobile objectForKey:@"update_time"]];
        guide.guideSize = [NSString stringWithFormat:@"%@",[dic_mobile objectForKey:@"size"]];
        guide.guidePages = [NSString stringWithFormat:@"%@",[dic_mobile objectForKey:@"page"]];
        
        
        
        
        
        guide.guideCatalog = [dic objectForKey:@"catalog"];
        guide.guideCreate_time = [NSString stringWithFormat:@"%@",[dic objectForKey:@"create_time"]];
        guide.guideDownloadTimes = [NSString stringWithFormat:@"%@",[dic objectForKey:@"download"]];
        guide.guideType = [dic objectForKey:@"type"];
        guide.guideAuthor_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"author_id"]];
        guide.guideAuthor_name = [dic objectForKey:@"author_name"];
        guide.guideAuthor_icon = [dic objectForKey:@"author_icon"];
        guide.guideAuthor_intro = [dic objectForKey:@"author_intro"];
        guide.guideData_iPhone = [dic objectForKey:@"mobile_guide"];
        guide.guideData_iPad = [dic objectForKey:@"pad_guide"];
        guide.guide_relatedGuide_ids = [dic objectForKey:@"other_guide_ids"];
        guide.guideUpdate_log = [dic objectForKey:@"guide_relatedGuide_ids"];
        
        return guide;
    }
    
    return nil;
}
+(void)cancleGuideDetailInfoWithGuideId:(NSString *)guide_id
{
    [[QYAPIClient sharedAPIClient] cancleGuideDetailInfoWithGuideId:guide_id];
}




//根据国家或城市ID获取锦囊列表:
+(void)getGuideListWithType:(NSString *)type
                      andId:(NSString *)str_id
                    success:(QYGuideListSuccessBlock)successBlock
                     failed:(QYGuideListFailedBlock)failedBlock
{
    if([[QYGuideData sharedQYGuideData] flag_getAllNew] == YES)
    {
        [[QYAPIClient sharedAPIClient] getGuideListWithType:type
                                                      andId:str_id
                                                    success:^(NSDictionary *dic){
                                                        
                                                        if(dic && [dic isKindOfClass:[NSDictionary class]] && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && [[dic objectForKey:@"data"] isKindOfClass:[NSArray class]])
                                                        {
                                                            NSArray *array = [[self prepareGuideList:[dic objectForKey:@"data"]] retain];
                                                            successBlock(array);
                                                            [array release];
                                                        }
                                                        else
                                                        {
                                                            failedBlock();
                                                        }
                                                    }
                                                     failed:^{
                                                         failedBlock();
                                                     }];
    }
    else
    {
        [self fromV4_getAllGuideIncludeCache:NO
                                     success:^(NSArray *array,BOOL isCache){
            
            [[QYAPIClient sharedAPIClient] getGuideListWithType:type
                                                          andId:str_id
                                                        success:^(NSDictionary *dic){
                                                            
                                                            if(dic && [dic isKindOfClass:[NSDictionary class]] && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && [[dic objectForKey:@"data"] isKindOfClass:[NSArray class]])
                                                            {
                                                                NSArray *array = [[self prepareGuideList:[dic objectForKey:@"data"]] retain];
                                                                successBlock(array);
                                                                [array release];
                                                            }
                                                            else
                                                            {
                                                                failedBlock();
                                                            }
                                                        }
                                                         failed:^{
                                                             failedBlock();
                                                         }];
            
        } failed:^{
            NSLog(@" fromV4_getAllGuide 失败 --- ");
        }];
    }
    
}
+(NSArray *)prepareGuideList:(NSArray *)array
{
    NSMutableArray *array_out = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic && [dic isKindOfClass:[NSDictionary class]])
        {
            
            if((![dic objectForKey:@"guide_id"] || [[dic objectForKey:@"guide_id"] isKindOfClass:[NSNull class]])
               ||(![dic objectForKey:@"guide_cnname"] || [[dic objectForKey:@"guide_cnname"] isKindOfClass:[NSNull class]])
               ||(![dic objectForKey:@"file"] || [[dic objectForKey:@"file"] isKindOfClass:[NSNull class]])
               ||(![dic objectForKey:@"category_title"] || [[dic objectForKey:@"category_title"] isKindOfClass:[NSNull class]])
               )
            {
                continue;
            }
            
            
            
            NSString *guide_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"guide_id"]];
            QYGuide *guide = [QYGuideData getGuideById:guide_id];
            if(guide)
            {
                [array_out addObject:guide];
            }
            
            
            
//            QYGuide *guide = [[QYGuide alloc] init];
//            guide.guideId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"guide_id"]];
//            guide.guideName = [dic objectForKey:@"guide_cnname"];
//            guide.guideName_en = [dic objectForKey:@"guide_enname"];
//            guide.guideCategory_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"category_id"]];
//            guide.guideCategory_name = [dic objectForKey:@"category_title"];
//            guide.guideCountry_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"country_id"]];
//            guide.guideCountry_name_cn = [dic objectForKey:@"country_name_cn"];
//            guide.guideCountry_name_en = [dic objectForKey:@"country_name_en"];
//            guide.guideCountry_name_py = [dic objectForKey:@"country_name_py"];
//            guide.guideCoverImage = [dic objectForKey:@"cover"];
//            guide.guideCover_updatetime = [dic objectForKey:@"cover_updatetime"];
//            guide.guideUpdate_time = [NSString stringWithFormat:@"%@",[dic objectForKey:@"update_time"]];
//            guide.guideSize = [NSString stringWithFormat:@"%@",[dic objectForKey:@"size"]];
//            guide.guideDownloadTimes = [NSString stringWithFormat:@"%@",[dic objectForKey:@"download"]];
//            guide.guideType = [dic objectForKey:@"type"];
//            
//            
//            [array_out addObject:guide];
//            [guide release];
        }
    }
    
    return [array_out autorelease];
}
+(void)fromV4_processData:(NSArray *)array
{
    NSMutableArray *array_newGuide = [[NSMutableArray alloc] init];
    [self fromV4_initGuideFromSrc:array toArray:array_newGuide];
    
    
    //本地已缓存的锦囊:
    //NSMutableArray *array_allLocalGuide = [[NSMutableArray alloc] initWithArray:[[CacheData sharedCacheData] getCacheData]];
    //本地已缓存的锦囊:
    NSMutableArray *array_allLocalGuide = [[NSMutableArray alloc] init];
    
    
    //*** 将数据缓存到本地:
    if(array_newGuide && array_newGuide.count > 0)
    {
        NSArray *array_local_tmp = [array_allLocalGuide retain];
        for(QYGuide *guide_server in array_newGuide)
        {
            for(QYGuide *guide_local in array_local_tmp)
            {
                if([guide_server.guideName isEqualToString:guide_local.guideName])
                {
                    [array_allLocalGuide removeObject:guide_local];
                    break;
                }
            }
        }
        [array_local_tmp release];
        [array_allLocalGuide addObjectsFromArray:array_newGuide];
        
        
        //*** 按照锦囊的更新时间排序:
        NSArray *array_sort = [array_allLocalGuide sortedArrayUsingComparator:^(QYGuide *obj1, QYGuide *obj2){
            
            BOOL result = [obj1.guideUpdate_time compare:obj2.guideUpdate_time];
            if(result <= 0)
            {
                return (NSComparisonResult)NSOrderedAscending;
            }
            else if(result > 0)
            {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        [array_allLocalGuide removeAllObjects];
        [array_allLocalGuide addObjectsFromArray:array_sort];
    }
    
    
    //*** 缓存到本地:
    [[CacheData sharedCacheData] cacheData:array_allLocalGuide];
    
    
    [array_allLocalGuide removeAllObjects];
    [array_allLocalGuide release];
    [array_newGuide removeAllObjects];
    [array_newGuide release];
}
+(void)fromV4_initGuideFromSrc:(NSArray *)array toArray:(NSMutableArray *)Array_allguide
{
    for(int i = 0 ; i < array.count ; i++)
    {
        
        NSDictionary *dic = [array objectAtIndex:i];
        if(dic && [dic isKindOfClass:[NSDictionary class]])
        {
            if((![dic objectForKey:@"guide_id"] || [[dic objectForKey:@"guide_id"] isKindOfClass:[NSNull class]])
               ||(![dic objectForKey:@"guide_cnname"] || [[dic objectForKey:@"guide_cnname"] isKindOfClass:[NSNull class]])
               ||(![dic objectForKey:@"file"] || [[dic objectForKey:@"file"] isKindOfClass:[NSNull class]])
               ||(![dic objectForKey:@"category_title"] || [[dic objectForKey:@"category_title"] isKindOfClass:[NSNull class]])
                )
            {
                continue;
            }
            
            
            
            QYGuide *guide = [[QYGuide alloc] init];
            guide.guideId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"guide_id"]];
            guide.guideName = [dic objectForKey:@"guide_cnname"];
            guide.guideName_en = [dic objectForKey:@"guide_enname"];
            guide.guideCategory_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"category_id"]];
            guide.guideCategory_name = [dic objectForKey:@"category_title"];
            guide.guideCountry_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"country_id"]];
            guide.guideCountry_name_cn = [dic objectForKey:@"country_name_cn"];
            guide.guideCountry_name_en = [dic objectForKey:@"country_name_en"];
            guide.guideCountry_name_py = [dic objectForKey:@"country_name_py"];
            guide.guideDownloadTimes = [NSString stringWithFormat:@"%@",[dic objectForKey:@"download"]];
            guide.guideSize = [NSString stringWithFormat:@"%@",[dic objectForKey:@"size"]];
            guide.guideUpdate_time = [NSString stringWithFormat:@"%@",[dic objectForKey:@"update_time"]];
            guide.guideCoverImage = [dic objectForKey:@"cover"];
            guide.guideCover_updatetime = [dic objectForKey:@"cover_updatetime"];
            guide.guideType = [dic objectForKey:@"type"];
            guide.guideFilePath = [dic objectForKey:@"file"];
            guide.guideUpdate_log = [dic objectForKey:@"update_log"];
            
            [Array_allguide addObject:guide];
            [guide release];
        }
        
    }
}

//根据搜索字符串获取锦囊列表:
+(void)getGuideListWithSearchString:(NSString *)str
                            success:(QYGuideListSuccessBlock)successBlock
                             failed:(QYGuideListFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getGuideListWithSearchString:str
                                                        success:^(NSDictionary *dic){
                                                            
                                                            if(dic && [dic isKindOfClass:[NSDictionary class]] && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && [[dic objectForKey:@"data"] isKindOfClass:[NSArray class]])
                                                            {
                                                                NSArray *array = [[self prepareGuideList:[dic objectForKey:@"data"]] retain];
                                                                successBlock(array);
                                                                [array release];
                                                            }
                                                            else
                                                            {
                                                                failedBlock();
                                                            }
                                                        }
                                                         failed:^{
                                                             failedBlock();
                                                         }];
}



#pragma mark -
#pragma mark --- 反馈给服务器
-(void)guideDownloadedCount:(NSInteger)guideId
{
    [[QYAPIClient sharedAPIClient] feedBackToServerWithGuideId:guideId
                                                       success:^(NSDictionary *dic){
                                                           
                                                           NSLog(@" 反馈给服务器成功: %@",dic);
                                                       } failed:^{
                                                           
                                                           NSLog(@" 反馈给服务器失败~");
                                                       }];
}


@end

