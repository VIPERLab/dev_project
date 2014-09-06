//
//  GuideCoverCell.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideCoverCell.h"
#import "QYGuide.h"
#import "UIImageView+WebCache.h"
#import "QYGuideData.h"
#import "ObserverObject.h"


#define     positionY_downloadTimes     (ios7 ? 3:5)
#define     positionY_pages             (ios7 ? 3:5)
#define     positionY_updateTime        (ios7 ? 18:21)
#define     positionY_guideSize         (ios7 ? 18:21)



@implementation GuideCoverCell
@synthesize imageView_cover = _imageView_cover;
@synthesize view_backGround = _view_backGround;
@synthesize label_downloadTimes = _label_downloadTimes;
@synthesize label_updateTime = _label_updateTime;
@synthesize label_pages = _label_pages;
@synthesize label_guideSize = _label_guideSize;
@synthesize guide = _guide;
@synthesize delegate = _delegate;

-(void)dealloc
{
    QY_VIEW_RELEASE(_imageView_cover);
    QY_VIEW_RELEASE(_label_downloadTimes);
    QY_VIEW_RELEASE(_label_updateTime);
    QY_VIEW_RELEASE(_label_pages);
    QY_VIEW_RELEASE(_label_guideSize);
    QY_VIEW_RELEASE(_view_backGround);
    
    
    self.guide = nil;
    
    self.delegate = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        _imageView_cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, GuideCoverImageviewHeight)];
        _imageView_cover.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView_cover];
        
        
        _view_backGround = [[UIView alloc] initWithFrame:CGRectMake(0, _imageView_cover.frame.size.height - 40, _imageView_cover.frame.size.width, 40)];
        _view_backGround.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [_imageView_cover addSubview:_view_backGround];
        
        
        _label_downloadTimes = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_downloadTimes, 145, 20)];
        _label_downloadTimes.backgroundColor = [UIColor clearColor];
        _label_downloadTimes.textColor = [UIColor whiteColor];
        _label_downloadTimes.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        [_view_backGround addSubview:_label_downloadTimes];
        
        
        _label_pages = [[UILabel alloc] initWithFrame:CGRectMake(165, positionY_pages, 145, 20)];
        _label_pages.backgroundColor = [UIColor clearColor];
        _label_pages.textColor = [UIColor whiteColor];
        _label_pages.textAlignment = NSTextAlignmentRight;
        _label_pages.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        [_view_backGround addSubview:_label_pages];
        
        
        _label_updateTime = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_updateTime, 145, 20)];
        _label_updateTime.backgroundColor = [UIColor clearColor];
        _label_updateTime.textColor = [UIColor whiteColor];
        _label_updateTime.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        _label_updateTime.textAlignment = NSTextAlignmentLeft;
        [_view_backGround addSubview:_label_updateTime];
        
        
        
        _label_guideSize = [[UILabel alloc] initWithFrame:CGRectMake(165, positionY_guideSize, 145, 20)];
        _label_guideSize.backgroundColor = [UIColor clearColor];
        _label_guideSize.textColor = [UIColor whiteColor];
        _label_guideSize.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
        _label_guideSize.textAlignment = NSTextAlignmentRight;
        [_view_backGround addSubview:_label_guideSize];
        
    }
    return self;
}



#pragma mark -
#pragma mark --- initCellWithGuide
-(void)initCellWithGuide:(QYGuide *)guide
                finished:(GuideCoverCellInitSuccessBlock)successBlock
                  failed:(GuideCoverCellInitFailedBlock)failedBlock
{
    self.guide = guide;
    self.label_downloadTimes.text = [NSString stringWithFormat:@"下载次数：%@",guide.guideDownloadTimes];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *myDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[guide.guideUpdate_time doubleValue]]];
    [dateFormatter release];
    self.label_updateTime.text = [NSString stringWithFormat:@"更新日期：%@",myDateStr];
    if(guide.guidePages)
    {
        self.label_pages.text = [NSString stringWithFormat:@"页数：%@页",guide.guidePages];
    }
    else
    {
        self.label_pages.text = @"";
    }
    
    
    
    NSLog(@" guideCover  添加监听 ");
    //监听:
    if(_guide.obj_observe_cover)
    {
        //取消kvo注册:
        [_guide removeObserver:_guide.obj_observe_cover forKeyPath:@"progressValue"];
        [_guide removeObserver:_guide.obj_observe_cover forKeyPath:@"guide_state"];
    }
    self.guide.obj_observe_cover = self;
    [self.guide addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.guide addObserver:self forKeyPath:@"guide_state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    
    
    
    
    if(guide.guide_state == GuideWating_State)
    {
        self.label_guideSize.text = [NSString stringWithFormat:@"%@ / %.2f M",@"等待下载",[guide.guideSize floatValue]/1048576];
    }
    else if(guide.guide_state == GuideDownloading_State)
    {
        self.label_guideSize.text = [NSString stringWithFormat:@"%@ M / %.2f M",[NSString stringWithFormat:@"%.2f",guide.progressValue],[guide.guideSize floatValue]/1048576];
    }
    else
    {
        self.label_guideSize.text = [NSString stringWithFormat:@"大小：%.2f M",[guide.guideSize floatValue]/1048576];
    }
    
    
    NSString *coverStrUrl = [NSString stringWithFormat:@"%@/670_420.jpg?cover_updatetime=%@", guide.guideCoverImage_big, guide.guideUpdate_time];
    [self.imageView_cover setImageWithURL:[NSURL URLWithString:coverStrUrl] placeholderImage:[UIImage imageNamed:@"bg_detail_cover_default"] success:^(UIImage *image){
        
        if(self.guide.guide_state == GuideRead_State)
        {
            UIControl *control_readGuide = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.imageView_cover.frame.size.width, self.imageView_cover.frame.size.height)];
            self.imageView_cover.userInteractionEnabled = YES;
            [control_readGuide addTarget:self action:@selector(readGuide) forControlEvents:UIControlEventTouchUpInside];
            [self.imageView_cover addSubview:control_readGuide];
            [control_readGuide release];
        }
        
        successBlock(image);
    } failure:^(NSError *error){
        failedBlock();
    }];
    
}
-(void)readGuide
{
    if(self.guide.guide_state == GuideRead_State)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(readGuide)])
        {
            [self.delegate readGuideWhenClickPic];
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
    
    NSLog(@"  observeValueForKeyPath   ---  guideCover");
    
    if([keyPath isEqualToString:@"progressValue"])
    {
        self.label_guideSize.text = [NSString stringWithFormat:@"%@ M / %.2f M",[NSString stringWithFormat:@"%.2f",self.guide.progressValue*[self.guide.guideSize floatValue]/1048576],[self.guide.guideSize floatValue]/1048576];
    }
    
    else if([keyPath isEqualToString:@"guide_state"])
    {
        NSInteger newKey = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        NSInteger oldKey = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        
        if(self.guide.guide_state == GuideWating_State && newKey == 1 && oldKey == 0)
        {
            NSLog(@"  guide_state 发生了变化 [GuideCoverCell] 等待下载 ");
        }
        else if(self.guide.guide_state == GuideDownloading_State && newKey == 2 && oldKey == 1)
        {
            NSLog(@"  guide_state 发生了变化 [GuideCoverCell] 开始下载 ");
        }
        else if(self.guide.guide_state == GuideRead_State && newKey == 3 && oldKey == 2)
        {
            NSLog(@"  guide_state 发生了变化 [GuideCoverCell] 下载成功 ");
            
            self.label_guideSize.text = [NSString stringWithFormat:@"大小：%.2f M",[self.guide.guideSize floatValue]/1048576];
            
            
            [self download_Finished];
            
            
            UIControl *control_readGuide = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.imageView_cover.frame.size.width, self.imageView_cover.frame.size.height)];
            self.imageView_cover.userInteractionEnabled = YES;
            [control_readGuide addTarget:self action:@selector(readGuide) forControlEvents:UIControlEventTouchUpInside];
            [self.imageView_cover addSubview:control_readGuide];
            [control_readGuide release];

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
-(void)download_Finished
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(guideDownloadFinished)])
    {
        [self.delegate guideDownloadFinished];
    }
}


#pragma mark -
#pragma mark --- setSelected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
