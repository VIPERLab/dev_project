//
//  ObserverObject.h
//  QYER
//
//  Created by 我去 on 14-4-21.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum
{
	Noamal_status = 0,          //初始状态
	Wating_status = 1,          //等待下载状态
    Downloading_status = 2,     //正在下载状态
    Read_status = 3,            //阅读状态
    DownloadFailed_status = 4   //下载失败的状态
} Observer_status;



@interface ObserverObject : NSObject
{
    NSString            *_name;                 //监听的对象的名称
    NSString            *_idString;             //监听的对象的id
    float               progress;               //监听的对象的下载进度
    NSMutableDictionary *_dic_progress;         //保存正在进行监听的对象的名称
    NSMutableDictionary *_dic_addObserver;
    NSMutableDictionary *_dic_addObserver_guidecell;     //已经进行监听的对象的名称
    NSMutableDictionary *_dic_addObserver_guidecover;    //已经进行监听的对象的名称
    NSMutableDictionary *_dic_addObserver_guideviewcell; //已经进行监听的对象的名称
    Observer_status     _status;                //监听的对象的状态
}

@property(nonatomic,retain) NSString            *name;
@property(nonatomic,retain) NSString            *idString;
@property(nonatomic,retain) NSMutableDictionary *dic_progress;
@property(nonatomic,retain) NSMutableDictionary *dic_addObserver;
@property(nonatomic,retain) NSMutableDictionary *dic_addObserver_guidecell;
@property(nonatomic,retain) NSMutableDictionary *dic_addObserver_guidecover;
@property(nonatomic,retain) NSMutableDictionary *dic_addObserver_guideviewcell;
@property(nonatomic,assign) Observer_status     status;
@property(nonatomic,assign) float               progress;

@end
