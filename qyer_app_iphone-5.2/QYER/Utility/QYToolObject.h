//
//  QYToolObject.h
//  QYER
//
//  Created by 张伊辉 on 14-3-25.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYToolObject : NSObject
+(CGSize)getContentSize:(NSString *)content font:(UIFont *)pFont width:(CGFloat)pWidth;

+(NSString *)cookieURL;
//设置cookie
+ (void)setCookie;

/**
 *  调用相机
 *
 *  @param delegate 当前页面控制器
 *  @param sysType  type = 0 是相册，1是相机
 *  @param flag     是否允许编辑照片
 */
+(void)transferSystemPicture:(id)delegate type:(int)sysType isPermitEdit:(BOOL)flag;

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/**
 *  计算经纬度之间的距离
 *
 *  @param lon1 lon1 description
 *  @param lat1 lat1 description
 *  @param lon2 lon2 description
 *  @param lat2 lat2 description
 *
 *  @return return value description
 */
+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2;
+(UINavigationController *)getControllerWithBaseController:(UIViewController *)viewController;
@end
