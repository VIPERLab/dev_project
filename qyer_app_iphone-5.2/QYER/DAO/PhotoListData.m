//
//  PhotoListData.m
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PhotoListData.h"
#import "QYAPIClient.h"
#import "PhotoList.h"

@implementation PhotoListData

+(void)getPhotoListByType:(NSString *)type
              andObjectId:(NSString *)str_id
                  success:(PhotoListDataSuccessBlock)finishedBlock
                   failed:(PhotoListDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getPhotoListByType:type
                                          andObjectId:str_id
                                              success:^(NSDictionary *dic){
                                                  
                                                  if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                  {
                                                      NSLog(@" getPhotoListByType 成功 ");
                                                      NSArray *array = [dic objectForKey:@"data"];
                                                      NSArray *array_out = [[self prepareData:array] retain];
                                                      finishedBlock(array_out);
                                                      [array_out release];
                                                  }
                                                  else
                                                  {
                                                      failedBlock();
                                                  }
                                                  
                                              } failed:^{
                                                  NSLog(@" getPhotoListByType 失败! ");
                                                  failedBlock();
                                              }];
}
+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_photoList = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            PhotoList *photoList_obj = [[PhotoList alloc] init];
            photoList_obj.str_photoid= [NSString stringWithFormat:@"%@",[dic objectForKey:@"photoid"]];
            photoList_obj.str_uid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"uid"]];
            photoList_obj.str_username = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
            photoList_obj.str_photourl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photourl"]];
            photoList_obj.str_avatar = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
            photoList_obj.str_datetime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"datetime"]];
            
            [array_photoList addObject:photoList_obj];
            [photoList_obj release];
        }
    }
    
    return [array_photoList autorelease];
}


@end
