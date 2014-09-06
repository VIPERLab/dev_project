//
//  GetPoiPhotoImages.h
//  QyGuide
//
//  Created by an qing on 13-2-19.
//
//

#import <Foundation/Foundation.h>
@class ASIHTTPRequest;


#if NS_BLOCKS_AVAILABLE
typedef void (^getPoiPhotoImagesFinishedBlock)(void);
typedef void (^getPoiPhotoImagesFailedBlock)(void);
#endif


@interface GetPoiPhotoImages : NSObject
{
    NSString *_position;
    
    NSString *_picUrl_small;
    NSString *_picUrl_big;
    NSString *_userName;
    NSString *_imageIdStr;
    NSString *_imageDate;
    
    NSMutableArray *_dataArray;
    NSMutableArray *_allDataArray;
    NSMutableArray *_allMaxIdArray;
    
    BOOL           _hasDone;
    BOOL           _hasAllDone;
    __block ASIHTTPRequest *_getPoiImagesRequest;
    __block ASIHTTPRequest *_getAllPoiImagesRequest;
}

@property(nonatomic,retain) NSString *position;
@property(nonatomic,retain) NSString *picUrl_small;
@property(nonatomic,retain) NSString *picUrl_big;
@property(nonatomic,retain) NSString *userName;
@property(nonatomic,retain) NSString *imageIdStr;
@property(nonatomic,retain) NSString *imageDate;
@property(nonatomic,retain) NSMutableArray *dataArray;
@property(nonatomic,retain) NSMutableArray *allDataArray;
@property(nonatomic,retain) NSMutableArray *allMaxIdArray;
@property(nonatomic,retain) ASIHTTPRequest *getPoiImagesRequest;
@property(nonatomic,retain) ASIHTTPRequest *getAllPoiImagesRequest;
@property(nonatomic,assign) BOOL hasDone;
@property(nonatomic,assign) BOOL hasAllDone;

-(void)getPoiPhotoImagesByClientid:(NSString *)client_id
                  andClientSecrect:(NSString *)client_secrect
                          andPoiId:(NSInteger)poiId
                         andMax_id:(NSInteger)max_id
                          finished:(getPoiPhotoImagesFinishedBlock)finished
                            failed:(getPoiPhotoImagesFailedBlock)failed;

-(void)getAllPoiPhotoImagesByClientid:(NSString *)client_id
                     andClientSecrect:(NSString *)client_secrect
                                 type:(NSString *)type
                             andPoiId:(NSInteger)poiId
                            pageSize:(NSInteger)pageSize
                                 page:(NSInteger)page
                             finished:(getPoiPhotoImagesFinishedBlock)finished
                               failed:(getPoiPhotoImagesFailedBlock)failed;


-(void)cancle;

@end
