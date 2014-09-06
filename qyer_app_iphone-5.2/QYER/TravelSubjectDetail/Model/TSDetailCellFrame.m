//
//  TSDetailCellFrame.m
//  TravelSubject
//
//  Created by chenguanglin on 14-7-21.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import "TSDetailCellFrame.h"
#import "TSDetailCellModel.h"
#import "QYToolObject.h"
#define TSDetailTableBorder 10;


@implementation TSDetailCellFrame

- (void)setTSDetailModel:(TSDetailCellModel *)TSDetailModel
{
    _TSDetailModel = TSDetailModel;
    
    CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
    
    NSString *countryNameString = [NSString stringWithFormat:@"%@, ",TSDetailModel.countryName];
    UIFont *countryNameFont = [UIFont systemFontOfSize:12];
    CGSize countryNameSize = [countryNameString sizeWithFont:countryNameFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, 15) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat countryNameX = 8;
    CGFloat countryNameY = 119;
    CGFloat countryNameH = countryNameSize.height;
    CGFloat countryNameW = countryNameSize.width;
    _countryNameF = CGRectMake(countryNameX, countryNameY, countryNameW, countryNameH);
    
    CGFloat cityNameX = countryNameX + countryNameW;
    CGFloat cityNameY = countryNameY;
    CGFloat cityNameW = 260 - countryNameW;
    CGFloat cityNameH = countryNameH;
    _cityNameF = CGRectMake(cityNameX, cityNameY, cityNameW, cityNameH);
    
    UIFont *descriptionFont = [UIFont systemFontOfSize:15];
    CGSize descriptionSize = [QYToolObject getContentSize:TSDetailModel.description font:descriptionFont width:cellW - 20];
    CGFloat descriptionX = 10;
    CGFloat descriptionY = 174 + 12;
    CGFloat descriptionW = cellW - 20;
    CGFloat descriptionH = descriptionSize.height;
    _descriptionF = CGRectMake(descriptionX, descriptionY, descriptionW, descriptionH);
    
    _cellFootF = CGRectMake(0, descriptionY + descriptionH + 15, UIScreenWidth, 10);
    _cellHeight = descriptionY + descriptionH + 25;
}

@end
