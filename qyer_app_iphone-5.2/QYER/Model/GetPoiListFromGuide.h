//
//  GetPoiListFromGuide.h
//  QyGuide
//
//  Created by an qing on 13-3-20.
//
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef int (^_getPoilistFinishedBlock)(void);
typedef int (^_getPoilistFailedBlock)(void);
#endif



@interface GetPoiListFromGuide : NSObject
{
    NSInteger       _poiId;
    NSInteger       _cateId;
    NSString        *_chineseName;
    NSString        *_englishName;
    NSString        *_categoryName;
    float           _lat;
    float           _lng;
    
    NSMutableArray *_poilistArray;
}

@property(nonatomic,assign) NSInteger poiId;
@property(nonatomic,assign) NSInteger cateId;
@property(nonatomic,retain) NSString  *chineseName;
@property(nonatomic,retain) NSString  *englishName;
@property(nonatomic,retain) NSString  *categoryName;
@property(nonatomic,assign) float     lat;
@property(nonatomic,assign) float     lng;
@property(nonatomic,retain) NSMutableArray *poilistArray;

+(id)sharedGetPoiListFromGuide;
-(int)getPoiListFromGuideByGuideName:(NSString *)guide_name
                            finished:(_getPoilistFinishedBlock)finished
                              failed:(_getPoilistFailedBlock)failed;

@end

