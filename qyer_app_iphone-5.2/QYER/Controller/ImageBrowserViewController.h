//
//  ImageBrowserViewController.h
//  QyGuide
//
//  Created by lide on 12-11-5.
//
//

#import <UIKit/UIKit.h>

@interface ImageBrowserViewController : UIViewController <UIScrollViewDelegate>
{
    UIImageView             *_headView;
    UIButton                *_closeButton;
    UIScrollView            *_scrollView;
    UIImageView             *_imageView;
    NSString                *_imagePath;
    UIImageView             *_backgroundImageView;
    UIActivityIndicatorView *activityIndicatorView;
}

@property (retain, nonatomic) NSString *imagePath;

@end
