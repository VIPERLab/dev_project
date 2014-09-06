//
//  MicroTravel.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>

@interface MicroTravel : NSObject <NSCoding>
{
    NSString        *_str_travelId;                 //游记id
    NSString        *_str_travelName;               //游记名称
    NSString        *_str_travelAlbumCover;         //游记头图
    NSString        *_str_browserCount;             //该游记的浏览次数
    NSString        *_str_commentCount;             //该游记的评论次数
    NSString        *_str_likeCount;                //该游记的喜欢次数
    NSString        *_str_travelBelongTo;           //创建该游记的用户
    NSString        *_str_travelUpdateTime;         //游记最后更新时间
    NSString        *_str_travelUrl_all;            //游记正文的url_所有内容
    NSString        *_str_travelUrl_onlyauthor;     //游记正文的url_仅楼主的内容
    
    NSString        *_str_avatarUrl;                //用户头像
    NSString        *_str_userId;                   //用户id
}

@property(nonatomic,retain) NSString        *str_travelId;                 //游记id
@property(nonatomic,retain) NSString        *str_travelName;               //游记名称
@property(nonatomic,retain) NSString        *str_travelAlbumCover;         //游记头图
@property(nonatomic,retain) NSString        *str_browserCount;             //该游记的浏览次数
@property(nonatomic,retain) NSString        *str_commentCount;             //该游记的评论次数
@property(nonatomic,retain) NSString        *str_likeCount;                //该游记的喜欢次数
@property(nonatomic,retain) NSString        *str_travelBelongTo;           //创建该游记的用户
@property(nonatomic,retain) NSString        *str_travelUpdateTime;         //游记最后更新时间
@property(nonatomic,retain) NSString        *str_travelUrl_all;            //游记正文的url_所有内容
@property(nonatomic,retain) NSString        *str_travelUrl_onlyauthor;     //游记正文的url_仅楼主的内容

@property(nonatomic,retain) NSString        *str_avatarUrl;                //用户头像
@property(nonatomic,retain) NSString        *str_userId;                   //用户id

@end
