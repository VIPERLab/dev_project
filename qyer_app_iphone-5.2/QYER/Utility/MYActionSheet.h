//
//  MYActionSheet.h
//  NewPackingList
//
//  Created by lide on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MYActionSheetDelegate;


#pragma mark -
#pragma mark --- MYActionSheet
@interface MYActionSheet : UIView
{
    UIImageView         *_backView;
    UIButton            *_cancelButton;
    
    id<MYActionSheetDelegate>  _delegate;
}
@property (assign, nonatomic) id<MYActionSheetDelegate> delegate;
- (id)initWithTitleArray:(NSArray *)titleArray
              imageArray:(NSArray *)imageArray;
- (void)show;
@end



#pragma mark -
#pragma mark --- MYActionSheetDelegate
@protocol MYActionSheetDelegate <NSObject>
@optional
- (void)cancelButtonDidClick:(MYActionSheet *)actionSheet;
//- (void)actionSheetButtonDidClickWithIndex:(NSUInteger)buttonIndex;
- (void)actionSheetButtonDidClickWithType:(NSString*)type;
@end
