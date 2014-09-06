//
//  GuideCell.m
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GuideCell.h"
#import "QYGuide.h"
#import "UIImageView+WebCache.h"
#import "CustomProessView.h"
#import "QYGuideData.h"
#import "MyControl.h"
#import "ObserverObject.h"


#define     offsetY     40/2    //进度条距离下边界的高度
#define     positionX   40/2    //进度条距离左边界的位置



@implementation GuideCell
@synthesize imageView_left = _imageView_left;
@synthesize imageView_right = _imageView_right;
@synthesize delegate = _delegate;
@synthesize section;
@synthesize indexPath_left;
@synthesize indexPath_right;
@synthesize progressView_left = _progressView_left;
@synthesize progressView_right = _progressView_right;
@synthesize guide_left = _guide_left;
@synthesize guide_right = _guide_right;
@synthesize imageView_read_left = _imageView_read_left;
@synthesize imageView_update_left = _imageView_update_left;
@synthesize imageView_read_right = _imageView_read_right;
@synthesize imageView_update_right = _imageView_update_right;
@synthesize labelState_left = _labelState_left;
@synthesize labelState_right = _labelState_right;


-(void)dealloc
{
    QY_VIEW_RELEASE(_control_left);
    QY_VIEW_RELEASE(_control_right);
    QY_VIEW_RELEASE(_labelState_left);
    QY_VIEW_RELEASE(_labelState_right);
    
    
    self.imageView_right = nil;
    self.imageView_left = nil;
    self.indexPath_left = nil;
    self.indexPath_right = nil;
    self.progressView_left = nil;
    self.progressView_right = nil;
    self.guide_left = nil;
    self.guide_right = nil;
    self.imageView_update_left = nil;
    self.imageView_read_left = nil;
    self.imageView_update_right = nil;
    self.imageView_read_right = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _imageView_left = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 220/2, 330/2)];
        _imageView_left.backgroundColor = [UIColor clearColor];
        _imageView_left.layer.masksToBounds = YES;
        [_imageView_left.layer setCornerRadius:2];
        [self addSubview:_imageView_left];
        
        
        
        _viewMask_left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _imageView_left.frame.size.width, _imageView_left.frame.size.height)];
        _viewMask_left.backgroundColor = [UIColor clearColor];
        [_imageView_left addSubview:_viewMask_left];
        
        
        
        _control_left = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, _imageView_left.frame.size.width, _imageView_left.frame.size.height) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        _control_left.backgroundColor = [UIColor clearColor];
        [_imageView_left addSubview:_control_left];
        [_control_left addTarget:self action:@selector(clickLeft) forControlEvents:UIControlEventTouchUpInside];
        
        
        if(ios7)
        {
            _progressView_left = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            float default_height = _progressView_left.frame.size.height;
            _progressView_left.frame = CGRectMake(positionX, _imageView_left.frame.size.height-default_height-offsetY, _imageView_left.frame.size.width-2*positionX, default_height);
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
            _progressView_left.transform = transform;
            _progressView_left.hidden = YES;
            [_imageView_left addSubview:_progressView_left];
            _progressView_left.trackImage = [UIImage imageNamed:@"bg_progress"];
            _progressView_left.progressTintColor = [UIColor colorWithRed:51/255. green:181/255. blue:229/255. alpha:1];
        }
        else
        {
            _progressView_left = [[CustomProessView alloc] initWithFrame:CGRectMake(positionX, _imageView_left.frame.size.height-4-offsetY, _imageView_left.frame.size.width-2*positionX, 4)];
            _progressView_left.progressViewStyle = UIProgressViewStyleDefault;
            [_progressView_left setTintColorWithImage:[UIImage imageNamed:@"progress"]];
            [_progressView_left setBackGroundTintColorWithImage:[UIImage imageNamed:@"bg_progress"]];
            _progressView_left.hidden = YES;
            [_imageView_left addSubview:_progressView_left];
        }
        
        
        _imageView_update_left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        _imageView_update_left.image = [UIImage imageNamed:@"guide_view_update"];
        _imageView_update_left.hidden = YES;
        [_imageView_left addSubview:_imageView_update_left];
        _imageView_read_left = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView_left.frame.size.width-29, _imageView_left.frame.size.height-29, 29, 29)];
        _imageView_read_left.backgroundColor = [UIColor clearColor];
        _imageView_read_left.image = [UIImage imageNamed:@"read_state"];
        _imageView_read_left.hidden = YES;
        [_imageView_left addSubview:_imageView_read_left];
        
        _labelState_left = [[UILabel alloc] initWithFrame:CGRectMake(0, _progressView_left.frame.origin.y-10-26, _imageView_left.frame.size.width, 26)];
        _labelState_left.backgroundColor = [UIColor clearColor];
        _labelState_left.textColor = [UIColor whiteColor];
        _labelState_left.textAlignment = NSTextAlignmentCenter;
        _labelState_left.font = [UIFont systemFontOfSize:12];
        [_imageView_left addSubview:_labelState_left];
        
        
        
        
        
        _imageView_right = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView_left.frame.origin.x+_imageView_left.frame.size.width+10, 0, 220/2, 330/2)];
        _imageView_right.backgroundColor = [UIColor clearColor];
        _imageView_right.layer.masksToBounds = YES;
        [_imageView_right.layer setCornerRadius:2];
        [self addSubview:_imageView_right];
        
        
        _viewMask_right = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _imageView_right.frame.size.width, _imageView_right.frame.size.height)];
        _viewMask_right.backgroundColor = [UIColor clearColor];
        [_imageView_right addSubview:_viewMask_right];
        
        
        _control_right = [[MyControl alloc] initWithFrame:CGRectMake(0, 0, _imageView_left.frame.size.width, _imageView_left.frame.size.height) andBackGroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        _control_right.backgroundColor = [UIColor clearColor];
        [_imageView_right addSubview:_control_right];
        [_control_right addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
        
        
        if(ios7)
        {
            _progressView_right = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            float default_height = _progressView_right.frame.size.height;
            _progressView_right.frame = CGRectMake(positionX, _imageView_right.frame.size.height-default_height-offsetY, _imageView_right.frame.size.width-2*positionX, default_height);
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
            _progressView_right.transform = transform;
            _progressView_right.hidden = YES;
            [_imageView_right addSubview:_progressView_right];
            _progressView_right.trackImage = [UIImage imageNamed:@"bg_progress"];
            //_progressView_right.progressImage = [UIImage imageNamed:@"mid"];
            _progressView_right.progressTintColor = [UIColor colorWithRed:51/255. green:181/255. blue:229/255. alpha:1];
        }
        else
        {
            _progressView_right = [[CustomProessView alloc] initWithFrame:CGRectMake(positionX, _imageView_right.frame.size.height-4-offsetY, _imageView_right.frame.size.width-2*positionX, 4)];
            //_progressView_right = [[CustomProessView alloc] initWithFrame:CGRectMake(0, 60, _imageView_right.frame.size.width, 4)];
            _progressView_right.progressViewStyle = UIProgressViewStyleDefault;
            [_progressView_right setTintColorWithImage:[UIImage imageNamed:@"progress"]];
            [_progressView_right setBackGroundTintColorWithImage:[UIImage imageNamed:@"bg_progress"]];
            _progressView_right.hidden = YES;
            [_imageView_right addSubview:_progressView_right];
        }
        
        _imageView_update_right = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        _imageView_update_right.image = [UIImage imageNamed:@"guide_view_update"];
        _imageView_update_right.hidden = YES;
        [_imageView_right addSubview:_imageView_update_right];
        _imageView_read_right = [[UIImageView alloc] initWithFrame:CGRectMake(_imageView_right.frame.size.width-29, _imageView_right.frame.size.height-29, 29, 29)];
        _imageView_read_right.backgroundColor = [UIColor clearColor];
        _imageView_read_right.image = [UIImage imageNamed:@"read_state"];
        _imageView_read_right.hidden = YES;
        [_imageView_right addSubview:_imageView_read_right];
        
        _labelState_right = [[UILabel alloc] initWithFrame:CGRectMake(0, _progressView_right.frame.origin.y-10-26, _imageView_right.frame.size.width, 26)];
        _labelState_right.backgroundColor = [UIColor clearColor];
        _labelState_right.textColor = [UIColor whiteColor];
        _labelState_right.textAlignment = NSTextAlignmentCenter;
        _labelState_right.font = [UIFont systemFontOfSize:12];
        [_imageView_right addSubview:_labelState_right];
        _labelState_right.text = @" FUCK FUCK";
        
    }
    return self;
}
-(void)initWithData:(NSArray *)array atIndexPath:(NSIndexPath *)indexPath_in
{
    if(!array)
    {
        return;
    }
    _imageView_left.hidden = YES;
    _imageView_right.hidden = YES;
    _imageView_left.userInteractionEnabled = NO;
    _imageView_right.userInteractionEnabled = NO;
    _progressView_left.hidden = YES;
    _progressView_right.hidden = YES;
    _imageView_update_left.hidden = YES;
    _imageView_update_right.hidden = YES;
    _imageView_read_left.hidden = YES;
    _imageView_read_right.hidden = YES;
    _viewMask_left.backgroundColor = [UIColor clearColor];
    _viewMask_right.backgroundColor = [UIColor clearColor];
    
    
    
    
    //左侧锦囊:
    NSInteger position_cell = indexPath_in.row * 2;
    if(array.count > position_cell)
    {
        QYGuide *guide = [array objectAtIndex:position_cell];
        if(guide && [guide isMemberOfClass:[QYGuide class]])
        {
            _imageView_left.hidden = NO;
            self.guide_left = guide;
            self.indexPath_left = [NSIndexPath indexPathForRow:position_cell inSection:indexPath_in.section];
            self.imageView_left.userInteractionEnabled = YES;
            NSString *imageUrl = [NSString stringWithFormat:@"%@/260_390.jpg?cover_updatetime=%@",guide.guideCoverImage, guide.guideCover_updatetime];
            [self.imageView_left setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"guideCell_default"]];
            _imageView_left.layer.masksToBounds = YES;
            [_imageView_left.layer setCornerRadius:2];
            
            
            
            
            if(guide.guide_state == GuideRead_State)
            {
                _progressView_left.hidden = YES;
                _imageView_read_left.hidden = NO;
                _viewMask_left.backgroundColor = [UIColor clearColor];
                _labelState_left.text = @"";
            }
            else if(guide.guide_state == GuideNoamal_State)
            {
                _progressView_left.hidden = YES;
                _imageView_read_left.hidden = YES;
                _viewMask_left.backgroundColor = [UIColor clearColor];
                _labelState_left.text = @"";
            }
            else if(guide.guide_state == GuideWating_State)
            {
                _progressView_left.hidden = NO;
                _imageView_read_left.hidden = YES;
                _viewMask_left.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
                _labelState_left.text = @"等待下载";
                _progressView_left.progress = 0.;
            }
            else if(guide.guide_state == GuideDownloading_State)
            {
                _progressView_left.hidden = NO;
                _imageView_read_left.hidden = YES;
                _viewMask_left.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
                _labelState_left.text = @"下载中...";
            }
            else if(guide.guide_state == GuideDownloadFailed_State)
            {
                _progressView_left.hidden = YES;
                _imageView_read_left.hidden = YES;
                _viewMask_left.backgroundColor = [UIColor clearColor];
                _labelState_left.text = @"";
            }
            
            
            
            //判断是否显示需要更新的icon:
            for(QYGuide *guide_ in [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated])
            {
                if([guide.guideName isEqualToString:guide_.guideName])
                {
                    _imageView_update_left.hidden = NO;
                    break;
                }
            }
            
            
            
            //*** 添加监听:
            if(guide.obj_observe_homepage_left)
            {
                //取消kvo注册:
                [guide removeObserver:guide.obj_observe_homepage_left forKeyPath:@"progressValue"];
                [guide removeObserver:guide.obj_observe_homepage_left forKeyPath:@"guide_state"];
            }
            guide.obj_observe_homepage_left = self;
            [guide addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            [guide addObserver:self forKeyPath:@"guide_state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            
            
            
            
//            //2014.04.21
//            id obj = [[[[QYGuideData sharedQYGuideData] obj_observer] dic_addObserver] objectForKey:_guide_left.guideName];
//            if(obj)
//            {
//                [[[QYGuideData sharedQYGuideData] obj_observer] removeObserver:obj forKeyPath:@"progress"];
//                [[[QYGuideData sharedQYGuideData] obj_observer] removeObserver:obj forKeyPath:@"status"];
//            }
//            [[[[QYGuideData sharedQYGuideData] obj_observer] dic_addObserver] setObject:self forKey:_guide_left.guideName];
//            [[[QYGuideData sharedQYGuideData] obj_observer] addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//            [[[QYGuideData sharedQYGuideData] obj_observer] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            
        }
    }
    
    
    //右侧锦囊:
    position_cell++;
    if(array.count <= position_cell) //不存在右边的锦囊
    {
        _imageView_right.hidden = YES;
    }
    else if(array.count > position_cell)
    {
        QYGuide *guide = [array objectAtIndex:position_cell];
        if(guide)
        {
            _imageView_right.hidden = NO;
            self.guide_right = guide;
            self.indexPath_right = [NSIndexPath indexPathForRow:position_cell inSection:indexPath_in.section];
            self.imageView_right.userInteractionEnabled = YES;
            NSString *imageUrl = [NSString stringWithFormat:@"%@/260_390.jpg?cover_updatetime=%@",guide.guideCoverImage, guide.guideCover_updatetime];
            [self.imageView_right setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"guideCell_default"]];
            
            
            
            
            if(guide.guide_state == GuideRead_State)
            {
                //NSLog(@" --- 阅读状态 : %@",guide.guideName);
                _progressView_right.hidden = YES;
                _imageView_read_right.hidden = NO;
                _viewMask_right.backgroundColor = [UIColor clearColor];
                _labelState_right.text = @"";
            }
            else if(guide.guide_state == GuideNoamal_State)
            {
                //NSLog(@" --- 正常状态 : %@",guide.guideName);
                _progressView_right.hidden = YES;
                _imageView_read_right.hidden = YES;
                _viewMask_right.backgroundColor = [UIColor clearColor];
                _labelState_right.text = @"";
            }
            else if(guide.guide_state == GuideWating_State)
            {
                //NSLog(@" --- 等待状态 : %@",guide.guideName);
                _progressView_right.hidden = NO;
                _imageView_read_right.hidden = YES;
                _viewMask_right.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
                _labelState_right.text = @"等待下载";
                _progressView_right.progress = 0.;
            }
            
            else if(guide.guide_state == GuideDownloading_State)
            {
                //NSLog(@" --- 正在下载状态 : %@",guide.guideName);
                _progressView_right.hidden = NO;
                _imageView_read_right.hidden = YES;
                _viewMask_right.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
                _labelState_right.text = @"下载中...";
            }
            else if(guide.guide_state == GuideDownloadFailed_State)
            {
                //NSLog(@" --- 下载失败状态 : %@",guide.guideName);
                _progressView_right.hidden = YES;
                _imageView_read_right.hidden = YES;
                _viewMask_right.backgroundColor = [UIColor clearColor];
                _labelState_right.text = @"";
            }
            
            
            
            
            //判断是否显示需要更新的icon:
            for(QYGuide *guide_ in [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated])
            {
                if([guide.guideName isEqualToString:guide_.guideName])
                {
                    _imageView_update_right.hidden = NO;
                    break;
                }
            }
            
            
            
            //*** 添加监听:
            if(guide.obj_observe_homepage_right)
            {
                //取消kvo注册:
                [guide removeObserver:guide.obj_observe_homepage_right forKeyPath:@"progressValue"];
                [guide removeObserver:guide.obj_observe_homepage_right forKeyPath:@"guide_state"];
            }
            guide.obj_observe_homepage_right = self;
            [guide addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            [guide addObserver:self forKeyPath:@"guide_state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            
            
            
            
            
            
//            //2014.04.21
//            id obj = [[[[QYGuideData sharedQYGuideData] obj_observer] dic_addObserver_guidecell] objectForKey:_guide_left.guideName];
//            if(obj)
//            {
//                [[[QYGuideData sharedQYGuideData] obj_observer] removeObserver:obj forKeyPath:@"progress"];
//                [[[QYGuideData sharedQYGuideData] obj_observer] removeObserver:obj forKeyPath:@"status"];
//            }
//            [[[[QYGuideData sharedQYGuideData] obj_observer] dic_addObserver_guidecell] setObject:self forKey:_guide_left.guideName];
//            [[[QYGuideData sharedQYGuideData] obj_observer] addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//            [[[QYGuideData sharedQYGuideData] obj_observer] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            
        }
    }
}
-(void)clickLeft
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickAtIndexPath:)])
    {
        [self.delegate clickAtIndexPath:self.indexPath_left];
    }
}
-(void)clickRight
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickAtIndexPath:)])
    {
        [self.delegate clickAtIndexPath:self.indexPath_right];
    }
}





#pragma mark -
#pragma mark --- 监听的方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
//    ObserverObject *obj = object;
//    NSString *name = [obj.dic_progress objectForKey:@"observering"];
//    NSLog(@" 正在监听的名称: %@",name);
//    
//    if([name isEqualToString:self.guide_left.guideName] || [name isEqualToString:self.guide_right.guideName])
//    {
//        if([keyPath isEqualToString:@"progress"])
//        {
//            NSLog(@" ［监听］ progress 正在发生变化");
//            
//            
//            if(self.guide_left && [name isEqualToString:self.guide_left.guideName])
//            {
//                NSLog(@" 左边");
//                NSLog(@"  self.guide_left.guideName : %@",self.guide_left.guideName);
//                self.progressView_left.progress = obj.progress;
//            }
//            else if (self.guide_right && [name isEqualToString:self.guide_right.guideName])
//            {
//                NSLog(@" 右边");
//                NSLog(@"  self.guide_right.guideName : %@",self.guide_right.guideName);
//                self.progressView_right.progress = obj.progress;
//            }
//        }
//        else if ([keyPath isEqualToString:@"status"])
//        {
//            NSLog(@" ［监听］ status 正在发生变化");
//            
//            NSInteger newKey = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
//            NSInteger oldKey = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
//            
//            
//            if(self.guide_left && [name isEqualToString:self.guide_left.guideName])
//            {
//                NSLog(@" self.guide_left.guideName: %@",self.guide_left.guideName);
//                NSLog(@" 左边的状态发生了变化");
//                NSLog(@" 现在的状态是: %d",obj.status);
//                NSLog(@" newkey : %d",newKey);
//                NSLog(@" oldKey : %d",oldKey);
//                
//                
//                if(obj.status == Wating_status)
//                {
//                    NSLog(@" --- freshLeft 等待下载 --- ");
//                    self.progressView_left.progress = 0.;
//                    self.guide_left.guide_state = GuideWating_State;
//                }
//                
//                else if(obj.status == Wating_status)
//                {
//                    NSLog(@" --- freshLeft 等待下载 --- ");
//                    self.labelState_left.text = @"等待下载";
//                    self.progressView_left.progress = 0.;
//                    self.guide_left.guide_state = GuideWating_State;
//                }
//                
//                else if(obj.status == Downloading_status)
//                {
//                    NSLog(@" --- freshLeft 正在下载 --- ");
//                    self.labelState_left.text = @"下载中...";
//                    self.guide_left.guide_state = GuideDownloading_State;
//                }
//                
//                else if(obj.status == Read_status)
//                {
//                    NSLog(@" --- freshLeftWhenFinished --- ");
//                    self.guide_left.guide_state = GuideRead_State;
//                    [self freshLeftWhenFinished];
//                }
//                
//                
//            }
//            else if (self.guide_right && [name isEqualToString:self.guide_right.guideName])
//            {
//                NSLog(@" 右边的状态发生了变化");
//                NSLog(@" self.guide_right.guideName: %@",self.guide_right.guideName);
//                
//                if(obj.status == Wating_status)
//                {
//                    NSLog(@" --- freshRight 等待下载 --- ");
//                    self.progressView_right.progress = 0;
//                    self.guide_right.guide_state = GuideWating_State;
//                }
//                
//                else if(obj.status == Wating_status)
//                {
//                    NSLog(@" --- freshRight 等待下载 --- ");
//                    self.labelState_right.text = @"等待下载";
//                    self.progressView_right.progress = 0;
//                    self.guide_right.guide_state = GuideWating_State;
//                }
//                
//                else if(obj.status == Downloading_status)
//                {
//                    NSLog(@" --- freshRight 正在下载 --- ");
//                    self.labelState_right.text = @"下载中...";
//                    self.guide_right.guide_state = GuideDownloading_State;
//                }
//                
//                else if(obj.status == Downloading_status)
//                {
//                    NSLog(@" --- freshRight 正在下载 --- ");
//                    self.labelState_right.text = @"下载中...";
//                    self.guide_right.guide_state = GuideDownloading_State;
//                }
//                
//                else if(obj.status == Read_status)
//                {
//                    NSLog(@" --- freshRightWhenFinished --- ");
//                    self.guide_right.guide_state = GuideRead_State;
//                    [self freshRightWhenFinished];
//                }
//                
//            }
//        }
//    }
//    
    
    
    
    
    
    
    
    
    
    
    if([keyPath isEqualToString:@"progressValue"])
    {
        if([object isEqual:self.guide_left])
        {
            if(_guide_left.progressValue - 0 == 0.)
            {
                return;
            }
            
            self.progressView_left.progress = _guide_left.progressValue;
        }
        else if ([object isEqual:self.guide_right])
        {
            if(_guide_right.progressValue - 0 == 0.)
            {
                return;
            }
            
            self.progressView_right.progress = _guide_right.progressValue;
        }
    }
    
    
    
    else if([keyPath isEqualToString:@"guide_state"])
    {
        NSInteger newKey = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        NSInteger oldKey = [[change objectForKey:NSKeyValueChangeOldKey] intValue];

        if([object isEqual:self.guide_left])
        {
            if(_guide_left.guide_state == GuideWating_State && newKey == 1 && oldKey == 0)
            {
                NSLog(@" --- freshLeft 等待下载 --- ");
                self.progressView_left.progress = 0.;
            }
            
            else if(_guide_left.guide_state == GuideWating_State && newKey == 1 && oldKey == 4)
            {
                NSLog(@" --- freshLeft 等待下载 --- ");
                _labelState_left.text = @"等待下载";
                self.progressView_left.progress = 0.;
            }
            
            else if(_guide_left.guide_state == GuideDownloading_State && newKey == 2 && oldKey == 4)
            {
                NSLog(@" --- freshLeft 正在下载 --- ");
                _labelState_left.text = @"下载中...";
            }
            
            else if(_guide_left.guide_state == GuideDownloading_State && newKey == 2 && oldKey == 1)
            {
                NSLog(@" --- freshLeft 正在下载 --- ");
                _labelState_left.text = @"下载中...";
            }
            
            else if(_guide_left.guide_state == GuideRead_State && newKey == 3 && oldKey == 2)
            {
                NSLog(@" --- freshLeftWhenFinished --- ");
                [self freshLeftWhenFinished];
            }
        }
        
        else if ([object isEqual:self.guide_right])
        {
            NSLog(@" observe(guide_state) : guide_right");
            
            if(_guide_right.guide_state == GuideWating_State && newKey == 1 && oldKey == 0)
            {
                NSLog(@" --- freshRight 等待下载 --- ");
                self.progressView_right.progress = 0;
            }
            
            else if(_guide_right.guide_state == GuideWating_State && newKey == 1 && oldKey == 4)
            {
                NSLog(@" --- freshRight 等待下载 --- ");
                _labelState_right.text = @"等待下载";
                self.progressView_right.progress = 0;
            }
            
            else if(_guide_right.guide_state == GuideDownloading_State && newKey == 2 && oldKey == 4)
            {
                NSLog(@" --- freshRight 正在下载 --- ");
                _labelState_right.text = @"下载中...";
            }
            
            else if(_guide_right.guide_state == GuideDownloading_State && newKey == 2 && oldKey == 1)
            {
                NSLog(@" --- freshRight 正在下载 --- ");
                _labelState_right.text = @"下载中...";
            }
            
            else if(_guide_right.guide_state == GuideRead_State && newKey == 3 && oldKey == 2)
            {
                NSLog(@" --- freshRightWhenFinished --- ");
                [self freshRightWhenFinished];
            }
        }
    }
    
    
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
-(void)freshLeftWhenFinished
{
    NSLog(@"  刷新Left:  self.guide_left - guideName : %@",self.guide_left.guideName);
    NSLog(@" self.guide_left : %@",self.guide_left);
    NSLog(@" self.guide_left.guide_state : %d",self.guide_left.guide_state);
    
    
    self.progressView_left.hidden = YES;
    self.imageView_read_left.hidden = NO;
    _viewMask_left.backgroundColor = [UIColor clearColor];
    self.labelState_left.text = @"";
    self.progressView_left.progress = 0;
}
-(void)freshRightWhenFinished
{
    NSLog(@"    刷新Right");
    NSLog(@"    self.guide_right.guideName : %@",self.guide_right.guideName);
    
    
    self.progressView_right.hidden = YES;
    self.imageView_read_right.hidden = NO;
    _viewMask_right.backgroundColor = [UIColor clearColor];
    self.labelState_right.text = @"";
    self.progressView_right.progress = 0;
}



#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end

