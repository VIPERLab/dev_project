//
//  KSSpringJoinView.m
//  KwSing
//
//  Created by 单 永杰 on 14-4-15.
//  Copyright (c) 2014年 酷我音乐. All rights reserved.
//

#import "KSSpringJoinView.h"
#include "ImageMgr.h"
#include "MessageManager.h"
#include "HttpRequest.h"
#include "iToast.h"

#define TAG_BTN_CLOSE     300
#define TAG_BTN_JOIN      301

#define TAG_TEXT_NAME     302
#define TAG_TEXT_PHONE    303
#define TAG_MAIN_VIEW     304

#define SPRING_MATCH_REGISTER_URL @"http://music.sprite.com.cn/sprite/kgeuser?act=register&name=%@&uid=%@&phone=%@&id=%@"

@interface KSSpringJoinView ()<UITextFieldDelegate>{
    UITextField* textFieldName;
    UITextField* textFieldPhoneNumber;
}

@end

@implementation KSSpringJoinView

@synthesize bSpringJoin = m_bJoin;
@synthesize strName = m_strName;
@synthesize strPhoneNumber = m_strPhoneNumber;
@synthesize strUserId = m_strUserId;
@synthesize strKid = m_strKid;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView* background_view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
        [background_view setBackgroundColor:[UIColor clearColor]];
        [self addSubview:background_view];
        
        UIImage* p_frame_image = CImageMgr::GetImageEx("SpringJoin.png");
        //        NSLog(@"width = %f height = %f", NORMALIZE(p_frame_image.size.width), NORMALIZE(p_frame_image.size.height));
        CGRect rect_main_view = CGRectMake(16.9, (background_view.frame.size.height - 343.5) / 2, 285, 343.5);
        UIView * mainview = [[[UIView alloc]initWithFrame:rect_main_view] autorelease];
        [mainview setBackgroundColor:[UIColor clearColor]];
        [mainview setTag:TAG_MAIN_VIEW];
        UIImageView* p_background_view = [[[UIImageView alloc] initWithImage:p_frame_image] autorelease];
        [p_background_view setFrame:CGRectMake(0, 0, (p_frame_image.size.width / 2), (p_frame_image.size.height / 2))];
        [mainview addSubview:p_background_view];
        
        [background_view addSubview:mainview];
        
        UIButton* btn_close = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_close.frame = CGRectMake(258, 2, 21, 21);
        [btn_close setBackgroundImage:CImageMgr::GetImageEx("SpringCloseBtn.png") forState:(UIControlStateNormal)];
        [btn_close addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
        [btn_close setTag:TAG_BTN_CLOSE];
        [mainview addSubview:btn_close];
        
        UIButton* btn_join = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_join.frame = CGRectMake(23, 289, 155, 42);
        [btn_join setBackgroundImage:CImageMgr::GetImageEx("SpringJoinBtn.png") forState:(UIControlStateNormal)];
        [btn_join addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
        [btn_join setTag:TAG_BTN_JOIN];
        [mainview addSubview:btn_join];
        
        textFieldName = [[UITextField alloc] initWithFrame:CGRectMake(23, 192, 240, 38)];
        textFieldName.placeholder = @"真实姓名";
        [textFieldName setBackgroundColor:[UIColor whiteColor]];
        textFieldName.returnKeyType = UIReturnKeyDone;
        textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
        textFieldName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        textFieldName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textFieldName.delegate = self;
        textFieldName.tag = TAG_TEXT_NAME;
        [mainview addSubview:textFieldName];
        
        textFieldPhoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(23, 240, 240, 38)];
        textFieldPhoneNumber.placeholder = @"手机号码";
        [textFieldPhoneNumber setBackgroundColor:[UIColor whiteColor]];
        textFieldPhoneNumber.returnKeyType = UIReturnKeyDone;
        textFieldPhoneNumber.clearButtonMode = UITextFieldViewModeWhileEditing;
        textFieldPhoneNumber.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        textFieldPhoneNumber.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textFieldPhoneNumber.delegate = self;
        textFieldPhoneNumber.tag = TAG_TEXT_PHONE;
        [mainview addSubview:textFieldPhoneNumber];
    }
    return self;
}

- (void)dealloc{
    
    if (textFieldName) {
        [textFieldName release];
        textFieldName = nil;
    }
    
    if (textFieldPhoneNumber) {
        [textFieldPhoneNumber release];
        textFieldPhoneNumber = nil;
    }
    
    if (m_strPhoneNumber) {
        [m_strPhoneNumber release];
        m_strPhoneNumber = nil;
    }
    
    if (m_strName) {
        [m_strName release];
        m_strName = nil;
    }
    
    [super dealloc];
}

- (void)onBtnClicked:(id)sender{
    UIButton* cur_btn = (UIButton*)sender;
    switch (cur_btn.tag) {
        case TAG_BTN_CLOSE:
        {
            [self removeFromSuperview];
            break;
        }
        case TAG_BTN_JOIN:
        {
            if (![self isPhoneNumberCorrect:textFieldPhoneNumber.text]) {
                [[[[iToast makeText:NSLocalizedString(@"手机号码输入有误, 请重新输入", @"")]setGravity:iToastGravityCenter] setDuration:3000] show];
                
                return;
            }
            
            NSString* str_register_url = [NSString stringWithFormat:SPRING_MATCH_REGISTER_URL, textFieldName.text, m_strUserId, textFieldPhoneNumber.text, m_strKid];
            KS_BLOCK_DECLARE{
                std::string str_out = "";
                int n_retry_time = 0;
                bool b_ret = CHttpRequest::QuickSyncGet([str_register_url UTF8String], str_out);
                while (!b_ret && 3 > n_retry_time++) {
                    b_ret = CHttpRequest::QuickSyncGet([str_register_url UTF8String], str_out);
                }
                
                if (b_ret && std::string::npos != str_out.find(":200")) {
                    KS_BLOCK_DECLARE{
                        [self removeFromSuperview];
                        [[[[iToast makeText:NSLocalizedString(@"参赛成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    }
                    KS_BLOCK_SYNRUN();
                }else {
                    KS_BLOCK_DECLARE{
                        [self removeFromSuperview];
                        [[[[iToast makeText:NSLocalizedString(@"参赛失败，请检查网络连接", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    }
                    KS_BLOCK_SYNRUN();
                }
            }
            KS_BLOCK_RUN_THREAD();
            break;
        }
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField superview].frame = CGRectMake(16.9, (textField.superview.superview.frame.size.height - 343.5) / 2, 285, 343.5);
    switch (textField.tag) {
        case TAG_TEXT_NAME:
        {
            [textFieldName resignFirstResponder];
            break;
        }
        case TAG_TEXT_PHONE:
        {
            [textFieldPhoneNumber resignFirstResponder];
            break;
        }
            
        default:
            break;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect rect = [textField superview].frame;
    rect.origin.y = -100;
    [textField superview].frame = rect;
}

- (BOOL) isPhoneNumberCorrect : (NSString*)str_input{
    NSScanner* scan = [NSScanner scannerWithString:str_input];
    
    int value = 0;
    return [scan scanInt:&value] && [scan isAtEnd] && (11 == str_input.length);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
