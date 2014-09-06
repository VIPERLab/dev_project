//
//  PoiInstructionViewController.h
//  QyGuide
//
//  Created by an qing on 13-3-5.
//
//

#import <UIKit/UIKit.h>

@interface PoiInstructionViewController : UIViewController <UIWebViewDelegate>
{
    UIImageView          *_headView;
    UILabel              *_chineseTitleLabel;
    UILabel              *_englishTitleLabel;
    UIButton             *_backButton;
    NSString             *_chineseTitle;
    NSString             *_englishTitle;
    
    UIScrollView         *_scrollView;
    
    NSString             *_instruction;
    UILabel              *_titleLabel;
    UIWebView            *_instructionWebView;
}

@property(nonatomic,retain) NSString *navigationTitle;
@property(nonatomic,retain) NSString *instruction;
@property(nonatomic,retain) UIImage  *typeImage;
@property(nonatomic,retain) NSString *chineseTitle;
@property(nonatomic,retain) NSString *englishTitle;

-(void)setTitleView;

@end

