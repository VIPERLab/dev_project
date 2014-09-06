//
//  QYGuide.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-4.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QYGuide.h"
#import "QYAPIClient.h"
#import "CacheData.h"
#import "FilePath.h"





@implementation QYGuide

@synthesize guideId = _guideId;
@synthesize guideName = _guideName;
@synthesize guideName_en = _guideName_en;
@synthesize guideName_pinyin = _guideName_pinyin;
@synthesize guideCategory_id = _guideCategory_id;
@synthesize guideCategory_name = _guideCategory_name;
@synthesize guideCountry_id = _guideCountry_id;
@synthesize guideCountry_name_cn = _guideCountry_name_cn;
@synthesize guideCountry_name_en = _guideCountry_name_en;
@synthesize guideCountry_name_py = _guideCountry_name_py;
@synthesize guideCoverImage = _guideCoverImage;
@synthesize guideCoverImage_big = _guideCoverImage_big;
@synthesize guideCover_updatetime = _guideCover_updatetime;
@synthesize guideBriefinfo = _guideBriefinfo;
@synthesize guideFilePath = _guideFilePath;
@synthesize guidePages = _guidePages;
@synthesize guideSize = _guideSize;
@synthesize guideCatalog = _guideCatalog;
@synthesize guideCreate_time = _guideCreate_time;
@synthesize guideUpdate_time = _guideUpdate_time;
@synthesize guideDownloadTimes = _guideDownloadTimes;
@synthesize guideType = _guideType;
@synthesize guideAuthor_id = _guideAuthor_id;
@synthesize guideAuthor_name = _guideAuthor_name;
@synthesize guideAuthor_icon = _guideAuthor_icon;
@synthesize guideAuthor_intro = _guideAuthor_intro;
@synthesize guideData_iPhone = _guideData_iPhone;
@synthesize guideData_iPad = _guideData_iPad;
@synthesize guide_relatedGuide_ids = _guide_relatedGuide_ids;
@synthesize guideUpdate_log = _guideUpdate_log;
@synthesize guide_state = _guide_state;
@synthesize arrayCellData_onShow = _arrayCellData_onShow;
@synthesize progressValue = _progressValue;
@synthesize download_type;
@synthesize obj_observe;
@synthesize obj_observe_cover;
@synthesize obj_observe_homepage_left;
@synthesize obj_observe_homepage_right;










//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
@synthesize guideNameEn;
@synthesize guideNamePy;
@synthesize guideCategoryId;
@synthesize guideCategoryTitle;
@synthesize guideCountryId;
@synthesize guideCountryName;
@synthesize guideCountryNameEn;
@synthesize guideCountryNamePy;
@synthesize guideBigCoverImage;
@synthesize guideBriefInfo;
@synthesize guidePageCount;
@synthesize guideCreateTime;
@synthesize guideUpdateTime;
@synthesize guideDownloadCount;
@synthesize guideCoverUpdateTime;
@synthesize authorId;
@synthesize authorName;
@synthesize authorIcon;
@synthesize authorIntroduction;
@synthesize otherGuideArray;
@synthesize deleteMode;
@synthesize mobileFilePath;
@synthesize mobileFileSize;
@synthesize mobilePageCount;
@synthesize mobileUpdateTime;
@synthesize updateLog;
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
//********************************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]













-(void)dealloc
{
    self.guideId = nil;
    self.guideName = nil;
    self.guideName_en = nil;
    self.guideName_pinyin = nil;
    self.guideCategory_id = nil;
    self.guideCategory_name = nil;
    self.guideCountry_id = nil;
    self.guideCountry_name_cn = nil;
    self.guideCountry_name_en = nil;
    self.guideCountry_name_py = nil;
    self.guideCoverImage = nil;
    self.guideCoverImage_big = nil;
    self.guideCover_updatetime = nil;
    self.guideBriefinfo = nil;
    self.guideFilePath = nil;
    self.guidePages = nil;
    self.guideSize = nil;
    self.guideCatalog = nil;
    self.guideCreate_time = nil;
    self.guideUpdate_time = nil;
    self.guideDownloadTimes = nil;
    self.guideType = nil;
    self.guideAuthor_id = nil;
    self.guideAuthor_name = nil;
    self.guideAuthor_icon = nil;
    self.guideAuthor_intro = nil;
    self.guideData_iPhone = nil;
    self.guideData_iPad = nil;
    self.guide_relatedGuide_ids = nil;
    self.guideUpdate_log = nil;
    self.download_type = nil;
    
    if(self.obj_observe)
    {
        [self removeObserver:self.obj_observe forKeyPath:@"progressValue"];
        [self removeObserver:self.obj_observe forKeyPath:@"guide_state"];
        self.obj_observe = nil;
    }
    
    if(self.obj_observe_cover)
    {
        [self removeObserver:self.obj_observe_cover forKeyPath:@"progressValue"];
        [self removeObserver:self.obj_observe_cover forKeyPath:@"guide_state"];
        self.obj_observe_cover = nil;
    }
    
    if(self.obj_observe_homepage_left)
    {
        [self removeObserver:self.obj_observe_homepage_left forKeyPath:@"progressValue"];
        [self removeObserver:self.obj_observe_homepage_left forKeyPath:@"guide_state"];
        self.obj_observe_homepage_left = nil;
    }
    
    if(self.obj_observe_homepage_right)
    {
        [self removeObserver:self.obj_observe_homepage_right forKeyPath:@"progressValue"];
        [self removeObserver:self.obj_observe_homepage_right forKeyPath:@"guide_state"];
        self.obj_observe_homepage_right = nil;
    }
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.guideId = [aDecoder decodeObjectForKey:@"guideId"];
        self.guideName = [aDecoder decodeObjectForKey:@"guideName"];
        self.guideName_en = [aDecoder decodeObjectForKey:@"guideName_en"];
        self.guideName_pinyin = [aDecoder decodeObjectForKey:@"guideName_pinyin"];
        self.guideCategory_id = [aDecoder decodeObjectForKey:@"guideCategory_id"];
        self.guideCategory_name = [aDecoder decodeObjectForKey:@"guideCategory_name"];
        self.guideCountry_id = [aDecoder decodeObjectForKey:@"guideCountry_id"];
        self.guideCountry_name_cn = [aDecoder decodeObjectForKey:@"guideCountry_name_cn"];
        self.guideCountry_name_en = [aDecoder decodeObjectForKey:@"guideCountry_name_en"];
        self.guideCountry_name_py = [aDecoder decodeObjectForKey:@"guideCountry_name_py"];
        self.guideCoverImage = [aDecoder decodeObjectForKey:@"guideCoverImage"];
        self.guideCoverImage_big = [aDecoder decodeObjectForKey:@"guideCoverImage_big"];
        self.guideCover_updatetime = [aDecoder decodeObjectForKey:@"guideCover_updatetime"];
        self.guideBriefinfo = [aDecoder decodeObjectForKey:@"guideBriefinfo"];
        self.guideFilePath = [aDecoder decodeObjectForKey:@"guideFilePath"];
        self.guidePages = [aDecoder decodeObjectForKey:@"guidePages"];
        self.guideSize = [aDecoder decodeObjectForKey:@"guideSize"];
        self.guideCatalog = [aDecoder decodeObjectForKey:@"guideCatalog"];
        self.guideCreate_time = [aDecoder decodeObjectForKey:@"guideCreate_time"];
        self.guideUpdate_time = [aDecoder decodeObjectForKey:@"guideUpdate_time"];
        self.guideDownloadTimes = [aDecoder decodeObjectForKey:@"guideDownloadTimes"];
        self.guideType = [aDecoder decodeObjectForKey:@"guideType"];
        self.guideAuthor_id = [aDecoder decodeObjectForKey:@"guideAuthor_id"];
        self.guideAuthor_name = [aDecoder decodeObjectForKey:@"guideAuthor_name"];
        self.guideAuthor_icon = [aDecoder decodeObjectForKey:@"guideAuthor_icon"];
        self.guideAuthor_intro = [aDecoder decodeObjectForKey:@"guideAuthor_intro"];
        self.guideData_iPhone = [aDecoder decodeObjectForKey:@"guideData_iPhone"];
        self.guideData_iPad = [aDecoder decodeObjectForKey:@"guideData_iPad"];
        self.guide_relatedGuide_ids = [aDecoder decodeObjectForKey:@"guide_relatedGuide_ids"];
        self.guideUpdate_log = [aDecoder decodeObjectForKey:@"guideUpdate_log"];
        
        
        
        
        
        
        
        //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        self.guideNameEn = [aDecoder decodeObjectForKey:@"guideNameEn"];
        self.guideNamePy = [aDecoder decodeObjectForKey:@"guideNamePy"];
        self.guideCategoryId = [aDecoder decodeObjectForKey:@"guideCategoryId"];
        self.guideCategoryTitle = [aDecoder decodeObjectForKey:@"guideCategoryTitle"];
        self.guideCountryId = [aDecoder decodeObjectForKey:@"guideCountryId"];
        self.guideCountryName = [aDecoder decodeObjectForKey:@"guideCountryName"];
        self.guideCountryNameEn = [aDecoder decodeObjectForKey:@"guideCountryNameEn"];
        self.guideCountryNamePy = [aDecoder decodeObjectForKey:@"guideCountryNamePy"];
        self.guideBigCoverImage = [aDecoder decodeObjectForKey:@"guideBigCoverImage"];
        self.guideBriefInfo = [aDecoder decodeObjectForKey:@"guideBriefInfo"];
        self.guidePageCount = [aDecoder decodeObjectForKey:@"guidePageCount"];
        self.guideCreateTime = [aDecoder decodeObjectForKey:@"guideCreateTime"];
        self.guideUpdateTime = [aDecoder decodeObjectForKey:@"guideUpdateTime"];
        self.guideDownloadCount = [aDecoder decodeObjectForKey:@"guideDownloadCount"];
        self.guideCoverUpdateTime = [aDecoder decodeObjectForKey:@"guideCoverUpdateTime"];
        self.authorId = [aDecoder decodeObjectForKey:@"authorId"];
        self.authorName = [aDecoder decodeObjectForKey:@"authorName"];
        self.authorIcon = [aDecoder decodeObjectForKey:@"authorIcon"];
        self.authorIntroduction = [aDecoder decodeObjectForKey:@"authorIntroduction"];
        self.otherGuideArray = [aDecoder decodeObjectForKey:@"otherGuideArray"];
        self.mobileFilePath = [aDecoder decodeObjectForKey:@"mobileFilePath"];
        self.mobileFileSize = [aDecoder decodeObjectForKey:@"mobileFileSize"];
        self.mobilePageCount = [aDecoder decodeObjectForKey:@"mobilePageCount"];
        self.mobileUpdateTime = [aDecoder decodeObjectForKey:@"mobileUpdateTime"];
        self.updateLog = [aDecoder decodeObjectForKey:@"updateLog"];
        //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
        
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.guideId forKey:@"guideId"];
    [aCoder encodeObject:self.guideName forKey:@"guideName"];
    [aCoder encodeObject:self.guideName_en forKey:@"guideName_en"];
    [aCoder encodeObject:self.guideName_pinyin forKey:@"guideName_pinyin"];
    [aCoder encodeObject:self.guideCategory_id forKey:@"guideCategory_id"];
    [aCoder encodeObject:self.guideCategory_name forKey:@"guideCategory_name"];
    [aCoder encodeObject:self.guideCountry_id forKey:@"guideCountry_id"];
    [aCoder encodeObject:self.guideCountry_name_cn forKey:@"guideCountry_name_cn"];
    [aCoder encodeObject:self.guideCountry_name_en forKey:@"guideCountry_name_en"];
    [aCoder encodeObject:self.guideCountry_name_py forKey:@"guideCountry_name_py"];
    [aCoder encodeObject:self.guideCoverImage forKey:@"guideCoverImage"];
    [aCoder encodeObject:self.guideCoverImage_big forKey:@"guideCoverImage_big"];
    [aCoder encodeObject:self.guideCover_updatetime forKey:@"guideCover_updatetime"];
    [aCoder encodeObject:self.guideBriefinfo forKey:@"guideBriefinfo"];
    [aCoder encodeObject:self.guideFilePath forKey:@"guideFilePath"];
    [aCoder encodeObject:self.guidePages forKey:@"guidePages"];
    [aCoder encodeObject:self.guideSize forKey:@"guideSize"];
    [aCoder encodeObject:self.guideCatalog forKey:@"guideCatalog"];
    [aCoder encodeObject:self.guideCreate_time forKey:@"guideCreate_time"];
    [aCoder encodeObject:self.guideUpdate_time forKey:@"guideUpdate_time"];
    [aCoder encodeObject:self.guideDownloadTimes forKey:@"guideDownloadTimes"];
    [aCoder encodeObject:self.guideType forKey:@"guideType"];
    [aCoder encodeObject:self.guideAuthor_id forKey:@"guideAuthor_id"];
    [aCoder encodeObject:self.guideAuthor_name forKey:@"guideAuthor_name"];
    [aCoder encodeObject:self.guideAuthor_icon forKey:@"guideAuthor_icon"];
    [aCoder encodeObject:self.guideAuthor_intro forKey:@"guideAuthor_intro"];
    [aCoder encodeObject:self.guideData_iPhone forKey:@"guideData_iPhone"];
    [aCoder encodeObject:self.guideData_iPad forKey:@"guideData_iPad"];
    [aCoder encodeObject:self.guide_relatedGuide_ids forKey:@"guide_relatedGuide_ids"];
    [aCoder encodeObject:self.guideUpdate_log forKey:@"guideUpdate_log"];
    
    
    
    
    
    
    
    //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    [aCoder encodeObject:self.guideNameEn forKey:@"guideNameEn"];
    [aCoder encodeObject:self.guideNamePy forKey:@"guideNamePy"];
    [aCoder encodeObject:self.guideCategoryId forKey:@"guideCategoryId"];
    [aCoder encodeObject:self.guideCategoryTitle forKey:@"guideCategoryTitle"];
    [aCoder encodeObject:self.guideCountryId forKey:@"guideCountryId"];
    [aCoder encodeObject:self.guideCountryName forKey:@"guideCountryName"];
    [aCoder encodeObject:self.guideCountryNameEn forKey:@"guideCountryNameEn"];
    [aCoder encodeObject:self.guideCountryNamePy forKey:@"guideCountryNamePy"];
    [aCoder encodeObject:self.guideBigCoverImage forKey:@"guideBigCoverImage"];
    [aCoder encodeObject:self.guideBriefInfo forKey:@"guideBriefInfo"];
    [aCoder encodeObject:self.guidePageCount forKey:@"guidePageCount"];
    [aCoder encodeObject:self.guideCreateTime forKey:@"guideCreateTime"];
    [aCoder encodeObject:self.guideUpdateTime forKey:@"guideUpdateTime"];
    [aCoder encodeObject:self.guideDownloadCount forKey:@"guideDownloadCount"];
    [aCoder encodeObject:self.guideCoverUpdateTime forKey:@"guideCoverUpdateTime"];
    [aCoder encodeObject:self.authorId forKey:@"authorId"];
    [aCoder encodeObject:self.authorName forKey:@"authorName"];
    [aCoder encodeObject:self.authorIcon forKey:@"authorIcon"];
    [aCoder encodeObject:self.authorIntroduction forKey:@"authorIntroduction"];
    [aCoder encodeObject:self.otherGuideArray forKey:@"otherGuideArray"];
    [aCoder encodeObject:self.mobileFilePath forKey:@"mobileFilePath"];
    [aCoder encodeObject:self.mobileFileSize forKey:@"mobileFileSize"];
    [aCoder encodeObject:self.mobilePageCount forKey:@"mobilePageCount"];
    [aCoder encodeObject:self.mobileUpdateTime forKey:@"mobileUpdateTime"];
    [aCoder encodeObject:self.updateLog forKey:@"updateLog"];
    //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    //******************************************************** fuck [ 为了兼容之前的版本,仅版本替换时使用 ]
    
}



- (id)copyWithZone:(NSZone *)zone
{
    QYGuide *guide = [[QYGuide alloc] init];
    
    guide.guideId = self.guideId;
    guide.guideName  = self.guideName;
    guide.guideName_en  = self.guideName_en;
    guide.guideName_pinyin  = self.guideName_pinyin;
    guide.guideCategory_id  = self.guideCategory_id;
    guide.guideCategory_name  = self.guideCategory_name;
    guide.guideCountry_id  = self.guideCountry_id;
    guide.guideCountry_name_cn  = self.guideCountry_name_cn;
    guide.guideCountry_name_en  = self.guideCountry_name_en;
    guide.guideCountry_name_py  = self.guideCountry_name_py;
    guide.guideCoverImage  = self.guideCoverImage;
    guide.guideCoverImage_big  = self.guideCoverImage_big;
    guide.guideCover_updatetime  = self.guideCover_updatetime;
    guide.guideBriefinfo  = self.guideBriefinfo;
    guide.guideFilePath  = self.guideFilePath;
    guide.guidePages  = self.guidePages;
    guide.guideSize  = self.guideSize;
    guide.guideCatalog  = self.guideCatalog;
    guide.guideCreate_time  = self.guideCreate_time;
    guide.guideUpdate_time  = self.guideUpdate_time;
    guide.guideDownloadTimes  = self.guideDownloadTimes;
    guide.guideType  = self.guideType;
    guide.guideAuthor_id  = self.guideAuthor_id;
    guide.guideAuthor_name  = self.guideAuthor_name;
    guide.guideAuthor_icon  = self.guideAuthor_icon;
    guide.guideAuthor_intro  = self.guideAuthor_intro;
    guide.guideData_iPhone  = self.guideData_iPhone;
    guide.guideData_iPad  = self.guideData_iPad;
    guide.guide_relatedGuide_ids  = self.guide_relatedGuide_ids;
    guide.guideUpdate_log  = self.guideUpdate_log;
    guide.guideNameEn  = self.guideNameEn;
    guide.guideNamePy  = self.guideNamePy;
    guide.guideCategoryId  = self.guideCategoryId;
    guide.guideCategoryTitle  = self.guideCategoryTitle;
    guide.guideCountryId  = self.guideCountryId;
    guide.guideCountryName  = self.guideCountryName;
    guide.guideCountryNameEn  = self.guideCountryNameEn;
    guide.guideCountryNamePy  = self.guideCountryNamePy;
    guide.guideBigCoverImage  = self.guideBigCoverImage;
    guide.guideBriefInfo  = self.guideBriefInfo;
    guide.guidePageCount  = self.guidePageCount;
    guide.guideCreateTime  = self.guideCreateTime;
    guide.guideUpdateTime  = self.guideUpdateTime;
    guide.guideDownloadCount  = self.guideDownloadCount;
    guide.guideCoverUpdateTime  = self.guideCoverUpdateTime;
    guide.authorId  = self.authorId;
    guide.authorName  = self.authorName;
    guide.authorIcon  = self.authorIcon;
    guide.authorIntroduction  = self.authorIntroduction;
    guide.otherGuideArray  = self.otherGuideArray;
    guide.mobileFilePath  = self.mobileFilePath;
    guide.mobileFileSize  = self.mobileFileSize;
    guide.mobilePageCount  = self.mobilePageCount;
    guide.mobileUpdateTime  = self.mobileUpdateTime;
    guide.updateLog  = self.updateLog;
    
    return guide;
}

@end

