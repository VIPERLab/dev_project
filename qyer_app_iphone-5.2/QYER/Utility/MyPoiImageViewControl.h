//
//  MyPoiImageViewControl.h
//  QyGuide
//
//  Created by an qing on 13-2-19.
//
//

#import <UIKit/UIKit.h>

@interface MyPoiImageViewControl : UIControl
{
    NSString *_position;
    
    BOOL     _hasBackGroundColorflag;
}

@property(nonatomic,retain) NSString *position;
@property(nonatomic,assign) BOOL     hasBackGroundColorflag;

@end

