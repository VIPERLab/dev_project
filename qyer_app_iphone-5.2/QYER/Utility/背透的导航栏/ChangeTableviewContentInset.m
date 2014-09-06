//
//  ChangeTableviewContentInset.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-12-30.
//
//

#import "ChangeTableviewContentInset.h"

#define height_statusBar    20
#define height_headView     44



@implementation ChangeTableviewContentInset

+(void)changeWithTableView:(UITableView *)tableview
{
    //*** ios7:
    if(ios7)
    {
        float height_top = height_headView + height_statusBar;
        tableview.contentInset = UIEdgeInsetsMake(height_top, 0, 0, 0);
        tableview.scrollIndicatorInsets = UIEdgeInsetsMake(height_top, 0, 0, 0);
        tableview.contentOffset = CGPointMake(0, -height_top);
    }
    
    else //*** ios6及以下系统版本:
    {
        float height_top = height_headView;
        tableview.contentInset = UIEdgeInsetsMake(height_top, 0, 0, 0);
        tableview.scrollIndicatorInsets = UIEdgeInsetsMake(height_top, 0, 0, 0);
        tableview.contentOffset = CGPointMake(0, -height_top);
    }
}

+(void)changeTableView:(UITableView *)tableview withOffSet:(float)offset
{
    //*** ios7:
    if(ios7)
    {
        float height_top = height_headView + height_statusBar + offset;
        tableview.contentInset = UIEdgeInsetsMake(height_top, 0, 0, 0);
        tableview.scrollIndicatorInsets = UIEdgeInsetsMake(height_top, 0, 0, 0);
        tableview.contentOffset = CGPointMake(0, -height_top);
    }
    
    else //*** ios6及以下系统版本:
    {
        float height_top = height_headView + offset;
        tableview.contentInset = UIEdgeInsetsMake(height_top, 0, 0, 0);
        tableview.scrollIndicatorInsets = UIEdgeInsetsMake(height_top, 0, 0, 0);
        tableview.contentOffset = CGPointMake(0, -height_top);
    }
}

@end

