//
//  PoiRateView.m
//  QyGuide
//
//  Created by an qing on 13-3-5.
//
//


#import "PoiRateView.h"
#import <QuartzCore/QuartzCore.h>
#import "DYRateView.h"
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"
#import "PoiAllCommentViewController.h"
#import "MobClick.h"
#import "QYControl.h"
#import "QYAPIClient.h"


#define getdatamaxtime  10   //发送评论时-请求超时时间
#define selfPositionY   568  //self的Y坐标偏移量


@implementation PoiRateView
@synthesize myRate;
@synthesize poiId;
@synthesize poiTitle;
@synthesize commentId_user;
//@synthesize userInstruction = _userInstruction;
@synthesize placeHoderLabel = _placeHoderLabel;

-(void)dealloc
{
    [_textView release];
    [_rateView release];
    [_placeHoderLabel release];
    [_imageView_toast release];
    //[_userInstruction release];
    [_button_left release];
    [_button_right release];
    [_bgView release];
    self.poiTitle = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)nothing
{
    NSLog(@" nothing nothing --- here");
}


-(PoiRateView *)initWithFrame:(CGRect)frame andLeftButTitle:(NSString*)leftTitle andRightButTitle:(NSString*)rightTitle andRate:(NSString*)rateStr andVC:(UIViewController*)vc
{
    if(iPhone5)
    {
        frame.size.height = frame.size.height+88;
    }
    
    _srcFrame = frame;
    frame.origin.y = frame.origin.y+selfPositionY;
    _poiAllCommentVC_no_release = (PoiAllCommentViewController *)vc;
    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.myRate = [rateStr intValue];
        
        [self initBackGroundView];
        [self initMyViewWithLeftTitle:leftTitle andRightButTitle:rightTitle];
        [self doShow];
    }
    return self;
}
-(void)initMyViewWithLeftTitle:(NSString *)leftTitle andRightButTitle:(NSString *)rightTitle
{
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"add_new_comment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.backgroundColor = [UIColor whiteColor];
    [self.layer setCornerRadius:2];
    
    
    NSString *str =[NSString stringWithFormat:@"%@@2x",@"poi_collorstar"];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    str =[NSString stringWithFormat:@"%@@2x",@"poi_hollowstar"];
    UIImage *hollowImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    
    _rateView = [[DYRateView alloc] initWithFrame:CGRectMake((self.frame.size.width-180)/2., (44-40)/2-4, 180, 40) fullStar:image emptyStar:hollowImage];
    _rateView.isShowRateView = 0;
    _rateView.rate = self.myRate;
    _rateView.delegate = self;
    _rateView.backgroundColor = [UIColor clearColor];
    _rateView.padding = 10; //间隔
    _rateView.alignment = RateViewAlignmentCenter;
    _rateView.editable = YES;
    [self addSubview:_rateView];
    
    UILabel *label_topline = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 0.5)];
    label_topline.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [self addSubview:label_topline];
    [label_topline release];
    
    
    
    
    
    _button_left = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _button_left.frame = CGRectMake(5, 2, 40, 40);
    _button_left.backgroundColor = [UIColor clearColor];
    [_button_left setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
//    [_button_left setTitle:@"取消" forState:UIControlStateNormal];
//    [_button_left.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    [_button_left.titleLabel setTextColor:[UIColor colorWithRed:52/255. green:52/255. blue:52/255. alpha:1]];
    [_button_left addTarget:self action:@selector(doQuit) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button_left];
    
    
    _button_right = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _button_right.frame = CGRectMake(self.frame.size.width-40-5, 2, 40, 40);
    _button_right.backgroundColor = [UIColor clearColor];
    [_button_right setBackgroundImage:[UIImage imageNamed:@"send_no text"] forState:UIControlStateNormal];
//    [_button_right setTitle:@"发布" forState:UIControlStateNormal];
//    [_button_right.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    [_button_right.titleLabel setTextColor:[UIColor colorWithRed:52/255. green:52/255. blue:52/255. alpha:1]];
    [_button_right addTarget:self action:@selector(doSend:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button_right];
    
    
    
    if(iPhone5)
    {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(9, _rateView.bounds.origin.y+_rateView.bounds.size.height+4, self.bounds.size.width-9*2, 200)];
    }
    else
    {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(9, _rateView.bounds.origin.y+_rateView.bounds.size.height+4, self.bounds.size.width-9*2, 76)];
    }
    _textView.delegate = self;
    [self addSubview:_textView];
    _textView.backgroundColor = [UIColor clearColor];
    [_textView becomeFirstResponder];
    //_textView.font = [UIFont fontWithName:@"Arial" size:13.f];
    _textView.font = [UIFont systemFontOfSize:13];
    _textView.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1];
    
    
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}
-(void)initBackGroundView
{
    CGRect frame = [[UIApplication sharedApplication] keyWindow].frame;
    _bgView = [[SlurImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _bgView.backgroundColor = [UIColor clearColor];
    _bgView.alpha = 0.3;
    [[[UIApplication sharedApplication] keyWindow] addSubview:_bgView];
    
    
    
    [UIView animateWithDuration:0.1 animations:^{
        _bgView.alpha = 1;
    } completion:^(BOOL finished) {
        
        _bgView.userInteractionEnabled = YES;
        UIControl *control = [[UIControl alloc] initWithFrame:_bgView.bounds];
        [_bgView addSubview:control];
        [control addTarget:self action:@selector(nothing) forControlEvents:UIControlEventTouchUpInside];
        [control release];
    }];
}
-(void)initTextViewPlacehoderWithAlpha:(BOOL)alpha
{
    _placeHoderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 100, 20)];
    _placeHoderLabel.backgroundColor = [UIColor clearColor];
    [_placeHoderLabel setText:@"最少10个字"];
    _placeHoderLabel.font = [UIFont systemFontOfSize:13];
    _placeHoderLabel.textAlignment = NSTextAlignmentLeft;
    _placeHoderLabel.textColor = [UIColor grayColor];
    if(alpha == 1)
    {
        _placeHoderLabel.alpha = 1;
        _button_right.enabled = NO;
        //[_button_right.titleLabel setTextColor:[UIColor grayColor]];
        [_button_right setBackgroundImage:[UIImage imageNamed:@"send_no text"] forState:UIControlStateNormal];
    }
    else
    {
        _placeHoderLabel.alpha = 0;
        _button_right.enabled = YES;
        //[_button_right.titleLabel setTextColor:[UIColor colorWithRed:52/255. green:52/255. blue:52/255. alpha:1]];
        [_button_right setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
        
        [self performSelector:@selector(showHasCommentedToastView) withObject:nil afterDelay:0.5];
    }
    [_textView addSubview:_placeHoderLabel];
}
-(void)showHasCommentedToastView
{
    [_poiAllCommentVC_no_release.view hideToast];
    [_poiAllCommentVC_no_release.view makeToast:@"您之前对此地点发表过点评\n可以更新后重新发送。" duration:2. position:@"center" isShadow:NO];
}
-(void)setTextViewText:(NSString *)text
{
    if(text && text.length > 0)
    {
        _hasCommented = 1;
        
        _textView.text = text;
        _button_right.enabled = YES;
        //[_button_right.titleLabel setTextColor:[UIColor colorWithRed:52/255. green:52/255. blue:52/255. alpha:1]];
        [_button_right setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
        [self initTextViewPlacehoderWithAlpha:0];
    }
    else
    {
        _hasCommented = 0;
        
        [self initTextViewPlacehoderWithAlpha:1];
    }
}
-(void)doShow
{
    [UIView animateWithDuration:0.3 animations:^{
        [self presentSelf];
    } completion:^(BOOL finished) {
    }];
}
-(void)showSuccessStatueAndQuit
{
    [self showSuccessView];
    [self performSelector:@selector(doQuit) withObject:nil afterDelay:1];
}
-(void)showSuccessView
{
    [_textView resignFirstResponder];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
    }];
    
    
    _imageView_toast = [[UIImageView alloc] initWithFrame:CGRectMake((320-186/2)/2, ([[UIScreen mainScreen] bounds].size.height - 240/2)/2, 186/2, 240/2)];
    _imageView_toast.backgroundColor = [UIColor clearColor];
    _imageView_toast.image = [UIImage imageNamed:@"点评成功"];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_imageView_toast];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentSuccess" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",poiId],@"poiid", nil]];
}
-(void)doQuit
{
    [_poiAllCommentVC_no_release.view hideToast];
    
    [_textView resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        [self dismissSelf];
        _bgView.alpha = 0.3;
    } completion:^(BOOL finished) {
        [_bgView removeFromSuperview];
        [_imageView_toast removeFromSuperview];
        
        [self removeFromSuperview];
    }];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickcanclecomment" object:nil userInfo:nil];
    
}
-(void)presentSelf
{
    self.frame = _srcFrame;
}

-(void)dismissSelf
{
    CGRect frame = self.frame;
    frame.origin.y = frame.origin.y+selfPositionY;
    self.frame = frame;
}
-(void)doSend:(id)sender
{
    if(_rateView.rate - 0 == 0.)
    {
        //NSLog(@"请完善POI评星");
        
        [_poiAllCommentVC_no_release.view hideToast];
        [_poiAllCommentVC_no_release.view makeToast:@"评星不能为空" duration:1. position:@"center" isShadow:NO];
        
        if([self sinaCountWord:_textView.text] < 10)
        {
            _button_right.enabled = NO;
            _button_right.backgroundColor = [UIColor grayColor];
        }
        else
        {
            _button_right.enabled = YES;
            //[_button_right.titleLabel setTextColor:[UIColor colorWithRed:52/255. green:52/255. blue:52/255. alpha:1]];
            [_button_right setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
        }
        
        return;
    }
    else if([self sinaCountWord:_textView.text] < 10)
    {
        //NSLog(@"点评内容最少10个字");
        
        [_poiAllCommentVC_no_release.view hideToast];
        [_poiAllCommentVC_no_release.view makeToast:@"点评内容最少10个字" duration:1. position:@"center" isShadow:NO];
        
        return;
    }
    else if([self sinaCountWord:_textView.text] > 500)
    {
        //NSLog(@"点评内容最多500字");
        [_poiAllCommentVC_no_release.view hideToast];
        [_poiAllCommentVC_no_release.view makeToast:@"点评内容最多500字" duration:1. position:@"center" isShadow:NO];
        
        return;
    }
    else
    {
        //NSLog(@"发送我的点评");
        [self postMyComment];
    }
}


#pragma mark -
#pragma mark --- textField Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length == 0)
    {
        _placeHoderLabel.alpha = 1;
    }
    else if(textView.text.length > 0)
    {
        _placeHoderLabel.alpha = 0;
    }
    
    if([self sinaCountWord:_textView.text] < 10)
    {
        _button_right.enabled = NO;
        //[_button_right.titleLabel setTextColor:[UIColor grayColor]];
        [_button_right setBackgroundImage:[UIImage imageNamed:@"send_no text"] forState:UIControlStateNormal];
    }
    else
    {
        _button_right.enabled = YES;
        //[_button_right.titleLabel setTextColor:[UIColor colorWithRed:52/255. green:52/255. blue:52/255. alpha:1]];
        [_button_right setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    }
    
    CGRect frame = _textView.frame;
    CGSize size = _textView.contentSize;
    if(size.height - frame.size.height > 0)
    {
        [_textView setContentOffset:CGPointMake(0, size.height - frame.size.height)];
    }
}

#pragma mark -
#pragma mark --- 判断已输入字的个数
-(int)sinaCountWord:(NSString*)s
{
    int i,n=[s length],l=0,a=0,b=0;
    
    unichar c;
    for(i=0;i<n;i++)
    {
        c=[s characterAtIndex:i];
        
        if(isblank(c))
        {
            b++;
        }else if(isascii(c))
        {
            a++;
        }
        else
        {
            l++;
        }
    }
    if(a==0 && l==0)
        return 0;
    return l+(int)ceilf((float)(a+b)/2.0);
}


#pragma mark -
#pragma mark --- rateView Delegate
- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate
{
    self.myRate = [[NSString stringWithFormat:@"%@",rate] intValue];
}


#pragma mark -
#pragma mark --- postMyComment
-(void)postMyComment
{
    [_poiAllCommentVC_no_release.view hideToast];
    [_poiAllCommentVC_no_release.view makeToast:@"正在发送..." duration:0 position:@"center" isShadow:NO];
    
    
    [[QYAPIClient sharedAPIClient] postMyCommentWithContent:_textView.text
                                                    andRate:[NSString stringWithFormat:@"%d",self.myRate*2]
                                                   andPoiid:[NSString stringWithFormat:@"%ld",(long)self.poiId]
                                               andCommentid:self.commentId_user
                                                   finished:^(NSDictionary *dic){
                                                       
                                                       [_poiAllCommentVC_no_release.view hideToast];
                                                       //[_poiAllCommentVC_no_release.view makeToast:@"评论成功" duration:1.0 position:@"center" isShadow:NO];
                                                       
                                                       
                                                       if([_poiAllCommentVC_no_release isKindOfClass:[PoiAllCommentViewController class]])
                                                       {
                                                           _poiAllCommentVC_no_release.userCommentRateCopy = [NSString stringWithFormat:@"%d",self.myRate*2];
                                                       }
                                                       
                                                       
                                                       
                                                       //***(1) 刷新评论列表
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"comment_success" object:nil userInfo:nil];
                                                       if(_hasCommented == 0)
                                                       {
                                                           [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"add_new_comment"];
                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                       }
                                                       
                                                       
                                                       //***(2) 删除rateview
                                                       [self showSuccessStatueAndQuit];
                                                       
                                                   }
                                                     failed:^(NSString *info){
                                                         
                                                         [_poiAllCommentVC_no_release.view hideToast];
                                                         if(info)
                                                         {
                                                             [_poiAllCommentVC_no_release.view makeToast:info duration:2 position:@"center" isShadow:NO];
                                                         }
                                                         else
                                                         {
                                                             [_poiAllCommentVC_no_release.view makeToast:@"评论失败" duration:1 position:@"center" isShadow:NO];
                                                         }

                                                     }];
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

