//
//  QYOperationPage.m
//  QyGuide
//
//  Created by an qing on 12-12-27.
//
//


#import "GetOperationPage.h"
#import "ASIHTTPRequest.h"
//#import "NSString+SBJSON.h"
#import "SBJsonParser.h"


#define getdatamaxtime 10 //获取运营页面的请求超时时间



@implementation GetOperationPage
@synthesize open_type = _open_type;
@synthesize title = _title;
@synthesize content = _content;
@synthesize html = _html;
@synthesize picUrl = _picUrl;
@synthesize specialJinnangListIdArray = _specialJinnangListIdArray;

@synthesize dataArray = _dataArray;


-(void)dealloc
{
    _dataArray = nil;
    
    _title = nil;
    _content = nil;
    _html = nil;
    _picUrl = nil;
    _specialJinnangListIdArray = nil;
    
    [super dealloc];
}

-(void)getOperationPageInfoByClientid:(NSString *)client_id
                     andClientSecrect:(NSString *)client_secrect
                             finished:(finishedBlock)finished
                               failed:(failedBlock)failed
{
    //NSLog(@"获取数据 ~~~~~~~~");
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/operation/get_top?client_id=%@&client_secret=%@&count=4",DomainName,client_id,client_secrect]]];
    request.timeOutSeconds = getdatamaxtime;
    //MYLog(@"url ==11== %@",[request.url absoluteString]);
    
    [request setCompletionBlock:^{
        
        NSString *result = [request responseString];
        
        //if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        SBJsonParser *json = [[SBJsonParser alloc] init];
        NSDictionary *dic = [json objectWithString:result];
        [json release];
        
        if([[dic objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            //MYLog(@"获取数据成功");
            NSMutableArray *array = [dic objectForKey:@"data"];
            NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
            [myDefault setObject:array forKey:@"operationpage"];
            [myDefault synchronize];
            [self produceData:array finished:finished failed:failed];
        }
        else
        {
            if([request.error.localizedDescription rangeOfString:@"timed out"].location != NSNotFound)
            {
               // MYLog(@"请求超时 ~~~");
            }
            else
            {
               // MYLog(@"获取数据失败");
            }
            NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
            NSArray *array = [myDefault objectForKey:@"operationpage"];
            
            [self produceData:array finished:finished failed:failed];
        }
        
    }];
    
    [request setFailedBlock:^{
        //NSLog(@"获取数据失败");
        NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
        NSArray *array = [myDefault objectForKey:@"operationpage"];
        
        [self produceData:array finished:finished failed:failed];
        
    }];
    [request startAsynchronous];
}

-(void)produceData:(NSArray*)array
          finished:(finishedBlock)finished
            failed:(failedBlock)failed
{
    if(array)
    {
        for(int i = 0; i < [array count]; i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            GetOperationPage *operation = [[GetOperationPage alloc] init];
            operation.open_type = [[dic objectForKey:@"open_type"] intValue];
            operation.title = [dic objectForKey:@"title"];
            operation.content = [dic objectForKey:@"content"];
            operation.specialJinnangListIdArray = [[dic objectForKey:@"ids"] componentsSeparatedByString:@","];
            operation.html = [dic objectForKey:@"url"];
            operation.picUrl = [dic objectForKey:@"pic"];
            
            if(!_dataArray)
            {
                _dataArray = [[NSMutableArray alloc] init];
            }
            [_dataArray addObject:operation];
            [operation release];
        }
        finished();
    }
    else
    {
        failed();
    }
}

@end

