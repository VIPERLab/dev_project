//
//  RPSViewController.h
//  Reese'sParallaxScrollView
//
//  Created by Reese on 13-6-14.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3ParallaxScrollView.h"
#import "cloudViewController.h"
@interface RPSViewController : UIViewController <UIScrollViewDelegate>
{
    A3ParallaxScrollView *parallaxScrollView;
    UIImageView* bg_imgview;
    
    cloudViewController* cloud;
}


@end
