//
//  ImageCropper.h
//  NewPackingList
//
//  Created by an qing on 12-9-25.
//
//

#import <UIKit/UIKit.h>
@protocol ImageCropperDelegate;


#pragma mark -
#pragma mark --- ImageCropper
@interface ImageCropper : UIViewController <UIScrollViewDelegate>
{
	UIScrollView *myScrollView;
	UIImageView *imageView;
    UINavigationBar *navigationBar;
    
    UIView *resultView;
    UILabel *alertLabel;
    
	id <ImageCropperDelegate> delegate;
}
@property (nonatomic, retain) UIScrollView *myScrollView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) id <ImageCropperDelegate> delegate;
-(id)initWithImage:(UIImage *)image;
-(void)saveImage;
@end




#pragma mark -
#pragma mark --- ImageCropperDelegate
@protocol ImageCropperDelegate <NSObject>
- (void)imageCropper:(ImageCropper *)cropper didFinishCroppingWithImage:(UIImage *)image;
- (void)imageCropperDidCancel:(ImageCropper *)cropper;
@end

