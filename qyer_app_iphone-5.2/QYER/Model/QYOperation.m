//
//  QYOperation.m
//  JinNangFrameApp
//
//  Created by lide on 12-12-28.
//
//

#import "QYOperation.h"
#import "QYAPIClient.h"

@implementation QYOperation

@synthesize openType = _openType;
@synthesize operationTitle = _operationTitle;
@synthesize operationContent = _operationContent;
@synthesize operationIds = _operationIds;
@synthesize operationUrl = _operationUrl;
@synthesize operationPic = _operationPic;
@synthesize operationBigPic = _operationBigPic;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:_openType forKey:@"openType"];
    [aCoder encodeObject:_operationTitle forKey:@"operationTitle"];
    [aCoder encodeObject:_operationContent forKey:@"operationContent"];
    [aCoder encodeObject:_operationIds forKey:@"operationIds"];
    [aCoder encodeObject:_operationUrl forKey:@"operationUrl"];
    [aCoder encodeObject:_operationPic forKey:@"operationPic"];
    [aCoder encodeObject:_operationBigPic forKey:@"operationBigPic"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self != nil)
    {
        
        self.openType = [aDecoder decodeObjectForKey:@"openType"];
        self.operationTitle = [aDecoder decodeObjectForKey:@"operationTitle"];
        self.operationContent = [aDecoder decodeObjectForKey:@"operationContent"];
        self.operationIds = [aDecoder decodeObjectForKey:@"operationIds"];
        self.operationUrl = [aDecoder decodeObjectForKey: @"operationUrl"];
        self.operationPic = [aDecoder decodeObjectForKey:@"operationPic"];
        self.operationBigPic = [aDecoder decodeObjectForKey:@"operationBigPic"];
        
    }
    return self;
}

- (id)copyWithZone: (NSZone*)zone{
    
    QYOperation *gdc = [[[self class] allocWithZone:zone] init];
    
    gdc.openType = _openType;
    gdc.operationTitle = _operationTitle;
    gdc.operationContent = _operationContent;
    gdc.operationIds = _operationIds;
    gdc.operationUrl = _operationUrl;
    gdc.operationPic = _operationPic;
    gdc.operationBigPic = _operationBigPic;
    
    
    return gdc;
}

- (void)dealloc
{
    QY_SAFE_RELEASE(_openType);
    QY_SAFE_RELEASE(_operationTitle);
    QY_SAFE_RELEASE(_operationContent);
    QY_SAFE_RELEASE(_operationIds);
    QY_SAFE_RELEASE(_operationUrl);
    QY_SAFE_RELEASE(_operationPic);
    QY_SAFE_RELEASE(_operationBigPic);
    
    [super dealloc];
}

- (id)initWithAttribute:(NSDictionary *)attribute{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
           
            
            self.openType = [NSNumber numberWithInt:[[attribute objectForKey:@"open_type"] intValue]];
            self.operationTitle = [attribute objectForKey:@"title"];
            self.operationContent = [attribute objectForKey:@"content"];
            
            NSString * ids = [attribute objectForKey:@"ids"];
            NSLog(@"ids is %@",ids);
            if (ids)
            {
                self.operationIds = [NSArray arrayWithArray:[ids componentsSeparatedByString:@"," ]];
            }
            
            self.operationUrl = [attribute objectForKey:@"url"];
            /**
             *  之前用pic字段，现改成photo  add zyh
             */
            self.operationPic = [attribute objectForKey:@"photo"];
            self.operationBigPic = [attribute objectForKey:@"big_pic"];
        }
    }
    return self;
    
}


+ (NSArray *)parseFromeData:(NSDictionary *)dict;
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *dict in mutableArray) {
        
        QYOperation *guideCategory = [[[QYOperation alloc] initWithAttribute:dict] autorelease];
        [mutableArray addObject:guideCategory];
    }
    
    return mutableArray;
}

+ (void)getOperationWithCount:(NSUInteger)count
                      success:(LastMinuteOperationSuccessBlock)successBlock
                      failure:(LastMinuteOperationFailureBlock)failureBlock
{
       
    [[QYAPIClient sharedAPIClient] getOperationWithCount:count success:^(NSDictionary *dic) {
        
        if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
        {
            NSLog(@" getCityPoiDataByCityId 成功 ");
            NSArray *array = [dic objectForKey:@"data"];
            NSLog(@"折扣 is %@",array);
            NSArray *array_out = [[self parseFromeData:array] retain];
            successBlock(array_out);
            [array_out release];
        }
        
    } failure:^{
        
        failureBlock();
       
    }];
    
}

@end
