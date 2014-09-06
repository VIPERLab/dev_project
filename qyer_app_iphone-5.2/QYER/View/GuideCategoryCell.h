//
//  GuideCategoryCell.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-24.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYGuideCategory;

@interface GuideCategoryCell : UITableViewCell
{
    UIImageView     *_imageView_backGround;
    
    UILabel         *_label_nameChinese;    //锦囊所属分类的中文名称
    UILabel         *_label_nameEnglish;    //锦囊所属分类的英文名称
    UILabel         *_label_guideNumber;    //锦囊所属分类中所有锦囊的个数
    
    UIView          *_backView;
    UIImageView     *_imageView_lastCell;
}
@property(nonatomic,retain) UILabel         *label_nameChinese;    //锦囊所属分类的中文名称
@property(nonatomic,retain) UILabel         *label_nameEnglish;    //锦囊所属分类的英文名称
@property(nonatomic,retain) UILabel         *label_guideNumber;    //锦囊所属分类中所有锦囊的个数

-(void)initWithCategoryArray:(NSArray *)array atPosition:(NSInteger)position;

@end
