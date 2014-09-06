//
//  KTPhotoView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTPhotoView+SDWebImage.h"
#import "SDWebImageManager.h"



@implementation KTPhotoView (SDWebImage)

- (void)setImageWithURL:(NSURL *)url
{
   [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
   SDWebImageManager *manager = [SDWebImageManager sharedManager];
   
   // Remove in progress downloader from queue
   [manager cancelForDelegate:self];
   
   UIImage *cachedImage = nil;
   if (url) {
     cachedImage = [manager imageWithURL:url];
   }
   
   if (cachedImage) {
      [self setImage:cachedImage];
   }
   else {
      if (placeholder) {
         [self setImage:placeholder];
      }
      
      if (url) {
        [manager downloadWithURL:url delegate:self];
      }
   }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
   [self setImage:image];
}




#pragma mark -
#pragma mark --- anqing 修改(至此以下为新增的) ******************************
- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholder
               finished:(setImageFinishedBlock)finished
                 failed:(setImageFailedBlock)failed
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    UIImage *cachedImage = nil;
    if (url)
    {
        cachedImage = [manager imageWithURL:url];
    }
    
    if (cachedImage)
    {
        [self setImage:cachedImage];
        finished();
    }
    else
    {
        if (placeholder)
        {
            [self setImage:placeholder];
        }
        
        if (url)
        {
            //[manager downloadWithURL:url delegate:self];
            [manager downloadWithURL:url delegate:self options:nil success:^(UIImage *image){finished();} failure:^(NSError *error){failed();}];
        }
        else
        {
            failed();
        }
    }
}

@end