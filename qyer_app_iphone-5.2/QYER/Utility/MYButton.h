//
//  MYButton.h
//  NewPackingList
//
//  Created by an qing on 12-9-25.
//
//

#import <UIKit/UIKit.h>

@interface MYButton : UIButton
{
    NSString *shareType;  //分享的类型
}
@property(nonatomic,retain) NSString *shareType;

@end
