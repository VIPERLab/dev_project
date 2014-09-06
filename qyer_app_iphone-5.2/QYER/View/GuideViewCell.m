//
//  GuideViewCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-4.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideViewCell.h"
#import "QYGuideData.h"
#import "QYGuide.h"
#import "UIImageView+WebCache.h"
#import "CustomProessView.h"
#import "FilePath.h"
#import "MobClick.h"
#import "Toast+UIView.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"
#import "CityLoginViewController.h"
#import "DownloadData.h"
#import "ObserverObject.h"



#define     NewGuideTimeLimit       7       //上线NewGuideTimeLimit天之内的锦囊属于新锦囊
#define     CellHeight              240/2
#define     PositionX               0
#define     PositionX_guide_cover   10
#define     PositionY_guide_cover   10
#define     PositionX_guide_name    8



@implementation GuideViewCell
@synthesize imageViewBackGround = _imageViewBackGround;
@synthesize imageView_cover = _imageView_cover;
@synthesize imageView_cover_NewOrUpdate = _imageView_cover_NewOrUpdate;
@synthesize label_guideName = _label_guideName;
@synthesize label_guideBelongtoCountryName = _label_guideBelongtoCountryName;
@synthesize label_guideDownloadTimes = _label_guideDownloadTimes;
@synthesize label_guideUpdateTime = _label_guideUpdateTime;
@synthesize label_progress = _label_progress;
@synthesize label_fileSize = _label_fileSize;
@synthesize button_fuction = _button_fuction;
@synthesize progressView = _progressView;
@synthesize position_section = _position_section;
@synthesize position_row = _position_row;
@synthesize guide = _guide;
@synthesize delegate = _delegate;
@synthesize flag_isInDownloadigVC;
@synthesize imageView_lastCell = _imageView_lastCell;
@synthesize where_from;



-(void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    QY_VIEW_RELEASE(_imageView_cover_NewOrUpdate);
    QY_VIEW_RELEASE(_imageView_cover);
    QY_VIEW_RELEASE(_label_guideName);
    QY_VIEW_RELEASE(_label_guideBelongtoCountryName);
    QY_VIEW_RELEASE(_label_guideDownloadTimes);
    QY_VIEW_RELEASE(_label_guideUpdateTime);
    QY_VIEW_RELEASE(_label_progress);
    QY_VIEW_RELEASE(_label_fileSize);
    QY_VIEW_RELEASE(_imageView_lastCell);
    QY_VIEW_RELEASE(_detailControl);
    QY_VIEW_RELEASE(_progressView);
    QY_VIEW_RELEASE(_bottomLine);
    QY_VIEW_RELEASE(_imageViewBackGround);
    
    QY_SAFE_RELEASE(_guide);
    self.delegate = nil;
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        _imageViewBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(PositionX, 0, 320-2*PositionX, CellHeight)];
        _imageViewBackGround.backgroundColor = [UIColor whiteColor];
        _imageViewBackGround.userInteractionEnabled = YES;
        [self addSubview:_imageViewBackGround];
        
        
        
        _detailControl = [[QAControl alloc] initWithFrame:CGRectMake(0, 0, 512/2, CellHeight)];
        _detailControl.backgroundColor = [UIColor clearColor];
        [_detailControl addTarget:self action:@selector(changeBackgroundColor:) forControlEvents:UIControlEventTouchDown];
        [_detailControl addTarget:self action:@selector(resetBackgroundColor:) forControlEvents:UIControlEventTouchUpOutside];
        [_detailControl addTarget:self action:@selector(resetBackgroundColor:) forControlEvents:UIControlEventTouchCancel];
        [_detailControl addTarget:self action:@selector(resetBackgroundColor:) forControlEvents:UIControlEventTouchDragExit];
        [_detailControl addTarget:self action:@selector(resetBackgroundColor:) forControlEvents:UIControlEventTouchDragOutside];
        [_detailControl addTarget:self action:@selector(showGuideDetail) forControlEvents:UIControlEventTouchUpInside];
        [_imageViewBackGround addSubview:_detailControl];
        
        
        _imageView_cover = [[UIImageView alloc] initWithFrame:CGRectMake(PositionX_guide_cover, PositionY_guide_cover, 68, 100)];
        _imageView_cover.backgroundColor = [UIColor clearColor];
        [_imageViewBackGround addSubview:_imageView_cover];
        
        
        _imageView_cover_NewOrUpdate = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        //_imageView_cover_NewOrUpdate.image = [UIImage imageNamed:@"guide_view_new"];
        _imageView_cover_NewOrUpdate.image = [UIImage imageNamed:@""];
        _imageView_cover_NewOrUpdate.hidden = YES;
        [_imageView_cover addSubview:_imageView_cover_NewOrUpdate];
        
        
        
        _label_guideName = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_cover.frame.origin.x+_imageView_cover.frame.size.width+PositionX_guide_name, 13, 160, 25)];
        _label_guideName.backgroundColor = [UIColor clearColor];
        _label_guideName.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        _label_guideName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        [_imageViewBackGround addSubview:_label_guideName];
        
        
        _label_guideBelongtoCountryName = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_cover.frame.origin.x+_imageView_cover.frame.size.width+PositionX_guide_name, _label_guideName.frame.origin.y+_label_guideName.frame.size.height, 160, 18)];
        _label_guideBelongtoCountryName.backgroundColor = [UIColor clearColor];
        _label_guideBelongtoCountryName.textColor = [UIColor colorWithRed:188/255. green:188/255. blue:188/255. alpha:1];
        _label_guideBelongtoCountryName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
        [_imageViewBackGround addSubview:_label_guideBelongtoCountryName];
        
        
        _label_guideDownloadTimes = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_cover.frame.origin.x+_imageView_cover.frame.size.width+PositionX_guide_name, _label_guideBelongtoCountryName.frame.origin.y+_label_guideBelongtoCountryName.frame.size.height, 160, 18)];
        _label_guideDownloadTimes.backgroundColor = [UIColor clearColor];
        _label_guideDownloadTimes.textColor = [UIColor colorWithRed:188/255. green:188/255. blue:188/255. alpha:1];
        _label_guideDownloadTimes.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
        [_imageViewBackGround addSubview:_label_guideDownloadTimes];
        
        
        _label_guideUpdateTime = [[UILabel alloc] initWithFrame:CGRectMake(_imageView_cover.frame.origin.x+_imageView_cover.frame.size.width+PositionX_guide_name, _label_guideDownloadTimes.frame.origin.y+_label_guideDownloadTimes.frame.size.height, 160, 18)];
        _label_guideUpdateTime.backgroundColor = [UIColor clearColor];
        _label_guideUpdateTime.textColor = [UIColor colorWithRed:188/255. green:188/255. blue:188/255. alpha:1];
        _label_guideUpdateTime.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
        [_imageViewBackGround addSubview:_label_guideUpdateTime];
        
        
        
        
        if(ios7)
        {
            _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            float default_height = _progressView.frame.size.height;
            _progressView.frame = CGRectMake(_imageView_cover.frame.origin.x+_imageView_cover.frame.size.width+PositionX_guide_name, _label_guideUpdateTime.frame.origin.y+_label_guideUpdateTime.frame.size.height+6, 160, default_height);
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.5f);
            _progressView.transform = transform;
            _progressView.alpha = 0.;
            [_imageViewBackGround addSubview:_progressView];
            
            _progressView.trackImage = [UIImage imageNamed:@"bg_progress"];
            _progressView.progressTintColor = [UIColor colorWithRed:51/255. green:181/255. blue:229/255. alpha:1];
        }
        else
        {
            _progressView = [[CustomProessView alloc] initWithFrame:CGRectMake(_imageView_cover.frame.origin.x+_imageView_cover.frame.size.width+PositionX_guide_name, _label_guideUpdateTime.frame.origin.y+_label_guideUpdateTime.frame.size.height+6, 160, 3)];
            _progressView.progressViewStyle = UIProgressViewStyleDefault;
            _progressView.alpha = 0.;
            [_progressView setTintColorWithImage:[UIImage imageNamed:@"progress"]];
            [_progressView setBackGroundTintColorWithImage:[UIImage imageNamed:@"bg_progress"]];
            [_imageViewBackGround addSubview:_progressView];
        }
        
        
        
        
        
        
        _label_progress = [[UILabel alloc] initWithFrame:CGRectMake(195, _progressView.frame.origin.y-26, 50, 24)];
        _label_progress.backgroundColor = [UIColor clearColor];
        _label_progress.textColor = [UIColor colorWithRed:45./255 green:158./255 blue:216./255 alpha:1];
        _label_progress.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        _label_progress.textAlignment = NSTextAlignmentRight;
        _label_progress.alpha = 0.;
        [_imageViewBackGround addSubview:_label_progress];
        
        
        
        _button_fuction = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_fuction.frame = CGRectMake(320-126/2, 0, 126/2, 240/2);
        [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_download"] forState:UIControlStateNormal];
        [_imageViewBackGround addSubview:_button_fuction];
        [_button_fuction addTarget:self action:@selector(changeBackgroundColor:) forControlEvents:UIControlEventTouchDown];
        [_button_fuction addTarget:self action:@selector(resetBackgroundColor:) forControlEvents:UIControlEventTouchCancel];
        [_button_fuction addTarget:self action:@selector(resetBackgroundColor:) forControlEvents:UIControlEventTouchDragExit];
        [_button_fuction addTarget:self action:@selector(button_selected:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _label_fileSize = [[UILabel alloc] initWithFrame:CGRectMake(_button_fuction.frame.origin.x, 69, _button_fuction.frame.size.width, 20)];
        _label_fileSize.backgroundColor = [UIColor clearColor];
        _label_fileSize.textColor = [UIColor grayColor];
        _label_fileSize.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        _label_fileSize.textAlignment = NSTextAlignmentCenter;
        [_imageViewBackGround addSubview:_label_fileSize];
        
        
        
        _bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(PositionX_guide_cover, CellHeight-1, 320-PositionX_guide_cover*2, 0.5)];
        _bottomLine.backgroundColor = [UIColor colorWithRed:188/255. green:188/255. blue:188/255. alpha:0.6];
        [_imageViewBackGround addSubview:_bottomLine];
        
        
        UILabel *verticalLine = [[UILabel alloc] initWithFrame:CGRectMake(512/2, 10, 0.5, CellHeight-10*2)];
        verticalLine.backgroundColor = [UIColor colorWithRed:188/255. green:188/255. blue:188/255. alpha:0.6];
        [_imageViewBackGround addSubview:verticalLine];
        [verticalLine release];
        
        
        
        _imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, CellHeight, 320, 2)];
        _imageView_lastCell.hidden = YES;
        _imageView_lastCell.backgroundColor = [UIColor clearColor];
        _imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影"];
        [_imageViewBackGround addSubview:_imageView_lastCell];
        
    }
    
    return self;
}



#pragma mark -
#pragma mark --- resetCell
-(void)resetCell
{
    self.label_progress.alpha = 0.;
    self.progressView.progress = 0;
    self.progressView.alpha = 0.;
    
    self.label_progress.alpha = 0.;
    self.label_progress.text = @"";
    
    _imageView_cover_NewOrUpdate.hidden = YES;
}


#pragma mark -
#pragma mark --- 刷新cell的内容
-(void)freshCellWithGuide:(QYGuide *)guide_
{
    if(_guide)
    {
        [_guide release];
    }
    _guide = [guide_ retain];
    
    
    
    //*** 进度条和下载进度显示:
    [self initProgressView:_guide];
    
    
    //*** 初始化cell的button样式:
    [self initButtonFuctionStateAndImage:_guide];
    
}
-(void)freshCellWhenFinished
{
    self.progressView.alpha = 0;
    self.label_progress.alpha = 0;
    self.label_fileSize.text = @"阅读";
    [self.button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_read"] forState:UIControlStateNormal];
}



#pragma mark -
#pragma mark --- 初始化cell的内容
-(void)initCellWithArray:(NSArray *)array_guide atPosition:(NSInteger)position
{
    if(!array_guide || [array_guide count] <= position)
    {
        return;
    }
    
    
    QYGuide *guide_ = [array_guide objectAtIndex:position];
    self.guide = guide_;
    
    
    
    
    //最后一条cell的底部阴影:
    self.imageView_lastCell.hidden = YES;
    self.bottomLine.hidden = NO;
    if(array_guide.count - 1 == position)
    {
        self.imageView_lastCell.hidden = NO;
        self.bottomLine.hidden = YES;
    }
    
    
    
    //*** cell初始化:
    NSString *imageUrl = [NSString stringWithFormat:@"%@/140_210.jpg?cover_updatetime=%@",self.guide.guideCoverImage, self.guide.guideCover_updatetime];
    [self.imageView_cover setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"bg_guide_cover_default"]];
    self.label_guideName.text = self.guide.guideName;
    self.label_guideBelongtoCountryName.text = self.guide.guideCountry_name_cn;
    self.label_guideDownloadTimes.text = [NSString stringWithFormat:@"%@次下载",self.guide.guideDownloadTimes];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *myDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.guide.guideUpdate_time doubleValue]]];
    self.label_guideUpdateTime.text = myDateStr;
    [dateFormatter release];
    self.label_fileSize.text = [NSString stringWithFormat:@"%.2fM", [self.guide.guideSize floatValue]/1048576];
    self.progressView.progress = self.guide.progressValue;
    self.label_progress.text = [NSString stringWithFormat:@"%.1f%%",self.guide.progressValue*100];
    
    
    
    //判断是否属于新锦囊:
    //_imageView_cover_NewOrUpdate.image = [UIImage imageNamed:@"guide_view_new"];
    _imageView_cover_NewOrUpdate.image = [UIImage imageNamed:@""];
    if([[NSDate date] timeIntervalSince1970] - self.guide.guideUpdate_time.intValue < NewGuideTimeLimit*24*60*60)
    {
        _imageView_cover_NewOrUpdate.hidden = NO;
    }
    else
    {
        _imageView_cover_NewOrUpdate.hidden = YES;
    }
    
    
    //判断是否显示需要更新的icon:
    _imageView_cover_NewOrUpdate.hidden = YES;
    for(QYGuide *guide in [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated])
    {
        if([guide_.guideName isEqualToString:guide.guideName])
        {
            _imageView_cover_NewOrUpdate.hidden = NO;
            _imageView_cover_NewOrUpdate.image = [UIImage imageNamed:@"guide_view_update"];
            break;
        }
    }
    
    
    
    //*** 添加监听:
    NSLog(@"  ------------- 添加监听");
    NSLog(@"  guide_state : %d",[self.guide guide_state]);
    if(self.guide.obj_observe)
    {
        //取消kvo注册:
        NSLog(@"  ------------- 取消kvo注册");
        [self.guide removeObserver:self.guide.obj_observe forKeyPath:@"progressValue"];
        [self.guide removeObserver:self.guide.obj_observe forKeyPath:@"guide_state"];
    }
    self.guide.obj_observe = self;
    [self.guide addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.guide addObserver:self forKeyPath:@"guide_state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    
    
    
    //*** 进度条和下载进度显示:
    [self initProgressView:self.guide];
    
    
    //*** 初始化cell的button样式:
    [self initButtonFuctionStateAndImage:self.guide];
    
}
-(void)initProgressView:(QYGuide *)guide_
{
    if(guide_.guide_state == GuideNoamal_State)
    {
        self.progressView.alpha = 0;
        self.label_progress.alpha = 0;
    }
    else if(guide_.guide_state == GuideWating_State)
    {
        self.progressView.alpha = 1;
        self.label_progress.text = @"等待下载";
        self.label_progress.alpha = 1;
    }
    else if(guide_.guide_state == GuideDownloading_State)
    {
        self.progressView.alpha = 1;
        self.progressView.progress = guide_.progressValue;
        self.label_progress.text = [NSString stringWithFormat:@"%.1f%%",guide_.progressValue*100];
        self.label_progress.alpha = 1;
    }
    else if(guide_.guide_state == GuideRead_State)
    {
        self.progressView.alpha = 0;
        self.label_progress.alpha = 0;
    }
    else if(guide_.guide_state == GuideDownloadFailed_State)
    {
        self.progressView.alpha = 1;
        self.progressView.progress = guide_.progressValue;
        self.label_progress.alpha = 1;
        self.label_progress.text = @"等待下载";
        if (self.progressView.progress - 0.0001 >= 0)
        {
            self.label_progress.text = [NSString stringWithFormat:@"%.1f%%",guide_.progressValue*100];
        }
    }
    else
    {
        self.progressView.alpha = 0;
        self.label_progress.alpha = 0;
    }
}
-(void)initButtonFuctionStateAndImage:(QYGuide *)guide_
{
    switch (guide_.guide_state)
    {
        case GuideNoamal_State:
        {
            [self.button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_download"] forState:UIControlStateNormal];
            self.label_fileSize.text = [NSString stringWithFormat:@"%.2fM", [self.guide.guideSize floatValue]/1048576];
            break;
        }
        case GuideWating_State:
        {
            [self.button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_cancle"] forState:UIControlStateNormal];
            self.label_fileSize.text = [NSString stringWithFormat:@"%.2fM", [self.guide.guideSize floatValue]/1048576];
            break;
        }
        case GuideDownloading_State:
        {
            [self.button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_cancle"] forState:UIControlStateNormal];
            self.label_fileSize.text = [NSString stringWithFormat:@"%.2fM", [self.guide.guideSize floatValue]/1048576];
            break;
        }
        case GuideRead_State:
        {
            [self.button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_read"] forState:UIControlStateNormal];
            self.label_fileSize.text = @"阅读";
            break;
        }
        case GuideDownloadFailed_State:
        {
            [self.button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_download"] forState:UIControlStateNormal];
            self.label_fileSize.text = [NSString stringWithFormat:@"%.2fM", [self.guide.guideSize floatValue]/1048576];
            break;
        }
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark --- button_selected 下载/暂停/阅读
-(void)button_selected:(id)sender
{
    [self performSelector:@selector(resetBackgroundColor:) withObject:nil afterDelay:0.1];
    
    switch (self.guide.guide_state)
    {
        case GuideNoamal_State:
        {
            NSLog(@" --- 开始下载");
            NSLog(@" --- guideName : %@",self.guide.guideName);
            
            
            //*** (1) 网络不好:
            if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
            {
                [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] hideToast];
                [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
                
                
                return;
            }
            
            
            //*** (2) 3G网络:
            if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
            {
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"WIFISwitch"] boolValue] == NO) //3g环境下允许下载
                {
                    NSLog(@" 3g环境下允许下载 ");
                    
                    
                    
                    //*** (3) 未登录:
                    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
                    {
                        NSInteger limit_counts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mobileDownloadLimit"] intValue];
                        NSInteger times = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mobileDownloadCount"] intValue];
                        if(times < limit_counts)
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",times+1] forKey:@"mobileDownloadCount"]; //未登录状态下的下载次数
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        else
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:self.guide.guideName forKey:@"guideName_notlogininwhendownload"];
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.position_section] forKey:@"section_notlogininwhendownload"];
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.position_row] forKey:@"row_notlogininwhendownload"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            
                            UIAlertView *alertView = [[UIAlertView alloc]
                                                      initWithTitle:nil
                                                      message:@"您登录之后才能下载更多锦囊"
                                                      delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"立即登录",nil];
                            alertView.tag = 11;
                            alertView.delegate = self;
                            [alertView show];
                            [alertView release];
                            
                            return;
                        }
                    }
                    
                    
                    else
                    {
                        //*** 修改锦囊的状态:
                        [self reSetGuide:self.guide.guideName withState:GuideWating_State];
                        
                        
                        //*** 进度条和下载进度显示:
                        [self initProgressView:self.guide];
                        
                        
                        [self startDownload];
                        [self changeButtonFuctionStateAndImage_ProgressLabelState];
                        
                        return;
                    }
                }
                else //仅允许wifi环境下下载:
                {
                    UIAlertView *alertView = [[UIAlertView alloc]
                                              initWithTitle:nil
                                              message:@"当前处于移动网络，已为您暂停了所有下载"
                                              delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"允许本次下载", @"始终允许移动网络下载", @"暂停下载", nil];
                    alertView.tag = 12;
                    alertView.delegate = self;
                    [alertView show];
                    [alertView release];
                    
                    return;
                }
            }
            
            
            //*** (3) 未登录:
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
            {
                NSInteger limit_counts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mobileDownloadLimit"] intValue];
                NSInteger times = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mobileDownloadCount"] intValue];
                if(times < limit_counts)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",times+1] forKey:@"mobileDownloadCount"]; //未登录状态下的下载次数
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setObject:self.guide.guideName forKey:@"guideName_notlogininwhendownload"];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.position_section] forKey:@"section_notlogininwhendownload"];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.position_row] forKey:@"row_notlogininwhendownload"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    UIAlertView *alertView = [[UIAlertView alloc]
                                              initWithTitle:Nil
                                              message:@"您登录之后才能下载更多锦囊"
                                              delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"立即登录",nil];
                    alertView.tag = 11;
                    alertView.delegate = self;
                    [alertView show];
                    [alertView release];
                    
                    return;
                }
            }
            
            
            
            //*** 修改锦囊的状态:
            [self reSetGuide:self.guide.guideName withState:GuideWating_State];
            
            
            //*** 进度条和下载进度显示:
            [self initProgressView:self.guide];
            
            
            [self startDownload];
            [self changeButtonFuctionStateAndImage_ProgressLabelState];
            
            break;
        }
        case GuideWating_State:
        {
            NSLog(@" --- 暂停下载 1");
            
            
            //*** 修改锦囊的状态:
            [self reSetGuide:_guide.guideName withState:GuideNoamal_State];
            
            //*** 进度条和下载进度显示:
            [self initProgressView:self.guide];
            
            
            [self suspend];
            [self changeButtonFuctionStateAndImage_ProgressLabelState];
            
            
            //*** 刷新cell:
            [self freshCellWithGuide:self.guide];
            
            
            [self cancleDownload];
            
            
            break;
        }
        case GuideDownloading_State:
        {
            NSLog(@" --- 暂停下载 2");
            
            
            //*** 修改锦囊的状态:
            [self reSetGuide:self.guide.guideName withState:GuideNoamal_State];
            
            //*** 进度条和下载进度显示:
            [self initProgressView:self.guide];
            
            
            [self suspend];
            [self changeButtonFuctionStateAndImage_ProgressLabelState];
            
            
            //*** 刷新cell
            [self freshCellWithGuide:self.guide];
            
            
            [self cancleDownload];
            
            
            break;
        }
        case GuideRead_State:
        {
            NSLog(@" --- 阅读锦囊");
            [self readGuide];
            
            break;
        }
        case GuideDownloadFailed_State:
        {
            NSLog(@" --- 开始下载");
            
            //*** 网络不好:
            if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
            {
                [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] hideToast];
                [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
                
                return;
            }
            
            
            //修改锦囊的状态:
            [self reSetGuide:self.guide.guideName withState:GuideWating_State];
            
            //*** 进度条和下载进度显示:
            [self initProgressView:self.guide];
            
            [self startDownload];
            [self changeButtonFuctionStateAndImage_ProgressLabelState];
            
            break;
        }
            
        default:
            break;
    }
}



#pragma mark -
#pragma mark --- changeBackgroundColor & resetBackgroundColor
-(void)changeBackgroundColor:(id)sender
{
    if([sender isMemberOfClass:[UIButton class]])
    {
        [_button_fuction setBackgroundColor:[UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3]];
    }
    else if([sender isMemberOfClass:[QAControl class]])
    {
        _detailControl.backgroundColor = [UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:0.3];
    }
}
-(void)resetBackgroundColor:(id)sender
{
    [_button_fuction setBackgroundColor:[UIColor clearColor]];
    _detailControl.backgroundColor = [UIColor clearColor];
}



#pragma mark -
#pragma mark --- changeButtonFuctionStateAndImage_ProgressLabelState
-(void)changeButtonFuctionStateAndImage_ProgressLabelState
{
    switch (self.guide.guide_state)
    {
        case GuideNoamal_State:
        {
            self.progressView.alpha = 1;
            self.label_progress.alpha = 0;
            [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_download"] forState:UIControlStateNormal];
            break;
        }
        case GuideWating_State:
        {
            self.progressView.alpha = 1;
            self.label_progress.alpha = 1;
            [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_cancle"] forState:UIControlStateNormal];
            break;
        }
        case GuideDownloading_State:
        {
            self.progressView.alpha = 1;
            self.label_progress.alpha = 1;
            [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_cancle"] forState:UIControlStateNormal];
            break;
        }
        case GuideRead_State:
        {
            self.progressView.alpha = 0;
            self.label_progress.alpha = 0;
            [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_read"] forState:UIControlStateNormal];
            break;
        }
        case GuideDownloadFailed_State:
        {
            self.progressView.alpha = 1;
            self.label_progress.alpha = 0;
            [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_guide_view_download"] forState:UIControlStateNormal];
            break;
        }
            
        default:
            break;
    }
}




#pragma mark -
#pragma mark --- 开始下载 & 暂停下载
-(void)startDownload
{
    if(self.where_from && [self.where_from isEqualToString:@"country"])
    {
        [MobClick event:@"countryGuideListDownload"];
    }
    else if(self.where_from && [self.where_from isEqualToString:@"city"])
    {
        [MobClick event:@"cityGuideListDownload"];
    }
    else
    {
        [MobClick event:@"guideGuideDetailDownload"];
    }
    
    [QYGuideData startDownloadWithGuide:self.guide];
}
-(void)suspend
{
    [QYGuideData suspend:self.guide];
}


#pragma mark -
#pragma mark --- UIAlertView - delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex])
    {
        return;
    }
    else
    {
        if(alertView.tag == 11)
        {
            
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"download_notlogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
            navigationController.navigationBarHidden = YES;
            //[self presentModalViewController:navigationController animated:YES];
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController]  presentViewController:navigationController animated:YES completion:nil];
            [cityLoginVC release];
        }
        else if(alertView.tag == 12)
        {
            if(buttonIndex == 0)  //允许本次下载
            {
                NSLog(@"  允许本次下载 --- cell");
                
                //修改锦囊的状态:
                [self reSetGuide:self.guide.guideName withState:GuideWating_State];
                
                //*** 进度条和下载进度显示:
                [self initProgressView:self.guide];
                
                [self startDownload];
                [self changeButtonFuctionStateAndImage_ProgressLabelState];
            }
            else if(buttonIndex == 1) //始终允许移动网络下载
            {
                NSLog(@"  始终允许移动网络下载 --- cell");
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WIFISwitch"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                //修改锦囊的状态:
                [self reSetGuide:self.guide.guideName withState:GuideWating_State];
                
                //*** 进度条和下载进度显示:
                [self initProgressView:self.guide];
                
                [self startDownload];
                [self changeButtonFuctionStateAndImage_ProgressLabelState];
            }
            else if(buttonIndex == 2)  //暂停下载
            {
                NSLog(@"  暂停下载 --- cell");
                [self cancleDownload];
                
                return;
            }
        }
    }
}




#pragma mark -
#pragma mark --- 监听的方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    NSLog(@"  ------------- 接收到监听");
    
    if([keyPath isEqualToString:@"progressValue"])
    {
        NSLog(@" -------------- 111 ");
        if(self.guide.progressValue - 0 == 0.)
        {
            return;
        }
        
        self.progressView.progress = self.guide.progressValue;
        self.label_progress.text = [NSString stringWithFormat:@"%.1f%%",self.guide.progressValue*100];
    }
    
    else if([keyPath isEqualToString:@"guide_state"])
    {
        NSLog(@" -------------- 222 ");
        NSInteger newKey = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        NSInteger oldKey = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        
        
        if(self.guide.guide_state == GuideWating_State && newKey == 1 && oldKey == 0)
        {
            NSLog(@"  guide_state 发生了变化 [GuideViewCell] 等待下载 ");
        }
        else if(self.guide.guide_state == GuideDownloading_State && newKey == 2 && oldKey == 1)
        {
            NSLog(@"  guide_state 发生了变化 [GuideViewCell] 开始下载 ");
        }
        else if(self.guide.guide_state == GuideRead_State && newKey == 3 && oldKey == 2)
        {
            NSLog(@"  guide_state 发生了变化 [GuideViewCell] 下载完成 ");
            
            [self freshCellWhenFinished];
        }
    }
    
}




#pragma mark -
#pragma mark --- DownloadData - Delegate
-(void)downloadCancled:(id)info
{
    if(info && [info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)info;
        
        if([dic objectForKey:@"guideName"])
        {
            [[QYGuideData sharedQYGuideData] processGuideWhenDownloadFailed:dic];
        }
    }
}



#pragma mark -
#pragma mark --- reSetGuideState
-(void)reSetGuide:(NSString *)guide_name withState:(Guide_state_fuction)state
{
    QYGuide *guide = [QYGuideData getGuideByName:guide_name];
    guide.guide_state = state;
}


#pragma mark -
#pragma mark --- GuideViewCell - Delegate
-(void)showGuideDetail
{
    NSLog(@"  show - GuideDetail:  ");
    NSLog(@"self.editing : %d",self.editing);
    NSLog(@"self.showingDeleteConfirmation : %d",self.showingDeleteConfirmation);
    if(self.editing)
    {
        return;
    }
    
    
    [self performSelector:@selector(resetBackgroundColor:) withObject:nil afterDelay:0.1];
    if(self.delegate && [self.delegate respondsToSelector:@selector(guideViewCellSelectedDetail:)])
    {
        [self.delegate guideViewCellSelectedDetail:self];
    }
}
-(void)readGuide
{
    NSLog(@"  read - Guide:  ");
    NSLog(@"self.editing : %d",self.editing);
    NSLog(@"self.showingDeleteConfirmation : %d",self.showingDeleteConfirmation);
    if(self.editing)
    {
        return;
    }
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(guideViewCellSelectedReadGuide:)])
    {
        [self.delegate guideViewCellSelectedReadGuide:self];
    }
}
-(void)cancleDownload
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(guideViewCellCancleDownload:)])
    {
        [self.delegate guideViewCellCancleDownload:self];
    }
}



#pragma mark -
#pragma mark --- 保存正在下载的锦囊
-(void)saveGuideIsDownloading
{
    [QYGuideData cacheDownloadingGuide:_guide];
}




#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



@end
