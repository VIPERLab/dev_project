//
//  LastMinute.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-15.
//
//

#import <Foundation/Foundation.h>

typedef void(^QYLastMinuteSuccessBlock) (NSArray *data);
typedef void(^QYLastMinuteFailureBlock) (void);

@interface LastMinute : NSObject
{
    NSString    *_str_id;           //id
    NSString    *_str_pic;          //折扣封图
    NSString    *_str_title;        //折扣title
    NSString    *_str_price;        //折扣价格
    NSString    *_str_end_date;     //折扣到期时间
    NSString    *_str_web_url;      //web方面链接
    NSString    *_str_m_url;        //m方面链接
    NSString    *_str_productType;  //分类
    NSString    *_str_detail;       //折扣详情
    
    NSNumber    *_qyerOnlyFlag;
    NSNumber    *_qyerFirstFlag;
    NSString    *_lastMinutePicture800;   //add by zyh
}

@property(nonatomic,retain) NSString    *str_id;           //id
@property(nonatomic,retain) NSString    *str_pic;          //折扣封图
@property(nonatomic,retain) NSString    *str_title;        //折扣title
@property(nonatomic,retain) NSString    *str_price;        //折扣价格
@property(nonatomic,retain) NSString    *str_end_date;     //折扣到期时间
@property(nonatomic,retain) NSString    *str_web_url;      //web方面链接
@property(nonatomic,retain) NSString    *str_m_url;        //m方面链接
@property(nonatomic,retain) NSString    *str_productType;  //分类
@property(nonatomic,retain) NSString    *str_detail;       //折扣详情

@property (retain, nonatomic) NSNumber *qyerOnlyFlag;
@property (retain, nonatomic) NSNumber *qyerFirstFlag;
@property (retain, nonatomic) NSString *lastMinutePicture800;

+ (void)getLastMinuteFavorListWithMaxId:(NSUInteger)maxId
                               pageSize:(NSUInteger)pageSize
                                success:(QYLastMinuteSuccessBlock)successBlock
                                failure:(QYLastMinuteFailureBlock)failureBlock;

@end
