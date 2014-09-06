//
//  CustomProessView.h
//  QyGuide
//
//  Created by Qyer on 13-1-8.
//
//

#import <UIKit/UIKit.h>

@interface CustomProessView : UIProgressView
{
    UIColor *_tintColor;
    UIColor *_backgroundColor;
}

/**
 Set the desired tintColor for this control with image
 **/
-(void)setTintColorWithImage:(UIImage *)image;

/**
 Set the desired BackGroundColor for this control
 **/
-(void)setBackGroundTintColor:(UIColor *)color;

/**
 Set the desired BackGroundColor for this control with image
 **/
-(void)setBackGroundTintColorWithImage:(UIImage *)image;

@end
