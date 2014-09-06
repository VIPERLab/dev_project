//
//  CalloutButton.h
//  QyGuide
//
//  Created by an qing on 13-4-8.
//
//

#import <UIKit/UIKit.h>

@interface CalloutButton : UIButton
{
    NSInteger _colorFlag;
    UIView    *frontView;
}
@property(nonatomic,assign) NSInteger colorFlag;

@end
