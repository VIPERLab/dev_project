//
//  LineSpaceLabel.h
//  BookReader
//
//  Created by 张伊辉 on 14-1-22.
//  Copyright (c) 2014年 张伊辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineSpaceLabel : UILabel{
    CGFloat charSpace_;
    CGFloat lineSpace_;
}
@property(nonatomic, assign) CGFloat charSpace;
@property(nonatomic, assign) CGFloat lineSpace;

@end


