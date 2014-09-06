//
//  DetailItem.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-17.
//
//

#import "LastMinuteProduct.H"

@implementation LastMinuteProduct

@synthesize productId = _productId;
@synthesize productCid = _productCid;
@synthesize productTitle = _productTitle;
@synthesize productStock = _productStock;
@synthesize productBuyLimit = _productBuyLimit;
@synthesize productType = _productType;
@synthesize productPrice = _productPrice;
@synthesize isSelected = _isSelected;
@synthesize currentBuyCount = _currentBuyCount;

- (void)dealloc
{
    QY_SAFE_RELEASE(_productId);
    QY_SAFE_RELEASE(_productCid);
    QY_SAFE_RELEASE(_productTitle);
    QY_SAFE_RELEASE(_productStock);
    QY_SAFE_RELEASE(_productBuyLimit);
    QY_SAFE_RELEASE(_productPrice);
    
    [super dealloc];
}

@end
