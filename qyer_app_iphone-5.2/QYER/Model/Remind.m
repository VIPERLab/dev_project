//
//  Remind.m
//  LastMinute
//
//  Created by lide on 13-9-26.
//
//

#import "Remind.h"
#import "QYAPIClient.h"

@implementation Remind

@synthesize remindId = _remindId;
@synthesize remindType = _remindType;
@synthesize remindDate = _remindDate;
@synthesize remindStartPositon = _remindStartPositon;
@synthesize remindCountry = _remindCountry;

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            self.remindId = [NSNumber numberWithInt:[[attribute objectForKey:@"id"] intValue]];
            self.remindType = ([attribute objectForKey:@"product_type"]&&[attribute objectForKey:@"product_type"]!=[NSNull null])?[attribute objectForKey:@"product_type"]:@"全部";
            self.remindDate = ([attribute objectForKey:@"date_str"]&&[attribute objectForKey:@"date_str"]!=[NSNull null])?[attribute objectForKey:@"date_str"]:@"全部";
            self.remindStartPositon = ([attribute objectForKey:@"start_pos"]&&[attribute objectForKey:@"start_pos"]!=[NSNull null])?[attribute objectForKey:@"start_pos"]:@"全部";
            self.remindCountry = ([attribute objectForKey:@"country"]&&[attribute objectForKey:@"country"]!=[NSNull null])?[attribute objectForKey:@"country"]:@"全部";
        }
    }
    
    return self;
}

- (void)dealloc
{
    QY_SAFE_RELEASE(_remindId);
    QY_SAFE_RELEASE(_remindType);
    QY_SAFE_RELEASE(_remindDate);
    QY_SAFE_RELEASE(_remindStartPositon);
    QY_SAFE_RELEASE(_remindCountry);
    
    [super dealloc];
}

+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
//    NSDictionary *dictionary = (NSDictionary *)[[QYAPIClient sharedAPIClient] responseJSON:data];
    
    if([aDictionary objectForKey:@"data"])
    {
        aDictionary = [aDictionary objectForKey:@"data"];
    }
    
    if([aDictionary isKindOfClass:[NSArray class]])
    {
        for(NSDictionary *attribute in (NSArray *)aDictionary)
        {
            Remind *remind = [[Remind alloc] initWithAttribute:attribute];
            [mutableArray addObject:remind];
            [remind release];
        }
    }
    else if([aDictionary isKindOfClass:[NSDictionary class]])
    {
        if([aDictionary objectForKey:@"LastMinutes"])
        {
            id suppliers = [aDictionary objectForKey:@"LastMinutes"];
            if([suppliers isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *attribute in (NSArray *)suppliers)
                {
                    Remind *remind = [[Remind alloc] initWithAttribute:attribute];
                    [mutableArray addObject:remind];
                    [remind release];
                }
            }
        }
        else
        {
            Remind *remind = [[Remind alloc] initWithAttribute:aDictionary];
            [mutableArray addObject:remind];
            [remind release];
        }
    }
    
    return mutableArray;
}

+ (void)getRemindListWithMaxId:(NSUInteger)maxId
                      pageSize:(NSUInteger)pageSize
                       success:(QYRemindSuccessBlock)successBlock
                       failure:(QYRemindFailureBlock)failureBlock
{
//    [[QYAPIClient sharedAPIClient] getRemindListWithMaxId:maxId
//                                                 pageSize:pageSize
//                                                  success:^(NSData *data) {
//                                                      if(successBlock)
//                                                      {
//                                                          successBlock([self parseFromeData:data]);
//                                                      }
//                                                  } failure:^(NSError *error) {
//                                                      if(failureBlock)
//                                                      {
//                                                          failureBlock(error);
//                                                      }
//                                                  }];
    
    [[QYAPIClient sharedAPIClient] getRemindListWithMaxId:maxId
                                                 pageSize:pageSize
                                                  success:^(NSDictionary *dic) {
                                                      if(successBlock)
                                                      {
                                                          successBlock([self parseFromeDictionary:dic]);
                                                      }

                                                  } failure:^{
                                                      if (failureBlock) {
                                                          failureBlock();
                                                      }
                                                      
                                                  }];
}

- (CGFloat)cellHeight
{
    NSUInteger count = 0;
    
//    NSLog(@"_remindId:%d", [_remindId integerValue]);
//    NSLog(@"_remindType:'%@'", _remindType);
//    NSLog(@"_remindDate:'%@'", _remindDate);
//    NSLog(@"_remindCountry:'%@'", _remindCountry);
    
    if(_remindType && [_remindType length]>0)
    {
        count++;
    }
    if(_remindDate && [_remindDate length]>0)
    {
        count++;
    }
    if(_remindStartPositon && [_remindStartPositon length]>0)
    {
        count++;
    }
    if(_remindCountry && [_remindCountry length]>0)
    {
        count++;
    }
    
//    switch (count)
//    {
//        case 1:
//        {
//            return 78.0f-9;
//        }
//            break;
//        case 2:
//        {
//            return 102.0f-9;
//        }
//            break;
//        case 3:
//        {
//            return 126.0f-9;
//        }
//            break;
//        case 4:
//        {
//            return 150.0f-9;
//        }
//            break;
//        default:
//        {
//            return 44.0f;
//        }
//            break;
//    }

    return 150.0f-9;

}

@end
