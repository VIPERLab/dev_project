//
//  MyMoreControl.h
//  iPhoneJinNang
//
//  Created by 安庆 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMoreControl : UIControl
{
    UIView      *frontView;
    NSString    *url;
    NSString    *appName;
}
@property(nonatomic,retain) NSString *url;
@property(nonatomic,retain) NSString *appName;
@end


