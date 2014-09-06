//
//  GetPoiCommentData.m
//  QYGuide
//
//  Created by 我去 on 14-2-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GetPoiCommentData.h"
#import "PoiComment.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "RegexKitLite.h"



#define getdatamaxtime 10    //获取POI评论的请求超时时间



@implementation GetPoiCommentData
@synthesize allCommentNumber = _allCommentNumber;
@synthesize isDeleteUserCommentFlag = _isDeleteUserCommentFlag;



-(void)dealloc
{
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- GetPoiCommentData单例
static GetPoiCommentData *sharedGetPoiCommentData = nil;
+(GetPoiCommentData *)sharedGetPoiCommentData
{
    @synchronized (self)
    {
        if(!sharedGetPoiCommentData)
        {
            sharedGetPoiCommentData = [[self alloc] init];
        }
    }
    
    return sharedGetPoiCommentData; //外界初始化得到单例类对象的唯一借口，这个类方法返回的就是sharedGetPoiCommentData，即类的一个对象，如果sharedGetPoiCommentData为空，则实例化一个对象，如果不为空，则直接返回。这样保证了实例的唯一。
}
+(id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if(!sharedGetPoiCommentData)
        {
            sharedGetPoiCommentData = [super allocWithZone:zone];
            return sharedGetPoiCommentData;
        }
        
        return sharedGetPoiCommentData;
    }
}
-(id)init
{
    @synchronized(self)
    {
        if(sharedGetPoiCommentData)
        {
            return sharedGetPoiCommentData;
        }
        else
        {
            self = [super init];
            return self;
        }
    }
}
-(id)copy
{
    return self; //copy和copyWithZone这两个方法是为了防止外界拷贝造成多个实例，保证实例的唯一性。
}
-(id)copyWithZone:(NSZone *)zone
{
    return self;
}
-(id)retain
{
    return self; //因为只有一个实例对象，所以retain不能增加引用计数。
}
-(unsigned)retainCount
{
    return UINT_MAX; //因为只有一个实例对象，设置默认引用计数。这里是取的NSUinteger的最大值，当然也可以设置成1或其他值。
}
-(oneway void)release  //oneway void是用于多线程编程中，表示单向执行，不能“回滚”，即原子操作。
{
    // Do nothing
}






#pragma mark -
#pragma mark --- 取消请求
-(void)cancle
{
    if(_hasDone == 1 && _getPoiRequest)
    {
        [_getPoiRequest clearDelegatesAndCancel];
    }
}



#pragma mark -
#pragma mark --- 请求poiComment数据
-(void)getPoiCommentByClientid:(NSString *)client_id
              andClientSecrect:(NSString *)client_secrect
                      andPoiId:(NSInteger)poiId
                     andMax_Id:(NSInteger)max_id
                andOauth_token:(NSString *)user_oauth_token
                      finished:(GetPoiCommentDataSuccessBlock)finished
                        failed:(GetPoiCommentDataFailedBlock)failed
{
    _hasDone = 1;
    //NSLog(@"poiCommentUrl:%@",[NSString stringWithFormat:@"%@/poi_comment/get_list?client_id=%@&client_secret=%@&poiid=%d&max_id=%d&oauth_token=%@&count=20",@"http://open.qyer.com",client_id,client_secrect,poiId,max_id,user_oauth_token]);
    if(user_oauth_token && [user_oauth_token length] > 0)
    {
        _getPoiRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/poi_comment/get_list?client_id=%@&client_secret=%@&poiid=%d&max_id=%d&oauth_token=%@&count=20",@"http://open.qyer.com",client_id,client_secrect,poiId,max_id,user_oauth_token]]];
    }
    else
    {
        _getPoiRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/poi_comment/get_list?client_id=%@&client_secret=%@&poiid=%d&max_id=%d&count=20",@"http://open.qyer.com",client_id,client_secrect,poiId,max_id]]];
    }
    _getPoiRequest.timeOutSeconds = getdatamaxtime;
    MYLog(@"url ==POI COMMENT== %@",[_getPoiRequest.url absoluteString]);
    
    [_getPoiRequest setCompletionBlock:^{
        
        _hasDone = 0;
        
        NSString *result = [_getPoiRequest responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            MYLog(@"获取poicomment数据成功");
            
            if(_userCommentDataArray)
            {
                [_userCommentDataArray removeAllObjects];
            }
            if(_commentDataArray)
            {
                [_commentDataArray removeAllObjects];
            }
            
            if([[[result JSONValue] valueForKey:@"data"] valueForKey:@"list"] && ![[[[result JSONValue] valueForKey:@"data"] valueForKey:@"list"] isKindOfClass:[NSNull class]] && [[[[result JSONValue] valueForKey:@"data"] valueForKey:@"list"] isKindOfClass:[NSArray class]] && [[[[result JSONValue] valueForKey:@"data"] valueForKey:@"list"] count] > 0)
            {
                //当前用户的评论
                if(user_oauth_token && [user_oauth_token length] > 0)
                {
                    if([[[result JSONValue] valueForKey:@"data"] valueForKey:@"one"] && [[[[result JSONValue] valueForKey:@"data"] valueForKey:@"one"] isKindOfClass:[NSDictionary class]])
                    {
                        PoiComment *poiComment = [[PoiComment alloc] init];
                        
                        NSDictionary *dic = [[[result JSONValue] valueForKey:@"data"] valueForKey:@"one"];
                        if([dic objectForKey:@"user"] && [[dic objectForKey:@"user"] isKindOfClass:[NSDictionary class]])
                        {
                            NSDictionary *userDic = [dic objectForKey:@"user"];
                            poiComment.str_userImageUrl = [userDic objectForKey:@"avatar"];
                            poiComment.name_user = [userDic objectForKey:@"username"];
                        }
                        else
                        {
                            poiComment.str_userImageUrl = @"";
                            poiComment.name_user = @"";
                        }
                        
                        NSString *comment_str = [dic objectForKey:@"comment"];
                        for(;;)
                        {
                            if([comment_str rangeOfString:@"\n\n\n"].location != NSNotFound)
                            {
                                comment_str = [comment_str stringByReplacingOccurrencesOfRegex:@"\n\n\n" withString:@"\n\n"];
                            }
                            else
                            {
                                break;
                            }
                        }
                        poiComment.comment_user       = comment_str;
                        poiComment.rate_user          = [dic objectForKey:@"star"];
                        poiComment.commentTime_user   = [dic objectForKey:@"datetime"];
                        poiComment.commentId_user     = [dic objectForKey:@"id"];
                        if(!_userCommentDataArray)
                        {
                            _userCommentDataArray = [[NSMutableArray alloc] init];
                        }
                        [_userCommentDataArray removeAllObjects];
                        [_userCommentDataArray addObject:poiComment];
                        [poiComment release];
                    }
                }
                
                
                NSArray *array = [[[result JSONValue] valueForKey:@"data"] valueForKey:@"list"];
                NSMutableArray *arrayData = [[NSMutableArray alloc] initWithArray:array copyItems:YES];
                self.allCommentNumber = [[[[result JSONValue] valueForKey:@"data"] valueForKey:@"total_number"] intValue];
                [self processData:arrayData];
                [arrayData removeAllObjects];
                [arrayData release];
                
                
                
                
                finished(_commentDataArray,_userCommentDataArray);
            }
            else
            {
                //NSLog(@"评论没有数据");
                
                if(!_commentDataArray)
                {
                    _commentDataArray = [[NSMutableArray alloc] init];
                }
                [_commentDataArray removeAllObjects];
                
                finished(nil,nil);
            }
        }
        else
        {
            if([result rangeOfString:@"timed out"].location != NSNotFound)
            {
                MYLog(@"请求poicomment数据超时 ~~~");
                if(!_commentDataArray)
                {
                    _commentDataArray = [[NSMutableArray alloc] init];
                }
                [_commentDataArray removeAllObjects];
                
                failed();
            }
            else
            {
                MYLog(@"获取poicomment数据失败");
                if(!_commentDataArray)
                {
                    _commentDataArray = [[NSMutableArray alloc] init];
                }
                [_commentDataArray removeAllObjects];
                
                failed();
            }
        }
    }];
    
    [_getPoiRequest setFailedBlock:^{
        MYLog(@"获取数据poicomment失败");
        
        _hasDone = 0;
        
        if(!_commentDataArray)
        {
            _commentDataArray = [[NSMutableArray alloc] init];
        }
        [_commentDataArray removeAllObjects];
        
        failed();
    }];
    [_getPoiRequest startAsynchronous];
}

-(void)processData:(NSMutableArray *)array
{
    _isDeleteUserCommentFlag = 0;
    
    if(array && [array count] > 0)
    {
        if(!_commentDataArray)
        {
            _commentDataArray = [[NSMutableArray alloc] init];
        }
        [_commentDataArray removeAllObjects];
        
        
        for(int i = 0; i < [array count]; i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            
            PoiComment *poiComment = [[PoiComment alloc] init];
            if([dic objectForKey:@"user"] && [[dic objectForKey:@"user"] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *userDic = [dic objectForKey:@"user"];
                poiComment.str_userImageUrl = [userDic objectForKey:@"avatar"];
                poiComment.name_user = [userDic objectForKey:@"username"];
            }
            else
            {
                poiComment.str_userImageUrl = @"";
                poiComment.name_user = @"";
            }
            
            NSString *comment_str = [dic objectForKey:@"comment"];
            for(;;)
            {
                if([comment_str rangeOfString:@"\n\n\n"].location != NSNotFound)
                {
                    comment_str = [comment_str stringByReplacingOccurrencesOfRegex:@"\n\n\n" withString:@"\n\n"];
                }
                else
                {
                    break;
                }
            }
            poiComment.comment_user       = [NSString stringWithFormat:@"%@",comment_str];
            poiComment.rate_user          = [NSString stringWithFormat:@"%@",[dic objectForKey:@"star"]];
            poiComment.commentTime_user   = [NSString stringWithFormat:@"%@",[dic objectForKey:@"datetime"]];
            poiComment.commentId_user     = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            
            [_commentDataArray addObject:poiComment];
            [poiComment release];
        }
    }
}


@end
