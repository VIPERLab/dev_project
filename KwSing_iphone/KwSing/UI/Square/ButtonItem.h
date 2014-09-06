//
//  ButtonItem.h
//  KwSing
//
//  Created by 熊 改 on 12-11-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>


enum BUTTON_TYPE
{
    HOTSONG_BUTTON,
    KSONG_BUTTON,
    NEWSONG_BUTTON,
    OTHER_BUTTON,       //其它的一些button，热门作品里的一些活动或者广告之类，只执行load图片和跳转网页
    APPSTORE_BUTTON     //jump to app store
};

@interface ButtonItem : UIButton
{
    NSString* _imageUrl;
    NSString* _songId;
    
    NSString* _upString;
    NSString* _downString;
    
    BUTTON_TYPE _type;
    
    UILabel *upLabel;
    UILabel *downLabel;
    
    bool _isFistShow;
}
@property (retain,nonatomic) NSString* upString;
@property (retain,nonatomic) NSString* donwString;
@property (retain,nonatomic) NSString* songId;
@property (retain,nonatomic) NSString* url;
@property (nonatomic) BUTTON_TYPE type;

-(void)initDefaulfImage:(bool)isSmall;
-(void)loadImage:(NSString*)imageUrl;

-(void)setType:(BUTTON_TYPE)type;
@end
