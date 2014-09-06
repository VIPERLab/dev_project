//
//  ControlWithColorWhenTap.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-16.
//
//

#import <UIKit/UIKit.h>

@interface ControlWithColorWhenTap : UIControl
{
    UIColor     *_backGroundColor;
}
-(id)initWithFrame:(CGRect)frame andColorWhenTap:(UIColor *)color;

@end
