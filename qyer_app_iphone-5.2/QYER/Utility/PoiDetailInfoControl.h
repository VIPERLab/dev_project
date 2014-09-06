//
//  PoiDetailInfoControl.h
//  QyGuide
//
//  Created by an qing on 13-2-26.
//
//

#import <UIKit/UIKit.h>

@interface PoiDetailInfoControl : UIControl
{
    NSString    *_type;
    NSInteger   _bgColorType;
    
    NSString    *_bookingUrlStr;
}

@property(nonatomic,retain) NSString *type;
@property(nonatomic,assign) NSInteger bgColorType;
@property(nonatomic,assign) NSString  *bookingUrlStr;

@end

