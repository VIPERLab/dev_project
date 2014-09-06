//
//  LastMinuteData.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-15.
//
//

#import "LastMinuteData.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "LastMinute.h"
#import "QYAPIClient.h"


#define getdatamaxtime  10    //获取用户的行程列表的请求超时时间


@implementation LastMinuteData


//由锦囊id获取折扣信息:
+(void)getLastMinuteInfoWithGuideId:(NSString *)guide_id
                            success:(LastMinuteDataSuccessBlock)finished
                             failed:(LastMinuteDataFailedBlock)failed
{
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/lastminute/get_list_byjnid?client_id=%@&client_secret=%@&jn_id=%@",DomainName,ClientId_QY,ClientSecret_QY,guide_id]]];
    request.timeOutSeconds = getdatamaxtime;
    MYLog(@"url == lastminute == %@",[request.url absoluteString]);
    
    
    [request setCompletionBlock:^{
        
        NSString *result = [request responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            MYLog(@"获取lastminute 成功");
            NSArray *array = [[result JSONValue] valueForKey:@"data"];
            
            NSMutableArray *array_lastminute = [[NSMutableArray alloc] init];
            if(array && [array count] > 0)
            {
                NSArray *array_ = [[self processData:array] retain];
                
                [array_lastminute removeAllObjects];
                [array_lastminute addObjectsFromArray:array_];
                
                finished(array_lastminute);
                [array_ release];
            }
            else
            {
                MYLog(@"获取lastminute 暂无数据 ~~~ ");
                finished(array_lastminute);
            }
            
            [array_lastminute removeAllObjects];
            [array_lastminute release];
        }
        else
        {
            if([result rangeOfString:@"timed out"].location != NSNotFound)
            {
                MYLog(@"请求lastminute 超时 ~~~");
                failed();
            }
            else
            {
                MYLog(@"获取lastminute 失败");
                failed();
            }
        }
    }];
    
    [request setFailedBlock:^{
        MYLog(@"获取lastminute 失败");
        
        failed();
    }];
    [request startAsynchronous];
    
}


//获取折扣列表
+ (void)getLastMinuteListWithType:(NSUInteger)type
                            maxId:(NSUInteger)maxId
                         pageSize:(NSUInteger)pageSize
                            times:(NSString *)times
                      continentId:(NSUInteger)continentId
                        countryId:(NSUInteger)countryId
                        departure:(NSString *)departure
                          success:(LastMinuteDataSuccessBlock)successBlock
                          failure:(LastMinuteDataFailedBlock)failureBlock{
    
    
    [[QYAPIClient sharedAPIClient] getLastMinuteListWithType:type maxId:maxId pageSize:pageSize times:times continentId:continentId countryId:countryId departure:departure success:^(NSDictionary *dic) {
        
        
        if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
        {
            NSLog(@"成功  is %@",dic);
            NSArray *array = [dic objectForKey:@"data"];
            NSArray *array_out = [[self processData:array] retain];
            successBlock(array_out);
            [array_out release];
        }
        
    } failure:^{
        
        failureBlock();
    }];
    
}

+(NSArray *)processData:(NSArray *)array
{
    NSMutableArray *array_ = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        LastMinute *last_minute = [[LastMinute alloc] init];
        
        last_minute.str_web_url = [NSString stringWithFormat:@"%@",[dic objectForKey:@"web_url"]];
        last_minute.str_title = [NSString stringWithFormat:@"%@",[dic objectForKey:@"title"]];
        last_minute.str_price = [NSString stringWithFormat:@"%@",[dic objectForKey:@"price"]];
        last_minute.str_pic = [NSString stringWithFormat:@"%@",[dic objectForKey:@"pic"]];
        last_minute.str_m_url = [NSString stringWithFormat:@"%@",[dic objectForKey:@"m_url"]];
        last_minute.str_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        last_minute.str_end_date = [NSString stringWithFormat:@"%@",[dic objectForKey:@"end_date"]];
        last_minute.str_productType = [NSString stringWithFormat:@"%@",[dic objectForKey:@"product_type"]];
        
        
        
        last_minute.qyerOnlyFlag = [NSNumber numberWithInt:[[dic objectForKey:@"self_use"] intValue]];
        last_minute.qyerFirstFlag = [NSNumber numberWithInt:[[dic objectForKey:@"first_pub"] intValue]];
        last_minute.lastMinutePicture800 = [NSString stringWithFormat:@"%@",[dic objectForKey:@"op_pic1"]];
        
        [array_ addObject:last_minute];
        [last_minute release];
    }
    
    return [array_ autorelease];
}

@end

