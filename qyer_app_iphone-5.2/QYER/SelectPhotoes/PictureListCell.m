//
//  PictureListCell.m
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PictureListCell.h"

@implementation PictureListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        
        for (int i = 0; i<4; i++) {
            
            QYImageView *imageView = [[QYImageView alloc]initWithFrame:CGRectMake(3+i*80, 5, 73, 73)];
            imageView.tag = i+10;
            imageView.userInteractionEnabled = YES;
            imageView.image = [UIImage imageNamed:@"Default"];
            [self addSubview:imageView];
            [imageView release];
            
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            imageView.layer.borderWidth = 1.0;
            imageView.layer.masksToBounds = YES;
            
            UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageAction:)];
            [imageView addGestureRecognizer:tapImage];
            [tapImage release];
            
        }
    }
    return self;
}

-(void)tapImageAction:(UITapGestureRecognizer *)tap{
    
    QYImageView *imageView = (QYImageView *)[tap view];

    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
   
    NSURL *url = [NSURL URLWithString:imageView.strURL];
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {

        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSString *fileName = [representation filename];
        
        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        [self.delegate customImagePickerController:nil image:image imageName:fileName];
        
    }failureBlock:^(NSError *error) {
        
        NSLog(@"error=%@",error);
    }];

    [assetLibrary release];

}

-(void)upDateUIWithDict:(NSMutableArray *)photoArray index:(int)row{
    
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];

    for (int i = 0; i<4; i++) {
        
        QYImageView *imageView = (QYImageView *)[self viewWithTag:10+i];
        
        
        if (row*4+i < photoArray.count) {
            
            NSString *strURL = [photoArray objectAtIndex:row*4 + i];
            imageView.strURL = strURL;
            
            NSURL *url = [NSURL URLWithString:strURL];
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
                
                UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
                imageView.image=image;
                imageView.hidden = NO;
                imageView.userInteractionEnabled = YES;
                
                
            }failureBlock:^(NSError *error) {
                
                
                NSLog(@"error=%@",error);
                
            }];
            
        }else{
            
            imageView.hidden = YES;
            imageView.userInteractionEnabled = NO;
        }
    }
    
    [assetLibrary release];
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
