//
//  AboutViewController.h
//  QyGuide
//
//  Created by lide on 12-11-3.
//
//

#import <UIKit/UIKit.h>
#import "WebViewViewController.h"
@interface AboutViewController : UIViewController <UIWebViewDelegate>
{
    UIImageView     *_headView;
    
    UIButton        *_backButton;
    
    UIImageView     *_briefImageView;
    UIButton        *_siteButton;
    UIImageView     *_logoImageView;
    UIImageView     *_versionImageView;
    
    UILabel         *_titleLabel;
    WebViewViewController* webVC;
    BOOL openUrlInAppFlag;
    
    BOOL updateFlag;
    NSString *appNewInfo;
    NSString *path;
}

@end
