//
//  MyControl.h
//  iPhoneJinNang
//
//  Created by 安庆 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyControl : UIControl
{
    UIColor     *_backGroundColor;
}
@property(nonatomic,retain) NSDictionary *info;
-(id)initWithFrame:(CGRect)frame andBackGroundColor:(UIColor *)color;
@end

