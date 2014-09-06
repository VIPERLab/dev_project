//
//  FooterTabBar.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-7-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "FooterTabBar.h"
#include "ImageMgr.h"
#import "MessageManager.h"
#import "MyMessageManager.h"
#import "IMyMessageStateObserver.h"
#import "IUserStatusObserver.h"
#include "globalm.h"

@interface KSFooterTabBar()<IMyMessageStateObserver, IUserStatusObserver>
{
    NSArray* pButtons;
    UIImage* pBkg;
    UIButton *messageNum;
}
@property (nonatomic,assign) id<KSFooterTabBarDelegate> idDelegate;

- (UIButton*)addBtnWithFrame:(CGRect)frame imagename:(NSString*)strImg;
- (void)onClickBtn:(id)sender;
- (void)dealloc;
- (void)drawRect:(CGRect)rect;

@end

@implementation KSFooterTabBar
@synthesize idDelegate;

- (id)initWithSuperView:(UIView*)pSuperView
{
    CGRect superFrame=[pSuperView bounds];
    CGRect frame=CGRectMake(superFrame.origin.x, superFrame.origin.y+superFrame.size.height-FOOTER_TABBAR_HEIGHT, superFrame.size.width, FOOTER_TABBAR_HEIGHT);
    
    self=[super initWithFrame:frame];
    self.backgroundColor = UIColorFromRGBValue(0x23242a);
    [pSuperView addSubview:self];
    
//    pBkg=CImageMgr::GetImageEx("bottomBkg.png");
//    
//    UIImageView* pShadow=[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("bottomShadow.png")];
//    pShadow.frame=CGRectMake(superFrame.origin.x, superFrame.origin.y+superFrame.size.height-FOOTER_TABBAR_HEIGHT-FOOTER_TABBAR_SHADOW_HEIGHT, superFrame.size.width, FOOTER_TABBAR_SHADOW_HEIGHT);
//    [pSuperView addSubview:pShadow];
//    [pShadow release];
    
    UIButton* pButton1;
    UIButton* pButton2;
    UIButton* pSingNowBtn;
    UIButton* pButton3;
    UIButton* pButton4;
    
    int nLeft=frame.origin.x+(frame.size.width-FOOTER_TABBAR_CENTERBTN_WIDTH)/2;
    int nTop=superFrame.size.height-FOOTER_TABBAR_CENTERBTN_HEIGHT;
    pSingNowBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [pSingNowBtn setFrame:CGRectMake(nLeft, nTop - 2, 47, 46.5)];
    [pSuperView addSubview:pSingNowBtn];
    [pSingNowBtn addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    pSingNowBtn.adjustsImageWhenHighlighted=FALSE;
    [pSingNowBtn setImage:CImageMgr::GetImageEx("KgeBtn.png") forState:UIControlStateNormal];
    [pSingNowBtn setImage:CImageMgr::GetImageEx("KgeBtnClick.png") forState:UIControlStateHighlighted];
    [pSingNowBtn setImage:CImageMgr::GetImageEx("KgeBtnClick.png") forState:UIControlStateDisabled];

    CGRect rcBtn=CGRectMake(12, frame.size.height-44, 40, 40.5);
    pButton1=[self addBtnWithFrame:rcBtn imagename:@"KgeGroundBtn"];
    rcBtn.origin.x=71;
    rcBtn.size.width=40;
    pButton2=[self addBtnWithFrame:rcBtn imagename:@"KgeDynamicBtn"];
    rcBtn.origin.x=210;
    pButton3=[self addBtnWithFrame:rcBtn imagename:@"KgeMineBtn"];
    rcBtn.origin.x=269;
    rcBtn.size.width=40;
    pButton4=[self addBtnWithFrame:rcBtn imagename:@"KgeSettingBtn"];
    pButtons=[[NSArray alloc] initWithObjects:pButton1,pButton2,pSingNowBtn,pButton3,pButton4,nil];
    
    [self initMessageNum];
    
    [self onClickBtn:pButton1];
    
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MY_MESSAGE,IMyMessageStateObserver);
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS, IUserStatusObserver);
    return self;
}

- (void)initMessageNum
{
    int nums=CMyMessageManager::GetInstance()->NumOfNewMessages();
    messageNum=[[[UIButton alloc] init] autorelease];
    [messageNum setFrame:CGRectMake(235, 0, 30, 30)];
    [messageNum setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [messageNum setBackgroundImage:CImageMgr::GetImageEx("messageNum_29.png") forState:UIControlStateNormal];
    messageNum.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:15];
    [messageNum.titleLabel setTextColor:[UIColor whiteColor]];
    [messageNum setTitleEdgeInsets:UIEdgeInsetsMake(-4,2,0,0)];
    [messageNum setTitle:[NSString stringWithFormat:@"%d",nums] forState:UIControlStateNormal];
    [messageNum setUserInteractionEnabled:NO];
    
    [self addSubview:messageNum];
    if (nums <= 0) {
        [messageNum setHidden:YES];
    }
    else  if(nums>99){
        [messageNum setTitle:@"99" forState:UIControlStateNormal];
        [messageNum setHidden:NO];
    }
    else {
        [messageNum setHidden:NO];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [pBkg drawAtPoint:CGPointMake(0, 0)];
}

- (UIButton*)addBtnWithFrame:(CGRect)frame imagename:(NSString*)strImg
{
    UIButton* pButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [pButton setFrame:frame];
    [self addSubview:pButton];
    pButton.adjustsImageWhenHighlighted=FALSE;
    [pButton setImage:CImageMgr::GetImageEx([[NSString stringWithFormat:@"%@.png",strImg] UTF8String]) forState:UIControlStateNormal];
    [pButton setImage:CImageMgr::GetImageEx([[NSString stringWithFormat:@"%@Click.png",strImg] UTF8String]) forState:UIControlStateHighlighted];
    [pButton setImage:CImageMgr::GetImageEx([[NSString stringWithFormat:@"%@Click.png",strImg] UTF8String]) forState:UIControlStateDisabled];
    [pButton addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    return pButton;
}

- (void)dealloc
{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_MY_MESSAGE, IMyMessageStateObserver);
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS, IUserStatusObserver);
    [super dealloc];
    [pButtons release];
}

- (void)setDeletate:(id<KSFooterTabBarDelegate>)delegate
{
    self.idDelegate=delegate;
}

- (void)selectIdx:(unsigned)idx
{
    [self onClickBtn:[pButtons objectAtIndex:idx]];
}

- (int)getSelectedIdx
{
    for (int i=0; i<[pButtons count]; ++i) {
        if([[pButtons objectAtIndex:i] isSelected])
        {
            return i;
        }
    }
    return -1;
}

- (void)onClickBtn:(id)sender
{
    UIButton* pBtn=(UIButton*)sender;
    for (int i=0; i<[pButtons count]; ++i) {
        UIButton* p=[pButtons objectAtIndex:i];
        if (p==pBtn) {
            [p setEnabled:FALSE];
            if (i==3) {
                [messageNum setHidden:YES];
            }
            [self.idDelegate didFooterTabBarSelected:i];
        } else {
            [p setEnabled:TRUE];
        }
    }
}

-(void)IMyMessageStateObserver_MessageNumChanged
{
    int nums=CMyMessageManager::GetInstance()->NumOfNewMessages();
    [messageNum setTitle:[NSString stringWithFormat:@"%d",nums] forState:UIControlStateNormal];
    if (nums <= 0) {
        [messageNum setHidden:YES];
    }
    else if(nums>99){
        [messageNum setHidden:NO];
        [messageNum setTitle:@"99" forState:UIControlStateNormal];
    }
    else {
        [messageNum setHidden:NO];
    }
}

-(void)IUserStatusObserver_Logout{
    [messageNum setHidden:YES];
}

@end