//
//  KTPhotoView+SDWebImage.h
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTPhotoView.h"
#import "SDWebImageManagerDelegate.h"


#if NS_BLOCKS_AVAILABLE
typedef void (^setImageFinishedBlock)(void);
typedef void (^setImageFailedBlock)(void);
#endif


@interface KTPhotoView (SDWebImage) <SDWebImageManagerDelegate>

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

//*** anqing
- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholder
               finished:(setImageFinishedBlock)finished
                 failed:(setImageFailedBlock)failed;

@end