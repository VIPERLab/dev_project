//
//  GetRecommendedGuideByEditer.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-6-6.
//
//

#import "GetRecommendedGuideByEditer.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"


#define getdatamaxtime 10    //获取穷编辑推荐锦囊的请求超时时间



@implementation GetRecommendedGuideByEditer


+(void)getRecommendedGuidebyPoiByClientid:(NSString *)client_id
                         andClientSecrect:(NSString *)client_secrect
                            andDeviceType:(NSString *)type
                                 finished:(getRecommendedGuideByEditerFinishedBlock)finished
                                   failed:(getRecommendedGuideByEditerFailedBlock)failed
{
    MYLog(@" 开始获取穷编辑推荐锦囊 ");
    
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/guide/get_id_list?client_id=%@&client_secret=%@&type=%@",DomainName,client_id,client_secrect,type]]];
    request.timeOutSeconds = getdatamaxtime;
    
    MYLog(@"url ==GetRecommendedGuideByEditer == %@",[request.url absoluteString]);
    
    [request setCompletionBlock:^{
        
        NSString *result = [request responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            MYLog(@"GetRecommendedGuideByEditer数据成功");
            
            if([[result JSONValue] valueForKey:@"data"] && ![[[result JSONValue] valueForKey:@"data"] isKindOfClass:[NSNull class]] && [[[result JSONValue] valueForKey:@"data"] isKindOfClass:[NSArray class]] && [[[result JSONValue] valueForKey:@"data"] count] > 0)
            {
                NSArray *array = [[result JSONValue] valueForKey:@"data"];
                if(array && [array isKindOfClass:[NSArray class]] && array.count > 0)
                {
                    finished(array);
                }
            }
            else
            {
                MYLog(@"GetRecommendedGuideByEditer没有数据");
                NSArray *array = [[result JSONValue] valueForKey:@"data"];
                finished(array);
            }
        }
        else
        {
            if([request.error.localizedDescription rangeOfString:@"timed out"].location != NSNotFound)
            {
                MYLog(@"GetRecommendedGuideByEditer数据超时 ~~~");
                failed();
            }
            else
            {
                MYLog(@"GetRecommendedGuideByEditer数据失败");
                failed();
            }
        }
    }];
    
    [request setFailedBlock:^{
        MYLog(@"GetRecommendedGuideByEditer失败");
        failed();
    }];
    
    [request startAsynchronous];
}

@end
