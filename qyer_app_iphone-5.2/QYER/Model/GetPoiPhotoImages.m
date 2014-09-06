//
//  GetPoiPhotoImages.m
//  QyGuide
//
//  Created by an qing on 13-2-19.
//
//

#import "GetPoiPhotoImages.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "QyYhConst.h"
#define getdatamaxtime      10 //获取POI图库的请求超时时间



@implementation GetPoiPhotoImages
@synthesize picUrl_small    = _picUrl_small;
@synthesize picUrl_big      = _picUrl_big ;
@synthesize dataArray       = _dataArray;
@synthesize position        = _position;
@synthesize userName        = _userName;
@synthesize imageIdStr      = _imageIdStr;
@synthesize allDataArray    = _allDataArray;
@synthesize allMaxIdArray   = _allMaxIdArray;
@synthesize imageDate       = _imageDate;
@synthesize getPoiImagesRequest    = _getPoiImagesRequest;
@synthesize getAllPoiImagesRequest = _getAllPoiImagesRequest;
@synthesize hasDone    = _hasDone;
@synthesize hasAllDone = _hasAllDone;


-(void)dealloc
{
    [_imageIdStr release];
    [_userName release];
    [_picUrl_small release];
    [_picUrl_big release];
    [_dataArray removeAllObjects];
    [_dataArray release];
    [_position release];
    [_imageDate release];
    
    [_allDataArray removeAllObjects];
    [_allDataArray release];
    [_allMaxIdArray removeAllObjects];
    [_allMaxIdArray release];
    
    
    [super dealloc];
}

-(void)cancle
{
    if(self.hasDone == 1)
    {
        [self.getPoiImagesRequest clearDelegatesAndCancel];
    }
    
    if(self.hasAllDone == 1)
    {
        [self.getAllPoiImagesRequest clearDelegatesAndCancel];
    }
}

-(void)getPoiPhotoImagesByClientid:(NSString *)client_id
                  andClientSecrect:(NSString *)client_secrect
                          andPoiId:(NSInteger)poiId
                         andMax_id:(NSInteger)max_id
                          finished:(getPoiPhotoImagesFinishedBlock)finished
                            failed:(getPoiPhotoImagesFailedBlock)failed
{
    _hasDone = 1;
    
    
    _getPoiImagesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/poi/get_pic_list?client_id=%@&client_secret=%@&poi_id=%d&max_id=%d&count=%d",DomainName,client_id,client_secrect,poiId,max_id,getImageNumberOneTime]]];
    _getPoiImagesRequest.timeOutSeconds = getdatamaxtime;
    MYLog(@"url ==POI IMAGES== %@",[_getPoiImagesRequest.url absoluteString]);
    
    [_getPoiImagesRequest setCompletionBlock:^{
        
        _hasDone = 0;
        
        
        NSString *result = [_getPoiImagesRequest responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            MYLog(@"获取数据成功 -- getPoiImages");
            if([[result JSONValue] valueForKey:@"data"] && [[[result JSONValue] valueForKey:@"data"] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dic = [[result JSONValue] valueForKey:@"data"];
                if(dic && [dic count] > 0 && [dic objectForKey:@"photo_list"] && [[dic objectForKey:@"photo_list"] isKindOfClass:[NSArray class]])
                {
                    [self produceData:[dic objectForKey:@"photo_list"] finished:finished failed:failed];
                }
            }
            else
            {
                MYLog(@"获取数据失败-1");
                if(!_dataArray)
                {
                    _dataArray = [[NSMutableArray alloc] init];
                }
                else if(_dataArray)
                {
                    [_dataArray removeAllObjects];
                }
                
                failed();
            }
        }
        else
        {
            if([result rangeOfString:@"timed out"].location != NSNotFound)
            {
                MYLog(@"请求超时~~~");
                if(!_dataArray)
                {
                    _dataArray = [[NSMutableArray alloc] init];
                }
                else if(_dataArray)
                {
                    [_dataArray removeAllObjects];
                }
                
                failed();
            }
            else
            {
                MYLog(@"获取数据失败-2");
                if(!_dataArray)
                {
                    _dataArray = [[NSMutableArray alloc] init];
                }
                else if(_dataArray)
                {
                    [_dataArray removeAllObjects];
                }
                
                failed();
                
            }
        }
    }];
    
    [_getPoiImagesRequest setFailedBlock:^{
        MYLog(@"获取数据失败-3");
        
        _hasDone = 0;
        
        if(!_dataArray)
        {
            _dataArray = [[NSMutableArray alloc] init];
        }
        else if(_dataArray)
        {
            [_dataArray removeAllObjects];
        }
        
        
        failed();
        
    }];
    [_getPoiImagesRequest startAsynchronous];
}

-(void)produceData:(NSArray*)array
          finished:(getPoiPhotoImagesFinishedBlock)finished
            failed:(getPoiPhotoImagesFailedBlock)failed
{
    if(array)
    {
        if(!_dataArray)
        {
            _dataArray = [[NSMutableArray alloc] init];
        }
        else if(_dataArray)
        {
            [_dataArray removeAllObjects];
        }
        
        
        for(int i = 0; i < [array count]; i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            
            GetPoiPhotoImages *poiPhotoImage = [[GetPoiPhotoImages alloc] init];
            if(dic && [dic objectForKey:@"url"] && ![[dic objectForKey:@"url"] isKindOfClass:[NSNull class]] && [[dic objectForKey:@"url"] length] > 0 && ![[dic objectForKey:@"url"] isEqualToString:@"null"])
            {
                poiPhotoImage.picUrl_small = [NSString stringWithFormat:@"%@%d",[dic objectForKey:@"url"],poiImageViewHeightOnServer];
                poiPhotoImage.picUrl_big = [NSString stringWithFormat:@"%@%d",[dic objectForKey:@"url"],showPoiImageViewHeightOnServer];
                poiPhotoImage.userName = [dic objectForKey:@"author_name"];
                poiPhotoImage.imageIdStr = [dic objectForKey:@"id"];
                [_dataArray addObject:poiPhotoImage];
            }
            [poiPhotoImage release];
        }
        finished();
    }
    else
    {
        failed();
    }
}







#pragma mark -
#pragma mark --- getAllPoiPhotoImages
/*
 http://open.qyer.com/place/common/get_photo_list
 client_id	true	string	Open平台客户端id
 client_secret	true	string	Open平台客户端密码
 client_secret	true	string	Open平台客户端密码
 type	true	string	country:国家维度, city:城市维度, poi：poi
 objectid	true	string	对象id
 pagesize	false	int	每页获取条数，默认20
 page	false	int	页码，默认1
 
 */
-(void)getAllPoiPhotoImagesByClientid:(NSString *)client_id
                  andClientSecrect:(NSString *)client_secrect
                                 type:(NSString *)type
                             andPoiId:(NSInteger)poiId
                             pageSize:(NSInteger)pageSize
                                 page:(NSInteger)page
                          finished:(getPoiPhotoImagesFinishedBlock)finished
                            failed:(getPoiPhotoImagesFailedBlock)failed
{
    _hasAllDone = 1;
    
    
    _getAllPoiImagesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/place/common/get_photo_list?client_id=%@&client_secret=%@&type=%@&objectid=%d&pagesize=%d&page=%d&screensize=%@",DomainName,client_id,client_secrect,type,poiId,pageSize,page,screenSize]]];
    _getAllPoiImagesRequest.timeOutSeconds = getdatamaxtime;
    MYLog(@"url ==POI All IMAGES== %@",[_getAllPoiImagesRequest.url absoluteString]);
    
    [_getAllPoiImagesRequest setCompletionBlock:^{
        
        _hasAllDone = 0;
        
        
        NSString *result = [_getAllPoiImagesRequest responseString];
        NSDictionary *jsonDict = [result JSONValue];
        if([[jsonDict objectForKey:@"status"] intValue] == 1)
        {
            MYLog(@"获取数据成功 -- getAllPoiImages");
            if([jsonDict valueForKey:@"data"] && [[jsonDict valueForKey:@"data"] isKindOfClass:[NSArray class]])
            {
                
                NSArray *array = [jsonDict objectForKey:@"data"];

                [self produceAllData:array finished:finished failed:failed];
//                NSDictionary *dic = [[result JSONValue] valueForKey:@"data"];
//                if(dic && [dic count] > 0 && [dic objectForKey:@"photo_list"] && [[dic objectForKey:@"photo_list"] isKindOfClass:[NSArray class]])
//                {
//                    [self produceAllData:[dic objectForKey:@"photo_list"] finished:finished failed:failed];
//                }
            }
            else
            {
                MYLog(@"获取数据失败-1");
                if(!_allDataArray)
                {
                    _allDataArray = [[NSMutableArray alloc] init];
                }
                else if(_allDataArray)
                {
                    [_allDataArray removeAllObjects];
                }
                
                if(!_allMaxIdArray)
                {
                    _allMaxIdArray = [[NSMutableArray alloc] init];
                }
                else if(_allMaxIdArray)
                {
                    [_allMaxIdArray removeAllObjects];
                }
                
                failed();
            }
        }
        else
        {
            if([result rangeOfString:@"timed out"].location != NSNotFound)
            {
                MYLog(@"请求超时~~~");
                if(!_allDataArray)
                {
                    _allDataArray = [[NSMutableArray alloc] init];
                }
                else if(_allDataArray)
                {
                    [_allDataArray removeAllObjects];
                }
                
                if(!_allMaxIdArray)
                {
                    _allMaxIdArray = [[NSMutableArray alloc] init];
                }
                else if(_allMaxIdArray)
                {
                    [_allMaxIdArray removeAllObjects];
                }
                
                failed();
            }
            else
            {
                MYLog(@"获取数据失败-2");
                if(!_allDataArray)
                {
                    _allDataArray = [[NSMutableArray alloc] init];
                }
                else if(_allDataArray)
                {
                    [_allDataArray removeAllObjects];
                }
                
                if(!_allMaxIdArray)
                {
                    _allMaxIdArray = [[NSMutableArray alloc] init];
                }
                else if(_allMaxIdArray)
                {
                    [_allMaxIdArray removeAllObjects];
                }
                
                failed();
                
            }
        }
    }];
    
    [_getAllPoiImagesRequest setFailedBlock:^{
        MYLog(@"获取数据失败-3");
        
        _hasAllDone = 0;
        
        if(!_allDataArray)
        {
            _allDataArray = [[NSMutableArray alloc] init];
        }
        else if(_allDataArray)
        {
            [_allDataArray removeAllObjects];
        }
        
        if(!_allMaxIdArray)
        {
            _allMaxIdArray = [[NSMutableArray alloc] init];
        }
        else if(_allMaxIdArray)
        {
            [_allMaxIdArray removeAllObjects];
        }
        
        failed();
        
    }];
    [_getAllPoiImagesRequest startAsynchronous];
}

-(void)produceAllData:(NSArray*)array
          finished:(getPoiPhotoImagesFinishedBlock)finished
            failed:(getPoiPhotoImagesFailedBlock)failed
{
    if(array)
    {
        if(!_allDataArray)
        {
            _allDataArray = [[NSMutableArray alloc] init];
        }
        else if(_allDataArray)
        {
            [_allDataArray removeAllObjects];
        }
        
        if(!_allMaxIdArray)
        {
            _allMaxIdArray = [[NSMutableArray alloc] init];
        }
        else if(_allMaxIdArray)
        {
            [_allMaxIdArray removeAllObjects];
        }
        
        
        for(int i = 0; i < [array count]; i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            
            GetPoiPhotoImages *poiPhotoImage = [[GetPoiPhotoImages alloc] init];
            if(dic && [dic objectForKey:@"photourl"] && ![[dic objectForKey:@"photourl"] isKindOfClass:[NSNull class]] && [[dic objectForKey:@"photourl"] length] > 0 && ![[dic objectForKey:@"photourl"] isEqualToString:@"null"])
            {

                
                poiPhotoImage.picUrl_small = [NSString stringWithFormat:@"%@",[dic objectForKey:@"small_photourl"]];
                poiPhotoImage.picUrl_big = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photourl"]];
                poiPhotoImage.userName = [dic objectForKey:@"username"];
                poiPhotoImage.imageIdStr = [dic objectForKey:@"photoid"];
                poiPhotoImage.imageDate = [dic objectForKey:@"datetime"];
                [_allDataArray addObject:poiPhotoImage];
                
            }
            [poiPhotoImage release];
        }
        finished();
    }
    else
    {
        failed();
    }
}


@end

