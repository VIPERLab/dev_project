//
//  QYGuide.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-4.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
	GuideNoamal_State = 0,          //初始状态
	GuideWating_State = 1,          //等待下载状态
    GuideDownloading_State = 2,     //正在下载状态
    GuideRead_State = 3,            //阅读状态
    GuideDownloadFailed_State = 4   //下载失败的状态
} Guide_state_fuction;



@interface QYGuide : NSObject <NSCoding,NSCopying>
{
    NSString        *_guideId;                  //锦囊ID
    NSString        *_guideName;                //锦囊名称
    NSString        *_guideName_en;             //锦囊英文名
    NSString        *_guideName_pinyin;         //锦囊拼音
    NSString        *_guideCategory_id;         //锦囊分类ID
    NSString        *_guideCategory_name;       //锦囊分类名称 [所属大洲名称]
    NSString        *_guideCountry_id;          //国家ID
    NSString        *_guideCountry_name_cn;     //国家中文名
    NSString        *_guideCountry_name_en;     //国家英文名
    NSString        *_guideCountry_name_py;     //国家拼音
    NSString        *_guideCoverImage;          //封图
    NSString        *_guideCoverImage_big;      //大封图
    NSString        *_guideCover_updatetime;    //更新时间
    NSString        *_guideBriefinfo;           //简介
    NSString        *_guideFilePath;            //html文件URL
    NSString        *_guidePages;               //锦囊页数
    NSString        *_guideSize;                //PDF锦囊大小
    NSString        *_guideCatalog;             //目录
    NSString        *_guideCreate_time;         //创建时间
    NSString        *_guideUpdate_time;         //更新时间
    NSString        *_guideDownloadTimes;       //下载次数
    NSString        *_guideType;                //锦囊类型
    NSString        *_guideAuthor_id;           //作者ID
    NSString        *_guideAuthor_name;         //作者名
    NSString        *_guideAuthor_icon;         //作者用户头像链接
    NSString        *_guideAuthor_intro;        //作者自我介绍
    NSDictionary    *_guideData_iPhone;         //HTML锦囊信息_iPhone
    NSDictionary    *_guideData_iPad;           //HTML锦囊信息_iPad
    NSString        *_guide_relatedGuide_ids;   //关联其他锦囊ID
    NSString        *_guideUpdate_log;          //锦囊更新日志
    
    Guide_state_fuction       _guide_state;
    NSMutableArray  *_arrayCellData_onShow;
    
    UIProgressView  *_progressView;             //下载进度条
    float           _progressValue;             //已下载的进度
}


@property(nonatomic,retain) NSString        *guideId;                  //锦囊ID
@property(nonatomic,retain) NSString        *guideName;                //锦囊名称
@property(nonatomic,retain) NSString        *guideName_en;             //锦囊英文名
@property(nonatomic,retain) NSString        *guideName_pinyin;         //锦囊拼音
@property(nonatomic,retain) NSString        *guideCategory_id;         //锦囊分类ID
@property(nonatomic,retain) NSString        *guideCategory_name;       //锦囊分类名称 [所属大洲名称]
@property(nonatomic,retain) NSString        *guideCountry_id;          //国家ID
@property(nonatomic,retain) NSString        *guideCountry_name_cn;     //国家中文名
@property(nonatomic,retain) NSString        *guideCountry_name_en;     //国家英文名
@property(nonatomic,retain) NSString        *guideCountry_name_py;     //国家拼音
@property(nonatomic,retain) NSString        *guideCoverImage;          //封图
@property(nonatomic,retain) NSString        *guideCoverImage_big;      //大封图
@property(nonatomic,retain) NSString        *guideCover_updatetime;    //更新时间
@property(nonatomic,retain) NSString        *guideBriefinfo;           //简介
@property(nonatomic,retain) NSString        *guideFilePath;            //html文件URL
@property(nonatomic,retain) NSString        *guidePages;               //锦囊页数
@property(nonatomic,retain) NSString        *guideSize;                //PDF锦囊大小
@property(nonatomic,retain) NSString        *guideCatalog;             //目录
@property(nonatomic,retain) NSString        *guideCreate_time;         //创建时间
@property(nonatomic,retain) NSString        *guideUpdate_time;         //更新时间
@property(nonatomic,retain) NSString        *guideDownloadTimes;       //下载次数
@property(nonatomic,retain) NSString        *guideType;                //锦囊类型
@property(nonatomic,retain) NSString        *guideAuthor_id;           //作者ID
@property(nonatomic,retain) NSString        *guideAuthor_name;         //作者名
@property(nonatomic,retain) NSString        *guideAuthor_icon;         //作者用户头像链接
@property(nonatomic,retain) NSString        *guideAuthor_intro;        //作者自我介绍
@property(nonatomic,retain) NSDictionary    *guideData_iPhone;         //HTML锦囊信息_iPhone
@property(nonatomic,retain) NSDictionary    *guideData_iPad;           //HTML锦囊信息_iPad
@property(nonatomic,retain) NSString        *guide_relatedGuide_ids;   //关联其他锦囊ID
@property(nonatomic,retain) NSString        *guideUpdate_log;          //锦囊更新日志
@property(nonatomic,retain) NSString        *download_type;            //下载或更新
@property(nonatomic,assign) Guide_state_fuction guide_state;
@property(nonatomic,retain) NSMutableArray  *arrayCellData_onShow;
@property(nonatomic,retain) NSMutableArray  *array_guide;
@property(nonatomic,assign) float           progressValue;
@property(nonatomic,retain) NSMutableArray  *array_allGuide;
@property(nonatomic,retain) id  obj_observe;
@property(nonatomic,retain) id  obj_observe_cover;
@property(nonatomic,retain) id  obj_observe_homepage_left;
@property(nonatomic,retain) id  obj_observe_homepage_right;











//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
@property (retain, nonatomic) NSString *guideNameEn;
@property (retain, nonatomic) NSString *guideNamePy;
@property (retain, nonatomic) NSNumber *guideCategoryId;
@property (retain, nonatomic) NSString *guideCategoryTitle;
@property (retain, nonatomic) NSNumber *guideCountryId;
@property (retain, nonatomic) NSString *guideCountryName;
@property (retain, nonatomic) NSString *guideCountryNameEn;
@property (retain, nonatomic) NSString *guideCountryNamePy;
@property (retain, nonatomic) NSString *guideBigCoverImage;
@property (retain, nonatomic) NSString *guideBriefInfo;
@property (retain, nonatomic) NSNumber *guidePageCount;
@property (retain, nonatomic) NSNumber *guideCreateTime;
@property (retain, nonatomic) NSNumber *guideUpdateTime;
@property (retain, nonatomic) NSNumber *guideDownloadCount;
@property (retain, nonatomic) NSNumber *guideCoverUpdateTime;
@property (retain, nonatomic) NSNumber *authorId;
@property (retain, nonatomic) NSString *authorName;
@property (retain, nonatomic) NSString *authorIcon;
@property (retain, nonatomic) NSString *authorIntroduction;
@property (retain, nonatomic) NSArray *otherGuideArray;
@property (assign, nonatomic) BOOL deleteMode;
@property (retain, nonatomic) NSString *mobileFilePath;
@property (retain, nonatomic) NSNumber *mobileFileSize;
@property (retain, nonatomic) NSNumber *mobilePageCount;
@property (retain, nonatomic) NSNumber *mobileUpdateTime;
@property (retain, nonatomic) NSString*   updateLog;
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]





@end

