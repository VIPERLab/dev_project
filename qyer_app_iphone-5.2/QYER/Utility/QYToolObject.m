//
//  QYToolObject.m
//  QYER
//
//  Created by 张伊辉 on 14-3-25.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QYToolObject.h"
#import "QyYhConst.h"

@implementation QYToolObject

+(CGSize)getContentSize:(NSString *)content font:(UIFont *)pFont width:(CGFloat)pWidth{
    
    CGSize contentSize;
    if (IS_IOS7) {
        contentSize = [content boundingRectWithSize:CGSizeMake(pWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:pFont,NSFontAttributeName, nil] context:nil].size;
    }else{
        
        contentSize = [content sizeWithFont:pFont constrainedToSize:CGSizeMake(pWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    }
    return contentSize;
}


+(NSString *)cookieURL{
    
    NSString *user_oauth_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];

    NSString *cookurl = [NSString stringWithFormat:@"%@/user/setuserlogincookie?oauth_token=%@&client_secret=%@&client_id=%@",DomainName,user_oauth_token,ClientSecret_QY,ClientId_QY];
    return cookurl;
    
}
//设置cookie
+ (void)setCookie{
    
    /*
     2014-04-11 14:47:02.027 QYER[10477:60b] ===<NSHTTPCookie version:0 name:"setuserlogincookie" value:"oauth_token=e3b405fcd209bf6c970f033c02734ded&client_secret=cd254439208ab658ddf9&client_id=qyer_ios" expiresDate:2014-05-10 20:32:12 +0000 created:2014-04-10 10:03:09 +0000 (4.18817e+08) sessionOnly:FALSE domain:"http://open.qyer.com/user" path:"/" isSecure:FALSE>

     */
    
    
    NSString *user_oauth_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    
    NSMutableDictionary *cookiePropertiesUser = [NSMutableDictionary dictionary];
    
    NSString *strValue = [NSString stringWithFormat:@"oauth_token=%@&client_secret=%@&client_id=%@",user_oauth_token,ClientSecret_QY,ClientId_QY];
    [cookiePropertiesUser setObject:@"http://open.qyer.com/user" forKey:NSHTTPCookieDomain];
    [cookiePropertiesUser setObject:@"setuserlogincookie" forKey:NSHTTPCookieName];
    [cookiePropertiesUser setObject:strValue forKey:NSHTTPCookieValue];
    [cookiePropertiesUser setObject:@"/" forKey:NSHTTPCookiePath];
    [cookiePropertiesUser setObject:@"0" forKey:NSHTTPCookieVersion];
    [cookiePropertiesUser setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookieuser = [NSHTTPCookie cookieWithProperties:cookiePropertiesUser];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookieuser];
}
//清除cookie
+ (void)deleteCookie{
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSLog(@"------cookieJar:%@", cookieJar);
    
    NSArray *cookieAry = [cookieJar cookies];//cookiesForURL: [NSURL URLWithString:_loadingURL]];
    
    NSLog(@"------cookieAry:%@", cookieAry);
    
    for (cookie in cookieAry) {
        [cookieJar deleteCookie: cookie];
        
    }
}
+(void)transferSystemPicture:(id)delegate type:(int)sysType isPermitEdit:(BOOL)flag{
    
    
    if (sysType == 0) {//系统相册
        
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            
            
            [imagePicker setVideoQuality:UIImagePickerControllerQualityTypeMedium];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = delegate;
            imagePicker.allowsEditing = flag;
            //[delegate presentModalViewController:imagePicker animated:YES];
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:imagePicker animated:YES completion:nil];
        }
        [imagePicker release];
    }else if (sysType == 1){ //照相机
        
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            
            [imagePicker setVideoQuality:UIImagePickerControllerQualityTypeMedium];
            imagePicker.allowsEditing = flag;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = delegate;
            //[delegate presentModalViewController:imagePicker animated:YES];
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:imagePicker animated:YES completion:nil];
            
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的设备不支持拍照!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        [imagePicker release];
    }
    
    
}
//缩放拍照后的图片，太大
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize, image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}



+(UINavigationController *)getControllerWithBaseController:(UIViewController *)viewController{
    
    UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:viewController] autorelease];
    nav.navigationBarHidden = YES;
    return nav;
}


#pragma mark -
#pragma mark --- calculate distance  根据2个经纬度计算距离

#define PI 3.1415926

+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2{
    double er = 6378137; // 6378700.0f;
	//ave. radius = 6371.315 (someone said more accurate is 6366.707)
	//equatorial radius = 6378.388
	//nautical mile = 1.15078
	double radlat1 = PI*lat1/180.0f;
	double radlat2 = PI*lat2/180.0f;
	//now long.
	double radlong1 = PI*lon1/180.0f;
	double radlong2 = PI*lon2/180.0f;
	if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
	if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
	if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
	if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
	if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
	if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
	//spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
	//zero ag is up so reverse lat
	double x1 = er * cos(radlong1) * sin(radlat1);
	double y1 = er * sin(radlong1) * sin(radlat1);
	double z1 = er * cos(radlat1);
	double x2 = er * cos(radlong2) * sin(radlat2);
	double y2 = er * sin(radlong2) * sin(radlat2);
	double z2 = er * cos(radlat2);
	double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
	//side, side, side, law of cosines and arccos
	double theta = acos((er*er+er*er-d*d)/(2*er*er));
	double dist  = theta*er;
	return dist;
}

@end
