//
//  BookView.h
//  LastMinute
//
//  Created by lide on 13-5-28.
//
//

#import <UIKit/UIKit.h>

@protocol BookViewDelegate;

@interface BookView : UIView
{
    UIImageView     *_backgroundImageView;
    UIImageView     *_iconImageView;
    UILabel         *_titleLabel;
    UIButton        *_cancelButton;
    
    NSArray         *_orderArray;
    NSArray         *_orderTitleArray;
    
    id<BookViewDelegate>    _delegate;
}

@property (retain, nonatomic) NSArray *orderArray;
@property (retain, nonatomic) NSArray *orderTitleArray;

@property (assign, nonatomic) id<BookViewDelegate> delegate;

- (id)initWithOrderArray:(NSArray *)orderArray
              titleArray:(NSArray *)titleArray
               orderType:(NSUInteger)orderType;

- (id)initWithOrderArray:(NSArray *)orderArray
              titleArray:(NSArray *)titleArray
             dicountCode:(NSString *)discountCode
               orderType:(NSUInteger)orderType;

- (void)show;

@end

@protocol BookViewDelegate <NSObject>

- (void)bookViewButtonDidClicked:(id)sender;

@end
