//
//  ChangeTableviewContentInset.h
//  QyGuide
//
//  Created by 你猜你猜 on 13-12-30.
//
//

#import <Foundation/Foundation.h>

@interface ChangeTableviewContentInset : NSObject

+(void)changeWithTableView:(UITableView *)tableview;
+(void)changeTableView:(UITableView *)tableview withOffSet:(float)offset;

@end
