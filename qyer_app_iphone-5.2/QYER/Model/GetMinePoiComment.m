//
//  GetMinePoiComment.m
//  QyGuide
//
//  Created by an qing on 13-3-7.
//
//

#import "GetMinePoiComment.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"


#define getdatamaxtime 10    //获取用户自己的评论-请求超时时间


@implementation GetMinePoiComment
@synthesize userImageUrl = _userImageUrl;
@synthesize userName = _userName;
@synthesize userComment = _userComment;
@synthesize userCommentRate = _userCommentRate;
@synthesize userCommentTime = _userCommentTime;
@synthesize userCommentId;

-(void)dealloc
{
    [_userCommentRate release];
    [_userComment release];
    [_userImageUrl release];
    [_userName release];
    [_userCommentTime release];
    
    [super dealloc];
}


-(void)getMineCommentByClientid:(NSString *)client_id
                       andPoiId:(NSInteger)poiId
                       finished:(getMineCommentFinishedBlock)finished
                         failed:(getMineCommentFailedBlock)failed
{
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/poi/comment/get_one_by_user?client_id=%@&oauth_token=%@&poiid=%d",DomainName,client_id,access_token,poiId]]];
    request.timeOutSeconds = getdatamaxtime;
    MYLog(@"url ==MINE COMMENT== %@",[request.url absoluteString]);
    
    [request setCompletionBlock:^{
        
        NSString *result = [request responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            MYLog(@"获取MINEcomment数据成功");
            
            if([[result JSONValue] valueForKey:@"data"] && ![[[result JSONValue] valueForKey:@"data"] isKindOfClass:[NSNull class]] && [[[result JSONValue] valueForKey:@"data"] isKindOfClass:[NSDictionary class]] && [[[result JSONValue] valueForKey:@"data"] count] > 0)
            {
                NSDictionary *dic = [[result JSONValue] valueForKey:@"data"];
                
                [self produceData:dic];
                
                finished();
            }
            else
            {
                MYLog(@"MINEcomment没有数据");
                finished();
            }
        }
        else
        {
            if([request.error.localizedDescription rangeOfString:@"timed out"].location != NSNotFound)
            {
                MYLog(@"请求MINEcomment数据超时 ~~~");
                failed();
            }
            else
            {
                MYLog(@"获取MINEcomment数据失败");
                failed();
            }
        }
        
    }];
    
    [request setFailedBlock:^{
        MYLog(@"获取MINEcomment失败");
        failed();
    }];
    [request startAsynchronous];
}

-(void)produceData:(NSDictionary *)dic
{
    if([dic count] > 0)
    {
        NSDictionary *userDic = [dic objectForKey:@"user"];
        
        self.userImageUrl             = [userDic objectForKey:@"avatar"];
        self.userName                 = [userDic objectForKey:@"username"];
        self.userCommentRate          = [dic objectForKey:@"star"];
        self.userComment              = [dic objectForKey:@"comment"];
        self.userCommentTime          = [dic objectForKey:@"datetime"];
        self.userCommentId            = [[dic objectForKey:@"id"] intValue];
    }
}

@end

