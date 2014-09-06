//
//  QYLastminuteCategory.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-19.
//
//

#import "QYSectionCategory.h"
#import "QYAPIClient.h"

@implementation QYSectionCategory

@synthesize cateYear = _cateYear;
@synthesize cateMonth = _cateMonth;
@synthesize cateDateCategoryArray = _cateDateCategoryArray;

- (id)copyWithZone:(NSZone *)zone
{
    QYSectionCategory *sectionCategory = [[[self class] allocWithZone:zone] init];
    
    sectionCategory.cateYear = _cateYear;
    sectionCategory.cateMonth = _cateMonth;
    sectionCategory.cateDateCategoryArray = _cateDateCategoryArray;
    
    return sectionCategory;
}

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            self.cateYear = [NSNumber numberWithInt:[[attribute objectForKey:@"year"] intValue]];
            self.cateMonth = [NSNumber numberWithInt:[[attribute objectForKey:@"month"] intValue]];
            
            NSArray *categoryArr = [attribute objectForKey:@"category"];
            NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
            
            for (int i=0; i<[categoryArr count]; i++) {
                NSDictionary *dic = [categoryArr objectAtIndex:i];
                
                QYDateCategory *dateCategory = [[QYDateCategory alloc] init];
                dateCategory.categoryId = [NSNumber numberWithInt:[[dic objectForKey:@"cid"] intValue]];
                dateCategory.categoryPrice = [dic objectForKey:@"price"];
                dateCategory.categoryStock = [NSNumber numberWithInt:[[dic objectForKey:@"stock"] intValue]];
                dateCategory.categoryDate = [NSNumber numberWithInt:[[dic objectForKey:@"date"] intValue]];
                dateCategory.categoryDays = [NSNumber numberWithInt:[[dic objectForKey:@"days"] intValue]];
                dateCategory.categoryMonth = self.cateMonth;
                dateCategory.categoryYear = self.cateYear;
                dateCategory.categoryBuyLimit = [NSNumber numberWithInt:[[dic objectForKey:@"buy_limit"] intValue]];
                
                [categoryArray addObject:dateCategory];
                [dateCategory release];
                
            }
            
            self.cateDateCategoryArray = categoryArray;
            [categoryArray release];
            
            
        }
    }
    
    return self;
}


-(void)dealloc
{
    QY_SAFE_RELEASE(_cateYear);
    QY_SAFE_RELEASE(_cateMonth);
    QY_SAFE_RELEASE(_cateDateCategoryArray);
    
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
            QYSectionCategory *sectionCategory = [[QYSectionCategory alloc] initWithAttribute:attribute];
            [mutableArray addObject:sectionCategory];
            [sectionCategory release];
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
                    QYSectionCategory *sectionCategory = [[QYSectionCategory alloc] initWithAttribute:attribute];
                    [mutableArray addObject:sectionCategory];
                    [sectionCategory release];
                }
            }
        }
        else
        {
            QYSectionCategory *sectionCategory = [[QYSectionCategory alloc] initWithAttribute:aDictionary];
            [mutableArray addObject:sectionCategory];
            [sectionCategory release];
        }
    }
    
    return mutableArray;
}

+ (void)getSectionCategorysWithId:(NSUInteger)productId
                          success:(QYSectionCategorySuccessBlock)successBlock
                          failure:(QYSectionCategoryFailureBlock)failureBlock
{
    
    [[QYAPIClient sharedAPIClient] getSectionCategorysWithId:productId
                                                     success:^(NSDictionary *dic) {
                                                         
                                                         if(successBlock)
                                                         {
                                                             successBlock([QYSectionCategory parseFromeDictionary:dic]);
                                                         }
                                                         
                                                     } failure:^(NSError *error) {
                                                         
                                                         if(failureBlock)
                                                         {
                                                             failureBlock(error);
                                                         }
                                                         
                                                     }];
    
    
}

//根据年、月计算天数
+ (NSInteger)daysFromMonth:(NSInteger)aMonth year:(NSInteger)aYear
{
    
    if (aMonth==1||aMonth==3||aMonth==5||aMonth==7||aMonth==8||aMonth==10||aMonth==12) {//1、3、5、7、8、10、12
        return 31;
        
    }else if(aMonth==2){//2月
        if ((aYear%4==0&&aYear%100!=0)||(aYear%400==0)) {//闰年
            return 29;
            
        }else{
            return 28;
            
        }
        
    }else{
        return 30;
        
    }
    
}

//根据年、月计算1号星期几
+ (NSInteger)dayOfWeekFromMonth:(NSInteger)aMonth year:(NSInteger)aYear
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:aYear];
    [components setMonth:aMonth];
    [components setDay:1];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:components];
    int count = [calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:date];
    
    return count-1;
    
}

//计算有多少行
+ (NSInteger)dateRowsFromDays:(NSInteger)aDays dayOfWeek:(NSInteger)aDayOfWeek
{
    NSInteger otherDay = aDayOfWeek%7;
    
    NSInteger dateRow = (aDays+otherDay)/7;
    dateRow += (aDays+otherDay)%7==0?0:1;
    
    return dateRow;
}


@end
