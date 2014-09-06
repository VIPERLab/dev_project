//
//  ShareViewController.h
//  KwSing
//
//  Created by Qian Hu on 12-8-24.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "SongInfo.h"
#import "AudioEffectType.h"

/*
大致流程说明：
    页面功能为保存、上传、分享；
    来源：播放页面点击分享——分享作品
         录制完成页面点击上传——（保存）上传
         我的页面点击上传/分享——上传/分享
 
    通过isShare区别上传和分享，上传需要设置songInfo，index（录制完成为0），isVideo,和音效effect,和伴奏音量和自唱音量；
                            分享只需要设置shareText和isShare
    shareText&shareURL————上传的shareText在本页面中自动生成，分享的需要设置（根据来源的不同区别是“我唱了”还是“我听到了”）
 */
@interface ShareViewController : UIViewController
{
    BOOL _isShare;                  //分享还是上传 默认false
    int  _songIndex;                //歌曲index，后期处理页作品为0
    BOOL _isVideo;                  //音频还是视频,默认音频
    
    CRecoSongInfo *_shareSongInfo;
    
    NSString *_shareText;
    NSString *_shareURL;
}
@property (retain,nonatomic) NSString* shareText;
@property (retain,nonatomic) NSString* shareURL;
@property (nonatomic) BOOL isShare;
//@property (nonatomic) BOOL isUploaded;

//对于没有保存的作品，需要设置的属性
-(void)setShareSongInfo:(CRecoSongInfo*)songInfo index:(int)songIndex isVideo:(BOOL)bVideo;
//对于已经保存好了，需要设置的属性
-(void)setShareSongInfo:(CRecoSongInfo *)songInfo index:(int)songIndex;
@end
