//
//  DetailItem.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-17.
//
//

#import <Foundation/Foundation.h>

#define kDefaultBuyCount     1

typedef enum {
    ProductTypeQuankuan=0,
    ProductTypeYufukuan=1
} ProductType;

@interface LastMinuteProduct : NSObject
{
    
    NSNumber                 *_productId;
    NSNumber                 *_productCid;//（如果该套餐无品类信息，则返回cid，否则，cid返回0，根据cid字段是否为0判断“选择日期”按钮是否可点击）
    NSString                 *_productTitle;
    NSNumber                 *_productStock;
    NSNumber                 *_productBuyLimit;
    ProductType               _productType;
    NSString                 *_productPrice;//（如果该套餐无品类信息，则返回单价，否则，返回空字符串）
    BOOL                      _isSelected;
    NSInteger                 _currentBuyCount;
    
    
}

@property (retain, nonatomic) NSNumber            *productId;
@property (retain, nonatomic) NSNumber            *productCid;
@property (retain, nonatomic) NSString            *productTitle;
@property (retain, nonatomic) NSNumber            *productStock;
@property (retain, nonatomic) NSNumber            *productBuyLimit;
@property (assign, nonatomic) ProductType          productType;
@property (retain, nonatomic) NSString            *productPrice;
@property (assign, nonatomic) BOOL                 isSelected;
@property (nonatomic, assign) NSInteger            currentBuyCount;





@end
