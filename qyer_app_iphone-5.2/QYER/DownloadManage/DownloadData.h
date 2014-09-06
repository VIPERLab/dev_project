//
//  DownloadData.h
//  DownLoadZipFile_withPods
//
//  Created by an qing on 13-4-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"


@protocol DownloadDataDelegate;
@interface DownloadData : NSObject <ASIProgressDelegate>
{
    ASINetworkQueue             *_downloadQueue;     //下载队列
    NSMutableDictionary         *_requestListDic;    //下载请求的url列表
    
    NSMutableDictionary         *_dic_requesFailed;
    NSMutableDictionary         *_dic_requesFailedNumber; //记录'_dic_requesFailed'里request的请求次数
    BOOL                        _flag_netWrong;
    
    id<DownloadDataDelegate>    _delegate;
}
@property(nonatomic,retain) ASINetworkQueue             *downloadQueue;
@property(nonatomic,retain) NSMutableDictionary         *requestListDic;
@property(nonatomic,assign) id<DownloadDataDelegate>    delegate;

+(id)sharedDownloadData;
-(void)suspend:(NSDictionary *)userInfo;
-(void)addRequest:(ASIHTTPRequest *)request withDelegate:(id)delegate;
-(void)cancleAllRequest;

@end




#pragma mark -
#pragma mark --- DownloadData - Delegate
@protocol DownloadDataDelegate <NSObject>
-(void)downloadCancled:(id)info;
@end
